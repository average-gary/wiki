---
title: Decentralization & Pool Concentration
type: topic
created: 2026-05-23
confidence: high
tags: [centralization, b10c, Foundry, AntPool, proxy-pooling]
---

# Decentralization & Pool Concentration

The empirical context for why payout-scheme reform matters in the 2024-2026 window.

## State of pool concentration (May 2026)

From [[../../raw/articles/2026-05-23-mempool-space-mining-dashboard|mempool.space]] (1-week window, ~979 EH/s network):

| Pool | Blocks (1 wk) | % |
|---|---|---|
| Foundry USA | 311 | 30.88 |
| AntPool | 181 | 17.97 |
| F2Pool | 114 | 11.32 |
| SpiderPool | 94 | 9.33 |
| ViaBTC | 78 | 7.75 |
| MARA Pool | 58 | 5.76 |
| OCEAN | 31 | **3.08** |
| ... | | |

- **Top 2** (Foundry + AntPool) ≈ 48.85% — close to majority.
- **Top 5** ≈ 77.25%.
- **OCEAN at ~3%** — the largest non-FPPS, non-custodial pool.

## "AntPool & friends" — proxy pooling

[[../../raw/articles/2026-05-23-b10c-mining-centralization-2025|b10c (2025-04)]]: smaller-branded pools relay AntPool's templates while branding their own coinbase tag. **The AntPool template-source network controls ~40% of network hashrate** — close to Foundry alone.

This means:
- Surface concentration (pool-share charts) **understates** real concentration.
- Coordinating censorship between Foundry and "AntPool & friends" would target ~70% of blocks.
- Mining decentralization peaked in 2017 (top-2 < 30%) and has **monotonically degraded** since.

## Why this drives payout-scheme reform

A new payout scheme alone does not solve centralization. But a payout scheme that **requires decoupled template construction** (PPLNS-JD, SLICE, TIDES + DATUM, eHash, p2poolv2) eliminates one centralization-amplifier: the pool's choice of which transactions to include.

The 2024-2026 projects target decentralization at four distinct layers:

| Layer | What it removes | Project example |
|---|---|---|
| **Custody** | Pool holds miner BTC | TIDES (coinbase splits) |
| **Template construction** | Pool picks transactions | DATUM, JD/SLICE |
| **Per-miner ledger** | Pool tracks miner balances | eHash |
| **Operator** | Pool entity exists at all | p2poolv2 |

Each can be adopted independently, but the **stack of all four** is what fully neutralizes pool-concentration risk.

## Why concentration grew despite p2pool existing

p2pool failed in 2014-2017 because:
- 30-sec share-chain → high stale rate vs centralized FPPS.
- Dust outputs as miners joined.
- Hardware incompatibilities (Cointerra, Antminer specific models).
- Operator complexity (full node + tuning).

ASIC-era miners chose **predictable cashflow** (FPPS) over decentralization. Concentration grew structurally.

The 2024-2026 projects bet that:
- SV2 + JD removes the stale-rate disadvantage.
- Lightning-paid-out shares remove dust.
- Standard hardware support is broader.
- Higher-level primitives (Cashu mints, atomic swaps) abstract away the operator complexity.

## The fee-era inflection (~2032)

Post-subsidy (block reward → 0 over halvings), pool revenue is dominated by transaction fees. **Whoever picks the transactions captures the revenue.** FPPS averages this; PPLNS-JD lets miners capture it directly.

Modeled outcome: FPPS pools must either (a) raise fees to compensate operator-side fee variance, or (b) cede market share to PPLNS-JD pools where miners pick their own tx selection. Most analyses (Pintos, BuildaMine) expect the second.

## Sources

- [[../../raw/articles/2026-05-23-b10c-mining-centralization-2025|b10c — Bitcoin Mining Centralization 2025]]
- [[../../raw/articles/2026-05-23-mempool-space-mining-dashboard|mempool.space May 2026]]
- [[../../raw/repos/2026-05-23-p2pool-and-p2poolv2|p2pool decline analysis]]

## See also

- [[payout-design-space]]
- [[sv2-jd-and-payout-decoupling]]
- [[../concepts/p2pool-share-chain]]
