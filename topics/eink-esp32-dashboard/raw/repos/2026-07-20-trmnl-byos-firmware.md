---
title: "TRMNL BYOS + firmware (usetrmnl, olivrrrr Waveshare fork)"
source: https://docs.trmnl.com/go/diy/byos
type: repo
tags: [trmnl, byos, thin-client, server-render, esp32, waveshare, firmware, self-hosted]
date: 2026-07-20
quality: 5
confidence: high
summary: "TRMNL is a thin-client e-paper device: a self-hostable BYOS server renders bitmaps and the device just fetches+displays them over a trivial 3-endpoint HTTP API. Seven OSS server implementations. The olivrrrr firmware fork already runs on a Waveshare universal e-paper driver board + 7.5in panel — the highest-fit clone candidate for our hardware."
---

# TRMNL — BYOS (Build Your Own Server) + firmware

The best architectural fit for a **server-renders-bitmap** dashboard on our board.

## Model
- Device is a **thin client**; the BYOS server generates the display image and the device fetches it. Design principle: "every device is un-brickable and can run with zero external dependencies."
- **3-endpoint HTTP protocol** (trivial to reimplement): `/api/setup` (provisioning), `/api/display` (returns an `image_url` to a `.bmp`), `/api/log`. Device MAC in headers. `/api/display` also drives cadence via refresh-rate fields.
- **Seven official OSS BYOS server implementations**: Terminus (Ruby/Hanami, flagship), LaraPaper (PHP), Inker (JS), BYOS Next.js, BYOS FastAPI (Python), BYOS Django, BYOS Phoenix (Elixir). Self-host any stack.
- **Plugin/recipe model**: servers host custom plugins/recipes, proxy to TRMNL core; playlists rotate screens.
- **Data sources**: open-ended — anything the server can fetch, rendered to a bitmap (dashboards, stats, charts, system health).

## Firmware
- Official firmware (github.com/usetrmnl/firmware) targets ESP32-C3 / ESP32-S3; GPL-3.0. Device fetches a ready-made `.bmp` over HTTP and pushes to panel — **no on-device rendering**. Includes **BMP header parsing** (validates width/height/bpp/color table).
- **olivrrrr/firmwareesp32 fork explicitly targets "Waveshare universal e-paper raw panel driver board ESP32" + "Waveshare 7.5 inch E-Ink Display"** — essentially our exact hardware class. Proof our board can run maintained OSS e-paper dashboard firmware.
- Setup: captive-portal WiFi config → exchange MAC for API key + friendly ID; MAC pasted into `config.h > DEVICE_MAC`. Cloud path needs a paid TRMNL account, but pairing with a **self-hosted BYOS server avoids that entirely**.

## Portability to Waveshare ESP32 Driver Board Rev3
**Highest of any surveyed.** WROOM-32E (no PSRAM) is sufficient because rendering is server-side. May need pin/board-config tweaks vs the fork's target ESP32, but no architectural change. Recommended primary path: self-host a BYOS server, seed the ESP32 from the olivrrrr fork.
