import {
  getAllDeliveries,
  getDeliveryById,
  markAsDelivered,
  markAsFailed,
  attachProofUrl,
  saveHandledAction
} from "./delivery_model.js";

export const readDeliveries = async (req, res) => {
  const deliveries = await getAllDeliveries();
  return res.status(200).json(deliveries);
};

export const readDeliveryById = async (req, res) => {
  const delivery = await getDeliveryById(req.params.id);
  if (!delivery) {
    return res.status(404).json({ message: "Delivery not found" });
  }
  return res.status(200).json(delivery);
};

export const completeDelivery = async (req, res) => {
  const { id } = req.params;
  const { recipient_name, note, client_action_id } = req.body;

  const delivery = await getDeliveryById(id);
  if (!delivery) {
    return res.status(404).json({ message: "Delivery not found" });
  }

  const updated = await markAsDelivered(id, { recipient_name, note, client_action_id });

  const result = {
    message: "Delivery completed successfully",
    delivery: updated
  };

  if (client_action_id) {
    saveHandledAction(client_action_id, result);
  }

  return res.status(200).json(result);
};

export const failDelivery = async (req, res) => {
  const { id } = req.params;
  const { reason, note, client_action_id } = req.body;

  const delivery = await getDeliveryById(id);
  if (!delivery) {
    return res.status(404).json({ message: "Delivery not found" });
  }

  const updated = await markAsFailed(id, { reason, note, client_action_id });

  const result = {
    message: "Delivery marked as failed",
    delivery: updated
  };

  if (client_action_id) {
    saveHandledAction(client_action_id, result);
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
    return res.status(404).json({ message: "Delivery not found" });
  }

  const proofUrl = `/uploads/${req.file.filename}`;
  const updated = await attachProofUrl(id, proofUrl);

  return res.status(200).json({
    message: "Proof uploaded successfully",
    proof_url: proofUrl,
    delivery: updated
  });
};
