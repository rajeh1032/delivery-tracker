import path from "path";
import { put } from "@vercel/blob";

export async function saveProof(deliveryId, file) {
  if (!process.env.BLOB_STORE_ID && !process.env.BLOB_READ_WRITE_TOKEN) {
    if (process.env.VERCEL) throw new Error("A connected Blob store is required on Vercel");
    return `/uploads/${file.filename}`;
  }
  const extension = path.extname(file.originalname) || ".jpg";
  const blob = await put(`proofs/${deliveryId}/photo${extension}`, file.buffer, {
    access: "public", addRandomSuffix: true, contentType: file.mimetype
  });
  return blob.url;
}
