# Librarian Report — 2026-05-23

> Scanned 6 articles in `rust-multi-platform`. Passes: staleness, quality.

## Headline finding

**Wiki is healthy on staleness and content quality.** The 2026-05-21 structural fix landed; staleness now scores currency, not missing frontmatter. All 6 articles above threshold.

The three broken cross-refs from the previous scan have **not been fixed** — those are still present and now show up in quality flags.

## Summary

| Metric | Value |
|--------|-------|
| Articles scanned | 6 |
| Below staleness threshold (70) | 0 |
| Low quality (< 50) | 0 |
| Average staleness | 99/100 |
| Average quality | 93/100 |

## Stale Articles (staleness < threshold)

None.

## Low Quality Articles (quality < 50)

None.

## Notable quality flags

| Article | Quality | Flags |
|---|---|---|
| ui-framework-decision | 95/100 | **broken-xref:browser-wasm-frontend-frameworks** |
| desktop-cross-compile-and-package | 95/100 | **broken-xref:release-pipeline-canonical-2026** |
| wasm-browser-and-server | 95/100 | **broken-xref:release-pipeline-canonical-2026** |
| mobile-ffi-decision-tree | 95/100 | suspect-cross-wiki-xref to gtx-1060/whisperx-known-broken-installs |

## All Articles (sorted by quality desc)

| Article | Staleness | Quality | Volatility | Flags |
|---|---|---|---|---|
| ui-framework-decision | 96 | 95 | hot | broken-xref:browser-wasm-frontend-frameworks |
| desktop-cross-compile-and-package | 96 | 95 | hot | broken-xref:release-pipeline-canonical-2026 |
| mobile-ffi-decision-tree | 99 | 95 | warm | suspect-cross-wiki-xref |
| wasm-browser-and-server | 96 | 95 | hot | broken-xref:release-pipeline-canonical-2026 |
| ios-xcframework-aar-pipeline | 99 | 90 | warm | — |
| rust-multi-platform-synthesis | 98 | 90 | warm | compiled-from: conversation |

## Recommended follow-ups

1. **Two broken cross-refs to `release-pipeline-canonical-2026`** in `desktop-cross-compile-and-package` and `wasm-browser-and-server`. Either create that article (the natural home for cargo-dist + signing combined) or remove the See Also entries.
2. **Broken cross-ref to `browser-wasm-frontend-frameworks`** in `ui-framework-decision`. Concept lives inside `wasm-browser-and-server.md` — fix the link to point there, or rename/split.
3. **Verify cross-wiki link** in `mobile-ffi-decision-tree`: `[[gtx-1060-headless-ai-server/concepts/whisperx-known-broken-installs]]` — that target article does not contain the iroh-ffi context the link claims.
4. **Hot-volatility articles**: `ui-framework-decision`, `desktop-cross-compile-and-package`, `wasm-browser-and-server` are tagged `hot`. Plan refresh by mid-July 2026.
