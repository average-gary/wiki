---
title: "ArduinoJson + HTTPClient: streaming JSON on ESP32"
source: https://arduinojson.org/v6/how-to/use-arduinojson-with-httpclient/
type: article
tags: [arduinojson, esp32, json, streaming, memory, https, filter]
date: 2026-07-20
quality: 5
confidence: high
summary: "Official memory-critical pattern for on-device JSON: deserialize directly from the HTTP stream (never buffer to String), useHTTP10(true) to defeat chunked encoding, right-size the JsonDocument, and apply a Filter to keep only needed fields. This is what fits API parsing into WROOM's ~320KB RAM."
---

# ArduinoJson + HTTPClient (official how-to)

The definitive on-device JSON survival pattern.

- **Stream directly**: `deserializeJson(doc, http.getStream())` instead of buffering the whole response into a `String` — "more efficient... saves a large amount of memory."
- Set **`http.useHTTP10(true)`** to disable chunked transfer encoding (which otherwise breaks streamed parsing); else wrap with `ChunkDecodingStream` (StreamUtils).
- HTTPS: swap `WiFiClient` for `WiFiClientSecure` — otherwise identical.
- **Filtering** (`DeserializationOption::Filter`): parse only the few fields you need from a large response — essential for Open-Meteo hourly arrays / Google Calendar event lists on WROOM.
- Right-size the `JsonDocument` (example: 2048 bytes). Streaming + filtering + right-sizing keeps RAM in budget.
- `ReadLoggingStream` for debugging without extra RAM.
