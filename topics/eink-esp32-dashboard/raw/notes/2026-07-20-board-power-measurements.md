---
title: "Real deep-sleep current of the Waveshare ESP32 driver board (forum measurements)"
source: https://forum.arduino.cc/t/what-is-the-best-power-supply-for-e-paper-esp32-driver-board/1198944
type: notes
tags: [power, deep-sleep, measurement, battery, led-mod, waveshare, gxepd2]
date: 2026-07-20
quality: 5
confidence: high
summary: "Real measured numbers for THIS board: ~1.4mA deep sleep UNMODIFIED (power LED intact), dropping to ~700uA after desoldering the power LED. Panel rail adds ~80-500uA if not gated. Theoretical floor ~20uA only by bypassing the board's LDO/LED/USB entirely. Recommended mods in payoff order."
---

# Real board power measurements

The bare module sleeps at ~10µA, but the **assembled board is far higher**.

## Measured (Arduino forum, real meter readings)
- **~1.4mA deep sleep unmodified** (power LED intact).
- **~700µA after desoldering the power LED** (LED alone ≈ 680–700µA via 2.2K to 3.3V).
- Active ~60mA during a ~30–40s/hour refresh; reporter got ~2 months on 4×AAA (~2000mAh) with LED removed + hourly updates.

## Panel-rail contribution (GxEPD2 discussion #142)
- ~600µA in deep sleep with panel connected; **~80µA when panel power disconnected** → the display/adapter rail is a major contributor. DESPI-C02 boost-converter capacitance suspected.
- Fixes: `display.hibernate()` (calls `powerOff()`), `display.end()` to tri-state pins, 100K pull-up on RST.

## Theoretical floor (Arduino forum HowTo)
- **~20µA total** (≈7µA ESP32 + ≈13µA panel) achievable ONLY by wiring the display to permanent VCC and bypassing the board's LDO/LED/USB. 3.3V systems only.

## Recommended mods (payoff order)
1. **Desolder the power LED** → ~700µA saved instantly.
2. **Power-gate the display** via GPIO4/AO3401 (or `display.hibernate()`) before sleep → up to ~450–520µA recovered.
3. **Disable/cut the CP2102/CH343** VBUS power → ~80µA.
4. For sub-50µA: bypass the RT9193s with an **external ultra-low-Iq LDO**.

## Battery-life implication
Unmodified ~1.4mA is battery-hostile (~2000mAh ÷ 1.4mA ≈ 60 days pure idle). LED removed (~700µA) ≈ doubles it. Display-gated + serial-chip-off (~150–250µA) → many months. Only an external low-Iq LDO reaches the "year+" regime the round-1 6–12 month figure assumed (that figure was for a low-quiescent board like the FireBeetle, NOT this Waveshare board stock).
