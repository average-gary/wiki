---
title: "TIDES: Transparent Index of Distinct Extended Shares"
author: Jason Hughes
publication: ocean.xyz
date: 2024-02-29
url: https://ocean.xyz/docs/tides
type: article
ingested: 2026-05-23
quality: 5
credibility: high
confidence: high
tags: [TIDES, OCEAN, PPLNS, non-custodial, payout-spec]
---

# TIDES (OCEAN Mining Pool)

Primary spec for the only post-2024 production payout scheme that publishes a full mathematical doc. Authored by Jason Hughes for OCEAN (Luke Dashjr's relaunch of the Eligius lineage). OCEAN launched March 2024.

## Parameters

- **Window**: `share_log_window = 8 × current_block_difficulty` worth of difficulty-weighted shares. Roughly **8 blocks of work** in expectation; no fixed share count — N scales with D.
- **Share weight**: each proof counts as a number of shares equal to its target difficulty (no fixed-difficulty bucketing).
- **Reward formula**: `miner_reward = (miner_shares_in_window / share_log_window) × current_block_reward`. Rounds down to nearest sat.
- **Fee model**: per-share fee-rate flag tagged at submission time. Uniform-fee form: `(r − f_sum) = Σᵢ (shares_m[i] × (1 − f%) / shares_w × r)`.
- **Self-described**: "what PPLNS was originally supposed to be" — full-resolution share log instead of legacy "shifts" that aggregate.

## Statistical guarantees

- **99.9665%** chance any given share contributes to at least one reward.
- Expected ~**8 reward events per share** over its lifetime in the window.
- Fallback when window underfilled: use `share_log_total` as denominator.

## Custody & auditability

- **Non-custodial**: payouts via the **coinbase generation transaction**; pool never buffers BTC.
- **Auditable**: every share in the log is published.
- No protocol-level minimum payout — pools may layer their own threshold.

## Operational fees

- Standard pool fee: **2%**.
- **DATUM fee: 1%** (when miner constructs own block templates via DATUM protocol).

## Critique noted in own doc

- Higher short-term variance than FPPS — explicit ramp-up period for new miners.
- ~0.03% of windows pay zero (the 99.9665% guarantee is a ceiling, not a floor).
- No external rebuttals included in the doc itself.

## Empirical from heatpunks experiment (2025-06 → 2025-08)

A direct head-to-head TIDES vs FPPS run by a home miner (tronsington, heatpunks.org/t/140): Braiins FPPS led OCEAN TIDES by ~3.3% over the test window — but OCEAN suffered an 85+ hour gap between blocks early on. Other long-run miners reported OCEAN outperforming 5–15% under different windows. Variance dominates short-run; convergence to mean takes months.
