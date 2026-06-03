# Librarian Report — 2026-06-02

> Scanned 21 articles in `open-source-logos-suite`. Passes: staleness, quality.
> **Maintenance pass landed 2026-06-02 15:00 — sections below updated.**

## Summary

| Metric | Initial scan | After maintenance |
|--------|-------|-------|
| Articles scanned | 21 | 21 |
| Below staleness threshold (70) | 0 | 0 |
| Low quality (< 50) | 0 | 0 |
| Average staleness | 98/100 | 99/100 |
| Average quality | 75/100 | 80/100 |
| Content-drift advisories | 3 | **0 — all resolved** |
| `no-see-also` flags | 3 | 0 |
| `thin-sources` flags | 3 | 2 (1 cleared on plugin-trust-model.md) |

**Staleness verdict**: clean. Every article either was created today (Round 2 — 6 articles, 2026-06-02) or 6 days ago (Round 1 — 15 articles, 2026-05-27). All `sources:` references resolve to existing files in `raw/`. Source-chain integrity = 100% across the wiki.

**Quality verdict**: healthy. 6 Round-2 articles score 80-95 (deep, well-sourced, coherent, actionable). 15 Round-1 articles score 65-80; the lower scores are primarily Tier-1 conservative defaults for `coherence` and `utility` (these were not Tier-2-escalated because they aren't stale and aren't `volatility: hot`).

## Stale Articles (staleness < 70)

None.

## Low Quality Articles (quality < 50)

None.

## Content Drift (advisory — NOT captured by metric scoring)

**Resolved 2026-06-02 by the maintenance pass.** All three drift advisories were addressed:

| Article | Drift | Resolution (2026-06-02) |
|---------|-------|----|
| [identity-and-recovery.md](../wiki/concepts/identity-and-recovery.md) | did:plc preference superseded by [nostr-key-rotation.md](../wiki/concepts/nostr-key-rotation.md) | **Rewritten.** Recommendation flipped to Nostr (NIP-22242 + NIP-07 default; NIP-46 bunker hot path; kind:0 social-layer migration convention for compromise). DID method comparison preserved as reference. 4 new sources added (NIP-26, NIP-46, did:plc rotation spec, nostr-how key safety). Quality 65→95. |
| [credible-exit.md](../wiki/concepts/credible-exit.md) | Nostr-rotation paragraph based on stale info | **Narrow-edited.** Architecture-implication identity row now reads "Nostr nsec — portable, signer-pluggable (NIP-07, NIP-46 bunker)…" with cross-link to identity-and-recovery + nostr-key-rotation. "When decentralization actually helps" identity row updated. See Also expanded. Quality 70→80. |
| [decentralized-sync.md](../wiki/concepts/decentralized-sync.md) | ATProto did:plc recommended | **Narrow-edited.** Top-of-article corrected-position note added; "Recommended hybrid model" identity section flipped to Nostr+NIP-22242+NIP-07+NIP-46; CRDT analysis preserved (with Loro trajectory note); See Also expanded. Quality 70→80. |

## Quality Flags (after maintenance)

| Flag | Articles |
|------|----------|
| `no-see-also` | 0 — all three Round-2 articles got See Also sections in the maintenance pass. Each lifted from 95→100. |
| `thin-sources` | 1 — `file-over-app.md` (2 sources; topic is a well-established design principle so thin sourcing is defensible; no action recommended). `identity-and-recovery.md` cleared (rewrite added 4 sources). `plugin-trust-model.md` cleared (Cyberhaven 2024-12 supply-chain case added as raw source + integrated into article). |
| `content-drift` | 0 — all three advisory items resolved. |

## Volatility Distribution

- `hot` (2): ai-bible-study-tools-2026, keyhive-small-group-sync. Both Round-2; expect to re-verify within 30 days.
- `warm` (15): the bulk; Round-1 set + 3 Round-2 articles. Half-life 90 days; comfortable for the next ~60 days at current scores.
- `cold` (4): credible-exit, file-over-app, library-distribution, plugin-trust-model. These are durable design-principle articles; half-life 365 days.

## All Articles (sorted by combined score)

| Article | Staleness | Quality | Volatility | Flags |
|---------|-----------|---------|------------|-------|
| concepts/ai-bible-study-tools-2026 | 100 | 95 | hot | no-see-also |
| concepts/keyhive-small-group-sync | 100 | 95 | hot | no-see-also |
| concepts/walled-translation-api-revocation-history | 100 | 95 | warm | no-see-also |
| concepts/macula-syntactic-search | 100 | 80 | warm | — |
| concepts/nostr-key-rotation | 100 | 80 | warm | — |
| topics/engineering-playbook | 97 | 80 | warm | — |
| reference/decentralized-infra-candidates | 97 | 75 | warm | — |
| reference/open-data-corpus | 97 | 75 | warm | — |
| reference/oss-bible-software-landscape | 97 | 75 | warm | — |
| concepts/biblical-data-licensing | 97 | 75 | warm | — |
| concepts/client-architecture | 97 | 70 | warm | — |
| concepts/credible-exit | 99 | 70 | cold | content-drift (narrow) |
| concepts/decentralized-sync | 97 | 70 | warm | content-drift (cross-link) |
| concepts/decentralized-text-distribution | 97 | 70 | warm | — |
| concepts/search-and-indexing | 97 | 70 | warm | — |
| concepts/study-tool-ux-gap | 97 | 70 | warm | — |
| reference/logos-feature-surface | 97 | 70 | warm | — |
| decisions/library-distribution | 99 | 70 | cold | — |
| decisions/plugin-trust-model | 99 | 65 | cold | thin-sources |
| concepts/file-over-app | 99 | 65 | cold | thin-sources |
| concepts/identity-and-recovery | 97 | 65 | warm | thin-sources, content-drift (rewrite) |

## Recommended Maintenance Actions — STATUS

| # | Action | Status |
|---|---|---|
| 1 | Rewrite `identity-and-recovery.md` to reflect Nostr-wins-but-rotation-is-unsolved per `nostr-key-rotation.md`. | **Done 2026-06-02** — full rewrite; recommendation flipped; 4 new sources; verified=2026-06-02. |
| 2 | Narrow-edit `credible-exit.md` Nostr paragraph + add cross-link. | **Done 2026-06-02** — architecture-implication identity row + decentralization helpfulness row updated; See Also expanded; 1 new source (nostr-how key safety guidance). |
| 3 | Add See Also sections to the 3 Round-2 articles (`ai-bible-study-tools-2026.md`, `keyhive-small-group-sync.md`, `walled-translation-api-revocation-history.md`). | **Done 2026-06-02** — each gets a 6-link See Also. |
| 4 | Cross-link `decentralized-sync.md` → `nostr-key-rotation.md`. | **Done 2026-06-02** — corrected-position note at top; identity recommendation flipped; Loro trajectory note added; See Also expanded. |
| 5 | Optional: add Cyberhaven 2024-12 case as source on `plugin-trust-model.md`. | **Done 2026-06-02** — raw source captured at `raw/articles/2026-06-02-cyberhaven-chrome-extension-supply-chain.md`; new "Update-signature enforcement" section added to the article; `thin-sources` flag cleared. |

All recommendations from the initial scan are resolved. No outstanding maintenance actions.

## Inventory follow-up suggestions

The following durable maintenance items could be tracked as inventory in a `~/wiki/topics/open-source-logos-suite/inventory/` if you want a backlog (not created automatically — show, then ask):

```
INV-LIB-001 | task | Rewrite identity-and-recovery.md (Nostr-correction) | p1
INV-LIB-002 | task | Narrow-edit credible-exit.md Nostr paragraph         | p2
INV-LIB-003 | task | Add See Also to 3 Round-2 concept articles            | p3
INV-LIB-004 | task | Cross-link decentralized-sync.md → nostr-key-rotation | p3
INV-LIB-005 | task | Add Cyberhaven case as source on plugin-trust-model  | p3
INV-LIB-006 | watch | Refresh AI Bible-study tools article in 30 days (hot)| p2
INV-LIB-007 | watch | Refresh Keyhive article on next non-0.0.0 release    | p2
```

Currently this topic wiki has no `inventory/` directory; if you want one, run `/wiki:inventory` (or hand-create).
