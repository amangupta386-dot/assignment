const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const { logger } = require("@kaarigar/shared");
const { paymentRoutes } = require("./modules/payments/routes");
const { startPaymentConsumer } = require("./infra/kafka");

const app = Fastify({ logger: false });
app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(swagger, { openapi: { info: { title: "Payment Service", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });
app.get("/health", async () => ({ ok: true, service: "payment-service" }));
app.register(paymentRoutes, { prefix: "/payments" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  await startPaymentConsumer();
  logger.info("payment_service_started");
};
start().catch((error) => { logger.error({ error }, "payment_service_failed"); process.exit(1); });
