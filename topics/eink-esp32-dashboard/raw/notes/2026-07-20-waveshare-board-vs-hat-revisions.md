---
title: "Waveshare e-Paper board family: ESP32 board vs Driver HAT vs DESPI (revision clarification)"
source: https://forum.arduino.cc/t/gxepd2-loss-of-contrast-waveshare-e-paper-driver-hat-rev2-3/1190325
type: notes
tags: [waveshare, driver-hat, despi, revision, rev2.3, pwr-pin, clarification]
date: 2026-07-20
quality: 4
confidence: high
summary: "Resolves the naming confusion: three distinct products share 'e-Paper driver' branding. The Rev2.1/2.2/2.3 + PWR-pin history belongs to the passive e-Paper Driver HAT (Raspberry Pi adapter, no MCU) — NOT the all-in-one ESP32 board. DESPI = third-party Good Display adapter."
---

# Waveshare e-paper driver family — three distinct products

Clears up the "Rev3 / PWR pin" confusion from round 1.

1. **e-Paper ESP32 Driver Board** — all-in-one: ESP-32S module + dual RT9193 LDOs + CP2102/CH343, USB-powered. *(This is what the user has.)* No published Rev1/2/3; changes are component-level (CP2102→CH343, micro-B→Type-C).
2. **e-Paper Driver HAT** — passive Raspberry-Pi SPI level-shifter/booster, **no MCU**. **This carries the Rev2.1/2.2/2.3 + PWR-pin history.**
   - Rev2.3 vs Rev2.2: RST no longer power-gates (reset only); **added a dedicated PWR pin** for power on/off; smaller/thinner inductor; connector PH2.0 8-pin → GH1.25 9-pin.
   - The smaller Rev2.3 inductor under-powers heavy 7.5" dithering → contrast loss (a power-delivery regression).
3. **DESPI (C02 etc.)** — third-party Good Display raw-panel adapters, distinct from Waveshare; preferred low-energy adapter in some builds.

**Takeaway**: the round-1 "HAT rev 2.2/2.3 not recommended / PWR pin to 3.3V" caveat is about the passive HAT, not the ESP32 board. It's still relevant if pairing a raw panel via a HAT/DESPI adapter, but the all-in-one ESP32 board doesn't have that PWR-pin story.
