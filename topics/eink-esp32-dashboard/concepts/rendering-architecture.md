---
title: Rendering Architecture — On-Device vs Server-Side
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [architecture, rendering, server-side, on-device, thin-client, bitmap, trmnl]
confidence: high
---

# Rendering Architecture — the central decision

Every ESP32 e-paper dashboard resolves one fork first, and everything else follows from it:
**where does the pixel layout get computed?**

## (A) On-device rendering

The ESP32 fetches structured data (JSON/text), then draws the layout locally with a graphics
library ([GxEPD2](firmware-stacks.md) + Adafruit_GFX + ArduinoJson, or ESPHome lambdas, or MicroPython framebuf).

- **Pros**: fully self-contained; no server to run/maintain; works anywhere with WiFi.
- **Cons**: pays in RAM (framebuffer + TLS buffers + fonts), firmware churn every time an API
  or layout changes, tedious on-device font/layout work, ASCII-only text by default (no Unicode/emoji),
  and on-device OAuth pain for services like Google Calendar.
- **Canonical example**: [esp32-weather-epd](../raw/repos/2026-07-20-esp32-weather-epd.md) — fetches OpenWeatherMap JSON, draws with GxEPD2.

## (B) Server-side rendering (thin client)

A server (Raspberry Pi, cloud VM, or a self-hosted TRMNL BYOS box) fetches all data, composes the
full layout, and renders a **1-bit bitmap**. The ESP32 just **downloads and blits** it, then sleeps.

- **Pros**: firmware becomes trivial and near-permanent ("un-brickable"); all complexity
  (auth, fonts, layout, API drift, dithering) moves to a maintainable server where iteration is
  fast; sidesteps the WROOM RAM ceiling because the device never holds structured data.
- **Cons**: you must run and maintain a server; the device depends on it being up.
- **Canonical examples**: [TRMNL BYOS](../raw/repos/2026-07-20-trmnl-byos-firmware.md), [Stavros "Timeframe"](../raw/articles/2026-07-20-stavros-timeframe.md), [MagInkDash](../raw/repos/2026-07-20-maginkdash-maginkcal.md), [ugomeda/esp32-epaper-display](../raw/repos/2026-07-20-calendar-integration-repos.md).

Both Stavros and ugomeda chose (B) *explicitly* to escape MCU complexity. Stavros even
Selenium-screenshots Google Calendar server-side to dodge on-device OAuth entirely.

## The server can drive the update loop

A well-designed server-render setup makes the device even dumber and more power-efficient:

- **ETag / 304**: server sends an image-id ETag; if the image is unchanged it returns HTTP 304,
  and the device **skips the e-paper refresh** — saving power *and* screen wear.
- **Cache-Control `max-age`**: tells the device exactly how long to deep-sleep before the next fetch
  is worthwhile — the server owns the cadence.
- **Refresh-hash**: Stavros computes a content hash so the device skips the distracting refresh flash
  when nothing changed.

## (C) The hybrid — often the sweet spot

For a multi-source dashboard, mix them:
- Pull **tiny, stable-schema feeds on-device** (mempool.space fees/height, Open-Meteo) — cheap and simple.
- Route the **auth-heavy / layout-heavy source** (Google Calendar) through a lightweight proxy
  (Google Apps Script) or a full server render.

This minimizes both on-device OAuth and firmware maintenance while keeping simple feeds fast.

## Decision guide

| If you… | Choose |
|---------|--------|
| Already run Home Assistant | ESPHome (on-device lambdas fed by HA) — see [Firmware Stacks](firmware-stacks.md) |
| Want zero servers, simple data | On-device GxEPD2 (esp32-weather-epd pattern) |
| Want max flexibility / complex layout / calendar | Server-side render + thin client (TRMNL BYOS) |
| Have a mix of simple + auth-heavy sources | Hybrid |

## See also

- [Firmware Stacks](firmware-stacks.md)
- [Data Sources](data-sources.md)
- [Turnkey Projects](../reference/turnkey-projects.md)
- [Build Playbook](../reference/build-playbook.md)
