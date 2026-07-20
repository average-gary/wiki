---
title: Limitations & Gotchas
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [limitations, gotchas, contrarian, psram, oauth, tls, ghosting, hardware-footguns]
confidence: high
---

# Limitations & Gotchas

The steelman of what makes this hard — design around these up front.

## Hardware / memory

- **No PSRAM on WROOM-32E.** 520 KB SRAM, ~200–320 KB free after WiFi/BT. Stay with **mono panels**
  (800×480 1bpp ≈ 48 KB fits). Tri-color = a 2nd bit-plane; 7-color ≈ 4 bpp → offload to WROVER/ESP32-S3
  or render server-side and stream 1-bit. ([details](hardware-platform.md))
- **Non-standard SPI pins** (BUSY25/RST26/DC27/CS15/CLK13/DIN14) → must remap the SPI bus; CS on GPIO15
  is a strapping pin.
- **Hardware footguns**: invert the **BUSY pin** on panels that require it (risk of *permanent* damage);
  don't power a 7.5" panel from the 3.3 V pin; the Rev2.3/PWR-pin caveat is about the *passive HAT*, not
  this ESP32 board.
- **This board is not battery-friendly stock**: **~1.4 mA deep sleep** (always-on power LED ≈ 700 µA;
  two RT9193 LDOs; CP2102/CH343). No onboard charger, no battery connector, no GPIO36 divider. Plan on
  weeks not months, or run on USB, or do the LED/display-gating mods. ([Power & Refresh](power-and-refresh.md))

## E-paper physics

- **Slow and it flashes.** Mono full ≈ 2–5 s, 7.5" tri-color ≈ 16–26 s, 7-color ≈ 12–35 s. **Not for
  real-time data** — update on an interval and hash-compare to skip needless redraws.
- **Ghosting is mandatory maintenance**: partial refresh accumulates artifacts → force a full refresh
  periodically (≥ every 5 partials; ≥1/24 h for color).
- **~180 s minimum refresh interval** and **sleep the panel after each refresh** or risk damage.
- **Temperature**: color panels fail sub-zero; cold slows refresh and worsens ghosting.
- **Deep-sleep gotcha**: partial refresh breaks after deep sleep (controller RAM lost) → re-init with a
  full refresh per wake. ([details](power-and-refresh.md))

## Software / integration

- **Google Calendar OAuth is painful on-device** (token refresh, reauth Google dislikes) → prefer public
  `.ics`, an Apps Script proxy, or full server-render.
- **TLS is the real memory tax**, not JSON. `setInsecure()` vs `setCACert()` (rotating certs to maintain);
  watch the repeated-connect **heap leak** (`delete` the client). ([details](data-sources.md))
- **On-device fonts/layout are tedious and ASCII-only by default** (no Unicode/emoji) → pre-render text
  server-side or pre-convert glyphs offline.
- **ESPHome can't fetch arbitrary APIs in lambdas** — effectively requires Home Assistant or a pushed image.
- **LVGL is unsuitable** for e-paper (built for fast LCDs).
- **WiFi reliability on battery** and **NTP/time drift** need retry logic and a fail-safe last-image.

## The honest summary

E-paper + WROOM-32E is excellent for a **slow, glanceable, battery-friendly** dashboard and poor for
anything fast, colorful, or high-resolution. The two decisions that remove most of the pain are:
**(1)** pick a **mono panel**, and **(2)** push **rendering + auth to a server** for anything beyond
simple JSON feeds.

## See also

- [Hardware Platform](hardware-platform.md)
- [Power & Refresh](power-and-refresh.md)
- [Rendering Architecture](rendering-architecture.md)
- [Data Sources](data-sources.md)
