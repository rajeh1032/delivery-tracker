import express from "express";
import {
  readDeliveries,
  readDeliveryById,
  completeDelivery,
  failDelivery,
  uploadProof
} from "./delivery_controller.js";
import { validation, checkIdempotency, upload } from "./delivery_middleware.js";
import { completeDeliverySchema, failDeliverySchema } from "./delivery_validation.js";

const deliveryRouter = express.Router();

deliveryRouter.get("/deliveries", readDeliveries);
deliveryRouter.get("/deliveries/:id", readDeliveryById);
deliveryRouter.post("/deliveries/:id/complete", checkIdempotency, validation(completeDeliverySchema), completeDelivery);
deliveryRouter.post("/deliveries/:id/fail", checkIdempotency, validation(failDeliverySchema), failDelivery);
deliveryRouter.post("/deliveries/:id/proof", upload.single("photo"), uploadProof);

export default deliveryRouter;
