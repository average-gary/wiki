---
title: DATUM (OCEAN template-construction)
category: concept
created: 2026-05-26
confidence: high
tags: [datum, ocean, template-construction, knots, custom-protocol, hughes]
volatility: warm
updated: 2026-07-17
verified: 2026-07-17
sources:
  - "raw/articles/2026-05-23-ocean-tides-spec.md"
  - "raw/repos/2026-05-26-ocean-datum-gateway-github.md"
---

# DATUM — Decentralized Alternative Templates for Universal Mining

OCEAN's protocol for **miner-side block-template construction**. Orthogonal to [[tides|TIDES]] (which is the payout layer). Where TIDES tells you how OCEAN splits the block reward, DATUM tells you who picks which transactions go into the block.

In short: DATUM is what makes OCEAN a "no-FOMO" pool in policy terms — miners build templates, miners pick transactions.

## Transport stack

| Hop | Protocol |
|---|---|
| Mining hardware → DATUM Gateway | Stratum v1 + version-rolling (ASICBoost) |
| DATUM Gateway → local Bitcoin node | GBT (`getblocktemplate`) RPC |
| DATUM Gateway → pool ("DATUM Prime") | encrypted, custom **DATUM Protocol** |

The DATUM Protocol wire-level spec is **not yet a public RFC**. README says: "evolving, subject to change, and will be published elsewhere."

## Bitcoin node compatibility

- **Bitcoin Knots is highly recommended.** README: Core "is severely lacking in template control options... a centralizing force which partly defeats the purpose."
- **No Bitcoin Core patches required** — uses standard GBT.
- Miners must currently set `blockmaxsize=3985000` and `blockmaxweight=3985000` to reserve coinbase room (will be removable via Knots client-side override later).

## What OCEAN actually verifies

Per the [[../../raw/repos/2026-05-26-ocean-datum-gateway-github|datum_gateway README]]:

- Valid block conforming to consensus rules
- Current height/time
- **Must include generation-transaction outputs provided by the pool, in the order provided** (this is how TIDES payout splits get enforced)
- **Must include the primary coinbase tag** provided by the pool
- **Must include the unique identifier** provided by the pool
- Meets share target

What OCEAN does **not** enforce: fee floor, transaction policy, OFAC posture. Miners pick their own mempool/policy.

## Beta vs. future

In current beta the pool **also** does block validation as a "training wheels" guard rail. In a future protocol version "the pool will not be in charge of this function and will be almost completely blinded to the contents of the miner's block template."

## Username = payout address

Per `doc/usernames.md`: username is the Bitcoin payout address. Address *is* identity; no separate auth/KYC layer. Gateway will not start without a valid `mining.pool_address`.

## DATUM vs SV2 Job Declaration

| Axis | DATUM | SV2-JD |
|---|---|---|
| Privacy | Pool currently sees full template (beta) | Coinbase-only mode hides txs |
| Standardization | OCEAN-only, no public spec | sv2-spec/06-Job-Declaration |
| Coinbase output for pool | "outputs in order provided" | First output reserved |
| Anti-cheat | Pool-side template validation | Economic — pool loses hash if rejecting acked custom jobs |
| Stratum to ASICs | v1 | v2 |
| Production at scale | OCEAN beta (live) | DMND |

DATUM's design philosophy: ship something working today over Stratum v1 + GBT, even if the pool can see the template during beta. SV2-JD's: hold out for the standardized end state where the pool is cryptographically blinded.

## Fee economics

DATUM miners receive a **50% discount on the OCEAN pool fee** — 1% with DATUM vs. 2% standard.

## Adoption gap

OCEAN total pool hashrate ~31.91 EH/s. **What fraction mines via DATUM**: not published by OCEAN; not surfaced by third-party measurement in the round of research that fed this article. The b10c miningpool-observer is the likely future source.

## Status

- v0.4.1beta as of January 2026.
- Repo last pushed 2026-04-06.
- Authors: Bitcoin Ocean, LLC + Jason Hughes + contributors. MIT license.

## Sources

- [[../../raw/repos/2026-05-26-ocean-datum-gateway-github|OCEAN-xyz/datum_gateway repo + README]]
- [[../../raw/articles/2026-05-23-ocean-tides-spec|OCEAN TIDES spec — payout layer]]

## See also

- [[tides|TIDES]] — OCEAN's payout layer (DATUM is orthogonal to this)
- [[pplns-jd|SLICE / PPLNS-JD]] — the SV2-JD competitor's payout
- [[braidpool|Braidpool]] — also builds on SV2 + JD
- [[ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] ([CTV Coinbase Payout Tree](../concepts/ctv-coinbase-payout-tree.md)) — CTV addresses the coinbase-space pressure that DATUM's pool-inserted payout outputs create
- [[payout-schema-taxonomy]]
