import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import multer from "multer";
import { uploadsDir } from "./config/upload_paths.js";
import deliveryRouter from "./features/delivery/delivery_router.js";

let app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" }));
app.get("/uploads/:filename", (req, res, next) => {
  res.sendFile(req.params.filename, { root: uploadsDir, dotfiles: "deny" }, (err) => {
    if (!err) return;
    if (err.status === 404) return res.status(404).json({ message: "Photo not found" });
    next(err);
  });
});

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

if (process.env.NODE_ENV !== "test" && !process.env.VERCEL) {
  app.listen(PORT, HOST, () => {
    console.log(`server is running on ${HOST}:${PORT}`);
  });
}

export default app;
