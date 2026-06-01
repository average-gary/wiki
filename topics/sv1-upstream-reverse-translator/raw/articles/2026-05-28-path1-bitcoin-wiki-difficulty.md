---
title: "Bitcoin Difficulty — pdiff vs bdiff"
source: https://en.bitcoin.it/wiki/Difficulty
type: articles
tags: [sv1, sv2, difficulty, target, pdiff, bdiff]
summary: "Bitcoin difficulty conventions. pdiff uses 0x00000000FFFFFFFF... as max; bdiff uses the truncated form 0x00000000FFFF0000.... Pool convention is pdiff. The reverse translator must apply pdiff when converting SV1 set_difficulty (float) to SV2 SetTarget (U256)."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 4
---

# pdiff vs bdiff

- **pdiff (pool-diff)**: max target = `0x00000000FFFFFFFF...` (32-bit truncated 0xffffffff). Pool difficulty=1 ↔ this max.
- **bdiff (Bitcoin-diff)**: max target = `0x00000000FFFF0000...` (uses the compact-target encoding's truncated form). Network difficulty=1 ↔ this max.

## Conversion in the reverse translator

`SV2 max_target := pdiff_max / sv1_set_difficulty`.

Lossy in the SV2→SV1 direction (U256 → float64 cannot represent precision past ~2^53), but the reverse translator only does SV1→SV2 here, which is precise enough.

## See also

- [[2026-05-28-path1-sv2-spec-mining-protocol-channels]] — SV2 SetTarget U256 shape
