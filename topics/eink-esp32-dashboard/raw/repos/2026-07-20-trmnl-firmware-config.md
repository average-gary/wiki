---
title: "TRMNL firmware config & flashing (usetrmnl/firmware, olivrrrr Waveshare fork)"
source: https://github.com/usetrmnl/firmware
type: repo
tags: [trmnl, firmware, platformio, config, api-base-url, wifimanager, gxepd2, waveshare, bmp]
date: 2026-07-20
quality: 5
confidence: high
summary: "Firmware knobs to point the device at a self-hosted BYOS: API_BASE_URL in include/config.h (default https://trmnl.app -> change to your LAN URL), also persisted as api_url preference. PlatformIO build with a 'waveshare' DEVICE_MODEL env. WiFiManager captive portal, MAC in ID header, downloads 1-bit BMP @ 800x480 rendered via GxEPD2."
---

# TRMNL firmware config & flashing

## Pointing at your BYOS
- `include/config.h` defines **`API_BASE_URL = "https://trmnl.app"`** → change to your BYOS URL (e.g. `http://192.168.x.x:2300`). Also persisted at runtime as the **`api_url`** preference (alongside `api_key`, `friendly_id`, `hostname`, `refresh_rate`), so a BYOS-aware build can set it via captive portal without reflashing.
- `FW_VERSION_STRING` (e.g. "1.8.10") sent as the `FW_VERSION` display header.

## Build & flash
- **PlatformIO** (`platformio.ini`). Envs include a **`waveshare` DEVICE_MODEL** (also `og`, `og_gen2`, `x`, `lilygo`, `paper_s3`). `pio run -e <env>` / `pio run -e <env> -t upload` / `pio device monitor -e <env>`.
- Alt: ESP32 Flash Download Tool — `bootloader.bin`@0x0, `partitions.bin`@0x8000, `boot_app0.bin`@0xe000, firmware@0x10000.

## Runtime flow
- **WiFiManager captive portal**: no stored creds → device raises an AP; user enters WiFi (and server URL on BYOS builds) via web form. Then calls `/api/setup` with `ID: <MAC>` → receives `api_key` + `friendly_id`, saved to NVS. Polls `/api/display` on `refresh_rate`, downloads the **1-bit BMP @ 800×480** from `image_url`, renders via **GxEPD2**.
- The **olivrrrr/firmwareesp32** fork is the Waveshare-ESP32-driver variant; it offers **3 selectable panel init/timing sequences** for the Waveshare 7.5" panel — pick the one matching your panel revision (wrong one → ghosting/blank refresh). Set `DEVICE_MAC`/`config.h`.

## Friction points
Compiled default phones home to trmnl.app (must edit); HTTP-vs-HTTPS/self-signed cert issues on a LAN BYOS; picking the correct Waveshare panel init sequence.
