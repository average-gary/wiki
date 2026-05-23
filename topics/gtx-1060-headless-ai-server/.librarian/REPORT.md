# Librarian Report — 2026-05-23

> Scanned 11 articles in `gtx-1060-headless-ai-server`. Passes: staleness, quality.

## Headline finding

**Wiki is healthy.** The 2026-05-21 structural fix (backfill `sources:`, add `verified:`/`volatility:`) landed; staleness now scores content currency, not missing frontmatter. All 11 articles are above threshold. No new low-quality articles.

One leftover from the prior scan: `ctranslate2-quantization-on-pascal.md` still references `[[gtx-1060-rtfx-baseline]]` in See Also — that article doesn't exist.

## Summary

| Metric | Value |
|--------|-------|
| Articles scanned | 11 |
| Below staleness threshold (70) | 0 |
| Low quality (< 50) | 0 |
| Average staleness | 98/100 |
| Average quality | 92/100 |

## Stale Articles (staleness < threshold)

None.

## Low Quality Articles (quality < 50)

None.

## Notable quality flags

| Article | Quality | Flags |
|---|---|---|
| ctranslate2-quantization-on-pascal | 80/100 | single-source, **broken-xref:gtx-1060-rtfx-baseline** |
| whisperx-known-broken-installs | 85/100 | single-source |

## All Articles (sorted by quality desc)

| Article | Staleness | Quality | Volatility | Flags |
|---|---|---|---|---|
| gpu-thermals-and-ops | 99 | 100 | warm | — |
| pyannote-audio-3.x-on-pascal | 99 | 95 | warm | — |
| headless-ubuntu-laptop-baseline | 100 | 95 | cold | — |
| pascal-driver-cuda-pinning | 99 | 95 | warm | — |
| gpu-bench-and-smoke-tests | 100 | 95 | cold | — |
| gtx-1060-headless-ai-server-synthesis | 98 | 95 | warm | compiled-from: conversation |
| faster-whisper-on-gtx-1060 | 96 | 90 | hot | — |
| farm-vision-on-gtx-1060 | 99 | 90 | warm | — |
| whisperx-vs-manual-pyannote-integration | 96 | 90 | hot | — |
| whisperx-known-broken-installs | 96 | 85 | hot | single-source |
| ctranslate2-quantization-on-pascal | 100 | 80 | cold | single-source, broken-xref |

## Recommended follow-ups

1. **Fix broken cross-ref**: `wiki/concepts/ctranslate2-quantization-on-pascal.md` See Also references `[[gtx-1060-rtfx-baseline]]` — either create that article or remove the link.
2. **Hot-volatility articles deserve refresh attention soon**: `faster-whisper-on-gtx-1060`, `whisperx-vs-manual-pyannote-integration`, `whisperx-known-broken-installs` are tagged `hot` (30-day half-life). They'll cross threshold around mid-July 2026 even with no change in the world.
3. **`whisperx-known-broken-installs`**: still single-sourced. Consider absorbing into a broader pin/troubleshooting article or expanding with version-specific status table.
