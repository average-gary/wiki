---
title: "Hydrapool — 256 Foundation's PPLNS pool product"
publication: github.com/256foundation/hydrapool + 256foundation.org
url: https://github.com/256foundation/hydrapool
url2: https://256foundation.org/projects/hydrapool
type: article
ingested: 2026-05-24
quality: 5
credibility: high
confidence: high
tags: [Hydrapool, 256-foundation, PPLNS, public-audit-api, one-click-pool]
---

# Hydrapool

256 Foundation's pool-software pillar. One-click open-source Bitcoin mining pool. Built on `p2poolv2_lib` as its accounting engine but deployed as a single-operator centralized pool with non-custodial payouts.

## Identity

- Repo: `github.com/256foundation/hydrapool` (Rust, AGPL-3.0)
- Lead engineer: **Jungly** (same person as `pool2win` — p2poolv2 lead)
- Project manager: **econoalchemist**
- Status: Active. v2.5.8 as of mid-May 2026. ~184 commits.
- Live test: `pool.256foundation.org:3333` and `test.hydrapool.org`

## Accounting model

- **Modes**: Solo + PPLNS
- **Library**: pinned to `p2poolv2 lib v0.10.14` (uses the `simple_pplns/` distributor or `PPLNS-with-decay` per config — small-state path)
- **Payouts**: direct from coinbase, **no custody**
- **User cap**: ~100 users per coinbase tx (`blockmaxweight = 3,930,000` allows ~500 P2PKH outputs ≈ 68,208 wu, but throttled to 100 in deployment)

## Public PPLNS audit API

The differentiating feature: **`/pplns_shares` API endpoint** lets miners download and validate the entire share ledger externally. Optional time-range filter. This makes Hydrapool one of the first pools to publish its share-accounting state for public verification — a meaningful step beyond FPPS pools' login-gated dashboards.

## Difference from p2poolv2 protocol

| | p2poolv2 (protocol) | Hydrapool (256 Foundation deployment) |
|---|---|---|
| Operator model | None — peer-to-peer share-chain | Single operator (256 Foundation) |
| Share consensus | libp2p gossip + share-chain | Internal pool ledger using p2poolv2 lib |
| Custody | None (coinbase splits) | None (coinbase splits) |
| Audit | On-chain coinbase | On-chain coinbase + `/pplns_shares` API |
| User cap | 500+ via atomic swaps (target) | ~100 in coinbase, no atomic-swap edge |
| One-click deploy | No | Yes |

So Hydrapool is **a centralized PPLNS pool that uses p2poolv2's accounting code, with a public audit endpoint as its decentralization concession**. p2poolv2 the protocol is the more ambitious decentralized share-chain version — but harder to deploy.

## Position in the payout-schema landscape

Hydrapool fits between FPPS pools (custodial, opaque) and OCEAN's TIDES (non-custodial coinbase splits, PPLNS-style):

- Like TIDES: non-custodial, coinbase-output payout.
- Unlike TIDES: ships as one-click open-source software; not a standalone pool brand.
- Unique: publishes raw share-ledger data via API for external audit.

## See also

- [[2026-05-24-256-foundation-overview|256 Foundation overview]]
- [[../repos/2026-05-24-p2poolv2-accounting-modules|p2poolv2 accounting library Hydrapool depends on]]
- [[2026-05-24-p2poolv2-pplns-with-decay-wiki|PPLNS-with-decay (Hydrapool's small-state path)]]
