import { actionResponse } from "./delivery_action_response.js";
import { pool, ensureDatabase } from "../../config/postgres.js";
import { DELIVERY_STATUS } from "../../config/constants.js";

export async function getAllDeliveries() {
  await ensureDatabase();
  const { rows } = await pool.query("SELECT data FROM deliveries ORDER BY id");
  return rows.map((row) => row.data);
}

export async function getDeliveryById(id) {
  if (!Number.isInteger(Number(id))) return null;
  await ensureDatabase();
  const { rows } = await pool.query("SELECT data FROM deliveries WHERE id=$1", [id]);
  return rows[0]?.data ?? null;
}

export async function getHandledAction(actionId) {
  await ensureDatabase();
  const { rows } = await pool.query(
    "SELECT response, delivery_id FROM handled_actions WHERE action_id=$1", [actionId]
  );
  return rows[0] ? { response: rows[0].response, deliveryId: rows[0].delivery_id } : null;
}

export async function attachProofUrl(id, proofUrl) {
  await ensureDatabase();
  const { rows } = await pool.query(
    `UPDATE deliveries SET data=jsonb_set(data, '{proof_url}', to_jsonb($2::text))
     WHERE id=$1 RETURNING data`, [id, proofUrl]
  );
  return rows[0]?.data ?? null;
}

export const markAsDelivered = (id, payload) => finalize(id, payload, DELIVERY_STATUS.DELIVERED);
export const markAsFailed = (id, payload) => finalize(id, payload, DELIVERY_STATUS.FAILED);

async function finalize(id, payload, status) {
  await ensureDatabase();
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    // Serialize the same action ID even when concurrent requests target different deliveries.
    await client.query("SELECT pg_advisory_xact_lock(hashtextextended($1, 0))", [payload.client_action_id]);
    const handled = await client.query(
      "SELECT delivery_id, response FROM handled_actions WHERE action_id=$1", [payload.client_action_id]
    );
    let outcome;
    if (handled.rows[0]) {
      outcome = handled.rows[0].delivery_id === Number(id)
        ? { replay: true, response: handled.rows[0].response }
        : { keyReuse: true };
    } else {
      outcome = await updateDelivery(client, id, payload, status);
    }
    await client.query("COMMIT");
    return outcome;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

async function updateDelivery(client, id, payload, status) {
  const { rows } = await client.query("SELECT data FROM deliveries WHERE id=$1 FOR UPDATE", [id]);
  const delivery = rows[0]?.data;
  if (!delivery) return null;
  if (delivery.status !== DELIVERY_STATUS.PENDING ||
      (payload.base_version !== undefined && payload.base_version !== delivery.version)) {
    return { conflict: true };
  }
  delivery.status = status;
  delivery.version += 1;
  delivery.client_action_id = payload.client_action_id;
  if (payload.note) delivery.note = payload.note;
  if (status === DELIVERY_STATUS.DELIVERED) {
    delivery.recipient_name = payload.recipient_name;
    delivery.completed_at = new Date().toISOString();
  } else {
    delivery.failure_reason = payload.reason;
    delivery.failed_at = new Date().toISOString();
  }
  const response = actionResponse(delivery);
  await client.query("UPDATE deliveries SET data=$2 WHERE id=$1", [id, JSON.stringify(delivery)]);
  await client.query(
    "INSERT INTO handled_actions(action_id, delivery_id, response) VALUES($1, $2, $3)",
    [payload.client_action_id, id, JSON.stringify(response)]
  );
  return delivery;
}
