import { DELIVERY_STATUS } from "../../config/constants.js";

export const actionResponse = (delivery) => ({
  message: delivery.status === DELIVERY_STATUS.DELIVERED
    ? "Delivery completed successfully" : "Delivery marked as failed",
  delivery
});
