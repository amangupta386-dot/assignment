const { createProducer, createConsumer, logger, redis } = require("@kaarigar/shared");

const publishJobEvent = async (type, payload) => {
  const producer = await createProducer();
  await producer.send({ topic: "job-events", messages: [{ key: type, value: JSON.stringify({ type, payload, occurredAt: new Date().toISOString() }) }] });
  await producer.disconnect();
};

const startJobConsumer = async () => {
  const consumer = await createConsumer("job-service-group");
  await consumer.subscribe({ topic: "worker-events", fromBeginning: false });
  await consumer.run({ eachMessage: async ({ message, partition }) => {
    const eventId = `${partition}:${message.offset}`;
    const lock = await redis.set(`idempotent:${eventId}`, "1", "EX", 3600, "NX");
    if (!lock) return;
    logger.info({ value: message.value && message.value.toString() }, "job_event_consumed");
  }});
};

module.exports = { publishJobEvent, startJobConsumer };
