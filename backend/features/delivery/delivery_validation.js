import Joi from "joi";

const completeDeliverySchema = Joi.object({
  recipient_name: Joi.string().min(2).max(100).required().messages({
    "any.required": "recipient_name is required",
    "string.empty": "recipient_name cannot be empty"
  }),
  note: Joi.string().allow("", null).optional(),
  client_action_id: Joi.string().required().messages({
    "any.required": "client_action_id is required"
  })
});

const failDeliverySchema = Joi.object({
  reason: Joi.string().min(3).max(100).required().messages({
    "any.required": "reason is required",
    "string.empty": "reason cannot be empty"
  }),
  note: Joi.string().allow("", null).optional(),
  client_action_id: Joi.string().required().messages({
    "any.required": "client_action_id is required"
  })
});

export { completeDeliverySchema, failDeliverySchema };
