---
title: TIDES (Transparent Index of Distinct Extended Shares)
category: concept
created: 2026-05-23
confidence: high
tags: [TIDES, OCEAN, PPLNS, non-custodial, Hughes-2024]
volatility: warm
updated: 2026-07-17
verified: 2026-07-17
sources:
  - "raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment.md"
  - "raw/articles/2026-05-23-mempool-space-mining-dashboard.md"
  - "raw/articles/2026-05-23-ocean-tides-spec.md"
---

# TIDES

OCEAN's payout scheme. Authored by **Jason Hughes** for OCEAN's launch (March 2024). Self-described as *"what PPLNS was originally supposed to be."*

## Parameters

- **Window**: `share_log_window = 8 × current_block_difficulty`. Approximately 8 blocks of work in expectation. **N scales with D** (no fixed share count).
- **Share weight**: each proof counts as a number of shares equal to its target difficulty. No fixed-difficulty bucketing.
- **Reward formula**: `miner_reward = (miner_shares_in_window / share_log_window) × current_block_reward`. Rounds down to nearest sat.
- **Fee model**: per-share fee-rate flag tagged at submission. Uniform-fee form: `(r − f_sum) = Σᵢ (shares_m[i] × (1 − f%) / shares_w × r)`.

## Statistical guarantees

- **99.9665%** chance any given share contributes to at least one reward.
- Expected ~**8 reward events per share** over its lifetime.
- Fallback when window underfilled: use `share_log_total` as denominator.

## Custody and auditability

- **Non-custodial**: payouts via the **coinbase generation transaction**. Pool never buffers BTC.
- **Auditable**: full share log published.
- **No protocol-level minimum payout** — pools may layer thresholds.

## OCEAN operational fees

- Standard: **2%**.
- DATUM (miner-built templates): **1%**.

## Why it's "PPLNS done right"

Legacy PPLNS implementations historically used "shifts" — aggregating shares into chunks for storage efficiency, losing per-share resolution. TIDES preserves every share forever in the log → can prove fairness per-share. Window scales with D so the scheme adapts as hashrate grows.

## Empirical reality (heatpunks 2025)

Direct head-to-head with Braiins FPPS on the same hardware: **FPPS led TIDES by ~3.3%** over the test window. But OCEAN had an 85+ hour gap between blocks early on (single luck event dominated short result). Other 2025 windows saw OCEAN lead 5-15%. **Variance dominates short-run; convergence horizon is months.**

## Critiques (in TIDES doc itself)

- Higher short-term variance than FPPS (acknowledged).
- Explicit ramp-up period for new miners (acknowledged).
- ~0.03% of windows pay zero (the 99.9665% guarantee is a ceiling).
- No external rebuttals included.

## Connection to DATUM

TIDES is the *accounting* scheme; **DATUM** is the *template construction* scheme. Together they create OCEAN's full non-custodial-non-censoring stack:

- TIDES → coinbase-output payouts (no pool BTC custody).
- DATUM → miner-built block templates (no pool transaction-selection power).

## Sources

- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN TIDES spec (Hughes 2024)]]
- [[../../raw/articles/2026-05-23-heatpunks-tides-vs-fpps-experiment|Heatpunks TIDES vs FPPS empirical 2025]]
- [[../../raw/articles/2026-05-23-mempool-space-mining-dashboard|mempool.space — OCEAN ~3% network share]]

## See also

- [[pplns]]
- [[fpps]]
- [[variance-and-risk-shifting]]
- [[pplns-jd|SLICE / PPLNS-JD]] — the DMND sibling scheme that converges on the same N = 8 × D
- [[sv2-share-accounting-ext|SV2 Share Accounting Extension]] — the miner-side payout-audit protocol in the DMND/SLICE line
- [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] ([CTV Coinbase Payout Tree](../concepts/ctv-coinbase-payout-tree.md)) — proposes lifting OCEAN's coinbase output-count limit via a CTV covenant commitment
- [[../topics/payout-design-space|Payout Design Space]]
