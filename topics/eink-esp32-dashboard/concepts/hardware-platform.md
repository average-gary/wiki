---
title: Hardware Platform — Waveshare ESP32 Driver Board + WROOM-32E
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [hardware, waveshare, esp32, wroom-32e, pinout, framebuffer, psram]
confidence: high
---

# Hardware Platform

The physical baseline: a **Waveshare e-Paper ESP32 Driver Board (Rev3)** carrying an
**ESP32-WROOM-32E**, connected to a Waveshare/GoodDisplay SPI e-paper panel through the
board's 8-pin FPC adapter.

## The board

- MCU: **ESP32-WROOM-32E** (module), **4 MB flash**.
- E-paper connector: **8-pin FPC** (BUSY, RST, DC, CS, CLK, DIN + VCC/GND) driving the panel over SPI.
- Power: **USB** input (micro-B on older units, **USB-C since 2024-12-30**), or wire a pack to the **5 V pin**. **No onboard LiPo charger and no battery connector** — see below.
- Regulators: **two Richtek RT9193** LDOs (NOT AMS1117), one for the ESP32 3.3 V and one (switchable) for the e-paper rail. USB-UART: **CP2102** (older) or **CH343** (2022+). User **KEY button on GPIO12**.
- **GPIO4 → AO3401 P-MOSFET gates the e-paper 3.3 V rail** — the intended firmware low-power hook.
- Flashing gotcha: may need **GPIO0 → GND during reset** to enter download mode.

> **Corrections to earlier notes** (per the [official schematic](../raw/data/2026-07-20-waveshare-esp32-board-schematic.md)):
> there is **no battery connector / charging IC** on this board, and **no onboard resistor divider on GPIO36** —
> battery monitoring needs an external divider. There is **no officially published "Rev3"**; documented changes
> are component-level (CP2102→CH343, micro-B→USB-C). "Rev3" is informal shorthand for the current unit. The
> **Rev2.2/2.3 + PWR-pin** history belongs to the *passive e-Paper Driver HAT*, not this all-in-one ESP32 board
> ([family clarification](../raw/notes/2026-07-20-waveshare-board-vs-hat-revisions.md)).

## SPI pin map (code-ready)

Confirmed by two independent primary sources (GxEPD2 `GxEPD2_wiring_examples.h` + the ESPHome device profile):

| Signal | GPIO |
|--------|------|
| BUSY | 25 |
| RST | 26 |
| DC | 27 |
| CS | 15 |
| SCK/CLK | 13 |
| DIN/MOSI | 14 |

These are **non-default VSPI pins** → firmware must remap the SPI bus. This is the **#1 wiring gotcha**.
CS on GPIO15 is a strapping pin → ESPHome needs `ignore_strapping_warning: true`.

> **Adapter caveat**: `esp32-weather-epd` warns that Waveshare HAT rev 2.2/2.3 adapters
> are "not recommended" (rev 2.3 needs its PWR pin tied to 3.3 V) and prefers the
> DESPI-C02 adapter. Verify the behavior of your exact Rev3 adapter.

## The RAM ceiling (the governing constraint)

The WROOM-32E has **520 KB on-chip SRAM and NO PSRAM**. After the WiFi + BT stacks,
only ~**200–320 KB** of heap is realistically free. This single fact governs which panels
you can drive and how.

**Framebuffer math** (1 bpp = W × H / 8 bytes):

| Panel | Resolution | Mono buffer | Fits WROOM? |
|-------|-----------|-------------|-------------|
| 2.9" | 128×296 | ~4.7 KB | Easily |
| 4.2" | 400×300 | ~15 KB | Easily |
| 5.83" | 648×480 | ~39 KB | Yes |
| 7.5" | 800×480 | **~48 KB** | Yes, but tight with WiFi/TLS |
| 7.5" tri-color | 880×528 | ~116 KB (2 bit-planes) | Risky |
| 7-color ACeP | 600×448 | ~4 bpp, much larger | No (needs WROVER/S3) |

For a **320×240 16-bit color** frame (~153 KB, ~29% of RAM) there is "almost no room for WiFi."
Mono panels up to 7.5" are the **WROOM-safe zone**; color/large color panels push you to
**WROVER (PSRAM)** or **ESP32-S3**, or you render server-side and stream 1-bit.

Two ways to live within the ceiling on-device:
1. **Paged drawing** (GxEPD2 `firstPage()/nextPage()`) — render the screen in horizontal strips; trades redraw time for RAM.
2. **Move rendering off-device** — see [Rendering Architecture](rendering-architecture.md).

## Boundary: this is an SPI board

The [epdiy](../raw/repos/2026-07-20-epdiy.md) library drives **parallel-interface** e-reader
panels (ED060/ED097/ED047) and needs PSRAM/ESP32-S3 — it is **incompatible** with this SPI
driver board. Use SPI-panel libraries (GxEPD2, Waveshare demo, ESPHome).

## Real power draw (important for battery use)

The bare module sleeps at ~10 µA, but the **assembled board draws ~1.4 mA in deep sleep unmodified** —
dominated by the **always-on power LED** (2.2 kΩ to 3.3 V ≈ 680–700 µA, not software-disableable).
Desoldering it drops the board to **~700 µA**. This is the single biggest correction to the round-1
battery estimate: the "6–12 months on 5000 mAh" figure was for a low-quiescent board (FireBeetle), **not
this Waveshare board stock**. See [Power & Refresh](power-and-refresh.md) for the mod sequence and honest
battery math.

## See also

- [Firmware Stacks](firmware-stacks.md)
- [Power & Refresh](power-and-refresh.md)
- [Grayscale & Richer Visuals](grayscale-and-upgrade-path.md)
- Sources: [WROOM-32E datasheet](../raw/data/2026-07-20-esp32-wroom-32e-datasheet.md), [board schematic](../raw/data/2026-07-20-waveshare-esp32-board-schematic.md), [board pinout](../raw/data/2026-07-20-waveshare-driver-board-pinout.md), [power measurements](../raw/notes/2026-07-20-board-power-measurements.md), [WROOM vs WROVER](../raw/articles/2026-07-20-wroom-vs-wrover-lvgl.md), [GxEPD2](../raw/repos/2026-07-20-gxepd2.md)
