---
title: "CTranslate2 compute_type on Pascal sm_61 — pick int8, never float16"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: cold
confidence: high
sources:
  - raw/articles/2026-05-21-ctranslate2-quantization-pascal.md
---

# CTranslate2 compute_type on Pascal sm_61

## TL;DR

On GTX 1060 (Pascal CC 6.1):
- **`int8`** ← right answer. INT8 weights, fp32 accumulate. ~50% VRAM.
- `float16` and `bfloat16` are **silently demoted to float32** — no error, no benefit, just a noisy warning.

## The Pascal fallback table

From [[CTranslate2 quantization docs|raw/articles/2026-05-21-ctranslate2-quantization-pascal]]:

| Requested compute_type | Actual on CC 6.1 |
|---|---|
| int8_float32 | int8_float32 |
| int8_float16 | int8_float32 |
| int8_bfloat16 | int8_float32 |
| int16 | float32 |
| **float16** | **float32** ← silent fallback |
| **bfloat16** | **float32** ← silent fallback |

## Confirmed in the wild

[faster-whisper issue #42](https://github.com/SYSTRAN/faster-whisper/issues/42) reports the warning on a GTX 1050 Ti (also Pascal): "Requested float16 compute type, but the target device or backend do not support efficient float16 computation." The model still runs, just at fp32. (confidence: high — confirmed by upstream docs and end-user reports)

## What int8 actually does on Pascal

- Weights stored in INT8 → ~50% VRAM savings vs fp32
- GEMM accumulates in fp32 (since Pascal CC 6.1 lacks fp16/bf16 native)
- Pascal sm_61 introduced **DP4A** (4-element 8-bit dot-product) → INT8 GEMM is plausibly hardware-accelerated; CT2 docs don't claim it explicitly but the kernel path exists

## Practical decision guide

| Goal | Pick | Why |
|------|------|-----|
| Smallest VRAM, fastest inference | `int8` | INT8 weights + DP4A path |
| Code that runs anywhere (Pascal + Turing+) | `int8_float16` | Auto-remaps to int8_float32 on Pascal; uses int8_float16 on Turing+ |
| Maximum accuracy | `float32` | Baseline — but no speed advantage over int8 on Pascal |
| **Don't pick** | `float16`, `bfloat16` | Silent fallback to fp32, only adds warning noise |

## See also

- [[faster-whisper-on-gtx-1060]] — VRAM tables per compute_type
- [[gtx-1060-rtfx-baseline]] — actual benchmark numbers
- [[pascal-driver-cuda-pinning]] — driver/CUDA stack
