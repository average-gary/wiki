---
title: "Waveshare e-Paper ESP32 Driver Board — official schematic (parsed)"
source: https://files.waveshare.com/upload/8/80/E-Paper_ESP32_Driver_Board_Schematic.pdf
type: data
tags: [waveshare, schematic, rt9193, cp2102, regulator, power, mosfet, no-battery, corrections]
date: 2026-07-20
quality: 5
confidence: high
summary: "Primary schematic. Corrects earlier assumptions: regulators are TWO Richtek RT9193 LDOs (NOT AMS1117), ~90uA quiescent each; USB-UART = CP2102 (older rev; CH343 on newest). NO onboard battery connector, NO LiPo charger, NO GPIO36 divider. GPIO4 -> S8050 -> AO3401 P-MOSFET gates the e-paper 3.3V rail. Power LED is hard-wired (2.2K to 3.3V), always on."
---

# Waveshare e-Paper ESP32 Driver Board — schematic

**Primary source; corrects several round-1 facts.**

- **Regulators are NOT AMS1117.** Two **Richtek RT9193** 300mA CMOS LDOs: **U2** (VDD5V→VDD3V3, feeds the ESP-32S) and **U3** (VDD5V'→EPD_3.3V, feeds the panel). RT9193 quiescent ~90µA each → ~180µA from the pair.
- **USB-UART = CP2102** (U1, Silabs) on the parsed (micro-B) revision; fed from VBUS via SW1 selectable resistor. ~80µA idle. Newest units use **CH343** (2022 swap).
- **MCU = ESP-32S module** (M1, WROOM-type), ~10µA bare deep sleep.
- **NO battery connector, NO LiPo charging IC.** Power enters via **USB micro-B** through Schottky D3 (B5819WS) to VDD5V, or directly on the **VDD5V pin (J4 pin 19)**. No VBAT/JST-PH port, no charger.
- **Display power-gating**: IO4 → Q32 (S8050) → Q31 (**AO3401 P-MOSFET**, R33/R34=100K) switches VDD5V→VDD5V'. So **GPIO4 can cut the e-paper regulator (U3)** — the intended low-power hook.
- **Power LED (LED2)**: via R2=2.2K straight to VDD3V3 — **always on, NOT software-controllable** (~680–700µA). LED1 on IO2 via R1=470.
- **No onboard resistor divider on GPIO36/SENSOR_VP** — it's routed only to the IO headers. Battery monitoring needs an EXTERNAL divider. (Round-1 note of "battery ADC on GPIO36" came from an ESPHome device profile that may describe a variant; the schematic shows no divider.)

## Revision reality
No officially published "Rev3." Documented board changes are component-level: **2022 CP2102→CH343** serial chip swap, and **2024-12-30 USB micro-B→USB Type-C**. "Rev3" is likely informal shorthand for the current Type-C/CH343 unit.
