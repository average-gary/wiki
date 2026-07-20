---
title: "Waveshare e-Paper ESP32 Driver Board — pinout & board facts"
source: https://devices.esphome.io/devices/waveshare-epaper-cloud-module/
type: data
tags: [waveshare, driver-board, pinout, gpio, spi, cp2102, battery-adc, hardware]
date: 2026-07-20
quality: 4
confidence: high
summary: "The Waveshare e-Paper ESP32 Driver Board SPI pinout, confirmed by two independent primary sources (GxEPD2 wiring header + ESPHome device page): BUSY=25, RST=26, DC=27, CS=15, CLK=13, DIN=14 (non-default VSPI). Plus KEY button GPIO12, battery ADC GPIO36, CP2102 USB-UART, USB-C + Li-Po, 8-pin FPC connector."
---

# Waveshare e-Paper ESP32 Driver Board — pinout & facts

**Confirmed by two independent primary sources** (GxEPD2 `GxEPD2_wiring_examples.h` + ESPHome device profile).

## SPI pin map (code-ready)
- **BUSY = GPIO25**
- **RST = GPIO26**
- **DC = GPIO27**
- **CS = GPIO15** (note: strapping pin → ESPHome needs `ignore_strapping_warning: true`)
- **SCK/CLK = GPIO13**
- **DIN/MOSI = GPIO14**

These are **non-default VSPI pins** → the sketch must remap the SPI bus. #1 wiring gotcha.

## Other board facts
- Onboard **USB-UART = CP2102**; user **KEY button on GPIO12**.
- **Battery voltage ADC on GPIO36** (~1/3 divider — needs `attenuation: auto` or ADC saturates).
- Power: **USB-C** input or **3.7V Li-Po** header; 3.3V regulated operation; 3.3V output pin for external components.
- E-paper connector = **8-pin FPC** (BUSY, RST, DC, CS, CLK, DIN + VCC/GND) driving the panel over SPI.
- MCU: **ESP32-WROOM-32(E), 4MB flash**, WiFi b/g/n + BT/BLE.
- Flashing gotcha: may need **GPIO0 → GND during reset** to enter download mode.

## Rev note
The board is commonly labeled Rev2.x/Rev3; the SPI pin map above is stable across these revisions. esp32-weather-epd warns Waveshare HAT rev 2.2/2.3 (a different adapter) needs its PWR pin tied to 3.3V and prefers the DESPI-C02 adapter — worth checking against your exact Rev3 adapter.
