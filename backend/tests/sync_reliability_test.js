import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, before, test } from 'node:test';
import express from 'express';
import deliveryRouter from '../features/delivery/delivery_router.js';
import { deliveriesDB, idempotencyStore } from '../config/database.js';
import { getDeliveryById, attachProofUrl } from '../features/delivery/delivery_model.js';

let server;
let baseUrl;
let originalDeliveries;
let originalActions;
const replayActionId = randomUUID();
const testDeliveries = [91001, 91002, 91003, 91004, 91005, 91006].map((id) => ({
  id,
  order_number: `ORD-${id}`,
  customer_name: 'Sync Test',
  phone: '55500000',
  address: 'Test address',
  amount_due: 10,
  payment_method: 'cash',
  status: 'pending',
  version: 1,
  recipient_name: null,
  failure_reason: null,
  note: null,
  proof_url: null,
  completed_at: null,
  failed_at: null,
}));

before(async () => {
  originalDeliveries = structuredClone(deliveriesDB);
  originalActions = new Map(idempotencyStore);
  deliveriesDB.push(...structuredClone(testDeliveries));
  const app = express();
  app.use(express.json());
  app.use(deliveryRouter);
  server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
  deliveriesDB.splice(0, deliveriesDB.length, ...originalDeliveries);
  idempotencyStore.clear();
  for (const [id, action] of originalActions) idempotencyStore.set(id, action);
});

const post = (path, body) => fetch(`${baseUrl}${path}`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body),
});

test('stale base_version rejects complete without changing any delivery field', async () => {
  const before = structuredClone(await getDeliveryById(91001));
  const response = await post('/deliveries/91001/complete', {
    recipient_name: 'Review Test', client_action_id: randomUUID(),
    base_version: before.version + 1,
  });
  const data = await response.json();
  assert.equal(response.status, 409);
  assert.equal(data.code, 'DELIVERY_CONFLICT');
  assert.match(data.message, /version/i);
  assert.deepEqual(data.current_delivery, before);
  assert.deepEqual(await getDeliveryById(91001), before);
});

test('stale base_version rejects fail without changing any delivery field', async () => {
  const before = structuredClone(await getDeliveryById(91002));
  const response = await post('/deliveries/91002/fail', {
    reason: 'wrong_address', client_action_id: randomUUID(),
    base_version: before.version + 1,
  });
  const data = await response.json();
  assert.equal(response.status, 409);
  assert.equal(data.code, 'DELIVERY_CONFLICT');
  assert.match(data.message, /version/i);
  assert.deepEqual(data.current_delivery, before);
  assert.deepEqual(await getDeliveryById(91002), before);
});

test('matching base_version is accepted for both actions', async () => {
  const complete = await post('/deliveries/91003/complete', {
    recipient_name: 'Review Test', client_action_id: replayActionId,
    base_version: 1,
  });
  assert.equal(complete.status, 200);
  assert.equal((await complete.json()).delivery.version, 2);
  const fail = await post('/deliveries/91005/fail', {
    reason: 'wrong_address', client_action_id: randomUUID(), base_version: 1,
  });
  assert.equal(fail.status, 200);
  assert.equal((await fail.json()).delivery.version, 2);
});

test('omitted base_version remains supported for both actions', async () => {
  const complete = await post('/deliveries/91006/complete', {
    recipient_name: 'Review Test', client_action_id: randomUUID(),
  });
  assert.equal(complete.status, 200);
  assert.equal((await complete.json()).delivery.version, 2);
  const fail = await post('/deliveries/91004/fail', {
    reason: 'wrong_address', client_action_id: randomUUID(),
  });
  assert.equal(fail.status, 200);
  assert.equal((await fail.json()).delivery.version, 2);
});

test('idempotent replay precedes version checking', async () => {
  const replay = await post('/deliveries/91003/complete', {
    recipient_name: 'Changed request', client_action_id: replayActionId,
    base_version: 1,
  });
  assert.equal(replay.status, 200);
  assert.equal(replay.headers.get('x-idempotent-replay'), 'true');
  assert.equal((await replay.json()).delivery.version, 2);
  assert.equal((await getDeliveryById(91003)).recipient_name, 'Review Test');
});


test('idempotent response remains a snapshot after attaching proof', async () => {
  const before = await post('/deliveries/91003/complete', {
    recipient_name: 'Review Test', client_action_id: replayActionId, base_version: 1,
  });
  const snapshot = await before.json();
  await attachProofUrl(91003, '/uploads/snapshot-test.jpg');
  const replay = await post('/deliveries/91003/complete', {
    recipient_name: 'Review Test', client_action_id: replayActionId, base_version: 1,
  });
  assert.deepEqual(await replay.json(), snapshot);
  assert.equal((await getDeliveryById(91003)).proof_url, '/uploads/snapshot-test.jpg');
});
