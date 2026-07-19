---
title: Concepts
type: section-index
---

# Concepts

Definitions and primitives — schemes, attacks, variance.

## Schemes

- [[payout-schema-taxonomy|Payout Schema Taxonomy]] — overarching map of all schemes by who absorbs variance
- [[pplns|PPLNS — Pay Per Last N Shares]] — Rosenfeld 2011, hop-resistant
- [[fpps|FPPS — Full Pay Per Share]] — variance to operator, dominant scheme today
- [[tides|TIDES (OCEAN)]] — PPLNS done right, non-custodial coinbase payout
- [[pplns-jd|PPLNS-JD / SLICE (DMND)]] — PPLNS bound to SV2 Job Declaration
- [[sv2-share-accounting-ext|SV2 Share Accounting Extension]] — SV2 extension (type 32) for miner-verifiable PPLNS-JD payout auditing
- [[ehash|eHash / hashpool]] — Cashu blind-signature share tokens
- [[p2pool-share-chain|p2pool / p2poolv2]] — on-chain PPLNS, no operator
- [[p2poolv2-accounting|p2poolv2 Accounting (deep-dive)]] — code-level: 133k-share window, 90% uncle weight, atomic-swap HTLCs
- [[hydrapool|Hydrapool — 256 Foundation pool]] — public-audit-API PPLNS, uses `p2poolv2_lib`
- [[parasite-pool|Parasite Pool]] — lottery + decay-EMA hybrid, custodial Lightning fanout, Stratum V1
- [[radpool|Radpool]] — DLC + FROST decentralized FPPS (proposal stage)
- [[braidpool|Braidpool]] — DAG sharechain, Full Proportional payout, covenant-based custody (prototype)
- [[datum|DATUM]] — OCEAN's miner-side template-construction protocol (orthogonal to TIDES payout)
- [[ark-for-mining-payouts|Ark for Mining Payouts]] — hypothetical ASP-backed payout layer; one BitMag mention; structural critiques on capital lockup, expiry, and exit cost
- [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] — OP_CTV (BIP-119) coinbase fanout for non-custodial payouts; flat (~319-output TRUC ceiling) vs layered tree, MuSig-node + P2Pool-reboot endgame (vnprc coinbase-playground)

## Attacks

- [[pool-hopping|Pool Hopping]] — original miner-vs-pool attack, killed proportional payout
- [[block-withholding|Block Withholding (BWH) and FAW]] — inter-pool sabotage, Eyal/Schrijvers/Kwon
- [[selfish-mining|Selfish Mining]] — pool-vs-network attack, Eyal/Sirer/Sapirshtein

## Cross-cutting

- [[variance-and-risk-shifting|Variance & Risk-Shifting]] — the central design dimension
- [[tides-variance-derivation|TIDES Variance — Closed-Form Derivation]] — quantitative σ at multiple horizons (Rosenfeld → TIDES, sanity-checked vs heatpunks 2025)
