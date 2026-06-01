---
title: "moq-net 0.1.8 — protocol/session layer for MoQ"
source: https://github.com/moq-dev/moq/tree/main/rs/moq-net, https://crates.io/crates/moq-net
type: repo
tags: [moq, moq-net, moq-lite, moq-transport, web-transport-trait]
date: 2026-06-01
publication_date: 2026-06-01
quality: 5
confidence: high
agent: 2
summary: "moq-net v0.1.8 (2026-06-01). The protocol/session layer — does NOT depend on quinn or iroh directly; depends on web-transport-trait. Object hierarchy Origin → Broadcast → Track → Group → Frame, each with paired Producer/Consumer types. Internal modules `ietf` and `lite` cover both wire protocols, negotiated at session setup. Async-first on tokio; transitioning to poll_xxx via kio for custom executor support."
---

# moq-net — the transport-agnostic MoQ engine

## Crate metadata

- **Version**: 0.1.8 (2026-06-01)
- **Description**: "real-time pub/sub with built-in caching, fan-out, and prioritization"
- **Direct deps**: `bytes, futures, kio, num_enum, rand, serde, serde_json, thiserror, tokio, tracing, web-async, web-transport-trait`
- **NOT depended on**: quinn, iroh, quiche directly

## Public modules

| Module    | Role |
|-----------|------|
| `client`  | Client-side session machinery |
| `server`  | Server-side session machinery |
| `session` | The shared state machine |
| `model`   | Origin / Broadcast / Track / Group / Frame types |
| `coding`  | Wire encoding |
| `error`   | Error taxonomy |
| `path`    | Path/namespace handling |
| `stats`   | Session metrics |
| `version` | Wire-version negotiation |

## Internal split: ietf vs lite

```
moq_net/
  src/
    ietf/   ← full IETF moq-transport
    lite/   ← simplified moq-lite (kixelated)
```

Negotiated at session setup; one wire dialect per session.

## Object model

```
Origin → Broadcast → Track → Group → Frame
```

Each with paired `Producer` / `Consumer` types. Cloning a `Producer` or `Consumer` yields independent handles sharing state — multiple subscribers, one source.

## Feature flags

Only `serde`, which is a legacy no-op.

## Async story

Currently async-first on tokio, but transitioning to `poll_xxx` via the `kio` crate to support custom executors and reduce tokio runtime coupling. Important for embedding in WASM or custom-runtime environments.

## Why this matters

The transport seam at `web-transport-trait` means **moq-net knows nothing about iroh**. Mounting it on iroh is a pure adapter concern (`web-transport-iroh`). For the GTX 1060 server, this means:

1. The MoQ protocol logic is the same regardless of transport
2. Replay/forensic tooling on raw QUIC moq-rs sessions transfers to iroh-mounted sessions
3. Migrating off iroh later is a feature flag flip
