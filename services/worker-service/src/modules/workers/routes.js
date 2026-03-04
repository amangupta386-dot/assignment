const { z } = require("zod");
const { prisma } = require("../../infra/db");
const { redis } = require("@kaarigar/shared");
const { publishWorkerEvent } = require("../../infra/kafka");

async function workerRoutes(app) {
  app.post("/", async (req, reply) => {
    const input = z.object({ userId: z.string().uuid(), bio: z.string().default(""), experienceYears: z.number().int().nonnegative(), available: z.boolean() }).parse(req.body);
    const worker = await prisma.worker.create({ data: input });
    await publishWorkerEvent("worker.created", { workerId: worker.id });
    return reply.code(201).send(worker);
  });

  app.put("/:id", async (req) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const input = z.object({ bio: z.string().optional(), experienceYears: z.number().int().nonnegative().optional(), available: z.boolean().optional() }).parse(req.body);
    const worker = await prisma.worker.update({ where: { id: params.id }, data: input });
    await redis.del(`worker:${params.id}`);
    await publishWorkerEvent("worker.updated", { workerId: worker.id });
    return worker;
  });

  app.post("/:id/skills", async (req, reply) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const input = z.object({ skillName: z.string(), level: z.string() }).parse(req.body);
    const skill = await prisma.workerSkill.create({ data: { workerId: params.id, ...input } });
    return reply.code(201).send(skill);
  });

  app.post("/:id/subscription", async (req) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const input = z.object({ planName: z.string(), isActive: z.boolean(), expiresAt: z.coerce.date() }).parse(req.body);
    const sub = await prisma.workerSubscription.upsert({ where: { workerId: params.id }, create: { workerId: params.id, ...input }, update: input });
    await publishWorkerEvent("worker.subscription.changed", { workerId: params.id, plan: sub.planName });
    return sub;
  });

  app.get("/:id", async (req, reply) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const cacheKey = `worker:${params.id}`;
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
    const worker = await prisma.worker.findUnique({ where: { id: params.id }, include: { skills: true, availability: true, insurance: true, subscription: true } });
    if (!worker) return reply.code(404).send({ message: "Worker not found" });
    await redis.setex(cacheKey, 300, JSON.stringify(worker));
    return worker;
  });
}

module.exports = { workerRoutes };
