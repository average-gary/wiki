---
title: "MagInkDash / MagInkCal (speedyg0nz) — server-rendered e-paper dashboards"
source: https://github.com/speedyg0nz/MagInkDash
type: repo
tags: [maginkdash, maginkcal, server-render, raspberry-pi, inkplate, calendar, weather, thin-client]
date: 2026-07-20
quality: 4
confidence: high
summary: "Canonical reference for the 'render dashboard to an image on a small server, dumb e-ink client fetches it' pattern. MagInkDash: a Pi renders Google Calendar + OpenWeatherMap + ChatGPT factoids to an image; an Inkplate (ESP32) fetches it. MagInkCal is the Pi-native on-device variant. Apache-2.0."
---

# MagInkDash / MagInkCal (speedyg0nz)

NOT ESP32 on the render side, but architecturally the cleanest reference for the thin-client model.

## MagInkCal (on-device, Pi)
- Raspberry Pi Zero WH + Waveshare **12.48" tri-color** + PiSugar2 (battery/RTC).
- Renders on-device in Python; Google Calendar via OAuth; daily RTC wake; **~3–4 weeks battery**. Apache-2.0.

## MagInkDash (server-render → thin ESP32 client) — the relevant pattern
- **Pi renders the full dashboard to an image server-side (Apache)**; an **Inkplate 10 (ESP32)** fetches the image over WiFi — same thin-client model as TRMNL.
- Data sources: **Google Calendar + OpenWeatherMap + OpenAI ChatGPT** (generated factoids).
- Hourly cron; **3–4 months on 1500mAh** thanks to e-ink persistence. Apache-2.0.

## Portability to Waveshare ESP32 Driver Board Rev3
Indirect but valuable. The **server-side Python renderer is fully reusable**; replace the Inkplate client with our Waveshare-driver-board ESP32 running thin image-fetch firmware (e.g. the TRMNL fork). The Pi-native MagInkCal path does not port to bare ESP32. Validates the TRMNL architecture with a concrete calendar+weather+LLM example under a permissive license.
