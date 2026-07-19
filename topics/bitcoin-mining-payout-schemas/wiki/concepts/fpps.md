---
title: FPPS (Full Pay Per Share)
category: concept
created: 2026-05-23
confidence: high
tags: [FPPS, PPS, pool-eats-variance, custodial]
volatility: warm
updated: 2026-07-15
verified: 2026-07-15
sources:
  - "raw/articles/2026-05-23-hashrate-index-pintos-payout-guide.md"
  - "raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis.md"
---

# FPPS — Full Pay Per Share

PPS plus a share of transaction fees averaged over a window. Dominant scheme at large pools (Foundry, AntPool, F2Pool, ViaBTC) since ~2016-2017.

## History (corrected 2026-05-23)

- **September 2016**: BTC.com pool (Bitmain) launches with FPPS as headline feature — **first major FPPS pool**.
- **Early 2017** (≤ Feb 28): AntPool adds **PPS+** to homepage payout menu (FPPS-equivalent).
- **November 2019**: AntPool's on-chain payout topology changes chain-like → tree-like (Tovanich et al. IEEE TVCG 2022).
- **July 13, 2020**: AntPool adds payout method explicitly labeled **"FPPS"** distinct from PPS+ (per AntPool Zendesk).

The earlier framing "FPPS dominant since 2014" is wrong — AntPool launched in 2014 with PPS + PPLNS only. *See [[../../raw/articles/2026-05-23-antpool-fpps-history|AntPool FPPS adoption history]] for the corrected timeline.*

## Formula (sketch)

`R_per_share = (B + avg(tx_fees)) / D`

The "F" — full — is the inclusion of tx fees. Vanilla PPS pays only the subsidy; FPPS adds the fee component.

## Risk allocation

- **Pool absorbs all variance** — block-luck and fee-market timing.
- **Operator reserve requirement: high.** Pool pays miners on schedule regardless of whether blocks were found. Unlucky runs can bankrupt undercapitalized pools.
- Practitioner consensus: only large pools with reserves can sustain FPPS. *See [[../../raw/articles/2026-05-23-hashrate-index-pintos-payout-guide|Pintos]].*

## Auditability

- **Audit-friendly variant** (24-hour settlement, 0% audit error possible): Lincoin (claimed); Antpool de-facto (daily settlement). Per-account dashboard + CSV export — but **internal-only**, login-gated. No published cryptographic proof.
- **Audit-hostile variant** (rolling-average, up to 48 reconciliations/day): F2Pool, ViaBTC, Foundry (cadence undocumented). "Almost impossible to audit" per Naseri 2023.

Critical: **No production FPPS pool has published a cryptographic public-audit framework or proof-of-reserves/liabilities** as of May 2026. "Auditable FPPS" today means *cadence-friendly*, not *cryptographically provable*. Non-custodial coinbase schemes (TIDES, SLICE) are categorically more auditable because the on-chain coinbase tx *is* the payout receipt.

*See [[../../raw/articles/2026-05-23-audit-friendly-fpps|Audit-Friendly FPPS landscape]] for the production map.*

## Fee landscape (typical 2024-2026)

- BTC.com: 4% (historical; may be outdated)
- Luxor: 2%
- Poolin: 2.5%
- F2Pool (PPS+): 2.5%
- AntPool (FPPS or PPS+): 2.5%
- OCEAN (TIDES, NOT FPPS): 2% / 1% with DATUM

## Why it dominates

Miners value certainty. FPPS sells daily-stable cashflow → easy break-even modeling, easy financing of CapEx. Variance reduction via diversification (Chatzigiannis et al. 2022) shows FPPS is *not* unambiguously optimal at portfolio level — but in practice, the simplicity wins.

## Why challenger schemes target it

- **Custodial.** Pool holds your BTC until threshold/payout. Counterparty risk (Mt. Gox, Bitfinex echoes).
- **Pool chooses block content.** Tx fees averaged means pool decides which transactions go in. Censorship vector.
- **Higher fee.** Pool variance-bearing premium typically 0.5-1.5% over PPLNS.

These are the hooks for OCEAN/TIDES, DMND/SLICE, and hashpool.

## Sources

- [[../../raw/articles/2026-05-23-hashrate-index-pintos-payout-guide|Pintos / Hashrate Index]]
- [[../../raw/papers/2026-05-23-rosenfeld-2011-pool-reward-analysis|Rosenfeld 2011]] (theory of variance shift)

## See also

- [[payout-schema-taxonomy]]
- [[pplns]]
- [[variance-and-risk-shifting]]
- [[../topics/why-fpps-dominates-but-is-fragile|Why FPPS dominates (and is fragile)]]
