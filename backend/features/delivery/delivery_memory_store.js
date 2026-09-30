import { actionResponse } from "./delivery_action_response.js";
import { deliveriesDB, idempotencyStore } from "../../config/database.js";
import { DELIVERY_STATUS } from "../../config/constants.js";

export const getAllDeliveries = async () => {
  return deliveriesDB;
};

export const getDeliveryById = async (id) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  return delivery || null;
};

export const markAsDelivered = async (id, { recipient_name, note, client_action_id, base_version }) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  if (delivery.status !== DELIVERY_STATUS.PENDING ||
      (base_version !== undefined && base_version !== delivery.version)) {
    return { conflict: true };
  }

  delivery.status = DELIVERY_STATUS.DELIVERED;
  delivery.recipient_name = recipient_name;
  if (note) delivery.note = note;
  delivery.version = (delivery.version || 1) + 1;
  delivery.completed_at = new Date().toISOString();
  delivery.client_action_id = client_action_id;
  saveHandledAction(client_action_id, actionResponse(delivery), id);

  return delivery;
};

export const markAsFailed = async (id, { reason, note, client_action_id, base_version }) => {
  const delivery = deliveriesDB.find((d) => d.id === Number(id));
  if (!delivery) return null;

  if (delivery.status !== DELIVERY_STATUS.PENDING ||
      (base_version !== undefined && base_version !== delivery.version)) {
    return { conflict: true };
  }

  delivery.status = DELIVERY_STATUS.FAILED;
  delivery.failure_reason = reason;
  if (note) delivery.note = note;
  delivery.version = (delivery.version || 1) + 1;
  delivery.failed_at = new Date().toISOString();
  delivery.client_action_id = client_action_id;
  saveHandledAction(client_action_id, actionResponse(delivery), id);

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

const saveHandledAction = (actionId, result, deliveryId) => {
  idempotencyStore.set(actionId, {
    response: structuredClone(result),
    deliveryId: Number(deliveryId)
  });
};
