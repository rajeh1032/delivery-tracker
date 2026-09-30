import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { execFileSync } from "node:child_process";
import { before, after, test } from "node:test";
import express from "express";
import deliveryRouter from "../features/delivery/delivery_router.js";
import { pool, ensureDatabase } from "../config/postgres.js";
import { deliveriesDB } from "../config/database.js";

let server, baseUrl;
const firstId = 900000000 + Math.floor(Math.random() * 100000000);
const ids = [firstId, firstId + 1, firstId + 2];
const actionId = randomUUID();

before(async () => {
  assert.ok(process.env.DATABASE_URL, "DATABASE_URL must target an integration database");
  await ensureDatabase();
  for (const id of ids) {
    const delivery = { ...deliveriesDB[0], id, order_number: `TEST-${id}`, customer_name: "Persistence Test" };
    await pool.query("INSERT INTO deliveries(id, data) VALUES($1, $2)", [id, JSON.stringify(delivery)]);
  }
  const app = express();
  app.use(express.json());
  app.use(deliveryRouter);
  server = app.listen(0, "127.0.0.1");
  await new Promise((resolve) => server.once("listening", resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  await pool.query("DELETE FROM handled_actions WHERE delivery_id=ANY($1::int[])", [ids]);
  await pool.query("DELETE FROM deliveries WHERE id=ANY($1::int[])", [ids]);
  await pool.end();
});

const complete = (id, clientActionId, baseVersion = 1) => fetch(`${baseUrl}/deliveries/${id}/complete`, {
  method: "POST", headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ recipient_name: "Persistence Test", client_action_id: clientActionId, base_version: baseVersion })
});

test("concurrent same-ID retries produce one version increment and identical responses", async () => {
  const responses = await Promise.all(Array.from({ length: 5 }, () => complete(firstId, actionId)));
  assert.ok(responses.every((response) => response.status === 200));
  const bodies = await Promise.all(responses.map((response) => response.json()));
  assert.ok(bodies.every((body) => body.delivery.version === 2));
  for (const body of bodies) assert.deepEqual(body, bodies[0]);
});

test("a new process observes the finalized delivery and stored replay response", () => {
  const script = `import { getDeliveryById, getHandledAction } from './features/delivery/delivery_postgres_store.js';
    import { pool } from './config/postgres.js';
    const delivery = await getDeliveryById(${firstId});
    const replay = await getHandledAction('${actionId}');
    console.log(JSON.stringify({ delivery, replay })); await pool.end();`;
  const output = execFileSync(process.execPath, ["--input-type=module", "-e", script], {
    cwd: process.cwd(), env: process.env, encoding: "utf8"
  });
  const { delivery, replay } = JSON.parse(output);
  assert.equal(delivery.status, "delivered");
  assert.equal(delivery.version, 2);
  assert.equal(replay.deliveryId, firstId);
  assert.deepEqual(replay.response.delivery, delivery);
});

test("same action ID cannot finalize another delivery", async () => {
  const response = await complete(firstId + 1, actionId);
  assert.equal(response.status, 409);
  assert.equal((await response.json()).code, "IDEMPOTENCY_KEY_REUSE");
  const { rows } = await pool.query("SELECT data FROM deliveries WHERE id=$1", [firstId + 1]);
  assert.equal(rows[0].data.status, "pending");
});

test("concurrent different actions cannot both finalize a delivery", async () => {
  const responses = await Promise.all([complete(firstId + 2, randomUUID()), complete(firstId + 2, randomUUID())]);
  assert.deepEqual(responses.map((response) => response.status).sort(), [200, 409]);
});

test("invalid action IDs return validation errors rather than database errors", async () => {
  const response = await complete(firstId + 1, "not-a-uuid");
  assert.equal(response.status, 400);
});
