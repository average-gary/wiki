---
title: "Bitcoin Mining Pool Payout Structures: A Simple Guide"
author: Guzman Pintos
publication: Hashrate Index (Luxor)
date: 2019-03-19, updated 2023-12-12
url: https://hashrateindex.com/blog/pps-fpps-pplns-pps_plus/
type: article
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [PPS, PPS+, FPPS, PPLNS, practitioner, Luxor]
---

# Hashrate Index Practitioner Guide (Pintos / Luxor)

Industry-standard practitioner reference. Author is Luxor co-founder — actual pool operator, not a journalist.

## Definitions (industry-canonical)

- **PPS** (Pay Per Share): pool pays fixed amount per share at expected value. Pool absorbs all variance. Highest fee. Subsidy only — no tx fee component.
- **FPPS** (Full PPS): PPS + share of tx fees averaged over a window. Most popular at large pools (F2Pool, Antpool, BTC.com).
- **PPS+**: hybrid. Block subsidy paid as PPS (smooth) + transaction fees distributed PPLNS-style (lumpy).
- **PPLNS** (Pay Per Last N Shares): payout only on block-find; rolling window of last N shares. Miners absorb variance. Penalizes pool-hoppers structurally.
- **SOLO**: full block reward to lucky miner; no smoothing.

## Key applied takeaways

- *"FPPS is the most riskiest for a pool operator so it usually comes with a slightly higher fee. PPLNS pools have little to no risk for the pool operator."*
- Variance smooths to mean over **months, not days**. PPLNS payouts can swing wildly short-term.
- Only large pools with reserves can sustainably offer FPPS — explains why small/new pools default to PPLNS.
- PPS+ balances predictability (subsidy) and fee upside (PPLNS for tx fees).
- PPLNS structurally penalizes pool-hoppers — explicit operator design choice.

## Fee landscape (typical 2023)

- PPS: 4-6%
- FPPS: 2-2.5% (Luxor 2%, Poolin 2.5%, BTC.com historically 4%)
- PPS+: ~2.5% (F2Pool, AntPool when on PPS+)
- PPLNS: 0-2.5% (variable, often bundled or 0%)
- Score-based (Braiins legacy): 2%

## Why it matters for the wiki

Canonical reference cited across the industry. The practitioner framing of "who absorbs which risk" is the lens for comparing TIDES, SLICE, eHash to the legacy schemes.
