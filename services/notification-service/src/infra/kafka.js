const { createConsumer, logger, redis } = require("@kaarigar/shared");

const startNotificationConsumer = async () => {
  const consumer = await createConsumer("notification-service-group");
  for (const topic of ["job-events", "payment-events", "worker-events"]) {
    await consumer.subscribe({ topic, fromBeginning: false });
  }

  await consumer.run({ eachMessage: async ({ topic, message, partition }) => {
    const key = `notification:evt:${topic}:${partition}:${message.offset}`;
    const lock = await redis.set(key, "1", "EX", 3600, "NX");
    if (!lock) return;
    logger.info({ topic, payload: message.value && message.value.toString() }, "notification_event_consumed");
  }});
};

module.exports = { startNotificationConsumer };
