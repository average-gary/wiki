---
title: "WROOM vs WROVER (PSRAM) & why LVGL is a poor fit for e-paper"
source: https://nexcir.com/esp32-wroom-vs-wrover-modules-when-do-you-need-extra-psram/
type: article
tags: [wroom, wrover, psram, sram, framebuffer, lvgl, e-paper, memory]
date: 2026-07-20
quality: 4
confidence: high
summary: "The hard RAM numbers that decide safe panel sizes on WROOM (520KB SRAM, no PSRAM; ~320KB heap free). Mono 800x480 1bpp (~48KB) is the WROOM-safe zone; a 320x240 16-bit color frame (~153KB) is why color builders pick WROVER/Inkplate. LVGL runs on mono e-paper but is impractical (designed for fast LCDs, fights the refresh model)."
---

# WROOM vs WROVER & LVGL-on-e-paper

## Memory ceiling
- **WROOM = 520KB internal SRAM, NO PSRAM**; usable heap far less after WiFi+BT (~200–320KB free). **WROVER = same 520KB + 4–8MB PSRAM** (GPIO16/17 reserved).
- Framebuffer math: 320×240 16-bit color ≈ **153KB (~29% of WROOM RAM)** → "almost no room for WiFi." Mono e-paper (800×480 1bpp ≈ **48KB**) is the **WROOM-safe zone**. Tri-color needs a 2nd buffer; 7-color ≈ 4bpp. Color/large buffers are why builders pick WROVER or Inkplate.

## LVGL on e-paper — avoid
- LVGL *runs* on mono e-paper but is impractical: after the first draw it "does not want to fully refresh," producing partial random-noise redraws; needs exact `hor_res/ver_res` match (SSD1680 vs SSD1681 200px cap); "unsuitable for frequent UI updates."
- LVGL is designed for **fast-refresh LCDs**, not e-paper. Use GxEPD2/Adafruit_GFX drawing or server-render instead.
