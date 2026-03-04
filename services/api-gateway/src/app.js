const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const rateLimit = require("@fastify/rate-limit");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const proxy = require("@fastify/http-proxy");
const { redis, logger, getCorrelationId } = require("@kaarigar/shared");

const app = Fastify({ logger: false });

app.addHook("onRequest", async (req, reply) => {
  const correlationId = getCorrelationId(req.headers["x-request-id"]);
  reply.header("x-request-id", correlationId);
  logger.info({ correlationId, path: req.url, method: req.method }, "incoming_request");
});

app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(rateLimit, { max: 150, timeWindow: "1 minute", redis });

app.register(swagger, { openapi: { info: { title: "Kaarigar Gateway", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });

app.get("/health", async () => ({ ok: true, service: "api-gateway" }));

app.addHook("preHandler", async (req, reply) => {
  if (req.url.startsWith("/auth") || req.url.startsWith("/health") || req.url.startsWith("/docs")) return;
  if (!req.headers.authorization) {
    reply.code(401).send({ message: "Unauthorized" });
  }
});

app.register(proxy, { upstream: "http://auth-service:3000", prefix: "/auth" });
app.register(proxy, { upstream: "http://worker-service:3000", prefix: "/workers" });
app.register(proxy, { upstream: "http://job-service:3000", prefix: "/jobs" });
app.register(proxy, { upstream: "http://geolocation-service:3000", prefix: "/geo" });
app.register(proxy, { upstream: "http://review-rating-service:3000", prefix: "/reviews" });
app.register(proxy, { upstream: "http://payment-service:3000", prefix: "/payments" });
app.register(proxy, { upstream: "http://notification-service:3000", prefix: "/notifications" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  logger.info("gateway_started");
};

start().catch((error) => {
  logger.error({ error }, "gateway_start_failed");
  process.exit(1);
});
