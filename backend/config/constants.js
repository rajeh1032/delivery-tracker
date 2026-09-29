export const DELIVERY_STATUS = {
  PENDING: "pending",
  DELIVERED: "delivered",
  FAILED: "failed"
};

export const API_ROUTES = {
  DELIVERIES: "/deliveries",
  DELIVERY_BY_ID: "/deliveries/:id",
  COMPLETE: "/deliveries/:id/complete",
  FAIL: "/deliveries/:id/fail",
  PROOF: "/deliveries/:id/proof"
};

export const ERROR_CODES = {
  DELIVERY_NOT_FOUND: "DELIVERY_NOT_FOUND",
  VALIDATION_ERROR: "VALIDATION_ERROR",
  IDEMPOTENCY_KEY_REUSE: "IDEMPOTENCY_KEY_REUSE",
  DELIVERY_CONFLICT: "DELIVERY_CONFLICT"
};
