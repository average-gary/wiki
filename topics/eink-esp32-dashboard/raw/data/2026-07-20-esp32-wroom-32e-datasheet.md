---
title: "ESP32-WROOM-32E module datasheet (Espressif)"
source: https://documentation.espressif.com/esp32-wroom-32e_esp32-wroom-32ue_datasheet_en.pdf
type: data
tags: [esp32, wroom-32e, datasheet, sram, psram, flash, deep-sleep, hardware]
date: 2026-07-20
quality: 5
confidence: high
summary: "Official datasheet. ESP32-D0WD-V3 dual-core up to 240MHz, 520KB on-chip SRAM, NO PSRAM (the hard RAM ceiling), 4/8/16MB flash options (Waveshare board = 4MB). Chip deep-sleep ~10uA. Establishes the memory constraint that governs which panels fit in a framebuffer."
---

# ESP32-WROOM-32E datasheet (Espressif)

The hard constraints that govern panel choice.

- SoC = **ESP32-D0WD-V3**, dual-core, up to **240MHz**; **520KB on-chip SRAM**; **NO PSRAM** on the -32E (PSRAM only on WROVER modules / D0WDR2-V3 which adds 2MB). Usable heap is far less than 520KB after WiFi + BT stacks (~200–320KB realistically free).
- Flash: **4 / 8 / 16MB** options (Waveshare driver board ships the **4MB** variant); 38-pin module.
- **Chip deep-sleep ≈ 10µA** (RTC timer + RTC memory retention) — but carrier-board LDO + USB-UART add quiescent draw, so real board sleep current is higher unless modified.
- RF: TX average ~239mA / peak ~379mA; RX ~112mA. WiFi 802.11 b/g/n + BT v4.2/BLE.
- Interfaces: SPI, I2C, I2S, UART, ADC, DAC, touch.

## Why this matters
Framebuffer math (1bpp = W×H/8): 800×480 = **48KB** (fits, but tight with WiFi/TLS); tri-color needs 2 bit-planes ≈ 2×; 7-color ≈ 4bpp (far larger). Above what fits → GxEPD2 **paged drawing** is mandatory, or move rendering server-side. Color/large color buffers are why builders pick WROVER/Inkplate.
