---
title: The Payout Design Space (synthesis)
category: topic
created: 2026-05-23
confidence: high
tags: [synthesis, design-space, FPPS, PPLNS, TIDES, SLICE, eHash, p2pool]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-23-b10c-mining-centralization-2025.md"
  - "raw/articles/2026-05-23-dmnd-demand-pool.md"
  - "raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment.md"
  - "raw/articles/2026-05-23-ocean-tides-spec.md"
  - "raw/papers/2026-05-23-chatzigiannis-2022-diversification.md"
  - "raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis.md"
  - "raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility.md"
  - "raw/repos/2026-05-23-hashpool-vnprc.md"
  - "raw/repos/2026-05-23-p2pool-and-p2poolv2.md"
  - "raw/repos/2026-05-23-stratum-v2-spec.md"
---

# The Payout Design Space

Synthesis of the payout-schema landscape. The 2024-2026 wave (TIDES, SLICE/PPLNS-JD, eHash, p2poolv2) is best understood not as five competing schemes but as **a multi-dimensional decentralization stack** where each project removes a different trust assumption from FPPS.

## What FPPS bundles

A standard FPPS pool combines five distinct services:

1. **Share counting** — pool counts your shares.
2. **Variance smoothing** — pool pays expected value daily.
3. **Custody** — pool holds your BTC until threshold.
4. **Template construction** — pool decides which transactions go in the block.
5. **Network connectivity** — pool runs the Bitcoin node.

Each is a discrete trust assumption. The 2024-2026 wave unbundles them.

## Decomposition matrix

| | Share count | Variance | Custody | Template | Node |
|---|---|---|---|---|---|
| **FPPS** | Pool | Pool | Pool | Pool | Pool |
| **OCEAN TIDES** | Pool | Miner | **None (coinbase)** | Pool | Pool |
| **OCEAN TIDES + DATUM** | Pool | Miner | **None** | **Miner** | Pool |
| **DMND SLICE** | Pool | Miner | **None** | **Miner (JD)** | Pool |
| **hashpool eHash** | **Mint (blind)** | **Tradeable** | **Mint reserves** | Pool | Pool |
| **p2poolv2** | **Share-chain** | Miner | **None** | **Miner** | **Miner** |

Bold cells = removed trust point relative to FPPS.

## What each project actually removes

- **TIDES**: removes pool's custody of payouts. Coinbase splits go direct from generation tx.
- **DATUM**: removes pool's choice of block content. Miner builds template; pool sees only merkle branches.
- **TIDES + DATUM together (OCEAN)**: pool keeps share counting; miner has custody and template control.
- **SLICE / PPLNS-JD (DMND)**: same as TIDES + DATUM in spirit, but uses SV2 Job Declaration end-to-end. JDS is the protocol-defined version of DATUM.
- **eHash (hashpool)**: removes pool's per-miner ledger. Pool mint sees only blinded share commitments. Trades pool ledger trust for **mint solvency trust** (different problem).
- **p2poolv2**: removes the pool operator entirely. Share-chain consensus + coinbase outputs to top-N miners + atomic-swap support transactions for small miners.

## The "best of all worlds" question

Each project hits 1-2 dimensions but not all 5:

- **Want non-custodial + miner-template + no operator?** → p2poolv2. Cost: highest stale rate, hardest UX, smallest hashrate.
- **Want non-custodial + miner-template + good UX + production?** → DMND SLICE or OCEAN TIDES + DATUM.
- **Want privacy of submission?** → eHash (mint can't link issuance to redemption identity).
- **Want variance as tradeable asset?** → eHash with secondary market (theoretical).
- **Want simplicity + predictable cashflow?** → FPPS (and accept all its trust assumptions).

**No scheme dominates on all dimensions.** This is the wiki's central insight.

## The Stratum V2 + JD enabling layer

None of TIDES + DATUM, SLICE, eHash would be operationally feasible at scale without **Stratum V2 + Job Declaration**:

- SV2 binary framing → 1-3 ms job-switch vs. 200-300 ms on V1 → low-stale rate makes PPLNS-style schemes economically viable.
- JD protocol → standard mechanism for "miner builds block, pool counts shares" — required by SLICE, used optionally by DATUM/TIDES, prerequisite for hashpool's SV2 stack.
- End-to-end encryption → eliminates SV1 hash-hijack attack surface.

The 2024-2026 wave is, in effect, **what becomes possible once SV2 ships**. SRI v1.0 released March 2024 — coinciding with OCEAN's launch, not by accident.

## Variance as the economic Schelling point

Across all schemes, **variance allocation** is the deepest design choice:

1. **Pool eats variance** (FPPS, PPS+) — operator-reserve premium baked into fee.
2. **Miner eats variance** (PPLNS, TIDES, SLICE, p2poolv2) — fee lower, but miner needs working capital.
3. **Variance as tradeable asset** (eHash, theoretical) — market clears variance pricing per share-difficulty bucket.

Chatzigiannis et al. 2022 argue (3) is the limit toward which mining converges as the field matures.

## Why FPPS still dominates (despite all of the above)

- ~95% of network hashrate is on FPPS-class pools as of May 2026 (mempool.space).
- Reasons: simplicity, daily cashflow, regulatory familiarity, miner inertia.
- Decline scenarios: post-subsidy fee era (2032+), regulatory pressure on custodial pools, KYC requirements, public-pool censorship events.

## Open questions

1. Will OCEAN's TIDES + DATUM combo or DMND's SLICE/JD achieve >5% network share by 2027?
2. Will hashpool ship a production mainnet mint?
3. Will Fedimint-as-mining-pool emerge as a federated alternative to single-mint hashpool?
4. Will p2poolv2 + atomic-swap support transactions actually solve the dust problem at scale?
5. Does eHash's secondary market for unmatured tokens ever clear, and at what haircut?

## Sources

This article synthesizes [[../../raw/_index|all 14 ingested sources]]; primary citations:

- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]]
- [[../../raw/papers/2026-05-23-schrijvers-2016-incentive-compatibility|Schrijvers et al. FC'16]]
- [[../../raw/papers/2026-05-23-chatzigiannis-2022-diversification|Chatzigiannis et al. 2022]]
- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN TIDES spec]]
- [[../../raw/articles/2026-05-23-dmnd-demand-pool|DMND / Demand Pool]]
- [[../../raw/repos/2026-05-23-hashpool-vnprc|hashpool]]
- [[../../raw/repos/2026-05-23-stratum-v2-spec|Stratum V2 spec]]
- [[../../raw/repos/2026-05-23-p2pool-and-p2poolv2|p2pool / p2poolv2]]
- [[../../raw/articles/2026-05-23-b10c-mining-centralization-2025|b10c centralization 2025]]
- [[../../raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment|Heatpunks empirical 2025]]

## See also

- [[../concepts/payout-schema-taxonomy|Payout Schema Taxonomy]]
- [[sv2-jd-and-payout-decoupling|SV2 JD ↔ Payout Decoupling]]
- [[decentralization-and-pool-concentration|Decentralization & Pool Concentration]]
- [[../decisions/custody-tradeoffs|Custody Tradeoffs]]
