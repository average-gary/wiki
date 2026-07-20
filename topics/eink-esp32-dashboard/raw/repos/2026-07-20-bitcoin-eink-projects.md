---
title: "Bitcoin e-ink displays — BTClock, FreedomClock, on-device mempool clients"
source: https://git.btclock.dev/btclock
type: repo
tags: [bitcoin, mempool, btclock, freedomclock, block-clock, bitaxe, mqtt, e-paper, esp32]
date: 2026-07-20
quality: 4
confidence: high
summary: "Survey of Bitcoin-specific e-ink projects. BTClock (ESP32-S3, multi-panel) and FreedomClock (Heltec integrated e-ink, MIT) show block height / price / fees / halving countdown / Bitaxe stats. Neither matches our single 7.5in WROOM board — but their data layer (mempool.space API, MQTT from own node, Bitaxe WebSocket) is directly reusable as a server plugin or GxEPD2 data source."
---

# Bitcoin e-ink displays (BTClock, FreedomClock, misc)

## BTClock
- ESP32-S3 / ESP-IDF C++, **multi-panel e-paper** (custom hardware, OpenSCAD case files).
- Displays: block height, price, fees, halving countdown, sats-per-currency, mining-pool + **Bitaxe stats** (via WebSocket to a dedicated data service). On-device rendering across split panels.
- Hardware-specific; not portable to a single 7.5" WROOM board.

## FreedomClock DIY Block Clock (mr21free/blockclock)
- ~$30 build, **MIT open source**. Targets **Heltec Vision Master E213/E290** (ESP32 + small integrated e-ink, 2.13"/2.9").
- Two data modes: **MQTT from your own node/Home Assistant**, OR **online from mempool.space**.
- On-device rendering; refresh every few minutes then sleep.

## Also noted
- Hodling-Hog — Lightning/cold-storage balance tracker on e-paper.
- thejerrod/ttogmempool — TTGO mempool.space monitor (HTTPClient + Arduino) confirming the on-device Bitcoin fetch pattern.

## Portability to Waveshare ESP32 Driver Board Rev3
Low–moderate on firmware (different hardware assumptions). **Reuse the data layer, not the hardware layer**: mempool.space REST/MQTT (block height, fees, price), Bitaxe WebSocket stats. Best implemented as a **server-side plugin/recipe** on a TRMNL BYOS server, or as a data module in a GxEPD2 on-device build. `mr21free/blockclock` is MIT reference firmware for the data plumbing.
