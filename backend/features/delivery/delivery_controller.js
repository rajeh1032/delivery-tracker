import {
  getAllDeliveries,
  getDeliveryById,
  markAsDelivered,
  markAsFailed,
  attachProofUrl,
  saveHandledAction
} from "./delivery_model.js";
import { ERROR_CODES, ERROR_MESSAGES } from "../../config/constants.js";

export const readDeliveries = async (req, res) => {
  const deliveries = await getAllDeliveries();
  return res.status(200).json(deliveries);
};

export const readDeliveryById = async (req, res) => {
  const delivery = await getDeliveryById(req.params.id);
  if (!delivery) {
    return res.status(404).json({
      code: ERROR_CODES.DELIVERY_NOT_FOUND,
      message: "Delivery not found"
    });
  }
  return res.status(200).json(delivery);
};

export const completeDelivery = async (req, res) => {
  const { id } = req.params;
  const { recipient_name, note, client_action_id, base_version } = req.body;

  const delivery = await getDeliveryById(id);
  if (!delivery) {
    return res.status(404).json({
      code: ERROR_CODES.DELIVERY_NOT_FOUND,
      message: "Delivery not found"
    });
  }

  const updated = await markAsDelivered(id, { recipient_name, note, client_action_id, base_version });
  if (updated.conflict) {
    return res.status(409).json({
      code: ERROR_CODES.DELIVERY_CONFLICT,
      message: ERROR_MESSAGES.DELIVERY_CONFLICT,
      current_delivery: await getDeliveryById(id)
    });
  }

  const result = {
    message: "Delivery completed successfully",
    delivery: updated
  };

  if (client_action_id) {
    saveHandledAction(client_action_id, result, id);
  }

  return res.status(200).json(result);
};

export const failDelivery = async (req, res) => {
  const { id } = req.params;
  const { reason, note, client_action_id, base_version } = req.body;

  const delivery = await getDeliveryById(id);
  if (!delivery) {
    return res.status(404).json({
      code: ERROR_CODES.DELIVERY_NOT_FOUND,
      message: "Delivery not found"
    });
  }

  const updated = await markAsFailed(id, { reason, note, client_action_id, base_version });
  if (updated.conflict) {
    return res.status(409).json({
      code: ERROR_CODES.DELIVERY_CONFLICT,
      message: ERROR_MESSAGES.DELIVERY_CONFLICT,
      current_delivery: await getDeliveryById(id)
    });
  }

  const result = {
    message: "Delivery marked as failed",
    delivery: updated
  };

  if (client_action_id) {
    saveHandledAction(client_action_id, result, id);
  }

  return res.status(200).json(result);
};

export const uploadProof = async (req, res) => {
  const { id } = req.params;

  if (!req.file) {
    return res.status(400).json({ message: "photo is required" });
  }

  const delivery = await getDeliveryById(id);
  if (!delivery) {
    return res.status(404).json({
      code: ERROR_CODES.DELIVERY_NOT_FOUND,
      message: "Delivery not found"
    });
  }

  const proofUrl = `/uploads/${req.file.filename}`;
  const updated = await attachProofUrl(id, proofUrl);

  return res.status(200).json({
    message: "Proof uploaded successfully",
    proof_url: proofUrl,
    delivery: updated
  });
};
