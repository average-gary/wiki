---
title: Build Playbook — a slow e-ink dashboard on the Waveshare ESP32 board
type: reference
created: 2026-07-20
updated: 2026-07-20
tags: [playbook, build, dashboard, workflow, recommendation]
confidence: high
---

# Build Playbook

**Question**: How can we leverage a Waveshare e-Paper ESP32 Driver Board (Rev3) + ESP32-WROOM-32E to
do slow dynamic updates from various data sources — a dashboard with calendar, Bitcoin network data,
and other feeds?

**Short answer**: Yes — this is a mainstream, well-trodden use case. The hardware is well-supported;
the only real constraints are the WROOM-32E's lack of PSRAM (→ use a **mono** panel) and e-paper's slow,
ghosting-prone refresh (→ **deep-sleep, update every 15–30 min, full-refresh per wake**). The single most
important design choice is **where you render** — on-device vs on a small server.

## Step 0 — Pick your panel (do this first)

The WROOM-32E has no PSRAM, so the panel decides everything downstream ([why](../concepts/hardware-platform.md)):

- **Recommended: a mono (B/W) panel, 4.2"–7.5".** 7.5" 800×480 1bpp ≈ 48 KB — fits WROOM comfortably,
  big enough for a rich dashboard, ~2–5 s refresh.
- Avoid tri-color / 7-color unless you have a strong reason: 2×–4× the RAM, 15–35 s refresh, sub-zero
  temperature limits, stricter ghosting rules. If you want color, move to WROVER/ESP32-S3 or render server-side.

## Step 1 — Choose the rendering architecture

This is the pivotal fork ([full comparison](../concepts/rendering-architecture.md)):

| Your situation | Path | Starting point |
|----------------|------|----------------|
| Want max flexibility, calendar + many feeds, willing to run a small server | **Server-side render (thin client)** | TRMNL BYOS |
| Already run Home Assistant | **ESPHome** (on-device lambdas fed by HA) | ESPHome `waveshare_epaper` |
| Want zero servers, simple feeds only | **On-device GxEPD2** | esp32-weather-epd |
| Mix of simple + auth-heavy feeds | **Hybrid** | on-device feeds + Apps Script/server for calendar |

**Recommendation for this project** (calendar + Bitcoin + "other"): the **server-side / thin-client**
path via a self-hosted **TRMNL BYOS** server. Reasons: it dodges the WROOM RAM ceiling, moves all auth
(Google Calendar) and layout off the fragile microcontroller, lets you add data sources by editing a
server plugin instead of reflashing firmware, and there's already a Waveshare-targeting firmware fork.

If you'd rather avoid running a server at all, the **esp32-weather-epd (GxEPD2)** codebase is the
cleanest on-device starting point — extend its fetch layer with mempool.space and a calendar `.ics`/proxy.

## Step 2 — Wire it up (firmware plumbing)

- Remap SPI to the board's pins: **BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14** ([pinout](../raw/data/2026-07-20-waveshare-driver-board-pinout.md)). These are non-default → set them explicitly.
- On ESPHome, set `ignore_strapping_warning: true` (CS=GPIO15) and **invert BUSY** if your panel's model requires it (permanent-damage risk otherwise).
- To flash: hold **GPIO0→GND during reset** if it won't enter download mode.
- Battery voltage is on **GPIO36** (~⅓ divider).

## Step 3 — Wire up the data sources

([full detail](../concepts/data-sources.md))

- **Bitcoin** (easy, on-device-friendly): [mempool.space](../raw/data/2026-07-20-mempool-space-api.md)
  — `/api/v1/fees/recommended`, `/api/blocks/tip/height` (bare integer), `/api/v1/prices`. Poll every few
  minutes max (HTTP 429 on abuse).
- **Weather**: [Open-Meteo](../raw/data/2026-07-20-open-meteo-api.md) (no API key). Filter the JSON to
  just the fields you render.
- **Calendar** (the hard one — avoid on-device OAuth): publish a **public `.ics`** and parse it, or deploy
  a **Google Apps Script proxy** that returns device-ready flat text, or render it server-side. See the
  [three poles](../raw/repos/2026-07-20-calendar-integration-repos.md).
- If parsing JSON on-device: **stream** with `deserializeJson(doc, http.getStream())`, `useHTTP10(true)`,
  and a **Filter**; for HTTPS use `setInsecure()` for public read-only APIs (or maintain a CA cert) and
  `delete` the secure client to avoid the heap leak ([JSON](../raw/articles/2026-07-20-arduinojson-httpclient.md),
  [HTTPS](../raw/articles/2026-07-20-esp32-https-requests.md)).

## Step 4 — Power & refresh loop

([full detail](../concepts/power-and-refresh.md))

- Loop: **wake (RTC timer) → WiFi → NTP → fetch → draw → deep sleep.** Keep awake ~5–15 s.
- **Update every 15–30 min** for months of battery (5000 mAh → 6–12 months). Tune per feed: calendar hourly/daily, weather 10–30 min, Bitcoin a few minutes.
- **Full-refresh per wake** (partial refresh breaks after deep sleep, and multi-minute intervals don't benefit from partial). Respect the **~180 s minimum** and **sleep the panel** after each refresh.
- Persist a **content hash in RTC memory** to skip redraws when nothing changed (avoids the refresh flash + saves power). In a server-render setup, let the server's **ETag/304 + Cache-Control** drive this.
- Mind the **carrier-board idle current** (regulator + CP2102) — the biggest real-world battery killer.

## Step 5 — Iterate

- Start from a working reference ([Turnkey Projects](turnkey-projects.md)) rather than a blank sketch.
- Add data sources one at a time; in the server-render path each is a server plugin (no reflash).
- Layout: for on-device, use GFX/U8g2 fonts + [image2cpp](../raw/articles/2026-07-20-image2cpp-conversion.md) for icons; for server-render, do layout + dithering in Python/Pillow and stream 1-bit.

## Recommended concrete stack (opinionated)

1. **Panel**: Waveshare 7.5" V2 **mono** (800×480).
2. **Architecture**: self-hosted **TRMNL BYOS** (byos_django for push-HTML, or byos_next to code screens), device runs the **olivrrrr Waveshare firmware fork** with `API_BASE_URL` pointed at your server. Full walkthrough: **[TRMNL BYOS Walkthrough](trmnl-byos-walkthrough.md)**.
3. **Data screens on the server**: Google Calendar (server-side auth), mempool.space (fees/height/price), Open-Meteo. Add more freely.
4. **Cadence**: server sets ~15–30 min via `refresh_rate`; device deep-sleeps between.
5. **Power**: this board is **USB-power-friendly, not battery-friendly stock** (~1.4 mA sleep — see below). For a wall/desk dashboard, just run it on USB. For battery, do the LED + display-gating mods first.
6. **Fallback if no server desired**: fork **esp32-weather-epd**, add mempool + `.ics` calendar, on-device GxEPD2 full-refresh per wake.

## If you want richer visuals later

The mono panel + WROOM is a dead-end for true grayscale, but there are cheaper middle grounds
(server-side dithering to 1-bit on the *existing* panel; GxEPD2_4G for 4 grey levels on supported panels)
and hardware upgrades (Inkplate + ESPHome, or epdiy on ESP32-S3). See
**[Grayscale & the Upgrade Path](../concepts/grayscale-and-upgrade-path.md)**.

## ⚠️ Battery reality (corrected)

Do not assume the "6–12 months on 5000 mAh" figure — that was a low-quiescent FireBeetle board. **This
Waveshare board draws ~1.4 mA in deep sleep stock** (the always-on power LED alone is ~700 µA). Plan on
**weeks, not months** unmodified. Desolder the LED (~700 µA), gate the display rail via GPIO4/`hibernate()`
(~150–250 µA), and for year+ life use an external low-Iq LDO. Full detail + table:
[Power & Refresh](../concepts/power-and-refresh.md).

## Watch out for

The top gotchas ([full list](../concepts/limitations-and-gotchas.md)): no PSRAM → mono only; non-standard
SPI pins; invert BUSY where required (damage risk); partial-refresh-after-sleep corruption; on-device
OAuth pain; TLS memory tax + heap leak; ASCII-only on-device fonts; ESPHome can't fetch arbitrary APIs.

## See also

- [Rendering Architecture](../concepts/rendering-architecture.md)
- [TRMNL BYOS Walkthrough](trmnl-byos-walkthrough.md) · [Turnkey Projects](turnkey-projects.md)
- [Hardware Platform](../concepts/hardware-platform.md) · [Firmware Stacks](../concepts/firmware-stacks.md) · [Data Sources](../concepts/data-sources.md) · [Power & Refresh](../concepts/power-and-refresh.md) · [Grayscale & Upgrade Path](../concepts/grayscale-and-upgrade-path.md) · [Limitations](../concepts/limitations-and-gotchas.md)
