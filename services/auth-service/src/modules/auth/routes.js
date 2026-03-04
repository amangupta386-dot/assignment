const bcrypt = require("bcryptjs");
const { z } = require("zod");
const { prisma } = require("../../infra/db");
const { redis } = require("@kaarigar/shared");
const { publishAuthEvent } = require("../../infra/kafka");

const registerSchema = z.object({
  fullName: z.string().min(2),
  phone: z.string().min(8),
  email: z.string().email(),
  password: z.string().min(8),
  role: z.enum(["WORKER", "CUSTOMER", "ADMIN"])
});

async function authRoutes(app) {
  app.post("/register", async (req, reply) => {
    const body = registerSchema.parse(req.body);
    const passwordHash = await bcrypt.hash(body.password, 10);

    const user = await prisma.user.create({ data: { ...body, passwordHash } });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    await redis.setex(`otp:${user.id}`, 300, otp);
    await prisma.oTPVerification.create({ data: { userId: user.id, otpCode: otp } });

    await publishAuthEvent("user.created", { userId: user.id, role: user.role });
    return reply.code(201).send({ userId: user.id, otpSent: true });
  });

  app.post("/verify-otp", async (req, reply) => {
    const input = z.object({ userId: z.string().uuid(), otp: z.string().length(6) }).parse(req.body);
    const cached = await redis.get(`otp:${input.userId}`);
    if (!cached || cached !== input.otp) return reply.code(400).send({ message: "Invalid OTP" });

    await prisma.user.update({ where: { id: input.userId }, data: { isVerified: true } });
    await publishAuthEvent("user.verified", { userId: input.userId });
    return { verified: true };
  });

  app.post("/login", async (req, reply) => {
    const input = z.object({ email: z.string().email(), password: z.string().min(8) }).parse(req.body);
    const user = await prisma.user.findUnique({ where: { email: input.email } });
    if (!user) return reply.code(401).send({ message: "Invalid credentials" });

    const valid = await bcrypt.compare(input.password, user.passwordHash);
    if (!valid) return reply.code(401).send({ message: "Invalid credentials" });

    const accessToken = await reply.jwtSign({ sub: user.id, role: user.role }, { expiresIn: "15m" });
    const refreshToken = await reply.jwtSign({ sub: user.id, role: user.role, type: "refresh" }, { expiresIn: "7d" });

    await prisma.session.create({ data: { userId: user.id, refreshToken, expiresAt: new Date(Date.now() + 7 * 86400000) } });
    await redis.setex(`session:${user.id}`, 604800, refreshToken);

    reply.setCookie("refreshToken", refreshToken, { httpOnly: true, secure: true, sameSite: "strict" });
    return { accessToken };
  });
}

module.exports = { authRoutes };

