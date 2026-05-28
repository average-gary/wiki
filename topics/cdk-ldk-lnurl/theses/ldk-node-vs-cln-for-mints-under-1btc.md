---
title: "Thesis: For Cashu mints with <1 BTC reserve, embedded cdk-ldk-node has lower operational risk than cdk-cln/cdk-lnd"
type: thesis
status: investigating
created: 2026-05-28
updated: 2026-05-28
verdict: pending
confidence: pending
core_claim: "For small mints (under ~1 BTC reserve), cdk-mintd + cdk-ldk-node has lower operational risk than cdk-mintd + cdk-cln or cdk-mintd + cdk-lnd, because the surface area of two-process LN ops is more failure-prone than the open-issue catalog of LDK Node at this scale."
key_variables: [reserve_size, persistence_panic_rate, operator_skill, surface_area]
falsification: "If even small mints suffer LDK Node panics frequently enough that they lose more sats to forced closes than CLN/LND operators lose to ops mistakes, the thesis is false."
---

# Thesis: LDK Node vs CLN for small mints

## Core Claim

For Cashu mints under ~1 BTC reserve, cdk-mintd + cdk-ldk-node has **lower** operational risk than cdk-mintd + cdk-cln/cdk-lnd, despite the open footgun catalog (issues #381, #834, #913).

Rationale: a two-process deployment (cdk-mintd + separate CLN/LND daemon) introduces network failure modes, version-skew risk, and config drift that exceed the panic-on-persistence risk of LDK Node at small scale. The cdk-ldk-node README's "Recommended for Testing" framing assumes a strict-uptime production posture that small mints don't have.

## Key Variables

- Reserve size (custodial value)
- LDK Node panic rate (issue #381 manifestation rate)
- Operator skill (CLN/LND require tuning that small operators may skip)
- Total surface area of failure modes

## Testable Prediction

A randomized survey of Cashu mints under 1 BTC reserve (or a synthetic Mutinynet load test) would find:
- LDK Node panic rate < CLN/LND ops-mistake rate at small scale
- Above ~1 BTC, the inversion happens

## Falsification Criteria

- Anecdata or post-mortems showing small LDK-Node-backed mints losing reserves to panic-induced force-closes at >1% annualized
- Confirmation from CDK maintainers that they would NOT recommend LDK Node even for a 0.01 BTC mint

## Evidence For

- LDK Node README explicitly recommends Mutinynet for testing — implying it is well-tested below mainnet stakes
- Fedimint Gateway runs LDK Node embedded for production federations and has been stable
- One-process deployment removes a class of mismatch errors

## Evidence Against

- cdk-ldk-node README itself positions LDK as testing-tier
- Issue #381 is open and tracked since 2024
- No published LDK-Node-mint post-mortem either way

## Verdict

**Status**: Investigating

## Suggested follow-up

Survey small operators in Cashu Discord / Stacker News. Reach out to thesimplekid for the maintainer view. Run a 90-day Mutinynet load test on cdk-mintd + cdk-ldk-node simulating ~10 deposits/day with random kill -9 to provoke panic recovery.
