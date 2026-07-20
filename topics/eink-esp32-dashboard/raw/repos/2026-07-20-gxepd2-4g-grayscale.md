---
title: "GxEPD2_4G — 4 grey levels on SPI panels (ZinggJM)"
source: https://github.com/ZinggJM/GxEPD2_4G
type: repo
tags: [gxepd2-4g, grayscale, 4-gray, spi, waveshare, good-display, ghosting, wroom]
date: 2026-07-20
quality: 5
confidence: high
summary: "Separate GxEPD2 fork adding 4 grey levels (2-bit) on SPECIFIC SPI panels via a special waveform. Runs on plain WROOM/SPI (paged drawing, no PSRAM) — the only grayscale option for the user's existing board — but only 4 levels, only named panels (GDEW075T7, GDEQ0426T82, GDEW042T2, etc.), with unavoidable ghosting and disabled/unreliable partial refresh."
---

# GxEPD2_4G (4 grey levels on SPI)

The honest "grayscale on the existing cheap SPI hardware" answer.

- **Stock GxEPD2 has NO grey support** (b/w + spot color only). **GxEPD2_4G is a separate fork** adding **4 grey levels** (2-bit: white, light gray, dark gray, black) by abusing the controller's old/new-data buffers with a special waveform.
- Supported 4-gray SPI panels (GoodDisplay/Waveshare): **GDEW027W3 (2.7"), GDEW042T2 / GDEY042T81 (4.2" 400×300), GDEQ0426T82 (4.26" 800×480), GDEW075T7 / GDEY075T7 (7.5" 800×480)**, plus small 1.54/2.13/2.9/3.7" panels. **Only these panels have working 4G waveforms** — arbitrary mono panels don't.
- Uses **paged drawing** → **runs on a plain WROOM/SPI setup, no PSRAM required**. This is the ONE grayscale path that reuses the user's board.
- Heavy limitations: **ghosting unavoidable** (needs `clearScreen()`); result is temperature/panel-dependent; **partial/fast refresh disabled or unreliable in grey mode** (e.g. GDEY075T7 grey partial off by default).
- Not a photo-like solution — 4 levels only, slow full refreshes.
