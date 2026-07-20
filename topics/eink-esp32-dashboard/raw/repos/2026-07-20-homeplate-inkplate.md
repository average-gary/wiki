---
title: "HomePlate (Inkplate) — HA-dashboard-screenshot thin client"
source: https://github.com/lanrat/homeplate
type: repo
tags: [inkplate, homeplate, home-assistant, screenshot, thin-client, wrover, psram, trmnl]
date: 2026-07-20
quality: 3
confidence: medium
summary: "HomePlate targets Inkplate boards (ESP32-WROVER, PSRAM). Thin client that fetches images — a Home Assistant dashboard screenshot (Puppeteer service) and/or a TRMNL mashup. Code doesn't port (WROVER/Inkplate API), but the 'screenshot an HA dashboard -> push to e-ink' pattern transfers."
---

# HomePlate (Inkplate)

- Targets **Inkplate boards** — ESP32 with **WROVER (PSRAM)**, required for full-frame image buffers on large panels.
- **Thin-client model**: fetches images from external sources — a **Home Assistant dashboard screenshot** (via a Puppeteer screenshot service) and/or a **TRMNL "mashup"** from TRMNL servers. Supports PNG/BMP/JPEG. Reports battery back to HA via MQTT.
- **1 month+** battery with deep sleep + partial updates. Apache-2.0.

## Portability
Low — coupled to Inkplate's board API and PSRAM. But useful reference for the **"screenshot an HA dashboard → push to e-ink"** pattern and TRMNL client interop. Concepts transfer even though the code doesn't.
