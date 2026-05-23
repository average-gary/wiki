---
title: "msi-ec — GS63VR 7RF Stealth Pro is UNIMPLEMENTED"
source: https://github.com/BeardOverflow/msi-ec
type: repo
tags: [msi-ec, gs63vr, fan-control, battery-threshold, kernel-module, unimplemented]
date: 2026-05-21
quality: 6
confidence: high
agent: 8
summary: "CRITICAL hardware finding: GS63VR 7RF Stealth Pro is listed as UNIMPLEMENTED in msi-ec support discussion. EC versions 16K2ED61 / 16K2EMS1, tracked in #88 and #247. No sysfs fan control, no battery charge thresholds, no fan profile switching via this driver."
---

# msi-ec — GS63VR is unimplemented

## What msi-ec provides on supported MSI laptops

When supported, sysfs interface exposes:

- **Fan modes**: `/sys/devices/platform/msi-ec/available_fan_modes` and `fan_mode` (auto/silent/basic/advanced)
- **Temps**: `cpu/realtime_temperature`, `gpu/realtime_temperature`
- **Fan speeds**: `cpu/realtime_fan_speed`, `gpu/realtime_fan_speed`
- **Battery thresholds**: `/sys/class/power_supply/<name>/charge_control_start_threshold` and `charge_control_end_threshold`
- **Power profiles**: `shift_mode` (eco/comfort/sport/turbo)
- `cooler_boost`, `webcam`, `kbd_backlight`

## GS63VR status — UNIMPLEMENTED

- Listed under "Very old" / Unimplemented in support discussion
- EC firmware versions: `16K2ED61`, `16K2EMS1`
- Tracked in **issues #88 and #247**
- Minimum kernel for the driver itself: 6.5.0
- **None of the above sysfs interfaces will work on the GS63VR**

## Implication for 24/7 server use

- **No software fan control** via msi-ec → use [[nbfc-linux]] as fallback
- **No software battery charge limit** → if keeping the battery in the laptop, you cannot set a stop-threshold
- **No `shift_mode` / `cooler_boost` software toggle** — use BIOS / hardware Cooler Boost button if present, or rely on `nvidia-smi -pl` for GPU power capping

## Workarounds

| Need | Workaround on GS63VR |
|------|----------------------|
| Fan control | nbfc-linux (NoteBook FanControl C port) |
| GPU power cap | `nvidia-smi -pm 1 && nvidia-smi -pl 65` (systemd oneshot) |
| CPU power limits | throttled (erpalma) — Kaby Lake supports MSR 0x150 |
| Battery charge limit | Remove battery (especially if swollen — fire risk) |
| Thermal monitoring | `lm-sensors` + `nvidia-smi dmon` |
