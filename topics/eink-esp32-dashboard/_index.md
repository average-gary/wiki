---
title: e-Ink ESP32 Dashboard
type: topic-index
created: 2026-07-20
updated: 2026-07-20
tags: [esp32, e-paper, e-ink, waveshare, iot, dashboard, embedded]
sources: 30
articles: 9
---

# e-Ink ESP32 Dashboard

Leveraging a **Waveshare e-Paper ESP32 Driver Board (Rev3)** with an **ESP32-WROOM-32E**
microcontroller to build a low-power, slowly-updating dashboard that renders external
data sources (calendar, Bitcoin network data, weather, etc.) onto an e-paper display.

## Hardware Baseline

- **Driver board:** Waveshare e-Paper ESP32 Driver Board Rev3
- **MCU:** ESP32-WROOM-32E (dual-core Xtensa LX6, Wi-Fi + BLE, 4 MB flash)
- **Display:** Waveshare SPI e-paper panel via the board's e-paper adapter/FPC connector

## Scope

- Firmware stacks / frameworks for driving Waveshare e-paper from ESP32
- Data-source integration (REST/JSON APIs, calendar/CalDAV, Bitcoin/mempool data)
- Power management + deep-sleep refresh cadence for "slow dynamic" updates
- Rendering: partial vs full refresh, ghosting, fonts, layout, server-side vs on-device rendering
- Turnkey / OSS dashboard projects and their architectures

## Start here

- **[Build Playbook](reference/build-playbook.md)** — the actionable answer: how to build this dashboard, step by step, with an opinionated recommended stack.

## Concepts

- [Hardware Platform](concepts/hardware-platform.md) — the board, SPI pin map, and the WROOM-32E RAM ceiling that governs panel choice.
- [Rendering Architecture](concepts/rendering-architecture.md) — the central fork: on-device vs server-side (thin client) rendering.
- [Firmware Stacks](concepts/firmware-stacks.md) — GxEPD2, ESPHome, MicroPython, ESP-IDF; why LVGL is out.
- [Data Sources](concepts/data-sources.md) — calendar, Bitcoin/mempool, weather; on-device JSON + HTTPS reality.
- [Power & Refresh](concepts/power-and-refresh.md) — deep-sleep loop, **corrected battery math for this board**, refresh mechanics, ghosting.
- [Grayscale & Upgrade Path](concepts/grayscale-and-upgrade-path.md) — richer visuals: server-side dithering, GxEPD2_4G, Inkplate/epdiy.
- [Limitations & Gotchas](concepts/limitations-and-gotchas.md) — the steelman of what makes this hard.

## Reference

- [Build Playbook](reference/build-playbook.md) — step-by-step build guide + recommended stack.
- [TRMNL BYOS Walkthrough](reference/trmnl-byos-walkthrough.md) — self-hosted server + Waveshare firmware + Bitcoin screen, concretely.
- [Turnkey & OSS Projects](reference/turnkey-projects.md) — clone/adapt candidates ranked by fit (TRMNL, esp32-weather-epd, ESPHome, MagInkDash, BTClock).

## Outputs

- **[Plan: On-device, self-contained dashboard (no server)](output/plan-ondevice-waveshare-dashboard-2026-07-20.md)** — **active** — fork esp32-weather-epd (GxEPD2), Bitcoin + weather on-device, WiFiManager for portability, calendar dropped for v1, USB power.
- [Plan: Self-hosted TRMNL BYOS dashboard](output/plan-byos-waveshare-dashboard-2026-07-20.md) — *superseded* (server dropped per user; kept for reference). See [output/_index.md](output/_index.md).

## Key findings

- **Feasible and well-trodden.** The board + WROOM-32E is a mainstream e-paper dashboard platform; a Waveshare-targeting TRMNL firmware fork already exists.
- **Two hard constraints**: no PSRAM (→ use a **mono** panel; 7.5" 800×480 ≈ 48 KB fits) and slow, ghosting-prone refresh (→ **deep-sleep, ~15–30 min updates, full-refresh per wake**).
- **The pivotal decision is where you render.** Server-side (thin-client) dodges the RAM ceiling, moves auth/layout off the MCU, and lets you add feeds without reflashing — recommended for a multi-source dashboard.
- **Data is easy where it's small** (mempool.space, Open-Meteo) and hard where it's auth-heavy (Google Calendar → prefer `.ics`, Apps Script proxy, or server-render; avoid on-device OAuth).
- **⚠️ Battery correction (round 2)**: this specific board is **NOT low-power stock** — **~1.4 mA deep sleep** (always-on power LED ≈ 700 µA; RT9193 LDOs; CP2102/CH343). Plan on **weeks not months**, run on USB, or do the LED/display-gating mods. The "6–12 months" figure was a different (FireBeetle) board. **No onboard charger/battery connector/GPIO36 divider.** No official "Rev3" — the Rev2.3/PWR-pin story is the passive HAT, not this board.
- **Richer visuals need new hardware** (Inkplate/ESPHome or epdiy/ESP32-S3 for 8–16 grey levels); cheaper middle grounds are server-side dithering to 1-bit or GxEPD2_4G (4 levels) on the existing board.

## Sources

See [raw/_index.md](raw/_index.md) — **30 sources** (repos 12, data 8, articles 8, notes 2).
