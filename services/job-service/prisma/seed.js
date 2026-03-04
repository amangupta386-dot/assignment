const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const job = await prisma.job.create({
    data: {
      customerId: "22222222-2222-2222-2222-222222222222",
      title: "Electrical wiring repair",
      description: "Urgent repair for kitchen wiring",
      latitude: 28.6139,
      longitude: 77.209,
      budget: 2500,
      suggestedPrice: 2750,
      status: "CREATED"
    }
  });
  await prisma.jobStatusHistory.create({ data: { jobId: job.id, status: "CREATED", note: "Seeded" } });
}
main().finally(async () => prisma.$disconnect());
