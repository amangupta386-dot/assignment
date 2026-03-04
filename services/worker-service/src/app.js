const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const jwt = require("@fastify/jwt");
const { logger } = require("@kaarigar/shared");
const { workerRoutes } = require("./modules/workers/routes");
const { startWorkerConsumer } = require("./infra/kafka");

const app = Fastify({ logger: false });
app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(jwt, { secret: process.env.JWT_SECRET || "secret" });
app.register(swagger, { openapi: { info: { title: "Worker Service", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });
app.get("/health", async () => ({ ok: true, service: "worker-service" }));
app.register(workerRoutes, { prefix: "/workers" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  await startWorkerConsumer();
  logger.info("worker_service_started");
};
start().catch((error) => { logger.error({ error }, "worker_service_failed"); process.exit(1); });
