---
title: TIDES (Transparent Index of Distinct Extended Shares)
category: concept
created: 2026-05-23
confidence: high
tags: [tides, ocean, pplns, non-custodial, Hughes-2024]
volatility: warm
updated: 2026-07-29
summary: "OCEAN's payout scheme. Authored by Jason Hughes for OCEAN's launch (March 2024). Self-described as *\"what PPLNS was originally supposed to be.\"*"
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
- **~~Auditable: full share log published.~~ → RETRACTED 2026-07-29.** This was unsupported. No
  primary source states that OCEAN publishes a full share log, and the 2026-07-29 attribution round
  found no such artifact. TIDES is auditable in the weaker sense that **coinbase outputs are on-chain
  and therefore verifiable after the fact** — which is a check on the *distribution*, not on the share
  data that produced it. Treat per-share auditability as an open question, and note it is in tension
  with attribution privacy: a published share log is precisely what
  [[payout-attribution-privacy|attribution privacy]] would need to withhold.
- **No protocol-level minimum payout** — pools may layer thresholds. (Note this sits awkwardly with
  OCEAN's own documentation conceding that satoshi-precision rewards produce uneconomic dust and that
  pools therefore accrue "until the sum exceeds a minimum threshold" — accrual to a threshold is a
  hosted balance. See [[../decisions/attribution-retention-tradeoffs|Attribution Retention
  Tradeoffs]].)

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
- [[coinbase-address-rotation|Coinbase Address Rotation]] ([Coinbase Address Rotation](../concepts/coinbase-address-rotation.md)) — TIDES already pays miner addresses direct from the coinbase, so it is the scheme where per-miner derived addresses would land most naturally
- [[xpub-payout-identity|xpub Payout Identity]] — what changes if a miner's username is a wildcard descriptor; TIDES pays the derivation cost per miner *per template* because the coinbase is precomputed at work-issue time
- [[../topics/self-blinding-pool-design-space|Self-Blinding Pool Design Space]] — TIDES as host for an attribution-minimizing pool, and the dust→accrual→custody chain its own docs concede
- [[../topics/payout-design-space|Payout Design Space]]
- [[datum.md|DATUM (OCEAN template-construction)]]
- [[lottery-pplns.md|Lottery-PPLNS (Finder-Bonus Hybrid)]]
- [[p2poolv2-accounting.md|p2poolv2 Accounting (deep-dive)]]
- [[parasite-pool.md|Parasite Pool]]
- [[../reference/people.md|People — eHash / hashpool / decentralized-pool ecosystem]]
- [[tides-variance-derivation.md|TIDES Variance — Derivation from Rosenfeld 2011]]
- [[payout-attribution-privacy|Payout Attribution Privacy — what a pool structurally knows]]

