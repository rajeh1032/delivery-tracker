import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import path from "path";
import multer from "multer";
import { fileURLToPath } from "url";
import deliveryRouter from "./features/delivery/delivery_router.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

let app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.get("/", (req, res) => {
  res.json({ status: "online" });
});

app.use(deliveryRouter);

// Centralized JSON Error Handler
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).json({
      code: "UPLOAD_ERROR",
      message: err.message
    });
  }
  console.error("Unhandled Error:", err);
  res.status(500).json({
    code: "INTERNAL_SERVER_ERROR",
    message: "An internal server error occurred"
  });
});

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";

if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, HOST, () => {
    console.log(`server is running on ${HOST}:${PORT}`);
  });
}

export default app;
