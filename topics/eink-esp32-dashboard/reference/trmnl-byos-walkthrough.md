---
title: TRMNL BYOS Walkthrough — self-hosted server, Waveshare firmware, Bitcoin screen
type: reference
created: 2026-07-20
updated: 2026-07-20
tags: [trmnl, byos, walkthrough, firmware, platformio, bitcoin, mempool, liquid, self-host]
confidence: high
---

# TRMNL BYOS Walkthrough

Concrete path to stand up a self-hosted **BYOS** server, flash the **Waveshare ESP32 firmware** to talk
to it, and author a **Bitcoin (mempool.space) screen**. Everything here is **free and self-hostable — no
TRMNL account required**. (Only TRMNL's *cloud* device-management and hardware are paid; Private Plugins
can be authored on a free cloud account without a device.)

## The device↔server contract

Every BYOS server implements just **three endpoints**, all keyed on the request header `ID: <device MAC>`
([canonical spec = Terminus `doc/api.adoc`](../raw/repos/2026-07-20-trmnl-byos-implementations.md); the
docs pages only list the endpoints and redirect there):

- **`GET /api/setup`** → `{ api_key, image_url (setup.bmp), message, status }` — issues the API key + `friendly_id`.
- **`GET /api/display`** → device sends `FW_VERSION, WIDTH, HEIGHT, MODEL, RSSI, BATTERY_VOLTAGE, …`;
  server returns `{ image_url, filename, refresh_rate (default 900), reset_firmware, update_firmware, special_function, … }`.
- **`POST /api/log`** → returns 204.

## Step A — Stand up a BYOS server

Pick by how you want to build screens ([details](../raw/repos/2026-07-20-trmnl-byos-implementations.md)):

| Server | Rendering | Best for |
|--------|-----------|----------|
| **byos_django** | Playwright/Firefox HTML→bitmap; `POST /api/v1/generate_screen` to push arbitrary HTML | Easiest push-HTML path |
| **byos_next** | Typed React "recipes" (`takumi`/`satori`/`browser` renderers) + playlists | **Coding a custom Bitcoin screen** |
| **byos_hanami / Terminus** (Ruby) | — | Canonical protocol reference |

- **byos_django**: `cp env-sample .env` → `docker compose up -d` → `docker compose exec app ./manage.py migrate` → `createsuperuser`. Serves `:8000`. Set `ALLOWED_HOSTS` (include the device-facing IP/hostname) and `SECRET_KEY`.
- **byos_next**: `cp .env.example .env`; set `POSTGRES_PASSWORD` + `BETTER_AUTH_SECRET` (`openssl rand -base64 32`); `docker-compose up -d`; `:3000`. Set `AUTH_ENABLED=false` for single-user, `REACT_RENDERER=takumi`. First account at `/setup` becomes admin.

Devices aren't pre-provisioned: point the firmware at your server, the device auto-appears in the admin, then you pair it.

## Step B — Flash the Waveshare firmware, pointed at your BYOS

Use [olivrrrr/firmwareesp32](../raw/repos/2026-07-20-trmnl-firmware-config.md) (the Waveshare fork) or `usetrmnl/firmware` with the `waveshare` env.

1. In `include/config.h`, change **`API_BASE_URL`** from `https://trmnl.app` to your BYOS URL (e.g. `http://192.168.1.50:8000`). *(Critical — otherwise the device phones home to TRMNL cloud.)* It's also persisted as the `api_url` preference, so a BYOS-aware build can set it via the captive portal.
2. Set `DEVICE_MAC` / `DEVICE_MODEL`, and pick the correct **Waveshare 7.5" GxEPD2 panel init sequence** (the fork ships 3 — wrong one → ghosting/blank).
3. Build & flash with **PlatformIO**: `pio run -e <waveshare-env> -t upload`; watch with `pio device monitor`. (Or ESP32 Flash Download Tool: bootloader@0x0, partitions@0x8000, boot_app0@0xe000, firmware@0x10000.)
4. Boot → **WiFiManager** captive portal → enter WiFi (and server URL if exposed). Device calls `/api/setup` with its MAC, saves `api_key` + `friendly_id` to NVS, then polls `/api/display` and downloads a **1-bit BMP @ 800×480** to render via GxEPD2.

## Step C — Build the Bitcoin (mempool.space) screen

Two routes:

- **Self-hosted BYOS (recommended, all-free)** — server-side screen:
  - *byos_next*: add a recipe folder `app/(app)/recipes/screens/bitcoin/` exporting `paramsSchema`, `dataSchema`, and a `definition` that fetches `mempool.space/api/v1/fees/recommended`, `/api/blocks/tip/height`, and `/api/v1/prices`, then renders a React screen the renderer converts to the 800×480 bitmap.
  - *byos_django*: fetch mempool.space in a view and push HTML via `POST /api/v1/generate_screen`, or add a Playwright-rendered template.
- **TRMNL cloud Private Plugin (free account, no device needed to author)** — use a **Polling URL** (TRMNL fetches the mempool.space JSON on schedule) or **Webhook** (`POST` data under a `merge_variables` node), then write **Liquid** markup with the layout framework (`.screen`/`.view`/`.layout`, regions `full`/`half`/`quadrant`), referencing `{{ fastestFee }}`, `{{ block_height }}`, `{{ price | money_with_currency }}`. See [plugins/Liquid](../raw/articles/2026-07-20-trmnl-plugins-liquid.md).

## Friction points to expect

1. **Docs vs code gap** — trust the Terminus `doc/api.adoc` schema over the docs pages.
2. **Firmware server URL** — the compiled default is `trmnl.app`; edit `config.h` or use a BYOS build that exposes `api_url`. Watch HTTP-vs-HTTPS / self-signed cert issues on a LAN.
3. **1-bit fidelity** — renderers (Playwright / takumi / ImageMagick guide) must dither/palette-snap to true 1-bit @ 800×480 or the panel looks wrong.
4. **Panel init sequence** — wrong Waveshare 7.5" sequence → ghosting/blank.
5. **Polling-URL docs are thin** — the Webhook path is better documented; confirm polling fields in the plugin UI.

## See also

- [Rendering Architecture](../concepts/rendering-architecture.md) — why this thin-client model fits our board
- [Turnkey Projects](turnkey-projects.md) · [Build Playbook](build-playbook.md)
- [Data Sources](../concepts/data-sources.md) — the mempool.space endpoints
