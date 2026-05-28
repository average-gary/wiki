---
title: "Federation trust model (KYF, debasement, exit, regulation)"
type: concept
created: 2026-05-28
updated: 2026-05-28
verified: 2026-05-28
volatility: cold
confidence: high
tags: [fedimint, trust-model, kyf, debasement, proof-of-reserves, regulation, threshold-signatures]
---

# Federation trust model

Fedimint's threshold-custody model has a well-enumerated risk surface, captured most concisely by [[../../raw/articles/2026-05-28-spark-fedimint-research-overview|Spark's research overview]]. Understanding it is prerequisite to evaluating any multi-currency proposal — most multi-currency risks **multiply** these baseline risks.

## Architecture (one-liner)

A federation is a t-of-n threshold-signature group of **guardians** that collectively custody BTC and issue blinded eCash notes via AlephBFT consensus. Modules sit on top: `wallet` (on-chain BTC), `mint` (eCash), `lightning` (LN gateway).

## Five named risks

(Per Spark, verbatim where quoted.)

1. **Custodial risk** — quorum collusion. Guardians can collude to steal funds.
2. **Debasement** — *"The federation could issue more ecash than bitcoin it holds, inflating the supply, and users would have no way to detect this until a bank run occurs."* Fedimint *"currently lacks a trustless proof-of-reserves mechanism."*
3. **Regulatory** — federations could be forced to shut down or freeze funds.
4. **Gateway censorship** — Lightning gateways can refuse traffic.
5. **Availability** — *"If a quorum of guardians refuses or goes offline permanently, deposited bitcoin is lost."*

## The exit problem

> Fedimint users cannot exit unilaterally. They must request a peg-out from the federation, and the federation must agree to process it.

Compare Lightning (unilateral channel close), Ark (server-cooperative exit with timelock fallback), or self-custody (always-exit). Fedimint sits with Cashu in the *no-unilateral-exit* category.

## "Know Your Federation" (KYF)

Fedimint's intended deployment model is small federations of personally-trusted guardians (friends, family, community organizations). The risk model is acceptable when guardians are real people the user knows — the threshold replaces a single counterparty's solvency with a coordinated-collusion problem at human scale.

The model **scales poorly** to anonymous guardian operators. There is no on-chain or cryptographic proof that guardians are who they claim to be, that the BTC backing is fully reserved, or that the federation is not double-counting eCash.

## How multi-currency multiplies these

Each non-BTC unit a federation issues introduces independent versions of the same risks:

- **Debasement risk** is per-unit. A `mintv2(usd-synth)` instance has its own bank-run failure mode independent of the BTC mint.
- **Regulatory exposure** depends on the asset. A BTC-only federation falls under Bitcoin custody regulation (often well-understood). A federation issuing fiat-pegged or commodity-pegged tokens potentially crosses into securities, money-transmitter, stablecoin-issuer, or commodity-token regimes.
- **Oracle dependency** is created per non-BTC unit. BTC mints don't need an oracle. USD-synth mints (Stability Pool) need a BTC/USD oracle. Fiat-pegged mints would need an off-chain peg + reserves attestation.
- **Custody complexity** scales linearly with units. Each unit needs its own backing source-of-truth, audit, and exit path.

## See also

- [[../../raw/articles/2026-05-28-spark-fedimint-research-overview|Spark research]] — source of the risk enumeration
- [[stability-pool|Stability Pool]] — first concrete instance of "multi-currency multiplies risks" (oracle dependency added)
- [[../topics/fedimint-multi-currency-status|Multi-currency status]] — applies these to the three architectural paths
