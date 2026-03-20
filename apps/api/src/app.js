const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const { env } = require("./config/env");
const routes = require("./routes");
const { demoUser } = require("./middlewares/demoAuth");
const { notFound, errorHandler } = require("./middlewares/errorHandler");

const app = express();

const localhostOriginPattern = /^https?:\/\/(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?$/i;
const allowedOrigin = env.clientOrigin;

app.use(helmet());
app.use(
  cors({
    origin(origin, callback) {
      // Allow non-browser clients (no Origin), explicit wildcard, and local dev origins.
      if (!origin || allowedOrigin === "*" || localhostOriginPattern.test(origin) || origin === allowedOrigin) {
        return callback(null, true);
      }
      return callback(new Error(`CORS blocked for origin: ${origin}`));
    }
  })
);
app.use(express.json());
app.use(demoUser);

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.use("/api", routes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
