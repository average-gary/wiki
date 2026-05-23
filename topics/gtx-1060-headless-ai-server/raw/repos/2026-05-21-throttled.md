---
title: "erpalma/throttled — Intel CPU PL1/PL2 + undervolt for Linux"
source: https://github.com/erpalma/throttled
type: repo
tags: [intel, undervolt, msr, kaby-lake, i7-7700hq, plundervolt, secure-boot]
date: 2026-05-21
quality: 5
confidence: medium
agent: 8
summary: "Linux workaround that overrides PL1/PL2 power limits + temperature trip points + undervolt offsets via MSR 0x150. i7-7700HQ (Kaby Lake, 7th gen) supports undervolt; 10th-gen+ are typically locked. Reapplies every 5s on AC, 30s on battery."
---

# throttled (erpalma)

## What it does

Overrides power limit (PL1/PL2) settings to **44W** (29W on battery) and temperature trip points to **95°C** (85°C on battery). Reapplies every 5 seconds (30s on battery) to prevent the EC resetting values to manufacturer defaults.

Undervolt offsets (`MSR 0x150`) on:
- CPU Core
- Cache
- GPU (iGPU)
- System Agent
- Analog I/O

## i7-7700HQ compatibility

> "Undervolt is typically locked from 10th gen onwards"

i7-7700HQ is **7th gen (Kaby Lake) → undervolt should work**. Common offsets for sustained load: **-50mV to -150mV** depending on silicon.

MSI not in the official supported model list, but the MSR 0x150 path is identical across vendors for the same generation.

## Plundervolt / Secure Boot caveat (CVE-2019-11157)

Modern kernels implement MSR lockdown protections. Plundervolt mitigation may block direct MSR writes:

- Kernel Lockdown (active when Secure Boot is on) blocks MSR writes
- Solutions:
  1. **Disable Secure Boot**, OR
  2. Pass `lsm=capability,yama` to remove `lockdown` from LSM kernel param
- Linux 5.9+ logs warnings on writes to unrecognized MSRs
- Required kernel configs: `CONFIG_DEVMEM`, `CONFIG_X86_MSR`

## Config file: `/etc/throttled.conf`

Sections: `[GENERAL]`, `[BATTERY]`, `[AC]`, `[UNDERVOLT]`, `[UNDERVOLT.AC]`, `[UNDERVOLT.BATTERY]`, `[ICCMAX]` (experts only), `[HWP]`, `[CTDP]`.

## Enable

```bash
sudo systemctl enable --now throttled.service
```

## Conflict with thermald

Recommendation: **disable thermald** (`sudo systemctl disable --now thermald`) to avoid throttling conflicts. Some users (e.g., Dell Latitude 7320) report success running `thermald --adaptive` alongside throttled — but disable is the simpler default.

## For GS63VR + 24/7 inference

Conservative starting point:
- PL1=35W, PL2=45W (vs default 45W TDP)
- Undervolt CPU Core / Cache: -80mV (validate stability with prime95 / mprime over 4+ hours)
- Trip temp: 90°C
- Disable thermald
