const { z } = require("zod");
const { prisma } = require("../../infra/db");
const { publishPaymentEvent } = require("../../infra/kafka");

async function paymentRoutes(app) {
  app.post("/create", async (req, reply) => {
    const input = z.object({ jobId: z.string().uuid(), customerId: z.string().uuid(), amount: z.number().positive(), currency: z.string().default("INR") }).parse(req.body);
    const payment = await prisma.payment.create({ data: { ...input, providerOrderId: `order_${Date.now()}`, status: "PENDING" } });
    const suspicious = input.amount > 100000;
    return reply.code(201).send({ ...payment, fraudFlag: suspicious });
  });

  app.post("/webhook", async (req) => {
    const input = z.object({ paymentId: z.string().uuid(), status: z.enum(["SUCCESS", "FAILED"]), gatewayTransactionId: z.string().optional() }).parse(req.body);
    const payment = await prisma.payment.update({ where: { id: input.paymentId }, data: { status: input.status, gatewayTransactionId: input.gatewayTransactionId } });

    if (input.status === "SUCCESS") {
      await prisma.invoice.create({ data: { paymentId: payment.id, invoiceNumber: `INV-${Date.now()}`, amount: payment.amount } });
      await publishPaymentEvent("payment.success", { paymentId: payment.id, jobId: payment.jobId });
    } else {
      await publishPaymentEvent("payment.failed", { paymentId: payment.id, jobId: payment.jobId });
    }
    return { acknowledged: true };
  });
}

module.exports = { paymentRoutes };
