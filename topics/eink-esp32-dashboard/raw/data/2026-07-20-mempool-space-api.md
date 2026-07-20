---
title: "mempool.space REST API — Bitcoin network data endpoints"
source: https://mempool.space/docs/api/rest
type: data
tags: [bitcoin, mempool, api, rest, fees, block-height, price, rate-limit]
date: 2026-07-20
quality: 5
confidence: high
summary: "Official mempool.space REST API. Small payloads ideal for a constrained ESP32: fee recommendations, block tip height (bare integer), mempool stats, difficulty adjustment, and BTC price. HTTP 429 on rate-limit abuse -> poll on the order of minutes, not seconds."
---

# mempool.space REST API

Ideal Bitcoin data source for ESP32 — tiny payloads, HTTPS.

## Key endpoints
- **Fees**: `GET /api/v1/fees/recommended` → `{fastestFee, halfHourFee, hourFee, economyFee, minimumFee}` in sat/vB; also `/api/v1/fees/precise`.
- **Block tip**: `GET /api/blocks/tip/height` → **plain integer text** (no JSON needed, use `atoi`); `/api/blocks/tip/hash`.
- **Mempool stats**: `GET /api/mempool` (backlog); `GET /api/v1/fees/mempool-blocks` (projected blocks).
- **Difficulty**: `GET /api/v1/difficulty-adjustment`.
- **Price**: `GET /api/v1/prices` (BTC in USD/EUR/GBP…); `/api/v1/historical-price`.

## Rate limits
- Exceeding → HTTP **429**; repeated abuse can trigger a ban. No published numeric limit (enterprise sponsorship for higher). **Poll every few minutes, not seconds.**
- Payloads are small → parse with ArduinoJson (or `atoi` for height). Can self-host a mempool instance or use MQTT from your own node to avoid public limits.
