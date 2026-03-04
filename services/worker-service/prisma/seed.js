const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const worker = await prisma.worker.create({
    data: { userId: "11111111-1111-1111-1111-111111111111", bio: "Civil mason with 8 years of experience", experienceYears: 8, available: true }
  });
  await prisma.workerSkill.createMany({
    data: [
      { workerId: worker.id, skillName: "MASON", level: "EXPERT" },
      { workerId: worker.id, skillName: "TILING", level: "ADVANCED" }
    ]
  });
}
main().finally(async () => prisma.$disconnect());
