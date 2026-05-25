---
title: "Diversification Across Mining Pools: Optimal Mining Strategies under PoW"
authors: [Panagiotis Chatzigiannis, Foteini Baldimtsi, Igor Griva, Jiasun Li]
year: 2022
venue: Journal of Cybersecurity (Oxford UP)
url: https://academic.oup.com/cybersecurity/article/8/1/tyab027/6550812
type: paper
ingested: 2026-05-23
quality: 4
credibility: high
confidence: high
tags: [variance, portfolio-theory, PPS, PPLNS, FPPS, miner-strategy]
---

# Diversification Across Mining Pools (Chatzigiannis et al. 2022)

Modern peer-reviewed update to Rosenfeld's variance analysis, recast as a portfolio-allocation problem.

## Model

Risk-averse miner with risk-aversion parameter λ allocates hashrate across pools and coins under three schemes (PPS, proportional, PPLNS). Closed-form decision rule for "which pool given my λ."

## Key empirical findings

- **PPLNS dominates today** in market share — confirmed.
- **Proportional remains hoppable** — confirmed Rosenfeld's prediction at scale.
- **PPS removes variance cleanly at a fee cost** — operator-bearing-variance still works for capitalized pools.
- **Active rebalancing** (every 3 days across pools): ~**260% Sharpe-ratio improvement** vs passive single-pool mining.
- **FX volatility dominates pool-luck variance** for FPPS-like deterministic streams. For miners settling in fiat, USD/BTC swings matter more than the choice between FPPS and PPS+.

## Implication for the wiki

The variance argument FPPS pools rely on (selling miners certainty) is partially undermined: at a portfolio level, FPPS doesn't dominate — diversification + cheaper PPLNS pools can produce better risk-adjusted returns. This is the empirical hook for OCEAN/DMND/hashpool's pitch ("higher headline variance, but cheaper and non-custodial → net better").
