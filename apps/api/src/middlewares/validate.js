const Joi = require("joi");

const validate = (schema) => (req, _res, next) => {
  const { error, value } = schema.validate(req.body, { abortEarly: false, stripUnknown: true });
  if (error) {
    const message = error.details.map((d) => d.message).join(", ");
    const err = new Error(message);
    err.statusCode = 400;
    return next(err);
  }
  req.body = value;
  next();
};

module.exports = { validate, Joi };
