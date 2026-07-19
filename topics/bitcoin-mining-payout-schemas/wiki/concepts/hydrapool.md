---
title: Hydrapool — 256 Foundation pool
category: concept
created: 2026-05-24
confidence: high
tags: [Hydrapool, 256-foundation, PPLNS, public-audit-api, p2poolv2-lib]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-24-256-foundation-overview.md"
  - "raw/articles/2026-05-24-hydrapool-256-foundation.md"
  - "raw/articles/2026-05-24-p2poolv2-pplns-with-decay-wiki.md"
---

# Hydrapool

256 Foundation's pool-software pillar. One-click open-source Bitcoin mining pool built on the `p2poolv2_lib` library.

## Identity

- Repo: `github.com/256foundation/hydrapool` (Rust, AGPL-3.0)
- Lead engineer: **Jungly** (also `pool2win`, the p2poolv2 lead)
- Project manager: **econoalchemist**
- Status: Active. v2.5.8 (~mid-May 2026). 184 commits, 45 stars.
- Live test: `pool.256foundation.org:3333` and `test.hydrapool.org`

## Accounting model

- **Modes**: Solo + PPLNS
- **Library**: pinned to `p2poolv2 lib v0.10.14` — uses either `simple_pplns/` or PPLNS-with-decay (small-state path) per config.
- **Payouts**: direct from coinbase, **non-custodial**.
- **User cap**: ~**100 users per coinbase tx**.
- **Coinbase tuning**: `blockmaxweight = 3,930,000` allows ~500 P2PKH outputs ≈ 68,208 wu.

## Public PPLNS audit API (the differentiator)

`/pplns_shares` API endpoint lets miners download and validate the entire share ledger externally. Optional time-range filter.

This is one of the first pools to publish its share-accounting state for public verification — a meaningful step beyond:

- **FPPS pools** (login-gated dashboards only).
- **TIDES (OCEAN)** (auditable via on-chain coinbase, but share-log not via public API).
- **DMND SLICE** (similar coinbase-auditable, but no public share-log API).

## Difference from p2poolv2 protocol

| | p2poolv2 (protocol) | Hydrapool (256 Foundation deployment) |
|---|---|---|
| Operator model | None — peer-to-peer share-chain | Single operator (256 Foundation) |
| Share consensus | libp2p gossip + share-chain | Internal pool ledger using p2poolv2 lib |
| Custody | None (coinbase splits) | None (coinbase splits) |
| Audit | On-chain coinbase | On-chain coinbase + `/pplns_shares` API |
| User cap | 500+ via atomic swaps (target) | ~100 in coinbase, no atomic-swap edge |
| One-click deploy | No | Yes |

Hydrapool is a **centralized PPLNS pool that uses p2poolv2's accounting code, with a public audit endpoint as its decentralization concession**. p2poolv2 the protocol is the more ambitious decentralized share-chain version — but harder to deploy.

## Why this matters

**The "256 Foundation runs p2poolv2" framing is wrong.** What's actually shipping:

1. **p2poolv2** = independent decentralized share-chain protocol (pool2win, no foundation funding visible).
2. **Hydrapool** = 256 Foundation's pool-software product. Uses `p2poolv2_lib` as a library. Centralized operator, non-custodial payouts, public audit API.

Both are led by the same engineer (Jungly = pool2win), so the engineering-relationship is real, but they are **two distinct systems** with different deployment philosophies.

## Position in the payout-schema landscape

Sits between FPPS pools (custodial, opaque) and OCEAN TIDES (non-custodial, on-chain auditable):

- Like TIDES: non-custodial, coinbase-output payout.
- Unlike TIDES: ships as one-click open-source software, not a standalone pool brand.
- **Unique**: publishes raw share-ledger data via API for external audit.

If miners adopt Hydrapool widely, the result is **many small operator-run pools** each running the same audited code — potentially the most realistic path to pool decentralization in the medium term (vs. p2poolv2's ambitious peer-to-peer share-chain).

## Sources

- [[../../raw/articles/2026-05-24-hydrapool-256-foundation|Hydrapool overview article]]
- [[../../raw/articles/2026-05-24-256-foundation-overview|256 Foundation overview]]
- [[../../raw/articles/2026-05-24-p2poolv2-pplns-with-decay-wiki|PPLNS with Decay (Hydrapool's small-state path)]]

## See also

- [[p2poolv2-accounting|p2poolv2 accounting deep-dive]]
- [[p2pool-share-chain|p2pool / p2poolv2 share-chain]]
- [[../topics/p2poolv2-and-256-foundation|p2poolv2 ↔ 256 Foundation]]
- [[../topics/payout-design-space|Payout Design Space]]
