---
title: TIDES Variance — Derivation from Rosenfeld 2011
type: concept
created: 2026-05-23
confidence: high
derivation_only: true
tags: [TIDES, FPPS, variance, Rosenfeld, derivation]
---

# TIDES (and SLICE) Variance — Closed-Form Derivation

Quantitative variance comparison between TIDES/SLICE and FPPS at multiple time horizons. **Derived from Rosenfeld 2011's σ² formulas with N = 8·D** (the deployed value at both [[tides|OCEAN TIDES]] and [[pplns-jd|DMND SLICE]]), sanity-checked against the heatpunks 2025 empirical run.

**SLICE confirmation 2026-05-23**: DMND blog explicitly states *"the Bitcoin's network difficulty multiplied by 8."* Same derivation applies to SLICE.

## Setup

For a miner whose share contributes 1/D toward a window of N shares (D = network difficulty in shares):

- **PPS**: σ_PPS ≈ 0 to the miner. Operator pays a fixed `B/D` per share regardless of luck. Pool absorbs all variance.
- **PPLNS sharp cutoff (TIDES)**: per Rosenfeld eq. (PPLNS variance), CV² = D/N for a miner whose hashrate is small relative to the pool.
- **TIDES specifically**: N = 8·D → CV² = 1/8 → **σ/μ ≈ 35.4% per single block-window**.

Over **B blocks**: `CV(B) = (1/√8)/√B = 0.354 / √B` for TIDES; ≈ 0 for FPPS.

## Critical insight: B is *pool-found* blocks, not network blocks

TIDES only pays out when *the pool* solves a block. A typical home miner with ~1% of pool hashrate sees variance scale with **how often the pool finds blocks**, not how often the network does.

OCEAN at ~3-4% network share finds ~4.3 blocks/day (network ≈ 144/day). A hypothetical 0.5% pool finds ~0.7 blocks/day — about 6× slower convergence.

## Variance at multiple horizons (OCEAN scale, ~4 pool-blocks/day)

| Horizon | OCEAN pool blocks (B) | TIDES σ/μ (≈ 0.354/√B) | FPPS σ/μ |
|---|---|---|---|
| 1 day | ~4 | **17.7%** | ~0% |
| 1 week | ~30 | **6.5%** | ~0% |
| 1 month | ~130 | **3.1%** | ~0% |
| 3 months | ~390 | **1.8%** | ~0% |
| 1 year | ~1,570 | **0.9%** | ~0% |

For a smaller pool (~0.5% network share), divide pool-block counts by ~6 → 1-month σ/μ rises to ~7.5%, 3-month ~4.4%.

## Convergence thresholds

Solve `0.354/√B < threshold`:

- TIDES σ/μ < **5%** → B > 50 → **~12 days at OCEAN**, ~75 days at 0.5%-network pool.
- TIDES σ/μ < **1%** → B > 1,250 → **~10 months at OCEAN**, ~5 years at 0.5% pool.

## Sanity check: heatpunks 2025 empirical

[[../../raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment|heatpunks experiment]]: 2-month head-to-head, FPPS led TIDES by **3.3%**.

Model prediction: TIDES σ/μ at 2 months ≈ 2.2%. A 3.3% gap is ~**1.5σ** — consistent with luck draw, not protocol bias. The 85-hour block gap is exactly the 1-2σ left-tail event the formula predicts will occur ~16% of the time.

**Model and empirical agree.**

## What the σ figure does NOT capture

1. **FPPS operator-default risk** — multi-week pool-bad-luck can break operator solvency. Not in σ; very real in stress events.
2. **FX (USD/BTC) volatility** — at any horizon > 1 month, fiat-settling miners see FX variance dominate pool variance ([[../../raw/papers/2026-05-23-chatzigiannis-2022-diversification|Chatzigiannis et al. 2022]]). FPPS's "predictability" advantage erodes for these miners.
3. **Fee-era variance** — post-subsidy, block rewards are dominated by stochastic transaction fees. FPPS pools must absorb fee-distribution variance, not just luck variance. Chatzigiannis argues this is the main long-horizon FPPS weakness.
4. **Whale advantage** — miners with >5% of pool hashrate see lower variance than this formula predicts; they nearly always have shares in window. The formula assumes a small miner.

## Implications

- **TIDES is competitive with FPPS for miners with horizons ≥ 1 month at OCEAN scale.**
- Below 1 month, FPPS predictability is real and matters for cashflow planning.
- Above 1 year, FPPS's structural risks (operator default, fee-era variance) start to dominate; FPPS's σ ≈ 0 figure is misleading.
- For sub-1%-network-share pools, TIDES variance convergence stretches to multi-month → these pools need FPPS or hybrid schemes to attract small miners.

## Caveats

- Sharp 0/1 cutoff PPLNS — exponentially-weighted variants have slightly higher CV.
- Fee gap (OCEAN 2%/1% vs FPPS ~2-2.5%) is steady-state EV, separate from σ.
- Transaction-fee variance not modeled here.

## Sources

- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]] — closed-form σ²(PPLNS, N) and σ²(PPS).
- [[../../raw/articles/2026-05-23-rosenfeld-pplns-bitcointalk-2011|Rosenfeld bitcointalk]] — primary specification of CV² = D/N.
- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN TIDES spec]] — N = 8·D.
- [[../../raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment|heatpunks 2025]] — empirical validation.
- [[../../raw/papers/2026-05-23-chatzigiannis-2022-diversification|Chatzigiannis et al. 2022]] — FX-dominance argument.

## See also

- [[variance-and-risk-shifting]]
- [[tides]]
- [[fpps]]
- [[../topics/why-fpps-dominates-but-is-fragile|Why FPPS Dominates (and is fragile)]]
