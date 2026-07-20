---
title: "ESPHome e-paper dashboards — waveshare_epaper + online_image (docs + SmartHomeScene)"
source: https://esphome.io/components/display/waveshare_epaper/
type: article
tags: [esphome, waveshare, e-paper, yaml, home-assistant, online-image, no-code, refresh]
date: 2026-07-20
quality: 5
confidence: high
summary: "The declarative (no-C++) path. ESPHome's waveshare_epaper natively supports many panels incl. 7.5in model IDs; draw via YAML lambdas (it.printf, fonts, images). Data comes from Home Assistant entities OR a pushed image (online_image). Key limit: you CANNOT fetch arbitrary APIs inside lambdas -> data must arrive via an HA sensor or a pre-rendered image."
---

# ESPHome e-paper dashboards

The lowest-effort path IF you run Home Assistant.

## waveshare_epaper component
- Native support 1.54"–13.3" incl. mono, tri-color (`-b` red suffix), 7.3" ACeP 7-color. Configure a `model:` string + wire SPI/BUSY/DC/RST/CS.
- Drawing in YAML **lambda** blocks: `it.printf()`, `it.print()`, `it.line/rectangle/image`, fonts (gfonts/local TTF), rotation 0/90/180/270.
- Two refresh modes: fast partial vs full clear/redraw. **`full_update_every`** (default 30) forces periodic full refresh to clear ghosting.
- Hard limits: larger models (7.5"V2, HD-b, 13.3") "run out of RAM" on ESP8266 → ESP32 required; some panels' **BUSY pin must be inverted or you risk "permanent display damage."** GPIO15 (CS) is a strapping pin → `ignore_strapping_warning: true`.

## online_image component (push a server-rendered image)
- Downloads + decodes BMP (1/8/24-bit), baseline JPEG (no progressive), PNG. Auto-detect via `AUTO`.
- RAM warning: "requires a fair amount of RAM... might work without PSRAM, no guarantee" — relevant to WROOM-32E. Use **BINARY buffer (1bpp, 8px/byte)** for mono to stay small (GRAYSCALE=1B/px, RGB565=2B/px, RGB=3–4B/px).
- Default 64KB download buffer (tunable); custom HTTP `request_headers`; HTTP caching via `Last-Modified`/`ETag`. Depends on `http_request`. Updates: manual / interval / on WiFi connect (not automatic by default).

## The critical boundary (SmartHomeScene)
- Data flows in via the `homeassistant` sensor platform (`id(x).state` in lambdas). **No direct arbitrary-API fetch inside lambdas** — data must arrive through an ESPHome component or a pushed image (e.g. the "Puppet" HA-dashboard-to-PNG addon).
- Concrete refresh times: 7.5" tri-color ≈ 26s full / 16s partial; 7.3" 7-color ≈ 35s; 4.2" mono ≈ 5s → color/large panels unsuitable for frequent updates.
- No true grayscale on tri-color (collapses to B/W/R blocks). "Timeout while displaying image" = PSRAM exhaustion or images >500KB → "prepare your image beforehand as pure 1-bit."
- Battery pattern: `update_interval: never` + event/deep-sleep-triggered refresh. Recommends 4.2"–7.5" two-color panels for wall dashboards.
- Ready-to-copy dashboard YAMLs: pavlojs/esphome-epaper-dashboard (LOLIN S3 Pro + 7.5"V2, ~1mo on 2500mAh), kevinfr95/epaper-dashboard-esphome.
