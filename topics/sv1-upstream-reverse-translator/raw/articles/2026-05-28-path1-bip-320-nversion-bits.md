---
title: "BIP-320 — nVersion bits reserved for general purpose use"
source: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
type: articles
tags: [sv1, sv2, version-rolling, asicboost]
summary: "Reserves nVersion bits 13-28 (mask 0x1fffe000, ~16 bits) for miner version-rolling, removed from BIP9 soft-fork signaling. This is the canonical mask used by both SV1 BIP-310 negotiation and SV2 version_rolling."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# BIP-320 — nVersion bits for general purpose use

Reserves nVersion bits 13-28, mask `0x1fffe000`, for miner version-rolling. Removed from BIP-9 soft-fork signaling so miners can roll without affecting consensus.

## Implication for the reverse translator

The 16 bits of overt AsicBoost rolling are protocol-shared between SV1 (via BIP-310 negotiated mask) and SV2 (`version_rolling_allowed` + version field). The translator just forwards the mask negotiation outcome from the upstream SV1 pool to the downstream SV2 stack.

## See also

- [[2026-05-28-path1-bip-310-version-rolling]]
- [[2026-05-28-path1-bitcoinops-asicboost]]
