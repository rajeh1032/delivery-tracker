import multer from "multer";
import path from "path";
import fs from "fs";
import crypto from "crypto";
import { fileURLToPath } from "url";
import { getHandledAction } from "./delivery_model.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadsDir = path.resolve(__dirname, "../../uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

export const validation = (schema) => {
  return async (req, res, next) => {
    try {
      const value = await schema.validateAsync(req.body, { abortEarly: false });
      req.body = value;
      next();
    } catch (err) {
      const errors = err.details ? err.details.map((detail) => detail.message) : [err.message];
      res.status(400).json({
        code: "VALIDATION_ERROR",
        message: errors.join(", "),
        details: errors
      });
    }
  };
};

export const checkIdempotency = (req, res, next) => {
  const actionId = req.body?.client_action_id;
  if (!actionId) return next();

  const deliveryId = Number(req.params.id);
  const routeKey = `${req.baseUrl || ""}${req.path}:${deliveryId}:${actionId}`;

  // Check if this actionId was already handled
  const cached = getHandledAction(actionId);
  if (cached) {
    // If the actionId was processed for a DIFFERENT delivery -> Reject with conflict
    if (cached.deliveryId !== deliveryId) {
      return res.status(409).json({
        code: "IDEMPOTENCY_KEY_REUSE",
        message: "client_action_id already used for a different delivery"
      });
    }

    // Replay cached response for the exact same delivery
    res.setHeader("X-Idempotent-Replay", "true");
    return res.status(cached.statusCode || 200).json(cached.response);
  }

  req.idempotencyKey = actionId;
  req.idempotencyDeliveryId = deliveryId;
  next();
};

const ALLOWED_MIME_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);
const MIME_EXTENSIONS = {
  "image/jpeg": ".jpg",
  "image/png": ".png",
  "image/webp": ".webp"
};

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const ext = MIME_EXTENSIONS[file.mimetype] || ".jpg";
    cb(null, `${crypto.randomUUID()}${ext}`);
  }
});

export const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
    files: 1
  },
  fileFilter: (req, file, cb) => {
    if (!ALLOWED_MIME_TYPES.has(file.mimetype)) {
      return cb(new multer.MulterError("LIMIT_UNEXPECTED_FILE", "photo"));
    }
    cb(null, true);
  }
});
