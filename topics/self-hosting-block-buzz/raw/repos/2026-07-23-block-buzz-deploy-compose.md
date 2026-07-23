---
title: "block/buzz — production Docker Compose deploy bundle (deploy/compose/)"
source: https://github.com/block/buzz/tree/main/deploy/compose
raw_source: "compose README, compose.yml, .env.example, run.sh, Dockerfile"
type: repo
tags: [buzz, deployment, docker-compose, self-host, ports, config, ops]
confidence: high
ingested: 2026-07-23
summary: "The real self-host recipe: prebuilt image ghcr.io/block/buzz, 5-service compose stack, env/secrets, exposed ports, run.sh ops wrapper, Caddy TLS overlay."
---

# block/buzz — deploy/compose bundle

**This is the production self-host path (distinct from the root `just` dev workflow).** You do NOT build from source — pull the prebuilt image.

## Steps (deploy/compose/README.md)
- Requires **Docker Compose v2.24.4+** (needs `!reset` tag for the TLS override).
- `cd deploy/compose` → `cp .env.example .env` → edit every `CHANGE_ME` → `./run.sh start`.
- TLS: `BUZZ_COMPOSE_TLS=true ./run.sh start` layers `compose.caddy.yml` (Caddy + Let's Encrypt on 80/443).
- Liveness: `curl -fsS http://127.0.0.1:$BUZZ_HTTP_PORT/_liveness`. Validate config: `./run.sh config`. Backups: `./run.sh backup-hint`.
- `BUZZ_AUTO_MIGRATE=true` auto-migrates fresh DBs (needs an image with embedded SQLx migrations). Keep `BUZZ_RELAY_PRIVATE_KEY` and `BUZZ_GIT_HOOK_HMAC_SECRET` stable across restarts.

## compose.yml (5 services)
- **relay**: `${BUZZ_IMAGE:-ghcr.io/block/buzz:main}`, publishes `${BUZZ_HTTP_PORT:-3000}:3000`; internal `BUZZ_BIND_ADDR=0.0.0.0:3000`, `BUZZ_HEALTH_PORT=8080` (`/_readiness`,`/_liveness`), `BUZZ_METRICS_PORT=9102`. Wires deps by service DNS: `DATABASE_URL=postgres://buzz:...@postgres:5432/buzz`, `REDIS_URL=redis://:...@redis:6379`, `BUZZ_S3_ENDPOINT=http://minio:9000`.
- **postgres**: `postgres:17-alpine`, vol `buzz-postgres-data` (internal-only).
- **redis**: `redis:7-alpine` `--appendonly yes --requirepass`, vol `buzz-redis-data` (internal-only).
- **minio**: `minio/minio:RELEASE.2025-09-07T16-13-09Z`, API 9000 / console 9001, vol `buzz-minio-data` (internal-only).
- **minio-init**: `minio/mc` — creates the `buzz-media` bucket.
- Git/NIP-34 repos persisted at `buzz-git-data:/data/git`.
- **Only the relay port (3000) is published to the host** — Postgres/Redis/MinIO are internal-only. This is the natural VPN choke point.

## .env.example
- Domain: `BUZZ_DOMAIN=buzz.example.com`, `RELAY_URL=wss://buzz.example.com`, `BUZZ_MEDIA_BASE_URL=https://buzz.example.com/media`, `BUZZ_CORS_ORIGINS`.
- Secrets: `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `BUZZ_S3_ACCESS_KEY`/`BUZZ_S3_SECRET_KEY` (bucket `buzz-media`), `RELAY_OWNER_PUBKEY` (64-hex; NOT BUZZ_-prefixed), `BUZZ_RELAY_PRIVATE_KEY` (64-hex), `BUZZ_GIT_HOOK_HMAC_SECRET`, `TYPESENSE_API_KEY`.
- **Closed-relay hardening (opt-in, multi-flag):** `BUZZ_REQUIRE_AUTH_TOKEN=true`, `BUZZ_REQUIRE_RELAY_MEMBERSHIP=true`, `RELAY_OWNER_PUBKEY=...`. Forget these and the relay is effectively open.
- Ports: `BUZZ_HTTP_PORT=3000`, `POSTGRES_PORT=5432`, `REDIS_PORT=6379`, `MINIO_API_PORT=9000`, `MINIO_CONSOLE_PORT=9001`, `TYPESENSE_PORT=8108`, `ADMINER_PORT=8082`, `PROMETHEUS_PORT=9090`, `CADDY_HTTP_PORT=80`, `CADDY_HTTPS_PORT=443`.

## run.sh (ops wrapper)
- Subcommands: `start|stop|restart|pull|upgrade|logs|status|config|backup-hint` + member admin `add-member|remove-member|list-members`.
- `start` = `up -d --wait`; `upgrade` = `pull` then restart. Core: `docker compose --env-file .env -f compose.yml [+overlays] "$@"`. TLS overlay via `BUZZ_COMPOSE_TLS=true`; dev overlay via `BUZZ_COMPOSE_DEV=true`.
- Migrations are NOT run by run.sh — delegated to container init, gated by `BUZZ_AUTO_MIGRATE`.

## Dockerfile
- Multi-stage (cargo-chef `rust:1.95-bookworm`, web `node:24`, runtime `debian:bookworm-slim`). Binaries: `buzz-relay` (primary), `buzz-admin`, `buzz-pair-relay`. `EXPOSE 3000 8080 9102`. Runs as unprivileged `buzz:buzz`. Serves UI from `BUZZ_WEB_DIR=/srv/buzz/web`.

## Kubernetes
- `deploy/charts/buzz` (+ `buzz-push-gateway`) Helm charts exist; concrete values.yaml not verified.
