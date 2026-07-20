---
title: "ESP32 sleep modes & power consumption (Last Minute Engineers, DeepBlue)"
source: https://lastminuteengineers.com/esp32-sleep-modes-power-consumption/
type: data
tags: [esp32, deep-sleep, power, current, battery, rtc-memory, timer-wakeup]
date: 2026-07-20
quality: 5
confidence: high
summary: "Authoritative per-wake-source current tables. Deep sleep timer-only wakeup ~6-10uA (lowest); WiFi TX up to 240mA (the burst that dominates a slow dashboard's energy budget). RTC memory persists state across sleeps. Battery runtime = capacity(mAh) / average current(mA)."
---

# ESP32 sleep modes & power consumption

Raw inputs for battery math.

## Deep-sleep current by wake source
- **Timer-only: 6–10µA** (lowest — use `esp_sleep_enable_timer_wakeup()`); ext1: 10µA; touch: 30µA; ext0: 50–100µA; ULP @1%: 100–150µA.
- Deep sleep cuts power to CPU, system RAM, all digital peripherals; only RTC controller + RTC memory remain → ~20,000–40,000× reduction vs active.
- ESP32 classic/WROOM ≈ 10µA timer sleep; ESP32-C3 ≈ 5µA; ESP8266 ≈ 20µA.

## Active current (the energy budget)
- WiFi TX (802.11b 1Mbps): **240mA**; WiFi RX: 95–100mA; BLE TX @0dBm: 130mA. Full active span ~95–380mA.
- The **WiFi burst during each wake dominates** the entire energy budget of a slow dashboard.

## State persistence
- **RTC memory stays powered during deep sleep** → persist boot count, last-drawn hash, partial-refresh counter, NTP epoch in `RTC_DATA_ATTR` variables to skip redundant redraws.

## Battery math
- **runtime (h) = battery capacity (mAh) ÷ average current (mA)**. Duty-cycle the active load: e.g. 83mA×15s per wake ≈ 0.35mAh/day at 30-min intervals + ~14µA idle ≈ 0.34mAh/day → 5000mAh reaches 6–12 months. Interval is the dominant lever.
- **Carrier-board caveat**: the bare module hits ~10µA, but board regulators (AMS1117) + USB-UART (CP2102/CH340) can add 500µA–several mA, silently destroying battery life. Pick a low-quiescent board, cut low-power pads, or MOSFET-gate the panel driver board.
