---
title: "Spark Research — Fedimint: Federated Ecash Mints on Bitcoin"
type: raw
source_type: articles
source_url: https://www.spark.money/research/fedimint-federated-ecash
fetched: 2026-05-28
verified: 2026-05-28
volatility: warm
quality: 4
confidence: high
tags: [fedimint, spark, research-overview, custodial, debasement-risk, proof-of-reserves, kyf, contrarian]
summary: Independent research overview of Fedimint by Spark. Concise architecture summary (guardians, t-of-n, AlephBFT, modules) and an unusually direct enumeration of structural risks: no unilateral exit, no trustless proof-of-reserves, debasement risk, regulatory exposure, gateway censorship. No mention of multi-currency.
---

# Spark Research — Fedimint: Federated Ecash Mints on Bitcoin

## Architecture (per Spark)

- **Guardians and federation**: t-of-n threshold signatures (e.g. 3-of-4). Tolerates Byzantine faults per the 3m+1 rule.
- **Three core modules**: wallet (on-chain deposit/withdrawal), mint (eCash issuance), Lightning. Custom modules can extend functionality.
- **Consensus**: AlephBFT — asynchronous BFT, no leader.

## Trust model (verbatim quotes)

> Fedimint users cannot exit unilaterally. They must request a peg-out from the federation, and the federation must agree to process it.

> The federation could issue more ecash than bitcoin it holds, inflating the supply, and users would have no way to detect this until a bank run occurs.

> If a quorum of guardians refuses or goes offline permanently, deposited bitcoin is lost.

> Fedimint currently lacks a trustless proof-of-reserves mechanism.

> Cashu uses single-operator mints: simpler to deploy...but with all custodial risk concentrated in one party.

## Risk categories enumerated

1. **Custodial risk** — quorum collusion
2. **Debasement** — guardians issue more eCash than BTC backing
3. **Regulatory** — federations could be forced to shut down or freeze funds
4. **Gateway censorship** — Lightning gateways can refuse traffic
5. **Availability** — quorum offline = funds locked

## Spark's framing: "Know Your Federation" (KYF)

Fedimint's intended deployment is small federations of personally-trusted guardians, not anonymous global trust. The risk model is acceptable when guardians are friends-and-family or community members; it scales poorly when guardians are anonymous service operators.

## Multi-asset support

**Not mentioned in Spark's overview.** Spark focuses on the BTC custody model. The omission is consistent with the rest of the corpus — multi-currency is plumbing being built rather than a public-facing differentiator.

## Why this matters for multi-currency analysis

Spark's risk enumeration applies directly to the multi-currency question:

- **Debasement risk multiplies per asset**. If a federation runs a mintv2 instance per unit, each unit has independent debasement risk. The proof-of-reserves gap is per-unit.
- **Regulatory exposure scales with asset choice**. A BTC-only federation is regulated as Bitcoin custody (in many jurisdictions, well-understood). A federation issuing fiat-pegged or commodity-pegged tokens potentially crosses into securities, money-transmitter, or stablecoin-issuer regimes.
- **Custody risk concentrates per oracle**. Stability Pool, fiat-pegged modules, and any peg-dependent unit add an oracle that the BTC-only mint does not need.

These risks are not new to multi-currency — they are inherent to federated Chaumian mints — but **multi-currency multiplies them**. This is the strongest steelman against expanding Fedimint's asset surface, and it comes from the project's own structural risk profile.

## See also

- [[2026-05-28-bitcoin-manual-fedimint-stability-pool|Stability Pool article]] — the synthetic-USD module: proof-of-reserves for stable balance is also nontrivial
- [[2026-05-28-fedimint-discussion-8218-gold-stablecoins|Discussion #8218]] — dpc explicitly distinguishing "synthetic" (current) from "any assets" (future)
- [[2026-05-28-fedimint-h1-2025-ecosystem-review|Fedimint H1 2025 review]] — official roadmap focus on Bitcoin custody UX
