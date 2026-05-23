---
title: "NVIDIA 535.247.01 supportedchips — GTX 1060 confirmed"
source: https://us.download.nvidia.com/XFree86/Linux-x86_64/535.247.01/README/supportedchips.html
type: article
tags: [nvidia, drivers, gtx-1060, pascal, supported-gpus]
date: 2026-05-21
quality: 6
confidence: high
agent: 2
summary: "535 LTS branch supports GTX 1060 6GB (device IDs 1B83, 1C03, 1C06, 1C23, 1C60). 535 is the workhorse Ubuntu 22.04 ships via nvidia-driver-535 and nvidia-driver-535-server."
---

# NVIDIA Driver 535 — GTX 1060 supported

## Key facts

- 535 is the LTS / "Production Branch" series carried by Ubuntu 22.04 main archive
- GTX 1060 6GB device IDs supported: 1B83, 1C03, 1C06, 1C23, 1C60 (covers MSI GS63VR mobile variants)
- VDPAU feature level: H 2 / H
- Pairs cleanly with CUDA 12.x toolkit
- `-server` (ERD / Enterprise Ready Drivers) variant is preferred for compute boxes

## Branch matrix as of 2026-05-21

| Branch | Version | Pascal? | Notes |
|--------|---------|---------|-------|
| Production | 595.71.05 | Verify | Latest mainline |
| New Feature | 590.48.01 | Verify | |
| Beta | 595.45.04 | — | |
| 580 | 580.95.05 / 580.126.09 | YES | Mainline still |
| 575 | 575.64.03 | YES | New Feature |
| 570 | 570.211.01 / 570.172.08 | YES | Production |
| 550 | 550.144.03 | YES | LTS-ish |
| **535 (LTS)** | **535.247.01** | **YES** | **Recommended for 22.04** |
| 470 (Legacy) | 470.256.02 | YES (covers Maxwell/Pascal/Kepler) | Legacy fallback |

Pascal is **still in mainline** through 580 — has not yet been pushed to 470 legacy as of May 2026.

## Verbatim excerpt

> NVIDIA GeForce GTX 1060 3GB (Device ID: 1B84)
> NVIDIA GeForce GTX 1060 6GB (Device IDs: 1B83, 1C03, 1C06, 1C23, 1C60)
> NVIDIA GeForce GTX 1060 5GB (Device ID: 1C04)
> All are designated with VDPAU feature level 'H 2' or 'H'.
> The document references driver version 535.247.01 specifically.

## Cross-references

- See [[NVIDIA open-gpu-kernel-modules]] — open modules NOT available for Pascal
- See [[CUDA toolkit Pascal removal]] — CUDA 13 dropped sm_61
