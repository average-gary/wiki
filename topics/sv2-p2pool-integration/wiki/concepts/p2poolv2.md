---
title: p2poolv2
type: concept
created: 2026-05-22
updated: 2026-05-22
verified: 2026-05-22
volatility: hot
confidence: high
sources:
  - "[[raw/repos/2026-05-22-p2poolv2-repo|p2poolv2 repo]]"
  - "[[raw/repos/2026-05-22-p2poolv2-module-map|p2poolv2 module map]]"
  - "[[raw/papers/2026-05-22-p2poolv2-tla-sharechain-spec|p2poolv2 TLA+ spec]]"
  - "[[raw/articles/2026-05-22-p2poolv2-architecture-docs|p2poolv2 architecture docs]]"
  - "[[raw/articles/2026-05-22-p2poolv2-releases|p2poolv2 releases]]"
  - "[[raw/articles/2026-05-22-p2poolv2-wiki-comparison-datum-sv2|p2poolv2 wiki: Comparison with DATUM and SV2]]"
---

# p2poolv2

p2poolv2 is a Rust rewrite of [[p2pool-history|the original P2Pool]] (Forrest Voight, 2011) that implements a fully decentralized Bitcoin mining pool: shares accounted on a peer-to-peer share chain, no custodial pool wallet, direct-to-coinbase payouts.

Canonical repo: `github.com/p2poolv2/p2poolv2`. (Some sources reference `pool2win/p2pool-v2` — this is a related/legacy account name; the canonical org is `p2poolv2`.) AGPL-3.0, MSRV Rust 1.88, edition 2024.

## Core mechanisms

1. **Share chain with uncles** — a parallel, faster-than-Bitcoin chain where every share is a near-block (carries its own coinbase, witness commitment, and full block-shape). Finding a real Bitcoin block is a side-effect of share validation. Uncle support recovers near-misses and reduces orphan rate.
2. **Direct coinbase payouts** to top-N miners — non-custodial, no pool wallet ever holds funds.
3. **Atomic swaps** for paying smaller miners (those below the top-N coinbase cutoff).
4. **Market-maker participation** — third parties can buy small-miner shares for liquidity.

## Workspace shape (7 crates)

- `bitcoindrpc` — Bitcoin Core RPC client
- `p2poolv2_config`, `p2poolv2_lib`, `p2poolv2_node`, `p2poolv2_cli`, `p2poolv2_api`, `p2poolv2_tests`

## Core modules in `p2poolv2_lib`

- `shares/` — share chain consensus (`chain/`, `validation/`, `share_block/`, `compact_block.rs`, `share_commitment.rs`, `witness_commitment.rs`, `handle_stratum_share.rs`)
- `stratum/` — V1 stratum server (`server.rs`, `session.rs`, `zmq_listener.rs`, `difficulty_adjuster/`, `work/`)
- `node/` — libp2p peer / gossip
- `accounting/` — share accounting and payout selection
- `store/` — rocksdb interface

## Networking

- **libp2p 0.53** with TCP, DNS, Tokio, Noise, Yamux, Kademlia, secp256k1 — for share gossip and peer discovery.
- Bitcoin layer: `bitcoin 0.32.5`, `bitcoinconsensus 0.106.0`, `zmq 0.10`. Templates today come from Bitcoin Core via **getblocktemplate RPC + ZMQ topics** (`stratum/zmq_listener.rs`).

## Formal specification

A single TLA+ file at `spec/ShareChain.tla` formally specifies share generation, validation, the longest-share-chain rule, and uncle organization. See [[raw/papers/2026-05-22-p2poolv2-tla-sharechain-spec|the TLA+ spec]]. Notably, payout, network protocol, and SV2 integration are **not** formally specified — a research gap.

## Status of SV2 integration

**None today.** [[sv2-integration-surface|See SV2 integration analysis]]. The project's Cargo.toml has no `stratum-common`, `binary_sv2`, `roles_logic_sv2`, `stratum-core`, or sv2-apps dependencies. The repo's GitHub wiki page "Using Stratum v2" describes SV2 integration as future-aspirational, with no timeline. Recent release work focuses on production-hardening the V1 stratum surface (extranonce.subscribe in v0.10.12, share-chain sync in v0.10.11, perf in v0.10.13).

## Differentiation from SV2 + DATUM

p2poolv2's central thesis is that SV2 and DATUM decentralize *template construction* but still route *payouts* through centralized servers. From the [[raw/articles/2026-05-22-p2poolv2-wiki-comparison-datum-sv2|project's own framing]]:

> The pay out distribution is decided by the centralised pools, with the template builders having no visibility on the share accounting.

p2poolv2 goes further by making **share accounting itself a peer-to-peer consensus problem**, treating the centralized share ledger as an attack surface (selective payout exclusion).

## See also

- [[p2pool-history|P2Pool lineage]] — Forrest Voight (2011) → SChernykh (Monero, 2021) → Braidpool / p2poolv2 (2024+)
- [[braidpool|Braidpool]] — DAG-based alternative
- [[ocean-datum|OCEAN DATUM]] — V1-based decentralized-template alternative
- [[sv2-integration-surface|SV2 integration surface]]
- [[../topics/integration-paths|Integration paths]]
