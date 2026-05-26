---
title: "Should I use LDK Server? — decision guide (May 2026)"
type: topic
created: 2026-05-26
updated: 2026-05-26
confidence: high
tags: [decision, comparison, lnd, cln, eclair, status]
---

# Should I use LDK Server? — decision guide (May 2026)

A synthesis across the May 2026 state of the project, the operational pitfalls, and the alternatives.

## TL;DR

**Don't run LDK Server in production today** unless you can absorb breakage and operate Lightning at depth. Use LND or CLN. Track LDK Server for the moment it tags 1.0 and matures the missing pieces (Postgres, watchtowers, log rotation, granular auth, HA story).

**Do** evaluate LDK Server today if any of these are true:
- You're prototyping a new product surface (e.g., MCP/agent-driven LN).
- You want BOLT12 / async-payments / splicing on the bleeding edge.
- You're already using LDK Node embedded and want to factor it out into a daemon.
- You want a Protobuf-first, language-agnostic API and don't want LND's macaroon model.

## Status as of May 2026

- **Pre-1.0**, no tagged releases. README says "not tested for production use."
- Heavy May 2026 commit activity (config hardening, Docker, error sanitization, CLI fixes) — signals an approaching first beta release.
- Beta milestone tracker [#121](https://github.com/lightningdevkit/ldk-server/issues/121) has unchecked items: Postgres, log rotation, channel events publishing, LSP forwarding history/accounting, formal release process.

See [[../../raw/repos/2026-05-26-ldk-server-readme.md|the README/repo state]].

## What LDK Server gives you

- A daemon you can run as a sidecar — same niche as LND, but Protobuf-first.
- ~40 gRPC RPCs (see [[../concepts/grpc-api-surface.md|gRPC API surface]]).
- BOLT12, hold invoices, splicing, async payments — newer BOLTs land in LDK first.
- MCP bridge baked in for agent integration.
- Single 32-byte HMAC API key, self-signed TLS by default.

## Where LND / CLN currently win

| Concern | LDK Server | LND | CLN |
|---|---|---|---|
| Production track record | None | 5+ years | 5+ years |
| Watchtowers | None ([#110](https://github.com/lightningdevkit/ldk-node/issues/110)) | Built-in | Plugin |
| Native Tor | No ([#178](https://github.com/lightningdevkit/ldk-node/issues/178), can use SOCKS) | Yes | Yes |
| Postgres / HA | No ([#204](https://github.com/lightningdevkit/ldk-server/issues/204)) | LND HA via lncli/etcd | Postgres + replication patterns |
| Log rotation | Manual logrotate + SIGHUP | Built-in | Built-in |
| Auth granularity | Single HMAC key | Macaroons | Rune-based |
| Manual channel acceptance | Open issue ([ldk-server #70](https://github.com/lightningdevkit/ldk-server/issues/70)) | Yes | Yes |
| Live TLS reload | No (restart needed) | Yes | Yes |

See [[../concepts/persistence-and-backup.md|persistence and backup]] for the operator-facing footguns.

## Where LDK Server is ahead

- **BOLT12 / Offers**: shipping in LDK before peer implementations finished it.
- **Async payments**: serve and pay static invoices (ldk-node v0.7.0).
- **Splicing**: experimental, but shipping (ldk-node v0.7.0).
- **MCP integration**: a Lightning daemon you can drive from an LLM agent out of the box.
- **Smaller surface, smaller footprint** for embedded use cases that don't need watchtowers/HA.

## Production-validated pattern: embed LDK Node, not LDK Server

The largest visible LDK production deployments today **embed LDK Node directly**, not LDK Server:

- [[../../raw/articles/2026-05-26-fedimint-gateway-ldk-node-case-study.md|Fedimint Gateway]] — single-binary gateway, drove hold-invoice API upstream.
- Alby Hub — Go + LDK Node via custom UniFFI.
- Bitkit — React Native + react-native-ldk.
- Lightspark Sparknodes — multiple LDK instances per process.

LDK Server is the productization of that pattern: stop re-embedding, run the standard daemon. Until the daemon is production-ready, the "embed LDK Node into your own daemon" pattern remains the safer way to get LDK in production.

## Decision matrix

| If you... | Use |
|---|---|
| Need to run LN in production today, low risk tolerance | **LND** or **CLN** |
| Need BOLT12 / async / splicing today, can absorb breakage | **LDK Server** (or embed LDK Node) |
| Are building a mobile / desktop wallet | **LDK Node** (or LDK direct) |
| Are building a payment-processor backend | **LND** for now; revisit LDK Server post-1.0 |
| Want LN driven by an AI agent | **LDK Server** (MCP bridge) |
| Need multi-tenant LN at scale | **LDK** direct (Sparknodes pattern) |

## See also

- [[../concepts/ldk-vs-ldk-node-vs-ldk-server.md|LDK vs LDK Node vs LDK Server]]
- [[../concepts/grpc-api-surface.md|gRPC API surface]]
- [[../concepts/persistence-and-backup.md|Persistence and backup]]
- [[../../raw/repos/2026-05-26-ldk-server-readme.md]]
- [[../../raw/articles/2026-05-26-ldk-server-operations.md]]
