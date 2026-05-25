---
title: "SChernykh Monero p2pool — design reference for p2poolv2"
publication: github.com/SChernykh/p2pool
url: https://github.com/SChernykh/p2pool
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [Monero, p2pool, SChernykh, uncle-blocks, sidechain]
---

# SChernykh Monero p2pool

Reference implementation in production for Monero since ~March 2021. Closest functional analog to p2poolv2; informs much of its design.

## Mechanism

- **PPLNS-by-difficulty**: payouts proportional to summed share difficulty within a rolling window. **Window: 2160 sidechain blocks (~6 hours)**, auto-adjustable.
- **Auto-adjusting window**: length self-tunes to balance payout frequency vs. payout size.
- **Uncle/orphan inclusion**: stale shares that lose the propagation race still earn full credit as uncles (vs. forrestv where orphans were lost).
- **Sidechain at 10s block time, multiple chains** (main / mini / nano): tiered sidechains let miners with different hashrates pick a target variance.
- **Zero-fee, no-minimum-payout architecture**: payouts merge into coinbase outputs of the eventually-found L1 block. No custodial accumulation.

## v4.0 hard fork (Oct 12, 2024)

Added merge-mining support for Tari, DarkFi, Townforge. Sidechain becomes a merge-mining anchor for smaller chains.

## Author credibility

SChernykh also authored **XMRig**, the dominant Monero mining client. Strong credibility in Monero mining community.

## Why it works for Monero where forrestv didn't for Bitcoin

| | Bitcoin (forrestv) | Monero (SChernykh) |
|---|---|---|
| Block time | 10 min | 2 min |
| Tx volume | High → coinbase blockspace expensive | Low → coinbase blockspace cheap |
| Mining base | ASIC-concentrated | RandomX (CPU/GPU) — diverse |
| Codebase | Python (no async, no tests) | C++ (proper async, full validation) |
| Uncle support | None — orphans lost | First-class — orphans paid |

Monero's block economics tolerate fat coinbases. Bitcoin's don't — which is why p2poolv2 had to add the atomic-swap edge to address what SChernykh's design inherited from forrestv but Monero's economics let it ignore.

## Direct lessons p2poolv2 took

1. **Uncle-block PPLNS** — direct port (p2poolv2 weight is 90%, max 3 uncles per share)
2. **Auto-adjustable window** — p2poolv2's work-bounded window (133k shares) is conceptually similar
3. **Sidechain as the truth source** — p2poolv2's libp2p-distributed share-chain
4. **Direct-coinbase payouts** — p2poolv2 inherits but adds the atomic-swap edge for the dust problem Monero doesn't have

## What p2poolv2 added

- **Atomic-swap edge** (HTLC outputs, Lightning bridge) — addresses Bitcoin-specific blockspace economics
- **DAG-lite chain-with-up-to-3-uncles** — slightly more general than Monero's chain-with-uncles
- **PPLNS-with-decay** as alt for small-state deployments

## See also

- [[2026-05-24-p2poolv2-lineage-and-history|p2poolv2 4-gen lineage]]
- [[2026-05-24-p2poolv2-uncle-blocks-wiki|p2poolv2 uncle rules]]
