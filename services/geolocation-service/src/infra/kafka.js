const { createConsumer, logger, redis } = require("@kaarigar/shared");

const startGeoConsumer = async () => {
  const consumer = await createConsumer("geolocation-service-group");
  await consumer.subscribe({ topic: "worker-events", fromBeginning: false });
  await consumer.run({ eachMessage: async ({ message, partition }) => {
    const key = `geo:evt:${partition}:${message.offset}`;
    const lock = await redis.set(key, "1", "EX", 3600, "NX");
    if (!lock) return;
    logger.info({ payload: message.value && message.value.toString() }, "geo_event_consumed");
  }});
};

module.exports = { startGeoConsumer };
