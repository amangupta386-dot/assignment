const { Kafka } = require("kafkajs");

const brokers = (process.env.KAFKA_BROKERS || "kafka:9092").split(",");
const kafka = new Kafka({ clientId: "kaarigar", brokers });

const createProducer = async () => {
  const producer = kafka.producer({ idempotent: true });
  await producer.connect();
  return producer;
};

const createConsumer = async (groupId) => {
  const consumer = kafka.consumer({ groupId });
  await consumer.connect();
  return consumer;
};

module.exports = { createProducer, createConsumer };
