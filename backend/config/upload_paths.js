import path from "path";
import os from "os";
import { fileURLToPath } from "url";

const backendDir = fileURLToPath(new URL("../", import.meta.url));

// Vercel's application bundle is read-only; only temporary storage is writable.
export const uploadsDir = process.env.VERCEL
  ? path.join(os.tmpdir(), "alshamel-uploads")
  : path.join(backendDir, "uploads");
