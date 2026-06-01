---
title: "Slush Pool — Stratum Extensions (mining.configure)"
source: https://github.com/slushpool/stratumprotocol/blob/master/stratum-extensions.mediawiki
type: articles
tags: [sv1, mining-configure, subscribe-extranonce, extension-negotiation]
summary: "Slush Pool's primary spec for Stratum extension negotiation via mining.configure. Defines version-rolling, minimum-difficulty, subscribe-extranonce, info extensions. Foundation for the reverse translator's upstream-pool capability discovery."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# Slush Stratum Extensions

## mining.configure

Negotiation handshake immediately after TCP connect, before subscribe. Miner sends `[extension_names], { params }`; server responds with the subset it supports plus negotiated parameters.

## Relevant extensions for the reverse translator

- **version-rolling** (BIP-310): negotiates the version-rolling mask. See [[2026-05-28-path1-bip-310-version-rolling]].
- **minimum-difficulty**: lets miner request a floor on `mining.set_difficulty` values.
- **subscribe-extranonce**: lets miner receive `mining.set_extranonce` messages mid-session (necessary for pools that re-allocate extranonce1).
- **info**: miner sends descriptive info (worker software/version) — translator should advertise itself.

## Reverse-translator startup sequence

1. TCP connect upstream pool.
2. `mining.configure` request: `["version-rolling", "subscribe-extranonce", "info"]` with desired params.
3. Record negotiated mask + capabilities. Map to SV2 advertisements at SetupConnection time downstream.
4. `mining.subscribe`, then `mining.authorize`.

## See also

- [[2026-05-28-path1-bitcoin-wiki-stratum-mining-protocol]] — base SV1 protocol
