---
title: "Pascal driver + CUDA pinning for Ubuntu 22.04"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-21-nvidia-open-gpu-kernel-modules.md
  - raw/articles/2026-05-21-cuda-toolkit-pascal-removal.md
  - raw/articles/2026-05-21-nvidia-driver-535-supportedchips.md
  - raw/articles/2026-05-21-ubuntu-server-nvidia-install.md
---

# Pascal driver + CUDA pinning for Ubuntu 22.04

## TL;DR

- **Driver**: `nvidia-driver-535-server` (proprietary, NOT `-open` — Pascal can't use open kernel modules)
- **CUDA**: 12.x (sweet spot 12.4–12.8). **Do NOT install CUDA 13.x** — Pascal sm_61 was removed.
- **Install**: `sudo ubuntu-drivers install --gpgpu`

## Why proprietary, not open

NVIDIA's [open-gpu-kernel-modules](../../raw/repos/2026-05-21-nvidia-open-gpu-kernel-modules.md) explicitly require **Turing or newer**. Pascal (GTX 10-series) and Maxwell are not supported. So `nvidia-driver-XXX-open` is unusable on a GTX 1060 — you must install the proprietary `nvidia-driver-XXX` package. This decision is forced, not optional. (confidence: high)

## CUDA version ceiling

Per the [CUDA toolkit release notes](../../raw/articles/2026-05-21-cuda-toolkit-pascal-removal.md), CUDA Toolkit 13.0 **removed offline compilation and library support** for Maxwell, Pascal, and Volta. The last toolkit series that supports sm_61 is 12.x.

Driver-side, GTX 1060 is still in mainline through driver 580. Pascal has not yet been pushed to the 470 legacy branch as of May 2026, but the EOL signal is clear.

## Recommended branches

| Branch | Status | GTX 1060? | Recommended? |
|--------|--------|-----------|--------------|
| 470 | Legacy (Maxwell/Pascal/Kepler) | Yes | Only if 535+ has issues |
| **535 LTS** | Production | **Yes** | **Default** — ships in 22.04 main, signed/Secure Boot friendly |
| 550 | Production-ish | Yes | Acceptable |
| 570 | Production | Yes | Acceptable |
| 575 / 580 | New Feature / mainline | Yes | Acceptable but bleeding edge |
| 595 | Production (latest) | Verify before installing | — |
| 13.x CUDA | — | **No** | Forbidden |

(Source: [535 supportedchips](../../raw/articles/2026-05-21-nvidia-driver-535-supportedchips.md))

## Install path

```bash
# Headless / compute box (recommended)
sudo ubuntu-drivers install --gpgpu       # selects nvidia-driver-535-server
sudo apt install nvidia-utils-535-server
sudo systemctl enable --now nvidia-persistenced
nvidia-smi                                  # verify

# Or pin a specific branch
sudo ubuntu-drivers install nvidia:535
```

`ubuntu-drivers` installs only **pre-built signed** drivers, which work with Secure Boot out-of-the-box. DKMS variants need manual MOK enrollment. (Source: [Ubuntu server NVIDIA install](../../raw/articles/2026-05-21-ubuntu-server-nvidia-install.md))

## Pin to prevent unattended-upgrade breakage

`/etc/apt/preferences.d/nvidia`:

```
Package: nvidia-* libcuda* cuda-*
Pin: version 535.*
Pin-Priority: 1001
```

See [[unattended-upgrades-pin-nvidia]]. Without pinning, an apt security upgrade can bump the driver and break the CUDA + ctranslate2 + PyTorch stack overnight.

## See also

- [[ctranslate2-quantization-on-pascal]] — fp16 silently falls back to fp32 on sm_61
- [[gpu-bench-and-smoke-tests]] — `gpu-burn` must be built with `make COMPUTE=6.1`
- [[gpu-thermals-and-ops]] — `nvidia-smi -pm` and `-pl` do NOT persist across reboots
