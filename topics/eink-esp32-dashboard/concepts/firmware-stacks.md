---
title: Firmware Stacks — GxEPD2, ESPHome, MicroPython, ESP-IDF
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [firmware, gxepd2, esphome, micropython, esp-idf, lvgl, arduino]
confidence: high
---

# Firmware Stacks

The software choices for driving the panel. Ordered by how commonly they're used for dashboards.

## Arduino + GxEPD2 (mainstream on-device path)

[GxEPD2](../raw/repos/2026-07-20-gxepd2.md) (ZinggJM) is the de-facto Arduino SPI e-paper library —
60+ panels, built on Adafruit_GFX, pairs with ArduinoJson for data.

- **Panel selection is manual**: uncomment exactly one class typedef matching your GoodDisplay/Waveshare
  part number (e.g. `GxEPD2_750_T7` = 7.5" 800×480, `GxEPD2_420` = 4.2" 400×300, tri-color `..._c`,
  7-color `GxEPD2_730c_GDEY073D46`). Resolution + refresh behavior are baked into the class.
- **Paged drawing** (`firstPage()/nextPage()`) is the key trick that lets a PSRAM-less WROOM drive
  large panels — render in horizontal strips, trading redraw time for RAM.
- `hibernate()`/`powerOff()` for battery use; **BUSY pin mandatory**; 3.3 V logic only.
- Use **image2cpp / img2lcd** ([tooling](../raw/articles/2026-07-20-image2cpp-conversion.md)) to bake
  static icons/logos into 1-bit arrays; GFX/U8g2 fonts for text.

Best when: you want full on-device control and no server.

## ESPHome (declarative, no-C++ path)

[ESPHome's `waveshare_epaper`](../raw/articles/2026-07-20-esphome-epaper-dashboards.md) component drives
many panels via a YAML `model:` string; you draw in `lambda` blocks (`it.printf`, fonts, `it.image`).

- **`full_update_every`** (default 30) forces periodic full refresh to clear ghosting.
- The **`online_image`** component downloads+decodes BMP/JPEG/PNG — the "push a server-rendered image"
  primitive (use **BINARY 1bpp** buffer for mono; RAM-risky without PSRAM).
- **Hard limit**: you **cannot fetch arbitrary APIs inside lambdas**. Data must arrive via a Home
  Assistant sensor/entity, or as a pre-rendered image. So ESPHome effectively **requires Home Assistant**
  as the data hub (or a server producing an image).
- Gotchas: invert the **BUSY pin** on panels that require it (risk of permanent damage), and set
  `ignore_strapping_warning: true` for CS on GPIO15.

Best when: you already run Home Assistant and want zero compiled firmware to maintain.

## MicroPython

[micropython-waveshare-epaper](../raw/repos/2026-07-20-micropython-waveshare-epaper.md) covers ~24
panels via `framebuf.FrameBuffer`. Viable for **small/medium mono** panels; heap-tight on WROOM
(runtime + framebuf + WiFi/TLS); **no rich layout engine**. Good for prototyping; not for large color
panels or elaborate layouts.

## ESP-IDF + Waveshare demo

Lower-level; more effort for little gain over GxEPD2 for a dashboard. Some server-render firmwares
(ugomeda) are ESP-IDF because the device only needs to blit a bitmap.

## LVGL — avoid on e-paper

[LVGL runs but is impractical](../raw/articles/2026-07-20-wroom-vs-wrover-lvgl.md) on e-paper: it's
designed for fast-refresh LCDs and fights the e-paper refresh model (partial-refresh noise, no clean
full refresh). Use GxEPD2/GFX drawing or server-render instead.

## Quick comparison

| Stack | Effort | Data flexibility | RAM friendliness | Needs server/HA |
|-------|--------|------------------|------------------|-----------------|
| GxEPD2 (Arduino) | Medium | High (any API) | Good (paged) | No |
| ESPHome | Low | Low (HA/image only) | Medium | Home Assistant |
| MicroPython | Low–Med | Medium | Tight | No |
| Thin-client (TRMNL fw) | Low | High (server does it) | Excellent | Yes (BYOS server) |

## See also

- [Rendering Architecture](rendering-architecture.md)
- [Hardware Platform](hardware-platform.md)
- [Data Sources](data-sources.md)
