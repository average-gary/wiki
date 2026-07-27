---
title: eink-esp32-dashboard — concepts
type: index
updated: 2026-07-27
---

# concepts

- [[data-sources.md|Data Sources — Calendar, Bitcoin, Weather & the JSON/HTTPS reality]] — What you can feed a slow dashboard, and how to fetch it on a constrained ESP32.
- [[firmware-stacks.md|Firmware Stacks — GxEPD2, ESPHome, MicroPython, ESP-IDF]] — The software choices for driving the panel. Ordered by how commonly they're used for dashboards.
- [[grayscale-and-upgrade-path.md|Grayscale & the Richer-Visuals Upgrade Path]] — If you later want more than 1-bit black/white — grayscale, photo-like imagery, bigger panels — here's what…
- [[hardware-platform.md|Hardware Platform — Waveshare ESP32 Driver Board + WROOM-32E]] — The physical baseline: a Waveshare e-Paper ESP32 Driver Board (Rev3) carrying an ESP32-WROOM-32E, connected…
- [[limitations-and-gotchas.md|Limitations & Gotchas]] — The steelman of what makes this hard — design around these up front.
- [[power-and-refresh.md|Power Management & E-Paper Refresh Mechanics]] — The \"dynamic (slowly)\" requirement lives here: cadence, deep sleep, battery life, and refresh quality.
- [[rendering-architecture.md|Rendering Architecture — On-Device vs Server-Side]] — Every ESP32 e-paper dashboard resolves one fork first, and everything else follows from it: where does the…
