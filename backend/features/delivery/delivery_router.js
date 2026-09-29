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
import { API_ROUTES } from "../../config/constants.js";

const deliveryRouter = express.Router();

deliveryRouter.get(API_ROUTES.DELIVERIES, readDeliveries);
deliveryRouter.get(API_ROUTES.DELIVERY_BY_ID, readDeliveryById);
deliveryRouter.post(API_ROUTES.COMPLETE, checkIdempotency, validation(completeDeliverySchema), completeDelivery);
deliveryRouter.post(API_ROUTES.FAIL, checkIdempotency, validation(failDeliverySchema), failDelivery);
deliveryRouter.post(API_ROUTES.PROOF, upload.single("photo"), uploadProof);

export default deliveryRouter;
