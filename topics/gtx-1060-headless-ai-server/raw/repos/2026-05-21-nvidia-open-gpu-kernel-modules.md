---
title: "NVIDIA open-gpu-kernel-modules"
source: https://github.com/NVIDIA/open-gpu-kernel-modules
type: repo
tags: [nvidia, drivers, kernel-modules, pascal, turing]
date: 2026-05-21
quality: 6
confidence: high
agent: 2
summary: "Definitive confirmation that NVIDIA's open-source kernel modules require Turing or newer. Pascal (GTX 10-series) and Maxwell are explicitly NOT supported. GTX 1060 must use proprietary nvidia-driver-XXX, NOT nvidia-driver-XXX-open."
---

# NVIDIA open-gpu-kernel-modules

## Key facts

- The NVIDIA open kernel modules can be used on any **Turing or later** GPU
- Supported architectures: Turing → Ampere → Ada → Hopper → Blackwell
- **Pascal and Maxwell GPUs are NOT supported by the open kernel modules**
- For GTX 1060 6GB on Ubuntu 22.04: install proprietary `nvidia-driver-XXX` (NOT the `-open` flavor)

## Verbatim excerpt

> "The NVIDIA open kernel modules can be used on any Turing or later GPU"
>
> Supported architectures: Turing (RTX 2060/2070/2080 series, Quadro RTX series), Ampere (RTX 3060/3070/3080 series, A100 series), Ada (RTX 4000/5000/6000 series, L40/L4), Hopper (H100/H200 series), Blackwell (RTX 5000/6000 Blackwell, B200/GB200).
>
> "Pascal and Maxwell GPUs are NOT supported by these open kernel modules. The documentation establishes Turing as the minimum supported architecture, meaning earlier generations like GTX 1080 (Pascal) and GTX 980 (Maxwell) cannot use this code."
