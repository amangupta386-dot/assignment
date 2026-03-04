const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const { logger } = require("@kaarigar/shared");
const { geoRoutes } = require("./modules/geo/routes");
const { startGeoConsumer } = require("./infra/kafka");

const app = Fastify({ logger: false });
app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(swagger, { openapi: { info: { title: "Geolocation Service", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });
app.get("/health", async () => ({ ok: true, service: "geolocation-service" }));
app.register(geoRoutes, { prefix: "/geo" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  await startGeoConsumer();
  logger.info("geolocation_service_started");
};
start().catch((error) => { logger.error({ error }, "geolocation_service_failed"); process.exit(1); });
