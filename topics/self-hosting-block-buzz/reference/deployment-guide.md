---
title: Deployment & Topology Reference
type: reference
tags: [buzz, deployment, docker-compose, ports, config, topology, vpn]
confidence: high
created: 2026-07-23
updated: 2026-07-23
---

# Deployment & Topology Reference

The concrete self-host facts for [block/buzz](https://github.com/block/buzz), and the network
topology that places its single exposed surface behind a VPN. For the opinionated step-by-step, see
the **[Team-over-VPN Playbook](../output/playbook-self-hosting-block-buzz-2026-07-23.md)**.

## The two deployment paths

| Path | Location | Use |
|------|----------|-----|
| **Dev** | root `docker-compose.yml` + `Justfile` (`just setup && just build`, `just dev`/`just relay`) | Local hacking; open infra, adds Adminer/Keycloak/Prometheus. |
| **Production** | **`deploy/compose/`** (prebuilt image) | The real self-host answer. Use this. |

You do **not** build from source for production — pull the prebuilt image `ghcr.io/block/buzz`.

## Production stack (`deploy/compose/compose.yml`) — 5 services

| Service | Image (pinned) | Ports | Exposure |
|---------|---------------|-------|----------|
| **relay** | `ghcr.io/block/buzz:main` (pin `:sha-<7>`) | `3000` (WS+REST), `8080` (health), `9102` (metrics) | **Only 3000 published to host** |
| **postgres** | `postgres:17-alpine` | 5432 | internal-only |
| **redis** | `redis:7-alpine` (`--appendonly yes --requirepass`) | 6379 | internal-only |
| **minio** | `minio/minio:RELEASE.2025-09-07T16-13-09Z` | 9000 (API) / 9001 (console) | internal-only |
| **minio-init** | `minio/mc:RELEASE.2025-08-13...` | — | creates `buzz-media` bucket |

- Relay wires deps by service DNS: `DATABASE_URL=postgres://buzz:…@postgres:5432/buzz`,
  `REDIS_URL=redis://:…@redis:6379`, `BUZZ_S3_ENDPOINT=http://minio:9000`.
- Health endpoints: `/_liveness`, `/_readiness` (port 8080).
- **Persistence (named volumes):** `buzz-postgres-data`, `buzz-redis-data`, `buzz-minio-data`,
  `buzz-git-data` (`/data/git`, NIP-34 repos).
- Relay runs as unprivileged `buzz:buzz`. Binaries in the image: `buzz-relay` (entrypoint),
  `buzz-admin`, `buzz-pair-relay`.

**This topology is already VPN-friendly:** Postgres/Redis/MinIO never touch the host network; the only
externally reachable surface is the relay on 3000 (optionally behind Caddy). That single port is where
the VPN gate goes.

## Requirements

- **Docker Compose v2.24.4+** (needs the `!reset` tag for the TLS override).
- The prebuilt image (no Rust/Node build needed for prod).
- A Kubernetes path also exists: Helm charts under `deploy/charts/buzz` (+ `buzz-push-gateway`) —
  concrete `values.yaml` unverified here.

## Configuration (`deploy/compose/.env.example`)

Copy `.env.example` → `.env` and set every `CHANGE_ME`.

**Domain / URLs:**
```
BUZZ_DOMAIN=buzz.example.com
RELAY_URL=wss://buzz.example.com          # what clients connect to — set to your INTERNAL name
BUZZ_MEDIA_BASE_URL=https://buzz.example.com/media
BUZZ_CORS_ORIGINS=...
```

**Secrets (generate real values):**
```
POSTGRES_PASSWORD, REDIS_PASSWORD
BUZZ_S3_ACCESS_KEY, BUZZ_S3_SECRET_KEY   (bucket BUZZ_S3_BUCKET=buzz-media)
RELAY_OWNER_PUBKEY        # 64-hex Nostr pubkey — NOTE: not BUZZ_-prefixed
BUZZ_RELAY_PRIVATE_KEY    # 64-hex — MUST stay stable across restarts
BUZZ_GIT_HOOK_HMAC_SECRET # MUST stay stable across restarts
TYPESENSE_API_KEY
```

**Closed-relay hardening (opt-in — set ALL of these or the relay is effectively open):**
```
BUZZ_REQUIRE_AUTH_TOKEN=true
BUZZ_REQUIRE_RELAY_MEMBERSHIP=true
RELAY_OWNER_PUBKEY=<your 64-hex pubkey>
```

**Ports (all configurable):** `BUZZ_HTTP_PORT=3000`, `POSTGRES_PORT=5432`, `REDIS_PORT=6379`,
`MINIO_API_PORT=9000`, `MINIO_CONSOLE_PORT=9001`, `TYPESENSE_PORT=8108`, `ADMINER_PORT=8082`,
`PROMETHEUS_PORT=9090`, `CADDY_HTTP_PORT=80`, `CADDY_HTTPS_PORT=443`.

## Run & operate (`deploy/compose/run.sh`)

```
cd deploy/compose
cp .env.example .env         # then edit every CHANGE_ME
./run.sh config              # validate
./run.sh start               # = docker compose up -d --wait
BUZZ_COMPOSE_TLS=true ./run.sh start   # layer Caddy + Let's Encrypt (80/443)
curl -fsS http://127.0.0.1:$BUZZ_HTTP_PORT/_liveness   # verify
```

- Subcommands: `start | stop | restart | pull | upgrade | logs | status | config | backup-hint`.
- **Member admin:** `add-member | remove-member | list-members`.
- `upgrade` = `pull` then restart. **Migrations** are NOT run by `run.sh` — they run at container init,
  gated by `BUZZ_AUTO_MIGRATE=true` (needs an image with embedded SQLx migrations). ⚠️ See the
  migration-checksum upgrade hazard in [Operations, Security & Maturity](../concepts/operations-security-maturity.md).

## Where the VPN gate goes

Because only relay:3000 is published, you have two clean options (details:
[VPN-Gating Patterns](../concepts/vpn-gating-patterns.md)):

1. **Don't publish 3000 to the public NIC at all** — bind it to the VPN/loopback interface and let
   Tailscale Serve (or a reverse proxy on the VPN net) front it.
2. **Firewall default-deny** public ingress; allow only the VPN.

Either way, set `RELAY_URL` / `BUZZ_RELAY_URL` to the **internal** hostname
(`wss://buzz-relay.<tailnet>.ts.net` or `wss://relay.internal`), and ensure `BUZZ_MEDIA_BASE_URL`
resolves over the VPN too.

## See Also

- [What buzz Is](../concepts/what-is-buzz.md)
- [VPN-Gating Patterns](../concepts/vpn-gating-patterns.md)
- [Connecting Clients & Agents Over a VPN](../concepts/connecting-over-vpn.md)
- [Operations, Security & Maturity](../concepts/operations-security-maturity.md)
- [Team-over-VPN Playbook](../output/playbook-self-hosting-block-buzz-2026-07-23.md)
