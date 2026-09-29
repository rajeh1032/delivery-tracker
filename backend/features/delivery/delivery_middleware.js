import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import { getHandledAction } from "./delivery_model.js";
import { ERROR_CODES } from "../../config/constants.js";

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
        code: ERROR_CODES.VALIDATION_ERROR,
        message: errors.join(", ")
      });
    }
  };
};

export const checkIdempotency = (req, res, next) => {
  const actionId = req.body?.client_action_id;
  const deliveryId = Number(req.params.id);

  if (actionId) {
    const cached = getHandledAction(actionId);
    if (cached) {
      if (cached.deliveryId && cached.deliveryId !== deliveryId) {
        return res.status(409).json({
          code: ERROR_CODES.IDEMPOTENCY_KEY_REUSE,
          message: "Action ID already used for a different delivery"
        });
      }
      res.setHeader("X-Idempotent-Replay", "true");
      return res.status(200).json(cached.response);
    }
  }
  next();
};

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || ".jpg";
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  }
});

export const upload = multer({ storage });
