---
title: "lightningdevkit/ldk-node — Overview (the layer LDK Server is built on)"
source_url: https://github.com/lightningdevkit/ldk-node
type: repo
ingested: 2026-05-26
tags: [ldk-node, lightning, library, architecture]
quality: 5
confidence: high
summary: LDK Node is a self-custodial Lightning node "in library form" — wires LDK + BDK + chain source + gossip + persistence behind a single Node/Builder. Exposed via UniFFI (Swift/Kotlin/Python). LDK Server wraps it and adds a gRPC daemon.
---

# LDK Node

> *"A self-custodial Lightning node in library form."*

LDK Server is a thin daemon over LDK Node — every server feature inherits its semantics from this layer.

## What LDK Node bundles

- **`lightning` (rust-lightning)** — protocol primitives
- **BDK** — on-chain wallet
- **Chain source** — pluggable: Bitcoin Core RPC, Electrum, or Esplora
- **Gossip** — P2P or Rapid Gossip Sync (RGS)
- **Entropy** — raw bytes or BIP39
- **Persistence** — SQLite (rusqlite), filesystem, or custom (`KVStore` trait); VSS support via `vss-client-ng`
- **Background processor** — `lightning-background-processor`
- **Block sync** — `lightning-block-sync`

## API shape

The whole crate exposes a single `Node` plus `Builder`:

- `Node::start()`, `Node::stop()`
- `Node::open_channel()`, `Node::close_channel()`
- `Node::send()`, `Node::receive()`
- Modules: `config`, `graph`, `io`, `liquidity`, `logger`, `payment`

## Bindings

UniFFI generates Swift, Kotlin, Python bindings. Used by mobile wallets (Bitkit, Alby Hub via custom UniFFI) and embedded daemons (Fedimint Gateway).

## Release timeline (relevant to LDK Server)

- **v0.5.0 (May 2025)** — first release on stable LDK `lightning` v0.1; bLIP-51/LSPS1 client; experimental bLIP-52/LSPS2 service; Electrum sync; BDK v1.0.
- **v0.6.x** — BDK 2.0 fix releases.
- **v0.7.0 (Dec 2025)** — experimental **channel splicing**; **async payments** (serve and pay static invoices); Bitcoin Core REST chain backend; VSS encryption upgrades; LSPS2 'client-trusts-LSP' model; LDK 0.2; BDK 2.2; MSRV 1.85.

LDK Server tracks ldk-node releases; major user-visible features (splicing, async payments, BOLT12) land in ldk-node first.

## Known gaps (as of May 2026)

Long-standing open issues that LDK Server inherits:
- **#110 Watchtowers** — open since May 2023.
- **#178 Native Tor** — no native SOCKS proxy in ldk-node.
- **#43 Lightweight "handle single htlc only" mode** — open since Mar 2023.
- **#321 BOLT12 Offers return semantics** — open since Jul 2024.
- **#408 Secondary storage for network graph** — open Nov 2024.
- **#815 Probing service**, **#863 Postgres** — high-traffic, unmerged.

## See also

- [[2026-05-26-ldk-server-readme.md]] — the daemon wrapper
- [[wiki/concepts/ldk-vs-ldk-node-vs-ldk-server.md|LDK vs LDK Node vs LDK Server]]
- [[wiki/concepts/persistence-and-backup.md|Persistence and backup]]
