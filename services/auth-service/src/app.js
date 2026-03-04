const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const jwt = require("@fastify/jwt");
const cookie = require("@fastify/cookie");
const { logger, getCorrelationId } = require("@kaarigar/shared");
const { authRoutes } = require("./modules/auth/routes");
const { startAuthConsumer } = require("./infra/kafka");

const app = Fastify({ logger: false });
app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(cookie);
app.register(jwt, { secret: process.env.JWT_SECRET || "secret" });
app.register(swagger, { openapi: { info: { title: "Auth Service", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });

app.addHook("onRequest", async (req, reply) => {
  const correlationId = getCorrelationId(req.headers["x-request-id"]);
  reply.header("x-request-id", correlationId);
});

app.get("/health", async () => ({ ok: true, service: "auth-service" }));
app.register(authRoutes, { prefix: "/auth" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  await startAuthConsumer();
  logger.info("auth_service_started");
};

start().catch((error) => {
  logger.error({ error }, "auth_service_failed");
  process.exit(1);
});
