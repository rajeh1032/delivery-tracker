import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { del } from "@vercel/blob";
import { pool, ensureDatabase } from "../config/postgres.js";
import { deliveriesDB } from "../config/database.js";

const baseUrl = process.env.API_BASE_URL;
assert.ok(baseUrl, "API_BASE_URL must target the deployment to verify");
const firstId = 1000000000 + Math.floor(Math.random() * 100000000);
const ids = [firstId, firstId + 1];
let proofUrl;
const post = (id, clientActionId, baseVersion = 1) => fetch(`${baseUrl}/deliveries/${id}/complete`, {
  method: "POST", headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ recipient_name: "Deployment Test", client_action_id: clientActionId, base_version: baseVersion })
});

try {
  const health = await fetch(`${baseUrl}/`);
  assert.equal(health.status, 200);
  assert.equal((await health.json()).status, "online");
  const list = await fetch(`${baseUrl}/deliveries`);
  assert.equal(list.status, 200);
  const orders = await list.json();
  assert.ok(orders.length >= 40);
  assert.ok(orders.some((order) => order.id === 1040));
  await ensureDatabase();
  for (const id of ids) {
    const delivery = { ...deliveriesDB[0], id, order_number: `TEST-${id}`, customer_name: "Deployment Test" };
    await pool.query("INSERT INTO deliveries(id, data) VALUES($1, $2)", [id, JSON.stringify(delivery)]);
  }
  const actionId = randomUUID();
  const responses = await Promise.all(Array.from({ length: 5 }, () => post(firstId, actionId)));
  assert.ok(responses.every((response) => response.status === 200));
  const bodies = await Promise.all(responses.map((response) => response.json()));
  for (const body of bodies) {
    assert.equal(body.delivery.version, 2);
    assert.deepEqual(body, bodies[0]);
  }
  assert.ok(responses.some((response) => response.headers.get("x-idempotent-replay") === "true"));
  const reused = await post(firstId + 1, actionId);
  assert.equal(reused.status, 409);
  assert.equal((await reused.json()).code, "IDEMPOTENCY_KEY_REUSE");
  const stale = await post(firstId + 1, randomUUID(), 99);
  assert.equal(stale.status, 409);
  const form = new FormData();
  const bytes = Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jK1cAAAAASUVORK5CYII=", "base64");
  form.append("photo", new Blob([bytes], { type: "image/png" }), "verification.png");
  const upload = await fetch(`${baseUrl}/deliveries/${firstId}/proof`, { method: "POST", body: form });
  assert.equal(upload.status, 200);
  const proof = await upload.json();
  proofUrl = proof.proof_url;
  assert.ok(new URL(proofUrl).hostname.endsWith(".public.blob.vercel-storage.com"));
  const photo = await fetch(proofUrl);
  assert.equal(photo.status, 200);
  assert.ok(Buffer.from(await photo.arrayBuffer()).equals(bytes));
  const stored = await (await fetch(`${baseUrl}/deliveries/${firstId}`)).json();
  assert.equal(stored.status, "delivered");
  assert.equal(stored.proof_url, proofUrl);
  assert.deepEqual(await (await post(firstId, actionId)).json(), bodies[0]);
  console.log("Live API passed: 40 orders, concurrent retries, persisted state, conflicts, Blob upload and retrieval.");
} finally {
  try {
    if (proofUrl) await del(proofUrl);
  } finally {
    await pool.query("DELETE FROM handled_actions WHERE delivery_id=ANY($1::int[])", [ids]);
    await pool.query("DELETE FROM deliveries WHERE id=ANY($1::int[])", [ids]);
    await pool.end();
  }
}
