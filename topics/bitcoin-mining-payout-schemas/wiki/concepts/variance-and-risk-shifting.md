---
title: Variance & Risk-Shifting in Pool Payout Schemes
category: concept
created: 2026-05-23
confidence: high
tags: [variance, risk, FPPS, PPLNS, Chatzigiannis, Rosenfeld]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-23-hashrate-index-pintos-payout-guide.md"
  - "raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment.md"
  - "raw/papers/2026-05-23-chatzigiannis-2022-diversification.md"
  - "raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis.md"
---

# Variance & Risk-Shifting

The single design dimension that distinguishes payout schemes: **who absorbs the gap between expected and actual block-find?**

## The variance budget

Bitcoin mining is a Poisson process. A pool with `h` hashrate finds blocks with rate `h × 144 / total_hashrate` blocks/day. Variance scales with **rate × time**. Short-horizon variance is high; long-horizon variance smooths to mean.

Three actors can absorb variance:

1. **The pool operator** (FPPS/PPS): pool pays miners on schedule regardless of luck. Variance = operator's reserves.
2. **The miner** (PPLNS / TIDES / SLICE / p2poolv2): miner gets paid only when blocks are found. Variance = miner's bank balance.
3. **A market** (eHash / hashpool): variance becomes a tradeable asset; miner sells the variance to a buyer who specializes in absorbing it.

## Operator-side variance: the reserve requirement

If operator pays daily (FPPS) and luck dictates 10-day block droughts at the 99th percentile, operator needs ~10 days of payouts in reserve to avoid bankruptcy. **This is why only large pools offer FPPS.**

Rosenfeld 2011: in a PPS pool with miner expected reward `B/D` per share and `n` shares per day, an unlucky pool can require reserves growing as O(σ × √n) before the bankruptcy probability falls below threshold. Closed-form analysis available in the paper.

## Miner-side variance: the cashflow problem

PPLNS-class miners must **wait for block-finds**. A small miner on a small pool can wait weeks. Heatpunks empirical: OCEAN suffered an 85+ hour gap during a 2025 test → home miner saw zero income for 3.5 days.

Variance horizon for convergence to mean is months, not days. **Miners modeling break-even on PPLNS need to capitalize 3-12 months of opex.**

## Diversification (Chatzigiannis et al. 2022)

Risk-averse miner allocates hashrate across pools. Active rebalancing every 3 days yielded **~260% Sharpe-ratio improvement** vs single-pool passive mining in their model.

For FPPS-like deterministic streams, **FX volatility (USD/BTC) dominates** pool-luck variance — so the FPPS premium for "predictable cashflow" is partly illusory if the miner sells to USD anyway.

## Variance as a tradeable asset (eHash)

hashpool issues a Cashu bearer token per share. Token accrues value during a maturity period:
- Miner who holds → captures block-luck upside.
- Miner who sells early (to a secondary-market buyer) → guaranteed payout.

This is a **third category** beyond pool-eats and miner-eats. Market clears variance pricing per share-difficulty class. Theoretical only — no production secondary market yet.

## Quantitative comparison

| Scheme | Operator reserve | Miner cashflow stability | Long-run EV vs FPPS |
|---|---|---|---|
| FPPS | High | Daily | Baseline |
| PPS+ | Medium | Daily subsidy + lumpy fees | ≈ baseline |
| PPLNS / TIDES | Low | Per block-find | Slightly higher (lower fee, no operator premium) |
| SLICE | Low | Per block-find | Higher if miner picks better tx selection |
| eHash (held) | Mint solvency | Per maturity event | Same as PPLNS |
| eHash (sold early) | Mint solvency | Stable (locked in at sale) | Lower than PPLNS (haircut to buyer) |
| p2poolv2 | None | Per block-find + atomic-swap | ≈ PPLNS, possibly higher (no operator fee) |

## Sources

- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]]
- [[../../raw/papers/2026-05-23-chatzigiannis-2022-diversification|Chatzigiannis et al. 2022]]
- [[../../raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment|Heatpunks empirical 2025]]
- [[../../raw/articles/2026-05-23-hashrate-index-pintos-payout-guide|Pintos / Hashrate Index]]

## See also

- [[fpps]]
- [[pplns]]
- [[tides]]
- [[ehash]]
- [[block-withholding]]
