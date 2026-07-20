---
title: "TRMNL BYOS server implementations & device↔server API contract"
source: https://github.com/usetrmnl/byos_hanami
type: repo
tags: [trmnl, byos, django, nextjs, hanami, terminus, api, self-host, docker, endpoints]
date: 2026-07-20
quality: 5
confidence: high
summary: "The three approachable BYOS servers (byos_django = Playwright HTML->bitmap + push-HTML; byos_next = typed React 'recipes' + playlists; byos_hanami/Terminus = canonical Ruby + the authoritative API spec) and the exact 3-endpoint contract keyed on ID:<MAC>. All fully free/self-hostable, no TRMNL account required."
---

# TRMNL BYOS implementations + API contract

## The 3-endpoint contract (from Terminus doc/api.adoc — the ground truth)
All keyed on request header `ID: <device MAC>` (or `ACCESS_TOKEN`):
- **`GET /api/setup`** → `{ api_key, image_url (setup.bmp), message, status }`. Issues api_key + friendly_id.
- **`GET /api/display`** → request headers include `FW_VERSION, WIDTH, HEIGHT, MODEL, RSSI, REFRESH_RATE, BATTERY_VOLTAGE, ...`; response `{ filename, image_url, refresh_rate (default 900), reset_firmware, update_firmware, firmware_url, special_function, image_url_timeout, temperature_profile, ... }`.
- **`POST /api/log`** → header `ID`, JSON body; returns 204.

docs.trmnl.com only lists these three endpoints and redirects to the Hanami `doc/api.adoc` for the real schema — treat that repo as source of truth, not the docs pages.

## Server options
- **byos_django** (github.com/usetrmnl/byos_django): `cp env-sample .env` → `docker compose up -d` → `manage.py migrate` + `createsuperuser`; `:8000`. Renders HTML→image via **Playwright/Firefox**. Config: `ALLOWED_HOSTS` (must include device-facing IP), `SECRET_KEY`. Devices auto-appear under Admin > Devices after pointing firmware at it. Has `POST /api/v1/generate_screen` (Bearer key, `{device, html}`) to push arbitrary HTML. Default refresh ~900s. **Easiest push-HTML path.**
- **byos_next** (github.com/usetrmnl/byos_next): `cp .env.example .env`, set `POSTGRES_PASSWORD` + `BETTER_AUTH_SECRET`, `docker-compose up -d`, `:3000`. Env: `DATABASE_URL` (Postgres), `AUTH_ENABLED=false` single-user, `REACT_RENDERER` = `takumi`(default)/`satori`/`browser`, `ENABLE_EXTERNAL_CATALOG`. **Recipes/screens are code**: `app/(app)/recipes/screens/<slug>/` exporting `paramsSchema`, `dataSchema`, `definition`. Playlists rotate screens. **Best for coding a custom Bitcoin screen.**
- **byos_hanami / Terminus** (Ruby): `curl .../scripts/docker/quick.sh | bash` → `:2300`. Canonical protocol reference.

## Free/paid boundary
Entire BYOS server + firmware + flashing + server-side screens = **fully free, no TRMNL account**. Only TRMNL's *cloud* device-management/hosted rendering (and hardware) is paid. Private Plugins can be authored on a free cloud account without a device.
