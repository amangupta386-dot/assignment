const { z } = require("zod");
const { prisma } = require("../../infra/db");

async function reviewRoutes(app) {
  app.post("/", async (req, reply) => {
    const input = z.object({ jobId: z.string().uuid(), workerId: z.string().uuid(), customerId: z.string().uuid(), rating: z.number().min(1).max(5), reviewText: z.string().max(500).optional() }).parse(req.body);
    const review = await prisma.review.create({ data: input });

    const agg = await prisma.review.aggregate({ where: { workerId: input.workerId }, _avg: { rating: true }, _count: { _all: true } });
    const avg = Number(agg._avg.rating || 0);
    const total = agg._count._all;
    const trustScore = Math.min(100, Math.round(avg * 20 + Math.min(20, total)));

    await prisma.workerRatingSummary.upsert({
      where: { workerId: input.workerId },
      create: { workerId: input.workerId, averageRating: avg, totalReviews: total, trustScore },
      update: { averageRating: avg, totalReviews: total, trustScore }
    });

    return reply.code(201).send(review);
  });

  app.get("/workers/:workerId/summary", async (req) => {
    const params = z.object({ workerId: z.string().uuid() }).parse(req.params);
    return prisma.workerRatingSummary.findUnique({ where: { workerId: params.workerId } });
  });
}

module.exports = { reviewRoutes };
