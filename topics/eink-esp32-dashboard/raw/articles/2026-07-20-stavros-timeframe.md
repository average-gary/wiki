---
title: "Making the Timeframe — server-rendered e-ink calendar (Stavros)"
source: https://www.stavros.io/posts/making-the-timeframe/
type: article
tags: [server-render, calendar, google-calendar, oauth, selenium, deep-sleep, refresh-hash, esp32]
date: 2026-07-20
quality: 5
confidence: high
summary: "The clearest steelman of the 'render server-side, device just downloads an image' school. Server Selenium-screenshots Google Calendar (dodging on-device OAuth); ESP32 downloads the bitmap, deep-sleeps ~30min; a server-computed hash lets the device skip redrawing when nothing changed (avoids the distracting refresh flash)."
---

# Stavros — "Making the Timeframe"

Design rationale for the server-side-render approach.

- Renders the full UI **server-side as an image**; ESP32 just downloads + displays it — "much easier to program" than on-device C++ drawing. Sidesteps font/layout/memory pain entirely.
- **Google Calendar handled server-side** (Selenium screenshots the calendar) precisely to **avoid on-device OAuth**, which "Google really doesn't like" in headless/reauth scenarios.
- Battery: HTTP download → deep sleep at ~30-min intervals ("basically zero battery").
- **Server-computed hash** lets the device skip redrawing when nothing changed → avoids the distracting B/W refresh flash and saves power/wear.
- Python pipeline resizes/dithers/adjusts brightness → outputs raw framebuffer bytes. Device uses a customized **epdiy** library (paired with an e-reader parallel panel).
