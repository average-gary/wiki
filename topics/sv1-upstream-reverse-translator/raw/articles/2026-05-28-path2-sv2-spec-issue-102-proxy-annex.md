---
title: "sv2-spec issue #102 — proxy annex / V2-to-V1 down-to-up translation"
source: https://github.com/stratum-mining/sv2-spec/issues/102
type: articles
tags: [sv2-spec, reverse-translator, proxy-annex, plebhash, jakubtrnka]
summary: "Tier-1 finding. Issue opened by @plebhash on 2024-10-25, defines four proxy archetypes including verbatim 'V2 to V1 down-to-up translation — zero configuration trivial translation layer for sv2-native miners and legacy sv1 pools.' Companion PR #103 is still WIP/draft 19 months later. Reviewer @jakubtrnka pushed to move the proxy taxonomy to a separate annex rather than the main mining-protocol spec."
confidence: high
ingested: 2026-05-28
ingested_by: path2
quality_score: 5
---

# sv2-spec issue #102 — Proxy taxonomy annex

## The verbatim canonical reference

> "**V2 to V1** down-to-up translation — zero configuration trivial translation layer for **sv2-native miners and legacy sv1 pools**"

This is *the* sentence that names the reverse translator concept in any SRI canonical document. Authored by `@plebhash` on 2024-10-25.

## Status

- Issue still **open** as of 2026-05-28.
- Companion PR #103 (the actual annex draft) is **WIP/draft, ~19 months stale**, with the author's own self-review note "TODO: review correctness."
- Reviewer `@jakubtrnka` pushed to keep proxy taxonomy in a separate annex rather than the main mining-protocol spec — soft political signal that core SRI authors view it as adjacent rather than central.

## The four proxy archetypes (from #102 / #103)

1. **V1-to-V2 up-to-down translation** — existing SRI translator-proxy direction (SV1 miner → SV2 pool).
2. **V2-to-V1 down-to-up translation** — *the reverse translator we're researching*.
3. **V2-to-V2 mining proxy** — SV2 fan-out with no protocol translation.
4. **V2-to-V2 with Job Declaration** — JDC/JDS topology.

## Reverse-translator implications

- The concept has spec-author acknowledgment but zero implementation traction.
- Movement from "main spec" to "annex" suggests the reference implementation is unlikely to land in stratum-mining/sv2-apps until external demand surfaces (or someone sponsors the work).
- The work is greenfield from a code perspective but on solid ground specification-wise — anyone implementing can cite #102/#103 as canonical.

## See also

- [[2026-05-28-path2-sri-translator-role]] — the existing forward role
- [[2026-05-28-path3-sv2-spec-discussion-deployment-scenarios]] — spec section 10.4.5 left blank
