---
title: "esp32-weather-epd (lmarzen) — ESP32 e-paper weather dashboard"
source: https://github.com/lmarzen/esp32-weather-epd
type: repo
tags: [esp32, e-paper, weather, dashboard, gxepd2, battery, on-device-render, waveshare]
date: 2026-07-20
quality: 5
confidence: high
summary: "The canonical battery-optimized, on-device-rendering ESP32 + Waveshare 800x480 weather dashboard. GxEPD2-based, OpenWeatherMap JSON fetched and drawn locally. 6-12 months on 5000mAh at 30-min updates. Documents driver-board/HAT wiring caveats directly relevant to the Rev3 board."
---

# esp32-weather-epd (lmarzen)

The reference implementation for the **no-server / on-device-render** path.

## Hardware
- Generic ESP32 (README recommends **FireBeetle 2 ESP32-E** for USB-C + battery mgmt). WROOM-32E is fine — **no PSRAM needed** (mono 800×480 1bpp ≈ 48KB fits).
- Supports **Waveshare + Good Display 800×480** panels: B/W, B/W/R tri-color, and 7-color ACeP; limited older 640×384.
- **Driver board caution**: primary path uses the **DESPI-C02** adapter. README explicitly says **Waveshare HATs rev 2.2/2.3 are "not recommended"** as the driver (rev 2.3 needs its PWR pin tied to 3.3V). Directly relevant to using a Waveshare driver board — expect to remap SPI pins and mind the PWR pin.

## Architecture
- **On-device rendering**: fetches JSON from OpenWeatherMap (One Call API 3.0 + Air Pollution, free tier 1000 calls/day) and draws with **GxEPD2** locally + GFX fonts.
- Uses full refresh each wake (30-min cadence → partial refresh unnecessary, avoids ghost accumulation).

## Power (concrete, real-world numbers)
- **Deep sleep ≈ 14µA** (13µA after cutting FireBeetle's low-power pad — concrete example of the board/regulator dominating the <10µA chip figure).
- Active draw **≈ 83mA for ~15s** per wake (WiFi connect + fetch + full 7.5" draw).
- **6–12 months on 5000mAh at 30-minute updates.**

## License
GPL-3.0 (fonts/icons under OFL/Apache/BSD).

## Portability to Waveshare ESP32 Driver Board Rev3
High. GxEPD2-based, already supports Waveshare 800×480 panels. Remap SPI to the board's GPIO25/26/27/15/13/14 and heed the HAT/PWR-pin caveat. Best code to mine for panel-driving + power management.
