---
title: Payout Schema Taxonomy
type: concept
created: 2026-05-23
updated: 2026-05-23
confidence: high
tags: [PPS, PPLNS, FPPS, PPS+, taxonomy]
---

# Payout Schema Taxonomy

Bitcoin pool payout schemes form three categories defined by **who absorbs variance**:

## 1. Pool-eats-variance (deterministic to miner)

- **PPS** — Pay Per Share. `R = B · p`, `p = 1/D`. Pool pays expected value per share immediately. Operator absorbs all variance; needs reserves. High fee. Subsidy only.
- **FPPS** — Full PPS. PPS + tx fees averaged over a window. Most common at large pools (Foundry, AntPool, F2Pool, ViaBTC). Fee 2-4%. *See [[fpps]].*
- **PPS+** — Hybrid. Block subsidy as PPS (smooth) + tx fees PPLNS-style (lumpy). F2Pool, AntPool variant.

Operator-reserve requirement is the structural barrier — only large/well-capitalized pools can offer FPPS sustainably.

## 2. Miners-eat-variance (lumpy, hop-resistant)

- **Proportional** — `R = B · (n/N)` over the round. Hop-vulnerable. Replaced by PPLNS post-2011.
- **PPLNS** — Pay Per Last N Shares. Window of last N shares paid on block-find. Per-share expected payout independent of round position → hop-resistant. Variants: sharp 0/1 cutoff, exponential decay (geometric), linear decay. *See [[pplns]].*
- **Slush score-based** — PPLNS with exponential-decay weight. Now operationally PPLNS.
- **TIDES** — OCEAN's PPLNS with `N = 8 × current_block_difficulty`, full-resolution share log, non-custodial coinbase payout. *See [[tides]].*
- **SLICE / PPLNS-JD** — DMND's PPLNS bound to SV2 Job Declaration. *See [[pplns-jd]].*
- **p2pool / p2poolv2 share-chain** — on-chain PPLNS without a custodian. *See [[p2pool-share-chain]].*
- **Geometric / DGM** (Rosenfeld) — tunable variance via parameters `f`, `c`, `o`. DGM was production at BTCDig 2013.

## 3. Variance-as-tradeable-asset

- **eHash / hashpool** — Cashu blind-signature mint issues a bearer token per share. Token accrues BTC value during a maturity period; miner can hold (capture luck upside) or sell early on a secondary market (variance offloaded to buyer). Pool maintains no per-miner ledger. *See [[ehash]].*

## Solo

- **SOLO** — full block reward to lucky miner; no smoothing.

## Cross-cutting axes

| Axis | PPS | FPPS | PPS+ | PPLNS | TIDES | SLICE | eHash | p2poolv2 |
|---|---|---|---|---|---|---|---|---|
| Variance to | Pool | Pool | Pool (subsidy) / Miner (fees) | Miner | Miner | Miner | Tradeable | Miner |
| Custody | Pool | Pool | Pool | Pool | None (coinbase) | None (coinbase) | Mint reserves | None (coinbase) |
| Hop-resistant | N/A | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| IC-provable (Schrijvers) | Yes | Yes | Yes | Yes (parametric) | Likely | Likely | Open | Yes |
| Operator reserve req | High | High | Medium | Low | None | None | Mint solvency | None |
| Auditable on-chain | No | No | No | No | Yes | Yes | DLEQ | Yes |
| Template control | Pool | Pool | Pool | Pool | Pool or DATUM | Miner (JD) | Pool | Miner |

## Sources

- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]] — formal taxonomy origin
- [[../../raw/articles/2026-05-23-hashrate-index-pintos-payout-guide|Pintos / Hashrate Index]] — practitioner framing
- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN TIDES doc]]
- [[../../raw/articles/2026-05-23-dmnd-demand-pool|DMND / SLICE]]
- [[../../raw/repos/2026-05-23-hashpool-vnprc|hashpool README]]

## See also

- [[../topics/payout-design-space|Payout Design Space (synthesis)]]
- [[../topics/sv2-jd-and-payout-decoupling|SV2 Job Declaration ↔ Payout Decoupling]]
