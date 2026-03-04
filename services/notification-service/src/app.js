const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const { logger } = require("@kaarigar/shared");
const { notificationRoutes } = require("./modules/notifications/routes");
const { startNotificationConsumer } = require("./infra/kafka");

const app = Fastify({ logger: false });
app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(swagger, { openapi: { info: { title: "Notification Service", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });
app.get("/health", async () => ({ ok: true, service: "notification-service" }));
app.register(notificationRoutes, { prefix: "/notifications" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  await startNotificationConsumer();
  logger.info("notification_service_started");
};
start().catch((error) => { logger.error({ error }, "notification_service_failed"); process.exit(1); });
