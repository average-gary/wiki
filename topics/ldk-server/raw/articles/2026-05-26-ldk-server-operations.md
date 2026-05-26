---
title: "LDK Server — Operations guide (backups, TLS, footguns)"
source_url: https://github.com/lightningdevkit/ldk-server/blob/main/docs/operations.md
type: article
ingested: 2026-05-26
tags: [ldk-server, operations, backup, persistence, tls, contrarian]
quality: 5
confidence: high
summary: Operator-facing guide. Concrete pitfalls: no built-in log rotation (disk-fill -> fund loss), don't restore same backup to two live nodes, TLS renewal needs daemon restart, two SQLite DBs, single 32-byte HMAC key.
---

# LDK Server — Operations guide

Source: official `docs/operations.md` in the upstream repo. This is the closest LDK Server has to a "running it in production" doc, and it doubles as the highest-credibility list of footguns.

## Persistence layout

Default `~/.ldk-server/<network>/` (Linux) or `~/Library/Application Support/ldk-server/<network>/` (macOS), with per-network subdirs (`bitcoin/`, `testnet/`, `regtest/`).

Files:
- `keys_seed` — node identity. **Must be backed up** for on-chain recovery.
- `ldk_node_data.sqlite` — channel state. **Must be backed up** to avoid losing in-flight payments / channel state.
- `ldk_server_data.sqlite` — server-side state.
- `api_key` — 32-byte HMAC secret.
- TLS cert/key.

## Critical operator hazards

### Log rotation

> *LDK Server does not rotate or truncate its own log file... A full disk can prevent the node from persisting channel state, **risking fund loss**.*

Operator must wire up `logrotate` and signal SIGHUP for log re-open. Server itself does no rotation.

### Two-instance backup hazard

> *Do not restore a backup onto two running nodes simultaneously. Running the same node identity on two instances will cause channel state conflicts and potential fund loss.*

There is no safe-restore tooling. Operators must ensure the old instance is fully stopped before restoring elsewhere.

### TLS renewal

ACME / Let's Encrypt certs require a **daemon restart** on every renewal unless you front the server with a separate reverse proxy. No live cert reload.

### Auth granularity

Single 32-byte HMAC API key. No granular auth schemes (issue #140 still open). Anyone with key + network access controls the node.

### Bitcoin backend tradeoffs

Choose exactly one of `[bitcoind]`, `[electrum]`, `[esplora]`. Warning: **Electrum and Esplora cannot verify gossip**, leading to memory-exhaustion risk on a public-graph node. Bitcoin Core RPC is recommended for non-trivial deployments.

## What's reconstructable vs not

**Must back up:**
- `keys_seed`
- `ldk_node_data.sqlite`

**Reconstructable on next start:**
- Network graph (re-syncs from gossip / RGS)
- Fee cache
- API keys (regenerated)
- TLS cert (re-generated self-signed)

## Graceful shutdown

Handles SIGTERM/SIGINT — disconnects streamers, persists state, exits cleanly.

## Monitoring

`[metrics]` block exposes Prometheus endpoint on the gRPC port (`GET /metrics`). Recommend Basic Auth for the metrics endpoint. Tracks balances, channel counts, payment status.

## See also

- [[2026-05-26-ldk-server-api-guide.md]] — auth/TLS spec
- [[2026-05-26-ldk-server-readme.md]] — pre-1.0 status disclaimer
- [[wiki/concepts/persistence-and-backup.md|Persistence and backup]]
