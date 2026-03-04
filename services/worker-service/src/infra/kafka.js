const { createProducer, createConsumer, logger, redis } = require("@kaarigar/shared");

const publishWorkerEvent = async (type, payload) => {
  const producer = await createProducer();
  await producer.send({ topic: "worker-events", messages: [{ key: type, value: JSON.stringify({ type, payload, occurredAt: new Date().toISOString() }) }] });
  await producer.disconnect();
};

const startWorkerConsumer = async () => {
  const consumer = await createConsumer("worker-service-group");
  await consumer.subscribe({ topic: "job-events", fromBeginning: false });
  await consumer.run({ eachMessage: async ({ message }) => {
    const eventId = `${message.key ? message.key.toString() : "evt"}:${message.offset || "0"}`;
    const processed = await redis.set(`idempotent:${eventId}`, "1", "EX", 3600, "NX");
    if (!processed) return;
    logger.info({ raw: message.value && message.value.toString() }, "worker_event_consumed");
  }});
};

module.exports = { publishWorkerEvent, startWorkerConsumer };
