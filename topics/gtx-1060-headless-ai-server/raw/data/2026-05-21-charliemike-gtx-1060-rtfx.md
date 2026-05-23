---
title: "charliemike.ai — GTX 1060 RTFx benchmark for distil-large-v3-turbo + int8"
source: https://charliemike.ai/benchmarks/
type: data
tags: [benchmark, gtx-1060, rtf, distil-whisper, faster-whisper]
date: 2026-05-21
quality: 4
confidence: medium
agent: 3
summary: "Only first-party benchmark targeting GTX 1060 specifically. ~60x RTFx (1 hour audio in ~1 minute) using distil-large-v3-turbo + int8 via faster-whisper."
---

# GTX 1060 — distil-large-v3-turbo INT8 benchmark

## Methodology

> "Whisper large-v3-turbo with INT8 quantization via faster-whisper."

## Full GPU table

| GPU | VRAM | RTFx | 10s audio | 30s audio | Tier |
|-----|------|------|-----------|-----------|------|
| RTX 5090 | 32 GB | ~200x | ~0.05s | ~0.15s | Ultra |
| RTX 4090 | 24 GB | ~180x | ~0.06s | ~0.17s | Ultra |
| RTX 5070 Ti | 16 GB | ~160x | ~0.06s | ~0.19s | High |
| RTX 4070 | 12 GB | ~140x | ~0.07s | ~0.21s | High |
| RTX 3070 | 8 GB | ~120x | ~0.08s | ~0.25s | Mid |
| RTX 3060 | 12 GB | ~110x | ~0.09s | ~0.27s | Mid |
| GTX 1660 | 6 GB | ~80x | ~0.13s | ~0.38s | Entry |
| **GTX 1060** | **6 GB** | **~60x** | **~0.17s** | **~0.50s** | **Entry** |
| CPU (Parakeet) | N/A | ~10–20x | ~0.5–1.0s | ~1.5–3.0s | Any PC |

## Practical rule of thumb (GTX 1060)

- **distil-large-v3-turbo + int8**: 60x RTFx → 1 hour audio in ~1 minute wall time
- Plain large-v3 int8 (extrapolated): ~3x slower than turbo → ~20x RTFx → 1 hour audio in ~3 minutes
- Plain large-v3 fp32: similar to int8 (memory-bandwidth bound) → ~15-25x RTFx
