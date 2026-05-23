---
title: "p2poolv2_lib/src — module map"
source_url: https://github.com/p2poolv2/p2poolv2/tree/main/p2poolv2_lib/src
type: code-tree
ingested: 2026-05-22
quality: 5
confidence: high
tags: [p2poolv2, code-architecture, integration-surface]
---

# p2poolv2_lib/src — module map

The integration map. The boundary between the V1-only stratum module and the share-chain core is the seam where SV2 integration would land.

## Top-level modules
- `accounting/` — share accounting / payout selection
- `command/` — CLI command handlers
- `middleware/` — tower-style middleware layers
- `node/` — libp2p node, peer management
- `service/` — service composition
- `shares/` — share-chain consensus
- `store/` — rocksdb interface
- `stratum/` — V1 stratum server (miner-facing)
- `utils/`
- Plus: `auth.rs`, `pool_difficulty.rs`, `monitoring/`

## `stratum/` subtree (V1)
- `server.rs` — stratum V1 listener
- `session.rs` — per-connection session
- `messages.rs`
- `client_connections.rs`
- `emission.rs` — work emission
- **`zmq_listener.rs`** — consumes Core block-template ZMQ topics directly (or hashblock for tip change)
- `difficulty_adjuster/`
- `message_handlers/`
- `work/`

The presence of `zmq_listener.rs` confirms the stratum server consumes templates from Bitcoin Core via ZMQ, *not* via SV2 Template Provider.

## `shares/` subtree
- `chain/` — share-chain
- `genesis/`
- `share_block/` — full block-shaped share objects
- `transactions/`
- `validation/`
- `coinbaseaux_flags.rs`
- `compact_block.rs`
- `extranonce.rs`
- **`handle_stratum_share.rs`** — entry point from stratum server into share-chain
- `share_commitment.rs` — share commitment scheme
- `witness_commitment.rs`

This is a **GBT-style share chain**: shares are full block-shaped objects with their own coinbase + witness commitment. Same paradigm as P2Pool v1 — every share is a near-block, finding a real block is a side-effect of share validation.

## SV2 plug-points (proposed)

1. **Template ingest** → replace `stratum/zmq_listener.rs` with an SV2 TP client. Adopt sv2-apps's `TemplateProviderType` enum from `stratum-apps/src/tp_type.rs`.
2. **Miner-facing SV2 server** → add sibling `stratum_v2/` module mirroring `stratum/`, terminate SV2 mining-protocol channels via stratum-core, funnel valid submissions into the *same* `shares::handle_stratum_share` entry point.
3. **JDS backend** → implement sv2-apps's `JobValidationEngine` trait so a JDS validates declared custom jobs against p2poolv2's share-chain rules. This is the **highest-leverage** integration — any SV2 miner with a JDC can point at p2poolv2 without p2poolv2 owning the miner-facing SV2 stack.
4. **Coinbase outputs / share commitment** — `shares::share_commitment.rs` + `coinbaseaux_flags.rs` need to interop with SV2's `CoinbaseOutputDataSize` and JDS coinbase-output negotiation.
