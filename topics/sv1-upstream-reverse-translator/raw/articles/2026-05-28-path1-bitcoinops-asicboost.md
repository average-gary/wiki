---
title: "Bitcoin Optech — AsicBoost"
source: https://bitcoinops.org/en/topics/asicboost/
type: articles
tags: [asicboost, version-rolling, segwit, covert, overt]
summary: "Overt AsicBoost = nVersion bit-rolling (BIP-320, ~16 bits, ~15% efficiency). Covert AsicBoost = merkle-root grinding via coinbase extranonce, structurally incompatible with SegWit. The reverse translator preserves overt AsicBoost (via BIP-310 mask passthrough) but structurally precludes covert AsicBoost (because SV1 mining.notify already lacks the witness commitment)."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# AsicBoost — overt vs covert

## Overt (BIP-320 + BIP-310)

Roll the upper 16 bits of nVersion to find headers with shared midstate prefixes. ~15% efficiency improvement on SHA-256 computation. Negotiated explicitly via `mining.configure` `version-rolling`.

## Covert

Roll the merkle root via coinbase extranonce until you find pairs with shared midstate prefixes. **Incompatible with SegWit**: SegWit's coinbase witness commitment changes with each merkle-grinding attempt, so the savings are wiped out.

## Reverse-translator implication

- **Overt**: preserved if the upstream SV1 pool supports BIP-310. Translator forwards the negotiated mask to downstream SV2 jobs as `version_rolling_allowed=true` + the mask.
- **Covert**: structurally impossible through this translator because SV1 `mining.notify` already gives the translator a coinbase that lacks the SegWit witness commitment, so the SV2 downstream never sees anything to grind. (This is normally a SegWit safety property — covert AsicBoost is widely considered antisocial.)

## See also

- [[2026-05-28-path1-bip-310-version-rolling]]
- [[2026-05-28-path1-bip-320-nversion-bits]]
