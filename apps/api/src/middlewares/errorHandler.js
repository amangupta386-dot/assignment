const notFound = (_req, _res, next) => {
  const err = new Error("Route not found");
  err.statusCode = 404;
  next(err);
};

const errorHandler = (err, _req, res, _next) => {
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    message: err.message || "Internal server error"
  });
};

module.exports = { notFound, errorHandler };
