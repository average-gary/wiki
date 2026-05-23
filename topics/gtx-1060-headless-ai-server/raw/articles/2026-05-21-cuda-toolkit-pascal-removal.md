---
title: "CUDA Toolkit Release Notes — Pascal removed in CUDA 13.0"
source: https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html
type: article
tags: [cuda, pascal, sm_61, gtx-1060, version-pinning]
date: 2026-05-21
quality: 6
confidence: high
agent: 2
summary: "CRITICAL pinning constraint: CUDA Toolkit 13.0 removed offline compilation and library support for Maxwell/Pascal/Volta. Last supported CUDA series for GTX 1060 is 12.x. CUDA 12.4 minimum driver: 550.54.14 on Linux x86_64."
---

# CUDA Toolkit Pascal removal — pin to 12.x

## Key facts

- CUDA Toolkit **13.0 removed** offline compilation + library support for Maxwell, Pascal, Volta (sm_50/52/53/60/61/70/72)
- Last supported toolkit series for GTX 1060: **CUDA 12.x** (sweet spot 12.4–12.8)
- Architecture support is "feature-complete" — no new features but still maintained
- Driver requirements:
  - CUDA 12.4 needs ≥ 550.54.14 on Linux x86_64
  - CUDA 12.x minor-version compatibility: ≥ 525.60.13 on Linux x86_64

## Verbatim excerpt

> "Architecture support for Maxwell, Pascal, and Volta is considered feature-complete. Offline compilation and library support for these architectures have been removed in CUDA Toolkit 13.0 major version release."
>
> "CUDA Toolkit 12.x series represents the final toolkits that can build applications targeting Pascal GPUs. Users needing Pascal support should use CUDA 12.x or earlier."
>
> "For CUDA 12.4, the minimum driver versions are: Linux x86_64: ≥550.54.14; Windows x86_64: ≥551.61. For CUDA minor version compatibility across the 12.x family, the requirement is: Linux x86_64: ≥525.60.13; Windows x86_64: ≥528.33"

## Decision

Pin to **CUDA 12.x** (recommended 12.4) + **driver 535 LTS** (or 550+). Do NOT install CUDA 13.x — Pascal sm_61 was removed.
