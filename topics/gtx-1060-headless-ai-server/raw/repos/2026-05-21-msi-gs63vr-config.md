---
title: "m3c4j/msi-gs63vr-config — model-specific Linux notes"
source: https://github.com/m3c4j/msi-gs63vr-config
type: repo
tags: [msi, gs63vr, optimus, bios, linux-laptop]
date: 2026-05-21
quality: 3
confidence: medium
agent: 1
summary: "One of the few model-specific Linux config write-ups for MSI GS63VR. Sets BIOS Primary Display = IGFX to manage Pascal dGPU; uses acpi_call to power down idle GTX 1060."
---

# MSI GS63VR Linux config notes

## Hardware confirmed

- Host: GS63VR 7RF REV:1.0
- CPU: Intel i7-7700HQ (8 threads) @ 3.800GHz
- GPU: Intel HD Graphics 630 (iGPU) + GTX 1060 (dGPU, muxless Optimus)

## BIOS

- Set **Primary Display = IGFX** in BIOS to make the dGPU manageable on Linux
- This is the closest GS63VR firmware gets to "disabling" Optimus — there is **no true mux switch** for muxless Optimus laptops
- Boot framebuffer drives via iGPU; GTX 1060 visible only to CUDA/NVIDIA driver

## Linux GPU management

- Blacklist `nouveau` if using proprietary NVIDIA driver
- Use `acpi_call` to power down the discrete Pascal GTX 1060 when idle
- Persist via `/etc/tmpfiles.d/`

For a headless **server** running GPU compute 24/7, you do NOT want to power down the dGPU — leave it up and use `nvidia-persistenced.service` to keep it ready.

## Other quirks

- RGB keyboard via `msi-keyboard` / `msi-perkeyrgb` — irrelevant for headless, harmless to ignore
- Killer E2400 Gigabit Ethernet — works out of the box on 22.04 (`alx`/`atl1c` driver)
- Killer 1535 Wi-Fi (Atheros QCA6174 / `ath10k_pci`) — known firmware-crash issues on Linux. **Use ethernet for headless.**

## See also

- [[msi-ec — GS63VR unimplemented]] — sysfs fan/battery control NOT supported on this model
- [[nbfc-linux]] — fan control fallback
