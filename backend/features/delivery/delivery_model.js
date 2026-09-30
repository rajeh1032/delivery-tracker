import "dotenv/config";

if (process.env.VERCEL && !process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is required on Vercel to persist delivery state");
}
const store = process.env.DATABASE_URL
  ? await import("./delivery_postgres_store.js")
  : await import("./delivery_memory_store.js");

export const getAllDeliveries = store.getAllDeliveries;
export const getDeliveryById = store.getDeliveryById;
export const markAsDelivered = store.markAsDelivered;
export const markAsFailed = store.markAsFailed;
export const attachProofUrl = store.attachProofUrl;
export const getHandledAction = store.getHandledAction;
