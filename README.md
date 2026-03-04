# Kaarigar

Location-based skilled trades marketplace built with Node.js (JavaScript) microservices and Flutter.

## Services
- API Gateway
- Auth Service
- Worker Service
- Job Service
- Geolocation Service (PostGIS)
- Review & Rating Service
- Payment Service
- Notification Service

## Infra
- PostgreSQL 16 + PostGIS
- Redis
- Kafka + Zookeeper
- NGINX
- Prometheus + Grafana

## Quick Start
1. Copy `.env.example` to `.env` and adjust secrets.
2. Build and start stack: `docker compose up --build`
3. Gateway available at `http://localhost`

## Kubernetes (Local, Single Port)
- Kubernetes manifests are in `infra/k8s`.
- Follow `infra/k8s/README.md` to run all services and expose only one local entrypoint (`http://kaarigar.local`).

