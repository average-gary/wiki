---
title: Grayscale & the Richer-Visuals Upgrade Path
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [grayscale, epdiy, esp32-s3, psram, inkplate, lilygo, gxepd2-4g, dithering, upgrade]
confidence: high
---

# Grayscale & the Richer-Visuals Upgrade Path

If you later want more than 1-bit black/white — grayscale, photo-like imagery, bigger panels — here's
what actually changes. Short version: **true grayscale on large panels needs new hardware**, but there
are two cheaper middle grounds that reuse (or nearly reuse) what you have.

## The honest constraint

The Waveshare ESP32 Driver Board (WROOM-32E, SPI) is a **dead end for true large-panel grayscale**.
WROOM has no PSRAM and ~300 KB usable SRAM — it can't hold a grayscale framebuffer alongside WiFi
([framebuffer math](../raw/data/2026-07-20-grayscale-hardware-options.md)):

| Panel | Depth | Framebuffer | Needs |
|-------|-------|-------------|-------|
| 960×540 | 4bpp (16 gray) | ~253 KB | PSRAM |
| 1200×825 (Inkplate 10) | 3bpp (8 gray) | ~370 KB | PSRAM |
| 1872×1404 (7.8") | 4bpp | ~1.25 MB | PSRAM |

## Three options, cheapest first

### 1. Server-side dithering to 1-bit — no new hardware (recommended first move)

Do the image processing **off-device** (Floyd–Steinberg / Jarvis dithering + exposure/contrast/gamut,
e.g. the `epaper-dithering` toolchain) and stream a packed 1-bit bitmap to your **existing mono panel**.
This yields genuinely **photo-like *perceived*** output on 1-bit hardware — no true grays, but visually
far richer than naive thresholding. Fits perfectly with the [server-side render](rendering-architecture.md)
architecture you'd likely use anyway.

### 2. GxEPD2_4G — 4 grey levels on the existing SPI board (with caveats)

[GxEPD2_4G](../raw/repos/2026-07-20-gxepd2-4g-grayscale.md) is a **separate fork** (stock GxEPD2 has no
grey support) that gets **4 grey levels** on *specific* SPI panels via a special waveform, using paged
drawing — so it **runs on your WROOM board, no PSRAM**. But: only **named panels**
(GDEW075T7 7.5", GDEQ0426T82 4.26" 800×480, GDEW042T2 4.2", GDEW027W3…), **unavoidable ghosting**
(`clearScreen()` needed), temperature-dependent output, and **partial refresh disabled** in grey mode.
Only worth it if your panel is on the supported list and 4 levels is enough.

### 3. New hardware — real 8–16 level grayscale

- **Easiest (turnkey + ESPHome)**: **Inkplate 6 (800×600) / Inkplate 10 (1200×825)** — ESP32-WROVER
  (PSRAM), **8 gray levels** (3-bit), recycled parallel panels, **first-class ESPHome / Home Assistant**
  support (widgets in YAML, no custom firmware). No partial update in 3-bit grey mode.
- **Max quality / DIY**: **epdiy** — **16 grey levels (4bpp, GC16)** over a parallel bus + TPS65185 PMIC,
  on ED047/ED060/ED078/ED097/ED133 e-reader panels; **V7 targets ESP32-S3**. Turnkey S3 boards:
  **LilyGo T5 4.7" S3 Pro** (960×540, 16-gray, 8 MB PSRAM) and **M5PaperS3** (960×540, 16-gray).
  Note: [epdiy is a parallel-interface driver](../raw/repos/2026-07-20-epdiy.md) — a different world from your SPI board.

## Decision shortcut

| Goal | Do this |
|------|---------|
| Photo-like now, cheaply, keep the board | **Server-side dithered 1-bit** |
| A little grey on the existing board | GxEPD2_4G (if panel supported) |
| Real grays + dashboards, least effort | **Inkplate 6/10 + ESPHome** |
| Max resolution/size/16-level, DIY control | **epdiy on ESP32-S3** (LilyGo T5 / M5PaperS3) |

## See also

- [Hardware Platform](hardware-platform.md) — the RAM ceiling this all stems from
- [Rendering Architecture](rendering-architecture.md) — server-side dithering lives here
- [Build Playbook](../reference/build-playbook.md)
