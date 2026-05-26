---
title: "lightningdevkit/ldk-server — README & repo state"
source_url: https://github.com/lightningdevkit/ldk-server
type: repo
ingested: 2026-05-26
tags: [ldk-server, lightning, primary-upstream, status]
quality: 5
confidence: high
summary: Primary upstream repo for LDK Server. Pre-1.0, no tagged releases, explicitly "not tested for production use". 5-crate workspace exposing a gRPC API on top of LDK Node.
---

# lightningdevkit/ldk-server — README & repo state

## What it is

A ready-to-use Lightning Network node binary built on top of [[ldk-node|LDK Node]]. Goal: a daemon you can run and integrate with via a language-agnostic API rather than embedding LDK Node as a library.

## Workspace layout (5 crates)

- `ldk-server` — the daemon binary
- `ldk-server-cli` — CLI client (auto-discovers credentials when run locally)
- `ldk-server-client` — Rust client library
- `ldk-server-grpc` — generated gRPC types (Protocol Buffers)
- `ldk-server-mcp` — MCP (Model Context Protocol) bridge over the unary RPCs (LLM/agent integration)

## Status (snapshot 2026-05-26)

- **No tagged releases yet.** Explicitly WIP.
- README: *"APIs are under development. Expect breaking changes... Not tested for production use."*
- 449 commits, 56 stars, 45 forks, 16 open issues; very active in May 2026 (config hardening, Docker support added 2026-03-16, error sanitization, CLI fixes).
- Beta release tracking issue (#121) still has unchecked items: Postgres support, full Docker support, log rotation, channel events publishing, LSP forwarding history/accounting, formal release process.
- Top contributors: G8XSU (Gursharan Singh, 177), benthecarman (138), tnull (Elias Rohrer, 66), tankyleo, Anyitechs.

## Build & run

- Rust 1.85.0+; `cargo build --release` produces both `ldk-server` and `ldk-server-cli`.
- Daemon takes a single TOML config path.
- Default bind `127.0.0.1:3536`.

## Notable choices

- **gRPC, not REST.** Protocol Buffers over HTTP/2 + TLS. The only REST surface is `GET /metrics` (Prometheus).
- **MCP bridge** ships in-tree — unusual for a Lightning daemon, positions LDK Server for AI/agent integration.
- **Pre-1.0 dependency on LDK Node** — features land in ldk-node (e.g. splicing in v0.7.0) and flow up.

## See also

- [[wiki/concepts/ldk-vs-ldk-node-vs-ldk-server.md|LDK vs LDK Node vs LDK Server]] — the three-layer architecture.
- [[2026-05-26-ldk-server-api-guide.md]] — full gRPC method catalog.
- [[2026-05-26-ldk-server-operations.md]] — operator footguns.
