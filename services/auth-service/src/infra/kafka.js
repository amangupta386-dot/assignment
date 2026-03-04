const { createProducer, createConsumer, logger } = require("@kaarigar/shared");

const publishAuthEvent = async (type, payload) => {
  const producer = await createProducer();
  await producer.send({
    topic: "user-events",
    messages: [{ key: type, value: JSON.stringify({ type, payload, occurredAt: new Date().toISOString() }) }]
  });
  await producer.disconnect();
};

const startAuthConsumer = async () => {
  const consumer = await createConsumer("auth-service-group");
  await consumer.subscribe({ topic: "notification-events", fromBeginning: false });
  await consumer.run({
    eachMessage: async ({ message }) => {
      logger.info({ message: message.value && message.value.toString() }, "auth_event_consumed");
    }
  });
};

module.exports = { publishAuthEvent, startAuthConsumer };
