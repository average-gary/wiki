---
title: "LDK vs LDK Node vs LDK Server"
type: concept
created: 2026-05-26
updated: 2026-05-26
confidence: high
tags: [architecture, terminology, ldk]
---

# LDK vs LDK Node vs LDK Server

The three layers are commonly conflated. They are distinct artifacts with different audiences.

## Layer 1 — LDK (`rust-lightning`)

The Lightning Development Kit *library*. A toolkit of protocol primitives:

- BOLT state machines (commitment txs, HTLCs, channel updates)
- Onion routing, gossip parsing, pathfinding
- Persistence is your problem; chain access is your problem; the daemon loop is your problem.

Audience: developers willing to wire everything themselves to fit a specific embedded environment (custom signer, custom storage, multi-tenant runtime).

## Layer 2 — LDK Node

A Rust crate (`ldk-node`) that bundles LDK + a sane default for everything LDK leaves open:

- LDK protocol layer
- BDK on-chain wallet
- Chain source: Bitcoin Core RPC / Electrum / Esplora (pick one)
- Gossip: P2P or Rapid Gossip Sync
- Persistence: SQLite, filesystem, or VSS
- A single `Node` + `Builder` API
- UniFFI bindings → Swift / Kotlin / Python

Audience: developers building wallets / daemons / mobile apps that want a turnkey LN node *embedded in their own process*. Production users: Fedimint Gateway, Alby Hub, Bitkit, Lightspark Sparknodes.

## Layer 3 — LDK Server

A *binary* (`ldk-server`) that wraps LDK Node and exposes it over **gRPC** (Protocol Buffers, HTTP/2 + TLS, HMAC-SHA256 auth). The daemon you run as its own process and talk to from any language.

Audience: developers who want LN-as-a-service inside their stack without writing Rust against LDK Node. Same niche LND occupies, but with a Protobuf API instead of LND's gRPC + REST surface.

Status (May 2026): pre-1.0, no tagged releases, explicitly *not tested for production use*. See [[../../raw/repos/2026-05-26-ldk-server-readme.md|the README]].

## Why this matters

| If you're... | Pick |
|---|---|
| Embedding LN in a mobile app or custom daemon | **LDK Node** (or LDK if you need full control) |
| Running an LN node as a sidecar to a backend service | **LDK Server** (today: experimental; LND/CLN are safer choices for prod) |
| Building a payment-processor backend / e-commerce LN integration | **LDK Server** if pre-1.0 risk is acceptable; otherwise LND/CLN |
| Doing protocol research, custom signer, multi-tenant LN | **LDK** directly |

## Production validation

Most public case studies are **LDK Node embeddings**, not LDK Server:

- [[../../raw/articles/2026-05-26-fedimint-gateway-ldk-node-case-study.md|Fedimint Gateway]] — LDK Node inside the gateway binary.
- Alby Hub — LDK Node + custom UniFFI from Go backend.
- Bitkit — LDK Node + react-native-ldk.
- Lightspark Sparknodes — multiple LDK *instances* in a single process.

LDK Server is the same idea formalized: stop re-embedding, run the standard daemon. No public LDK Server production users found yet.

## See also

- [[../../raw/repos/2026-05-26-ldk-server-readme.md|LDK Server README]]
- [[../../raw/repos/2026-05-26-ldk-node-overview.md|LDK Node overview]]
- [[grpc-api-surface.md|gRPC API surface]]
- [[../topics/should-i-use-ldk-server.md|Should I use LDK Server?]] — decision guide
