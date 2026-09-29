import { deliveriesDB, idempotencyStore } from "../../config/database.js";

export const getAllDeliveries = async () => {
  return deliveriesDB;
};

export const getDeliveryById = async (id) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  return delivery || null;
};

export const markAsDelivered = async (id, { recipient_name, note, client_action_id }) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  delivery.status = "delivered";
  delivery.recipient_name = recipient_name;
  if (note) delivery.note = note;
  delivery.completed_at = new Date().toISOString();
  delivery.client_action_id = client_action_id;

  return delivery;
};

export const markAsFailed = async (id, { reason, note, client_action_id }) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  delivery.status = "failed";
  delivery.failure_reason = reason;
  if (note) delivery.note = note;
  delivery.failed_at = new Date().toISOString();
  delivery.client_action_id = client_action_id;

  return delivery;
};

export const attachProofUrl = async (id, proofUrl) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  delivery.proof_url = proofUrl;
  return delivery;
};

export const getHandledAction = (actionId) => {
  return idempotencyStore.get(actionId) || null;
};

export const saveHandledAction = (actionId, result) => {
  idempotencyStore.set(actionId, result);
};
