---
title: "The Origins of DATUM"
source: "https://ocean.xyz/docs/datum"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, mining-decentralization, eligius, slush, jason-hughes, history]
summary: "Jason Hughes' essay on DATUM's motivation and naming. DATUM = Decentralized Alternative Templates for Universal Mining. Argues miners had become 'mere sellers of hash power' to pools — the centralization risk being pool-controlled block templates and transaction censorship if a few pools hold >51%. Pitches DATUM as the first fully decentralized mining protocol since Eligius (closed 2017): two components (DATUM gateway + Bitcoin full node), 50% pool-fee discount on OCEAN, non-custodial coinbase payouts."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "datum"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/datum"
content_format: "html"
authors: ["Jason Hughes"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# The Origins of DATUM

> **DATUM** = **D**ecentralized **A**lternative **T**emplates for **U**niversal
> **M**ining.

## Thesis

Miners had been reduced to "mere sellers of hash power" to large pools, no
longer active participants in blockchain construction. DATUM aims to restore
mining to its decentralized roots.

## Historical Arc

- **Bitcoin's early days:** Solo mining; nodes were both miners and ledger
  keepers.
- **Pool emergence:** Slush, Eligius — aggregating hash to dampen variance.
- **Side-effect:** *Pools*, not miners, began constructing block templates,
  centralizing transaction-selection power.

## The Problem

> "This centralized control of the block template construction has reached a
> dangerous peak."

If a handful of pools control >51% of hashrate and choose templates, they
choose which transactions get included — a censorship vector that erodes
Bitcoin's decentralization.

## Technical Solution

DATUM requires two components on the miner side:

1. **DATUM gateway** — talks to mining hardware via Stratum.
2. **Bitcoin full node** — peers with the network, builds templates,
   submits found blocks.

Architecture preserves miner control over the block template while allowing
participation in OCEAN's pool for variance reduction.

## Incentives on OCEAN

- 50% discount on pool fees for DATUM users.
- Non-custodial, instantaneous coinbase payouts directly to miners (TIDES
  + generation transaction).

## Positioning

> Presented as the first fully decentralized mining protocol since **Eligius
> closed in 2017**, claiming Bitcoin's natural evolution toward its original
> vision.

## Cross-Reference

- The mechanics promised here are spelled out in `tides` (payout math) and
  `datum-setup` (operator how-to).
- The 4MB-class `blockmaxweight=3985000` figure in the three node-policy
  docs is what makes "non-custodial coinbase payouts" possible at OCEAN's
  scale (large coinbase output set).
