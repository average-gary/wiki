---
title: Data Sources — Calendar, Bitcoin, Weather & the JSON/HTTPS reality
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [data-sources, calendar, bitcoin, mempool, weather, json, https, oauth, apps-script]
confidence: high
---

# Data Sources

What you can feed a slow dashboard, and how to fetch it on a constrained ESP32.

## Bitcoin / network data — ideal for on-device fetch

[mempool.space REST API](../raw/data/2026-07-20-mempool-space-api.md) is the go-to; payloads are tiny:

- **Fees**: `GET /api/v1/fees/recommended` → `{fastestFee, halfHourFee, hourFee, economyFee, minimumFee}` (sat/vB).
- **Block tip height**: `GET /api/blocks/tip/height` → **bare integer text**, parse with `atoi` (no JSON needed).
- **Price**: `GET /api/v1/prices` (BTC in USD/EUR/GBP…). **Difficulty**: `/api/v1/difficulty-adjustment`. **Mempool**: `/api/mempool`.
- **Rate limit**: HTTP **429** on abuse (possible ban); no published numeric limit → **poll every few minutes, not seconds**. Self-host mempool or use MQTT from your own node to avoid public limits.

Bitcoin-specific reference firmware (BTClock, FreedomClock) shows the same plumbing plus Bitaxe
WebSocket stats — see [Bitcoin e-ink projects](../raw/repos/2026-07-20-bitcoin-eink-projects.md).

## Weather — default to Open-Meteo (keyless)

[Open-Meteo](../raw/data/2026-07-20-open-meteo-api.md): `https://api.open-meteo.com/v1/forecast`,
**no API key**, HTTPS, generous free tier. Request only the `current`/`daily` fields you render and use
ArduinoJson's Filter to skip the large `hourly` arrays. (OpenWeatherMap works too but needs a key;
One Call 3.0 free tier = 1000 calls/day.)

## Calendar — the source that most wants offloading

Three architectural poles ([details](../raw/repos/2026-07-20-calendar-integration-repos.md)):

1. **Server-side render / screenshot** (ugomeda, Stavros): calendar handled entirely off-device; ESP32 gets only a bitmap. Most flexible, dodges OAuth.
2. **On-device Google Calendar OAuth** (0015/Fridge-Calendar): store client secret + refresh token in flash, refresh across deep sleep via NVS. Possible but the heaviest maintenance — the "OAuth pain."
3. **Google Apps Script proxy** (rogarmu8): a cloud web-app authenticates to Calendar server-side and returns **device-ready flat text** — no OAuth, no JSON/ICS parser on device, free hosting. The cheapest MCU-friendly pattern.

Also viable: publish a **public `.ics` URL** and parse it on-device.

**Recommendation**: avoid on-device OAuth. Use a public `.ics`, an Apps Script proxy, or full server-render.

## Anything else

Any REST/JSON source works within the same constraints — stocks, transit, sports, home-sensor
aggregates, RSS. If it's auth-heavy or the payload is large, prefer a server-side proxy/render.

## The on-device JSON + HTTPS reality

If you fetch and parse on-device, two references govern survival:

**JSON** ([ArduinoJson how-to](../raw/articles/2026-07-20-arduinojson-httpclient.md)):
- Stream directly: `deserializeJson(doc, http.getStream())` — never buffer to a `String`.
- `http.useHTTP10(true)` to defeat chunked transfer encoding.
- Apply a **Filter** to keep only needed fields; right-size the `JsonDocument`.

**HTTPS** ([ESP32 HTTPS](../raw/articles/2026-07-20-esp32-https-requests.md)) — the real memory tax, not JSON:
- **TLS handshake buffers are the biggest RAM consumer.**
- `setCACert()` verifies identity (production; must maintain rotating root certs) vs `setInsecure()`
  (encrypted but unauthenticated — fine for public read-only APIs / prototyping).
- **Heap-leak gotcha**: `delete` the `WiFiClientSecure`, don't just `stop()` it, or repeated connects crash.

## See also

- [Rendering Architecture](rendering-architecture.md) — on-device vs server-side changes where this parsing happens
- [Power & Refresh](power-and-refresh.md) — poll cadence tuned to data volatility
- [Build Playbook](../reference/build-playbook.md)
