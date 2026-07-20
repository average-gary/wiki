---
title: "Open-Meteo Forecast API — keyless weather data"
source: https://open-meteo.com/en/docs
type: data
tags: [weather, open-meteo, api, no-key, json, esp32]
date: 2026-07-20
quality: 4
confidence: high
summary: "The go-to KEYLESS weather API (vs OpenWeatherMap which needs a key). https://api.open-meteo.com/v1/forecast, no key for non-commercial use, HTTPS, generous free tier. Predictable nested JSON -> pair with ArduinoJson filtering to fetch only needed fields on WROOM."
---

# Open-Meteo Forecast API

The canonical keyless weather source for ESP32 dashboards.

- Base: `https://api.open-meteo.com/v1/forecast`, **no API key** for non-commercial use (contrast: OpenWeatherMap requires a key; One Call 3.0 free tier 1000 calls/day).
- Required params `latitude`/`longitude`; blocks `current`, `hourly`, `daily`; variables `temperature_2m`, `weather_code` (WMO codes), `precipitation`; `timezone` param for local time.
- Predictable nested JSON (`current`, `hourly`, `daily`, `*_units`) → pair with **ArduinoJson Filter** to grab only rendered fields and skip large hourly arrays.
- HTTPS. Free tier ~10k calls/day non-commercial → ESP32 polling every 15–30 min is well within limits.
