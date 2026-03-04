const { z } = require("zod");

async function notificationRoutes(app) {
  app.post("/push", async (req) => {
    const input = z.object({ userId: z.string(), title: z.string(), body: z.string() }).parse(req.body);
    return { queued: true, channel: "push", ...input };
  });

  app.post("/sms", async (req) => {
    const input = z.object({ phone: z.string(), message: z.string() }).parse(req.body);
    return { queued: true, channel: "sms", ...input };
  });

  app.post("/email", async (req) => {
    const input = z.object({ email: z.string().email(), subject: z.string(), body: z.string() }).parse(req.body);
    return { queued: true, channel: "email", ...input };
  });
}

module.exports = { notificationRoutes };
