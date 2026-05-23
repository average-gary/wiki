---
title: "CTranslate2 quantization on compute capability 6.1 (Pascal)"
source: https://opennmt.net/CTranslate2/quantization.html
type: article
tags: [ctranslate2, faster-whisper, pascal, sm_61, compute-type, fp16-fallback]
date: 2026-05-21
quality: 6
confidence: high
agent: 3
summary: "CRITICAL Pascal table: float16/bfloat16 silently fall back to float32 on CC 6.1. int8 keeps int8 weights but accumulates in fp32. compute_type='int8' is the right pick on GTX 1060."
---

# CTranslate2 — Pascal (CC 6.1) implicit conversion table

## Key Pascal-specific table

| Requested compute_type | Actual on CC 6.1 (Pascal) |
|---|---|
| int8_float32 | int8_float32 |
| int8_float16 | int8_float32 |
| int8_bfloat16 | int8_float32 |
| int16 | float32 |
| **float16** | **float32** ← silent fallback! |
| **bfloat16** | **float32** ← silent fallback! |

For comparison, CC ≥ 7.0 (Turing+) keeps fp16/int8_float16 native; CC 6.2 falls back to fp32 on everything.

## Verbatim excerpt

> "if the current platform or backend do not support optimized execution for this computation type...then the library converts the model weights to another optimized type."

## Practical implication for GTX 1060

- `compute_type="float16"` is **silently promoted to float32** — no error, no speedup, no VRAM savings vs fp32. Throws warning: "Requested float16 compute type, but the target device or backend do not support efficient float16 computation"
- `compute_type="int8"` (= int8_float32 on Pascal) **works on the GPU** — gives memory savings of int8 weights with fp32 accumulation; possibly DP4A-accelerated
- `compute_type="int8_float16"` is auto-remapped to int8_float32 — safe but no fp16 accumulation benefit

## Recommended ranking on GTX 1060 / Pascal sm_61

1. **`int8`** ← best (~50% VRAM, plausible DP4A acceleration, no fallback warnings)
2. `int8_float16` (same as int8, just cross-GPU portable code)
3. `float32` (baseline, use when accuracy matters)
4. `float16` ← AVOID, silent fallback adds noise without benefit

## Cross-references

- See [[faster-whisper README]] for VRAM benchmarks per compute_type
- See [[charliemike GTX 1060 RTFx benchmark]] for actual 1060 numbers
