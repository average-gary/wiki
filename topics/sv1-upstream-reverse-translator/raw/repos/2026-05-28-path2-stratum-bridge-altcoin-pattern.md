---
title: "stratum-bridge altcoin cluster (negative finding)"
source: https://github.com/onemorebsmith/kaspa-stratum-bridge
type: repos
tags: [stratum-bridge, kaspa, altcoin, naming-survey, negative-finding]
summary: "All `*-stratum-bridge` repos in the wild (kaspa, spectre, sedra, pyrin, cryptix, bugna, waglayla, kobra) are SV1↔altcoin-RPC bridges. None touches SV2. The natural naming slot for an SV2-aware bridge is unoccupied — confirms the reverse-translator gap."
confidence: medium
ingested: 2026-05-28
ingested_by: path2
quality_score: 2
---

# stratum-bridge altcoin cluster

## Naming-pattern survey

A cluster of ~10 Go repos following the `*-stratum-bridge` naming convention exists for non-Bitcoin chains: Kaspa, Spectre, Sedra, Pyrin, Cryptix, Bugna, Waglayla, Kobra. All are SV1-listener ↔ altcoin-RPC.

## Negative finding (the actual contribution)

- No Bitcoin-target `stratum-bridge` exists.
- No SV2-aware bridge exists in this cluster.
- The naming slot `sv2-stratum-bridge` or `sv2-to-sv1-bridge` is unclaimed across GitHub public code search.
- Code search for `"sv2_to_sv1"`, `"sv2-to-sv1"`, `"reverse translator"` returned zero hits (auth-walled but corroborated by zero result-page listings).

## Implication

Any reverse-translator implementation has a clean naming opportunity and zero merge-conflict prior art to integrate with. Greenfield code, but on documented spec ground (issue #102).

## See also

- [[2026-05-28-path2-sv2-spec-issue-102-proxy-annex]]
