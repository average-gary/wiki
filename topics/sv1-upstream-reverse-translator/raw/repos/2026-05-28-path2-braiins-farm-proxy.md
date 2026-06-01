---
title: "Braiins farm-proxy (proprietary commercial prior art)"
source: https://github.com/braiins/farm-proxy
type: repos
tags: [braiins, farm-proxy, hashrate-aggregator, sv1-only, proprietary]
summary: "JS hashrate aggregator from Braiins. SV1-only. No SV2 surface. Closest commercial prior art to a reverse translator, but does not bridge protocol versions — only aggregates SV1 connections."
confidence: medium
ingested: 2026-05-28
ingested_by: path2
quality_score: 3
---

# Braiins farm-proxy

## What it is

A JavaScript proxy that aggregates many miner connections into fewer pool-facing connections. Strictly SV1↔SV1.

## Why it's not a reverse translator

- No SV2 awareness on either side.
- No protocol-version translation, only multiplexing.
- README is silent on V1-vs-V2 — even Braiins's commercial proxy product does not advertise SV2 support, despite Braiins shipping SV2 firmware (BraiinsOS+) and Braiins Pool being SV2-native.

## Structural lesson for the reverse translator

- Multi-miner aggregation logic transfers (1 upstream socket : N downstream channels), but the channel-to-worker-name mapping has to be redone in SV2 channel terms.
- Vardiff + share routing already solved at SV1 layer; the reverse translator can borrow the *shape* but must replumb on SV2 primitives.

## See also

- [[2026-05-28-path2-sri-translator-role]]
- [[2026-05-28-path5-pool-software-landscape]] — pool-software adoption context
