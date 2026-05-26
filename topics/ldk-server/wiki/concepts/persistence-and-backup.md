---
title: "Persistence and backup in LDK Server"
type: concept
created: 2026-05-26
updated: 2026-05-26
confidence: high
tags: [persistence, backup, sqlite, vss, operations, fund-loss]
---

# Persistence and backup

LDK Server's persistence story is inherited from [[../../raw/repos/2026-05-26-ldk-node-overview.md|LDK Node]]. Out of the box: two SQLite files plus a key seed. Optionally: Versioned Storage Service (VSS) for client-server encrypted storage.

## On-disk layout

Default `~/.ldk-server/<network>/` (Linux) or `~/Library/Application Support/ldk-server/<network>/` (macOS).

| File | Purpose | Backup? |
|---|---|---|
| `keys_seed` | Node identity. On-chain recovery key. | **Yes** |
| `ldk_node_data.sqlite` | Channel state, in-flight payments. | **Yes** |
| `ldk_server_data.sqlite` | Server-side state (API keys, etc.) | Optional |
| `api_key` | 32-byte HMAC secret | Reconstructable |
| TLS cert/key | Self-signed by default | Reconstructable |

Issue [#172](https://github.com/lightningdevkit/ldk-server/issues/172) ("Unify database") is open — the two-DB layout is acknowledged as awkward.

## Reconstructable on next start

- Network graph (resyncs from gossip / RGS)
- Fee cache
- API key (regenerated)
- TLS cert (regenerated self-signed)

## The two-instance backup hazard

> *"Do not restore a backup onto two running nodes simultaneously. Running the same node identity on two instances will cause channel state conflicts and potential fund loss."*

There is no safe-restore tooling. **Restoring the channel state DB onto a second running node will likely cause channel-state conflicts and force-closes**, with potential fund loss. Best practice: ensure the prior instance is fully stopped before restoring.

This is structurally why **HA / active-active LDK Server is not a thing**. Issue [#204](https://github.com/lightningdevkit/ldk-server/issues/204) (Postgres support) is part of the path forward but doesn't solve the fundamental Lightning-state-must-be-singleton problem.

## Log rotation gotcha

LDK Server does **not** rotate or truncate its own log file:

> *"A full disk can prevent the node from persisting channel state, **risking fund loss**."*

Operator must wire up `logrotate` and signal SIGHUP. This is the highest-leverage operator footgun in the docs — a passive failure mode (disk fills) cascades into an active failure mode (channel state can't persist) which cascades into fund loss.

## VSS — the upgrade path

[Versioned Storage Service (VSS)](https://lightningdevkit.org/blog/announcing-vss/) is LDK's client-server storage framework:

- Client-side encryption + key obfuscation.
- Real-time sync to avoid stale-backup fund loss.
- Stateless server, horizontally scalable.
- Default Postgres backend; JWT auth (or none for local dev).
- Self-host or use a third-party provider.

Available in LDK Node v0.4+; **not yet surfaced as a first-class config option in LDK Server's TOML** as of May 2026. It's the obvious next step for serious deployments — replaces "back up SQLite manually" with "stream encrypted state to a remote."

## Watchtowers

Not implemented. LDK Node issue [#110](https://github.com/lightningdevkit/ldk-node/issues/110) open since May 2023. LND has watchtower client/server, CLN has a plugin. Without a watchtower, LDK Server is a hot wallet that **must stay online or accept the channel-breach risk** of being offline while a counterparty broadcasts a revoked commitment.

## See also

- [[../../raw/articles/2026-05-26-ldk-server-operations.md|Operations guide source]]
- [[../topics/should-i-use-ldk-server.md|Should I use LDK Server?]]
- [[ldk-vs-ldk-node-vs-ldk-server.md]]
