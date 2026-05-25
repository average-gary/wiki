---
title: Why FPPS Dominates (and is fragile)
type: topic
created: 2026-05-23
confidence: medium
tags: [FPPS, dominance, market-structure, fee-era]
---

# Why FPPS Dominates (and is fragile)

FPPS-class pools mine ~95% of network hashrate. Why? And what changes after 2032?

**Note on history**: FPPS dominance dates from 2016-2017 (BTC.com Sept 2016; AntPool PPS+ early 2017), not 2014 as commonly believed — see [[../../raw/articles/2026-05-23-antpool-fpps-history|AntPool FPPS adoption history]]. So FPPS has been dominant for **~10 years (2016-2026)**. The fee-era inflection (~2032) gives FPPS roughly the same length ahead of it as it has had behind it — bolsters the "structurally fragile" argument.

## Why FPPS won 2014-2024

1. **Daily-stable cashflow.** Miner break-even modeling is trivial. CapEx-financing banks/investors understand it. PPLNS variance is a banking-relationship problem.
2. **Operator-reserve premium baked into fee.** Pool eats the variance for ~0.5-1.5% extra fee — small for a miner who's risk-averse.
3. **Simple UX.** No window-fill ramp-up, no understanding of "share decay," no dust outputs.
4. **Network effect.** Top-3 pools (Foundry, AntPool, F2Pool) became default by 2017; new miners point at the largest pool by reflex.
5. **Regulatory clarity.** A custodial pool is a known financial structure; a non-custodial coinbase-splitting pool is novel.
6. **ASIC-era variance economics.** ASIC capex is large; investors want predictable revenue. Variance is the enemy of the financing model.

## What's structurally fragile

### 1. The custody assumption

FPPS pools hold miner BTC between payouts. This is:
- A counterparty risk (Mt. Gox / FTX-class events).
- A regulatory target (KYC, AML, Travel Rule).
- A censorship surface (pool can refuse withdrawals).

Non-custodial coinbase splits (TIDES, SLICE) eliminate this with no scheme-level downside.

### 2. The template-control assumption

FPPS pools build templates. This is:
- A censorship surface (pool can refuse to include certain tx).
- A revenue capture (pool decides which fees to capture vs share with miners).
- A centralization amplifier (3-4 pool template authors decide most blocks).

DATUM, JD/SLICE eliminate this — miner picks the block content.

### 3. The fee-era variance shift

**Post-subsidy, fee variance dominates.** Block subsidy is deterministic (3.125 BTC → 1.5625 BTC at next halving → 0). Fees are stochastic. FPPS averages fees over a window — but if average fees fall structurally, the operator's "predictability premium" becomes a "fee illusion."

Modeled outcome (Pintos, BuildaMine, fee-era analyses):
- Pools must either raise fees to absorb fee-variance, or cede share to PPLNS-JD where miners capture fees directly.
- Tipping point likely 2028-2032 as 4th halving (3.125 → 1.5625) takes effect and fee share of block reward exceeds 50%.

### 4. The diversification undermine

Chatzigiannis et al. 2022: active-rebalanced miner achieves 260% Sharpe-ratio improvement vs single-pool passive. Even better with multi-coin diversification.

If the average professional miner is rebalancing weekly, **FPPS's "predictable cashflow" advantage is at the wrong level of analysis.** What matters is the portfolio variance, which is dominated by FX (USD/BTC) and not by pool-luck.

### 5. The decentralization sentiment

b10c (2025): top-2 pools = 49%, top-5 = 78%. A coordinated 6-pool group could censor most blocks. Miner sentiment increasingly views FPPS-class concentration as an existential risk to Bitcoin itself.

## Plausible 5-year trajectory

- **Best case for FPPS**: 80-85% network share. Some miner share moves to OCEAN/DMND. FPPS pools modernize on-chain auditability (audit-friendly FPPS variants).
- **Median case**: 60-70% FPPS by 2030. PPLNS-JD pools capture mid-size sovereign miners. p2poolv2 + hashpool serve niche cypherpunk segment. OCEAN reaches ~10%.
- **Worst case for FPPS**: <50% by 2032. Post-subsidy fee variance + regulatory pressure on custodial pools + sovereign-miner momentum cascades.

## Why fee schedule matters less than people think

Fee differences (FPPS 2-2.5% vs PPLNS 0-2%) are typically dwarfed by:
- FX volatility (annualized USD/BTC σ ~50%)
- Pool luck variance (months-long convergence at small hashrate)
- Hardware downtime / opex (electricity contract terms)
- Stale rate differential (V1 0.5-2% vs SV2 0.0151%)

A miner moving from V1-FPPS to V2-SLICE may net a 0.5-1% improvement from stale-rate alone — comparable to the entire FPPS fee premium.

## Sources

- [[../../raw/articles/2026-05-23-hashrate-index-pintos-payout-guide|Pintos / Hashrate Index]]
- [[../../raw/papers/2026-05-23-chatzigiannis-2022-diversification|Chatzigiannis et al. 2022]]
- [[../../raw/articles/2026-05-23-b10c-mining-centralization-2025|b10c centralization]]
- [[../../raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment|Heatpunks empirical]]

## See also

- [[../concepts/fpps]]
- [[payout-design-space]]
- [[../decisions/custody-tradeoffs|Custody Tradeoffs]]
