const { z } = require("zod");
const { prisma } = require("../../infra/db");
const { redis } = require("@kaarigar/shared");

async function geoRoutes(app) {
  app.post("/workers/:workerId/location", async (req, reply) => {
    const params = z.object({ workerId: z.string().uuid() }).parse(req.params);
    const input = z.object({ latitude: z.number(), longitude: z.number() }).parse(req.body);
    const location = await prisma.workerLocation.upsert({
      where: { workerId: params.workerId },
      create: { workerId: params.workerId, latitude: input.latitude, longitude: input.longitude },
      update: { latitude: input.latitude, longitude: input.longitude }
    });
    await prisma.locationHistory.create({ data: { workerId: params.workerId, latitude: input.latitude, longitude: input.longitude } });
    await redis.del(`nearby:${params.workerId}`);
    return reply.code(201).send(location);
  });

  app.get("/nearby", async (req) => {
    const query = z.object({ latitude: z.coerce.number(), longitude: z.coerce.number(), radiusKm: z.coerce.number().default(5) }).parse(req.query);
    const cacheKey = `nearby:${query.latitude}:${query.longitude}:${query.radiusKm}`;
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const rows = await prisma.$queryRawUnsafe(
      `SELECT worker_id as "workerId", latitude, longitude,
              ST_Distance(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography) / 1000 as "distanceKm"
       FROM worker_locations
       WHERE ST_DWithin(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, $3 * 1000)
       ORDER BY "distanceKm" ASC
       LIMIT 20`,
      query.longitude,
      query.latitude,
      query.radiusKm
    );

    await redis.setex(cacheKey, 120, JSON.stringify(rows));
    return rows;
  });
}

module.exports = { geoRoutes };
