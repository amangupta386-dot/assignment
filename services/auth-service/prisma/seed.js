const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash("Pass@1234", 10);
  await prisma.user.upsert({
    where: { email: "admin@kaarigar.app" },
    update: {},
    create: {
      fullName: "Platform Admin",
      phone: "9999999999",
      email: "admin@kaarigar.app",
      passwordHash,
      role: "ADMIN",
      isVerified: true
    }
  });
}

main().finally(async () => prisma.$disconnect());

