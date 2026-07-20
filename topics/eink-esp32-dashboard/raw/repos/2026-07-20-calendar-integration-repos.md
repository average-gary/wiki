---
title: "ESP32 calendar-integration approaches (server-render, on-device OAuth, Apps Script proxy)"
source: https://github.com/ugomeda/esp32-epaper-display
type: repo
tags: [calendar, google-calendar, oauth, ics, caldav, apps-script, server-render, esp32, e-paper]
date: 2026-07-20
quality: 4
confidence: high
summary: "Three poles of calendar integration on ESP32 e-paper: (1) ugomeda/esp32-epaper-display — pure server-side Python (Pillow) renders a mono PNG, device blits it, with ETag/304 + Cache-Control-driven sleep; (2) 0015/Fridge-Calendar — full on-device Google Calendar OAuth + JSON parse; (3) Google Apps Script proxy returning device-ready flat text (no OAuth on device)."
---

# ESP32 calendar integration — three architectural poles

## 1. Server-side render (ugomeda/esp32-epaper-display)
- Python server (Pillow + AIOHTTP) renders all widgets (date, weather, Google Calendar, maps) into a single **monochrome PNG**; ESP32 only downloads and blits it. Firmware is minimal C/C++ (ESP-IDF 4.0) — no fonts, no JSON, no per-service logic on-device.
- **ETag caching**: server sends an image-id ETag; unchanged → HTTP 304, device skips the e-paper refresh (saves power + screen wear).
- **Cache-Control `max-age`** tells the device how long to deep-sleep before the next fetch — server drives cadence.
- All complexity (auth, layout, fonts, API drift) lives server-side; firmware rarely reflashed.

## 2. On-device Google Calendar OAuth (0015/Fridge-Calendar)
- The opposite pole: stores OAuth access token, refresh token, client ID + secret in `app_config.h`; calls the Calendar REST API directly.
- Fetches events as JSON, **parses on-device** (nlohmann/json), renders locally — no server.
- EPDiy (ESP32-S3, ESP-IDF 5.3.1); uses **NVS** to persist tokens + retry counters across deep sleep.
- Demonstrates the OAuth-on-MCU burden: on-device refresh-token exchange to keep access alive across power cycles.

## 3. Google Apps Script proxy (rogarmu8) — the cheap middle ground
- Deploy a **Google Apps Script web app** that authenticates to Calendar server-side and exposes a simple HTTP endpoint; the ESP32 just GETs it.
- Returns a **pre-simplified flat text string** (e.g. `Sat May 08 2021  Lunch with friends 14:30:00-15:30:00`) → device does near-zero parsing, no JSON lib or ICS parser needed.
- No OAuth on device; free Apps Script tier hosts it. Rendered on a 7.5" Waveshare via Arduino Waveshare lib; 24h updates.

## Also: Stavros "Timeframe"
- Server-side Selenium **screenshots Google Calendar**, uploads image; ESP32 downloads bitmap only. Sidesteps OAuth/ICS/JSON entirely.

## Takeaway
The `.ics` public-URL parse and the **Apps Script proxy** are the MCU-friendliest calendar patterns; full server-render is the most flexible; on-device OAuth is possible but the heaviest maintenance.
