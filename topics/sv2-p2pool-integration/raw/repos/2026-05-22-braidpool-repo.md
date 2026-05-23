---
title: "braidpool/braidpool"
source_url: https://github.com/braidpool/braidpool
type: repo
ingested: 2026-05-22
quality: 4
confidence: high
tags: [braidpool, dag, share-chain, comparator]
---

# braidpool/braidpool

The principal architectural alternative to p2poolv2. Same problem (decentralized pool), different consensus shape.

## Goals
1. Lower variance for small miners
2. **Block sovereignty** — miners build their own blocks, just like in p2pool
3. Scalable payouts — constant blockspace regardless of miner count
4. Hashrate-derivative / futures-market support

## Tech
- DAG/braid share chain (vs. p2poolv2's chain-with-uncles)
- Gossip-based P2P share broadcast with validation
- FROST threshold Schnorr signatures for payouts (post-Taproot)
- Python simulator + Rust impl on CPUNet
- 138 stars, active dev

## Stratum V2 stance
Explicitly designed to **build on SV2 Template Provider**. The braid is the consensus layer; SV2 is the protocol layer between miners and the pool.

## Provenance
Bob McElrath et al. Cites p2pool as design precedent for block sovereignty.

## Comparison with p2poolv2
| Dimension | p2poolv2 | Braidpool |
|---|---|---|
| Share-chain shape | Chain-with-uncles (linear + uncles) | DAG ("braid") of beads |
| Consensus rule | Longest-share-chain | SSDW (Simple Sum of Descendant Work) |
| Payout | Direct coinbase to top-N miners | Threshold-signed (FROST) coinbase |
| PPLNS window | (TBD — not in TLA+ spec) | N=2016 (one difficulty epoch) |
| SV2 integration | Not yet (V1 only) | Designed in from day 1 |
| Maturity | Active dev, no production deploys | Earlier, sim + CPUNet |
