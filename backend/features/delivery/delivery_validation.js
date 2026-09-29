import Joi from "joi";

const completeDeliverySchema = Joi.object({
  recipient_name: Joi.string().trim().min(2).max(100).required().messages({
    "any.required": "recipient_name is required",
    "string.empty": "recipient_name cannot be empty",
    "string.min": "recipient_name must be at least 2 characters",
    "string.max": "recipient_name cannot exceed 100 characters"
  }),
  note: Joi.string().trim().max(500).allow("", null).optional().messages({
    "string.max": "note cannot exceed 500 characters"
  }),
  client_action_id: Joi.string().trim().uuid().required().messages({
    "any.required": "client_action_id is required",
    "string.guid": "client_action_id must be a valid UUID v4"
  }),
  base_version: Joi.number().integer().min(1).optional()
});

const failDeliverySchema = Joi.object({
  reason: Joi.string().trim().min(3).max(100).required().messages({
    "any.required": "reason is required",
    "string.empty": "reason cannot be empty",
    "string.min": "reason must be at least 3 characters",
    "string.max": "reason cannot exceed 100 characters"
  }),
  note: Joi.string().trim().max(500).allow("", null).optional().messages({
    "string.max": "note cannot exceed 500 characters"
  }),
  client_action_id: Joi.string().trim().uuid().required().messages({
    "any.required": "client_action_id is required",
    "string.guid": "client_action_id must be a valid UUID v4"
  }),
  base_version: Joi.number().integer().min(1).optional()
});

export { completeDeliverySchema, failDeliverySchema };
