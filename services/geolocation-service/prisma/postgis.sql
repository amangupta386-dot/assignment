CREATE EXTENSION IF NOT EXISTS postgis;
CREATE INDEX IF NOT EXISTS idx_worker_locations_geom
ON worker_locations
USING GIST (
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
);
