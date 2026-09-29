import { deliveriesDB, idempotencyStore } from "../../config/database.js";

export const getAllDeliveries = async () => {
  return structuredClone(deliveriesDB);
};

export const getDeliveryById = async (id) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  return delivery ? structuredClone(delivery) : null;
};

export const markAsDelivered = async (id, { recipient_name, note, client_action_id, base_version }) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  // Optimistic concurrency & state machine check
  if (delivery.status !== "pending") {
    return { conflict: true, current: structuredClone(delivery) };
  }
  if (base_version !== undefined && base_version !== delivery.version) {
    return { conflict: true, current: structuredClone(delivery) };
  }

  delivery.status = "delivered";
  delivery.recipient_name = recipient_name;
  delivery.note = note || null;
  delivery.completed_at = new Date().toISOString();
  delivery.client_action_id = client_action_id;
  delivery.version = (delivery.version || 1) + 1;
  delivery.updated_at = new Date().toISOString();

  return structuredClone(delivery);
};

export const markAsFailed = async (id, { reason, note, client_action_id, base_version }) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  // Optimistic concurrency & state machine check
  if (delivery.status !== "pending") {
    return { conflict: true, current: structuredClone(delivery) };
  }
  if (base_version !== undefined && base_version !== delivery.version) {
    return { conflict: true, current: structuredClone(delivery) };
  }

  delivery.status = "failed";
  delivery.failure_reason = reason;
  delivery.note = note || null;
  delivery.failed_at = new Date().toISOString();
  delivery.client_action_id = client_action_id;
  delivery.version = (delivery.version || 1) + 1;
  delivery.updated_at = new Date().toISOString();

  return structuredClone(delivery);
};

export const attachProofUrl = async (id, proofUrl) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  delivery.proof_url = proofUrl;
  delivery.version = (delivery.version || 1) + 1;
  delivery.updated_at = new Date().toISOString();

  return structuredClone(delivery);
};

export const getHandledAction = (key) => {
  return idempotencyStore.get(key) || null;
};

export const saveHandledAction = (key, record) => {
  idempotencyStore.set(key, record);
};
