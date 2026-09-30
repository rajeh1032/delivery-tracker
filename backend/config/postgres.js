import pg from "pg";
import { deliveriesDB } from "./database.js";

export const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 3,
  connectionTimeoutMillis: 10000,
  idleTimeoutMillis: 10000
});
pool.on("error", (error) => console.error("PostgreSQL idle connection error:", error.message));

let initialization;
export function ensureDatabase() {
  initialization ??= initialize().catch((error) => {
    initialization = undefined;
    throw error;
  });
  return initialization;
}

async function initialize() {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT pg_advisory_xact_lock(73001001)");
    await client.query(`CREATE TABLE IF NOT EXISTS deliveries (
      id INTEGER PRIMARY KEY, data JSONB NOT NULL
    )`);
    await client.query(`CREATE TABLE IF NOT EXISTS handled_actions (
      action_id UUID PRIMARY KEY,
      delivery_id INTEGER NOT NULL REFERENCES deliveries(id),
      response JSONB NOT NULL
    )`);
    for (const delivery of deliveriesDB) {
      await client.query(
        "INSERT INTO deliveries(id, data) VALUES($1, $2) ON CONFLICT DO NOTHING",
        [delivery.id, JSON.stringify(delivery)]
      );
    }
    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}
