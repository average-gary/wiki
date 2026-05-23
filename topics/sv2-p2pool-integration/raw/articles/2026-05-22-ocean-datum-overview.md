---
title: "OCEAN DATUM Protocol Overview"
source_url: https://ocean.xyz/docs/datum
type: protocol-overview
ingested: 2026-05-22
quality: 4
confidence: high
tags: [ocean, datum, sv1, decentralized-template, comparator]
---

# OCEAN DATUM Protocol Overview

DATUM is the production-deployed competitor approach to decentralized mining. Its anti-SV2 framing is critical context for p2poolv2's pro-SV2 positioning.

## Pitch
> Built from scratch with decentralized template construction in mind.

Positioned as alternative to SV2 because *"Sv2 wouldn't be a viable solution in the near term"* (OCEAN's framing, 2024-era).

## Architecture
- Miners run a **DATUM gateway + local bitcoind**
- Gateway distributes work generated only from local node templates
- Coinbase payouts go directly to miners "instantaneously and without custodial oversight" — no custodial pool wallet
- Pool is being designed to become "almost completely blinded" to template contents in future versions
- 50% pool-fee discount for DATUM users as decentralization incentive

## Wire protocol
- **Stratum V1 + version-rolling (ASICBoost)**, NOT SV2
- Acknowledges V1's inability to retract previously-accepted work
- Trades SV2's protocol elegance for V1's deployable-today reality

## Implementation
Reference at `github.com/OCEAN-xyz/datum_gateway`:
- Communicates with bitcoind via standard `getblocktemplate` RPC + `blocknotify`
- Zero Bitcoin Core patches required
- Pool currently validates blocks during beta; trust model intentionally minimizes pool authority over template content

## Implication for p2poolv2
DATUM proves decentralized templating is achievable on V1 today. p2poolv2's bet is that SV2 is the right long-term protocol layer — but DATUM is the existence proof that miners will actually deploy a production pool that stays on V1 if SV2 ships too late.
