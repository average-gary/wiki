---
title: "Grayscale e-paper hardware: epdiy, LilyGo T5 S3, M5PaperS3, Inkplate"
source: https://github.com/vroland/epdiy
type: data
tags: [epdiy, grayscale, esp32-s3, psram, lilygo, m5paper, inkplate, parallel, tps65185, framebuffer]
date: 2026-07-20
quality: 5
confidence: high
summary: "The true-grayscale upgrade path requires new hardware: ESP32-S3/WROVER + PSRAM + parallel-interface panels. epdiy = 16-level (4bpp) grayscale over parallel bus + TPS65185 PMIC on ED047/ED060/ED097/ED133 panels (V7 targets S3). Turnkey: LilyGo T5 4.7in S3 (960x540, 16-gray, 8MB PSRAM), M5PaperS3, Inkplate 6/10 (WROVER, 8-gray, first-class ESPHome/HA support)."
---

# Grayscale hardware options (new-hardware path)

## epdiy (the flagship DIY path)
- **16 grayscale levels (4bpp, GC16 waveform)** — native, not dithered — over a **parallel** interface via a dedicated epdiy driver board + **TPS65185** PMIC (generates panel HV rails).
- Panels: 6" ED060 family, 4.7" ED047TC1, 5" ED050, 7.8" ED078KC1, 9.7" ED097, 13.3" ED133UT2 (recycled Kindle/Kobo-class).
- MCU: ESP32 for hardware V2–V6, **ESP32-S3 for V7** (current, faster). ESP-IDF faster than Arduino for refresh.

## Why PSRAM is non-negotiable (framebuffer math)
- 960×540 @ 4bpp ≈ **253KB**; Inkplate-10 1200×825 @ 3bpp ≈ **370KB**; 7.8" 1872×1404 @ 4bpp ≈ **1.25MB**. All need the **8MB PSRAM** on S3/WROVER — impossible on the mono WROOM board.

## Turnkey "buy it and it runs" boards
- **LilyGo T5 4.7" S3 Pro**: ESP32-S3-WROOM-1, 16MB flash, **8MB PSRAM**, ED047TC1 960×540, 16-gray, epdiy-based; GT911 touch, LoRa, GPS, battery mgmt.
- **M5PaperS3**: ESP32-S3, 4.7" 960×540, 16-gray.
- **Inkplate 6 (800×600) / Inkplate 10 (1200×825)**: ESP32-**WROVER** (PSRAM), **8 gray levels** (3-bit mode), recycled parallel panels, **first-class ESPHome + Home Assistant** support (define widgets in YAML, no custom firmware). No partial update in 3-bit grey mode.

## Honest verdict for the user's board
The Waveshare ESP32 Driver Board (WROOM, SPI) is a **dead end for true large-panel grayscale**. Options:
1. **GxEPD2_4G** — 4 grey levels on the existing board IF the panel is a supported model; heavy caveats.
2. **Server-side dithering to 1-bit** — photo-like perceived output on the existing mono panel, no new hardware (Floyd–Steinberg/Jarvis + exposure/contrast; e.g. `epaper-dithering` PyPI). Recommended first move.
3. **New hardware** — Inkplate (easiest, ESPHome) or epdiy/LilyGo/M5PaperS3 (max quality/DIY) for real 8–16 level grayscale.
