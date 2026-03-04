const { createConsumer, logger, redis } = require("@kaarigar/shared");

const startReviewConsumer = async () => {
  const consumer = await createConsumer("review-service-group");
  await consumer.subscribe({ topic: "job-events", fromBeginning: false });
  await consumer.run({ eachMessage: async ({ message, partition }) => {
    const key = `review:evt:${partition}:${message.offset}`;
    const lock = await redis.set(key, "1", "EX", 3600, "NX");
    if (!lock) return;
    logger.info({ payload: message.value && message.value.toString() }, "review_event_consumed");
  }});
};

module.exports = { startReviewConsumer };
