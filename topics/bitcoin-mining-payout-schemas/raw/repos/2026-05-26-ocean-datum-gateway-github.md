---
title: "OCEAN-xyz/datum_gateway — DATUM Gateway reference implementation"
url: https://github.com/OCEAN-xyz/datum_gateway
license: MIT
language: C
type: repo
status: BETA (v0.4.1beta as of Jan 2026)
ingested: 2026-05-26
quality: 5
credibility: high
confidence: high
tags: [datum, ocean, template-construction, knots, primary-spec]
---

# OCEAN datum_gateway — Primary Spec for DATUM

Bitcoin Ocean LLC + Jason Hughes. ~145 stars. License MIT. Currently public BETA.

## Acronym

**DATUM** = "Decentralized Alternative Templates for Universal Mining"

## Transport stack

- **DATUM Gateway → mining hardware**: Stratum v1 + version-rolling (ASICBoost)
- **DATUM Gateway → local Bitcoin node**: GBT (`getblocktemplate`) RPC
- **DATUM Gateway → pool ("DATUM Prime")**: encrypted, custom DATUM Protocol (no public RFC; "evolving, subject to change, and will be published elsewhere")

## Bitcoin node compatibility

- **Bitcoin Knots highly recommended**. Quote: Core "is severely lacking in template control options... a centralizing force which partly defeats the purpose."
- **No Bitcoin Core patches required** — uses standard GBT.
- Miners must currently set `blockmaxsize=3985000` and `blockmaxweight=3985000` to reserve coinbase room (will be removable via Knots client-side override later).

## What OCEAN verifies (Template/Share Requirements)

Per the README:
- Valid block conforming to consensus rules
- Current height/time
- **Must include generation transaction outputs provided by the pool, in the order provided** (this is how TIDES payout splits get enforced)
- **Must include the primary coinbase tag provided by the pool**
- **Must include the unique identifier provided by the pool**
- Meets share target

What OCEAN does NOT enforce: fee floor, transaction policy, OFAC posture. Miners pick their own mempool/policy.

## Beta-vs-future

In current beta the pool also does block validation as a "training wheels" guard rail. In a future protocol version "the pool will not be in charge of this function and will be almost completely blinded to the contents of the miner's block template."

## Username = payout address

Per `doc/usernames.md`: username is the Bitcoin payout address (Base58 / Bech32 / Bech32m). No separate auth/KYC layer; address *is* identity. Gateway will not start without a valid `mining.pool_address`.

## DATUM vs SV2 Job Declaration

| Axis | DATUM | SV2-JD |
|---|---|---|
| Privacy | Pool currently sees full template (beta) | Coinbase-only mode hides txs |
| Standardization | OCEAN-only, no public spec | sv2-spec/06-Job-Declaration |
| Coinbase output for pool | "outputs in order provided" | First output reserved |
| Anti-cheat | Template validation | Economic — pool loses hash if rejecting acked custom jobs |
| Stratum to ASICs | v1 | v2 |
| Production | Live (OCEAN beta) | DMND |

## Adoption gap

OCEAN total pool hashrate ~31.91 EH/s. **What fraction mines via DATUM**: not published by OCEAN; not surfaced by third-party measurement in this round. b10c miningpool-observer is the likely future source.

## Why ingestion-worthy

Primary technical artifact for DATUM. Closes the OCEAN-side template-construction axis the wiki was missing (TIDES is the payout layer; DATUM is the orthogonal template-construction protocol).

## See also

- [[../articles/2026-05-23-ocean-tides-spec|OCEAN TIDES spec]] — payout layer
- [[../articles/2026-05-26-nobsbitcoin-dmnd-sv2-solo-guide|DMND SV2+JD]] — standards-track alternative
