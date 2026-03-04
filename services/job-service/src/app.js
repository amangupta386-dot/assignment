const Fastify = require("fastify");
const helmet = require("@fastify/helmet");
const cors = require("@fastify/cors");
const swagger = require("@fastify/swagger");
const swaggerUi = require("@fastify/swagger-ui");
const websocket = require("@fastify/websocket");
const { logger } = require("@kaarigar/shared");
const { jobRoutes } = require("./modules/jobs/routes");
const { startJobConsumer } = require("./infra/kafka");

const socketsByJob = new Map();
const app = Fastify({ logger: false });
app.decorate("notifyJob", (jobId, payload) => {
  const sockets = socketsByJob.get(jobId);
  if (!sockets) return;
  for (const socket of sockets) socket.send(JSON.stringify(payload));
});

app.register(websocket);
app.register(helmet);
app.register(cors, { origin: true, credentials: true });
app.register(swagger, { openapi: { info: { title: "Job Service", version: "1.0.0" } } });
app.register(swaggerUi, { routePrefix: "/docs" });
app.get("/health", async () => ({ ok: true, service: "job-service" }));

app.get("/jobs/stream/:jobId", { websocket: true }, (connection, req) => {
  const jobId = req.params.jobId;
  const sockets = socketsByJob.get(jobId) || new Set();
  sockets.add(connection.socket);
  socketsByJob.set(jobId, sockets);
  connection.socket.on("close", () => {
    sockets.delete(connection.socket);
    if (!sockets.size) socketsByJob.delete(jobId);
  });
});

app.register(jobRoutes, { prefix: "/jobs" });

const start = async () => {
  await app.listen({ host: "0.0.0.0", port: Number(process.env.PORT || 3000) });
  await startJobConsumer();
  logger.info("job_service_started");
};
start().catch((error) => { logger.error({ error }, "job_service_failed"); process.exit(1); });
