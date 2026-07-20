---
title: Turnkey & OSS Projects — clone/adapt candidates
type: reference
created: 2026-07-20
updated: 2026-07-20
tags: [projects, trmnl, esp32-weather-epd, esphome, maginkdash, btclock, survey]
confidence: high
---

# Turnkey & OSS Projects

Existing open-source dashboards to clone/adapt rather than build from scratch, ranked by fit for a
**Waveshare ESP32 Driver Board Rev3 + WROOM-32E** driving a mono panel.

## 1. TRMNL BYOS + olivrrrr Waveshare firmware fork — best overall fit

[TRMNL](../raw/repos/2026-07-20-trmnl-byos-firmware.md) is a thin-client model: a self-hostable
**BYOS (Build Your Own Server)** renders bitmaps; the device fetches via a trivial 3-endpoint API
(`/api/setup`, `/api/display` → BMP URL, `/api/log`).

- **Seven OSS server implementations** (FastAPI, Django, Next.js, Ruby/Terminus, PHP, JS, Elixir) — self-host any.
- The **olivrrrr/firmwareesp32 fork already targets a Waveshare universal e-paper driver board + 7.5" panel** — proof our exact hardware class runs it. WROOM-32E is sufficient (rendering is server-side).
- Un-brickable design; GPL-3.0 firmware; self-hosted BYOS avoids the paid TRMNL cloud.

**Recommended primary path** for a flexible multi-source dashboard.

## 2. esp32-weather-epd (lmarzen) — best on-device / no-server reference

[esp32-weather-epd](../raw/repos/2026-07-20-esp32-weather-epd.md): GxEPD2-based, supports Waveshare
800×480 panels, **6–12 months on 5000 mAh**, and its README documents the exact driver-board/HAT wiring
caveats we'll hit. GPL-3.0. Expect to remap SPI to our board's pins. Best code to mine for panel
driving + power management if you want zero server infrastructure.

## 3. ESPHome waveshare_epaper — fastest path IF you run Home Assistant

Native support for our 7.5" panel model IDs, on-device lambda rendering, data from HA, and two
ready-to-copy dashboard YAMLs (pavlojs, kevinfr95). No compiled firmware to maintain — just config +
SPI pins. Heed the BUSY-inversion and strapping-pin warnings. See
[ESPHome dashboards](../raw/articles/2026-07-20-esphome-epaper-dashboards.md). MIT/ESLv1.

## 4. MagInkDash (speedyg0nz) — reusable server-side renderer

Not ESP32 on the render side, but its **Pi-renders-image / ESP32-fetches-image** design is exactly the
TRMNL model, with a concrete Apache-2.0 Python renderer combining **Google Calendar + weather + LLM
factoids**. Reuse its server-side approach behind a thin-client firmware.
See [MagInkDash/MagInkCal](../raw/repos/2026-07-20-maginkdash-maginkcal.md).

## Bitcoin note

No single Bitcoin e-ink project matches our board directly (BTClock = multi-panel ESP32-S3;
FreedomClock = Heltec integrated displays). Reuse their **data layer** — mempool.space API / MQTT
block-height + fees + price, and Bitaxe WebSocket stats (MIT `mr21free/blockclock`) — as a
**server-side plugin/recipe** rather than cloning firmware. See
[Bitcoin e-ink projects](../raw/repos/2026-07-20-bitcoin-eink-projects.md).

## Also referenced

- [HomePlate](../raw/repos/2026-07-20-homeplate-inkplate.md) (Inkplate/WROVER) — "screenshot an HA dashboard → push to e-ink" pattern; code doesn't port but the concept does.

## Bottom line

Adopt the **TRMNL BYOS thin-client architecture** as the backbone, seed the ESP32 from the olivrrrr
Waveshare fork, borrow panel-driving/power code and wiring notes from **esp32-weather-epd**, and
implement Bitcoin/weather/calendar as **server-side plugins** informed by MagInkDash and the
BTClock/FreedomClock data layers.

## See also

- [Rendering Architecture](../concepts/rendering-architecture.md)
- [TRMNL BYOS Walkthrough](trmnl-byos-walkthrough.md) — concrete setup for the #1 pick
- [Grayscale & Upgrade Path](../concepts/grayscale-and-upgrade-path.md) — Inkplate/epdiy for richer visuals
- [Build Playbook](build-playbook.md)
