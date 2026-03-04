const { z } = require("zod");
const { prisma } = require("../../infra/db");
const { publishJobEvent } = require("../../infra/kafka");

const statusFlow = ["CREATED", "ASSIGNED", "ACCEPTED", "IN_PROGRESS", "COMPLETED", "CANCELLED"];

async function jobRoutes(app) {
  app.post("/", async (req, reply) => {
    const input = z.object({ customerId: z.string().uuid(), title: z.string(), description: z.string(), latitude: z.number(), longitude: z.number(), budget: z.number().positive() }).parse(req.body);
    const suggestedPrice = Math.max(input.budget, input.budget * 1.1);
    const job = await prisma.job.create({ data: { ...input, suggestedPrice, status: "CREATED" } });
    await prisma.jobStatusHistory.create({ data: { jobId: job.id, status: "CREATED" } });
    await publishJobEvent("job.created", { jobId: job.id });
    return reply.code(201).send(job);
  });

  app.post("/:id/assign", async (req) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const input = z.object({ workerId: z.string().uuid(), distanceKm: z.number().nonnegative() }).parse(req.body);
    const assignment = await prisma.jobAssignment.create({ data: { jobId: params.id, workerId: input.workerId, distanceKm: input.distanceKm } });
    await prisma.job.update({ where: { id: params.id }, data: { status: "ASSIGNED" } });
    await prisma.jobStatusHistory.create({ data: { jobId: params.id, status: "ASSIGNED" } });
    await publishJobEvent("job.assigned", { jobId: params.id, workerId: input.workerId });
    app.notifyJob(params.id, { status: "ASSIGNED", workerId: input.workerId });
    return assignment;
  });

  app.post("/:id/status", async (req) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    const input = z.object({ status: z.enum(statusFlow), note: z.string().optional() }).parse(req.body);
    const updated = await prisma.job.update({ where: { id: params.id }, data: { status: input.status } });
    await prisma.jobStatusHistory.create({ data: { jobId: params.id, status: input.status, note: input.note } });
    const eventMap = { IN_PROGRESS: "job.started", COMPLETED: "job.completed", CANCELLED: "job.cancelled" };
    if (eventMap[input.status]) await publishJobEvent(eventMap[input.status], { jobId: params.id });
    app.notifyJob(params.id, { status: input.status, note: input.note });
    return updated;
  });

  app.get("/:id", async (req) => {
    const params = z.object({ id: z.string().uuid() }).parse(req.params);
    return prisma.job.findUnique({ where: { id: params.id }, include: { history: true, assignments: true } });
  });
}

module.exports = { jobRoutes };
