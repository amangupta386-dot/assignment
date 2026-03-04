const { createProducer, createConsumer, logger, redis } = require("@kaarigar/shared");

const publishPaymentEvent = async (type, payload) => {
  const producer = await createProducer();
  await producer.send({ topic: "payment-events", messages: [{ key: type, value: JSON.stringify({ type, payload, occurredAt: new Date().toISOString() }) }] });
  await producer.disconnect();
};

const startPaymentConsumer = async () => {
  const consumer = await createConsumer("payment-service-group");
  await consumer.subscribe({ topic: "job-events", fromBeginning: false });
  await consumer.run({ eachMessage: async ({ message, partition }) => {
    const key = `payment:evt:${partition}:${message.offset}`;
    const lock = await redis.set(key, "1", "EX", 3600, "NX");
    if (!lock) return;
    logger.info({ payload: message.value && message.value.toString() }, "payment_event_consumed");
  }});
};

module.exports = { publishPaymentEvent, startPaymentConsumer };
