---
title: "BIP-310 — version-rolling extension to Stratum"
source: https://github.com/bitcoin/bips/blob/master/bip-0310.mediawiki
type: articles
tags: [sv1, version-rolling, bip-310, asicboost, mining-configure]
summary: "BIP-310 negotiates a version-rolling mask between miner and pool via mining.configure. submit gains a 6th param `version_bits`. Server reconstructs nVersion = (job_version & ~mask) | (version_bits & mask). Maps cleanly to SV2."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# BIP-310 — version-rolling extension

## Negotiation

`mining.configure` requests `version-rolling` extension with a `version-rolling.mask` param. Server returns the AND of (its supported mask) & (miner-requested mask). Both sides record `negotiated_mask`. Subsequent `mining.submit` carries a 6th param `version_bits`.

**Server side**: `nVersion = (job_version & ~negotiated_mask) | (version_bits & negotiated_mask)` — reconstructs the actual block-header version.

## Pairs with BIP-320

BIP-320 reserves nVersion bits 13-28 (mask `0x1fffe000`, ~16 bits) for general-purpose miner use. This is the upper bound for AsicBoost overt rolling.

## Reverse-translator mapping to SV2

- SV2 `NewExtendedMiningJob.version_rolling_allowed: bool` ← derived from upstream pool's BIP-310 advertisement during the translator's startup `mining.configure` exchange.
- SV2 `SubmitSharesExtended.version: u32` (full nVersion) → SV1 `version_bits = submitted_version & negotiated_mask`.
- **Failure mode**: if the upstream SV1 pool does NOT support BIP-310, the reverse translator must hard-set `version_rolling_allowed=false` for all downstream extended jobs, and reject submits whose version differs from the job version. This loses overt-AsicBoost (~15% efficiency) and must be flagged at config time.

## See also

- [[2026-05-28-path1-bip-320-nversion-bits]] — bits reserved for general-purpose use
- [[2026-05-28-path1-bitcoinops-asicboost]] — overt vs covert AsicBoost
