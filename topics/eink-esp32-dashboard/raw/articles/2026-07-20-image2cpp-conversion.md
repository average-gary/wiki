---
title: "image2cpp — PNG/JPG/BMP to 1-bit byte arrays for e-paper"
source: https://javl.github.io/image2cpp/
type: article
tags: [image2cpp, img2lcd, dithering, 1-bit, bitmap, arduino, gxepd2, tooling]
date: 2026-07-20
quality: 3
confidence: high
summary: "The standard offline asset-conversion tool for the Arduino path: browser tool converting PNG/JPG/BMP to 1-bit byte arrays for Adafruit GFX / Waveshare, with Floyd-Steinberg/Atkinson/Bayer dithering, threshold, scaling, rotation, and horizontal/vertical draw modes. Waveshare's img2lcd is the vendor equivalent."
---

# image2cpp / img2lcd

Standard offline step for baking static bitmaps into on-device firmware.

- Browser tool: PNG/JPG/BMP → **1-bit byte arrays** for Adafruit GFX / Waveshare.
- Dithering: Floyd–Steinberg / Atkinson / Bayer; threshold control; scaling; rotation; horizontal/vertical draw modes.
- Waveshare's **img2lcd** is the vendor equivalent.
- Use for icons/logos/static layout elements in a GxEPD2 build; for server-render pipelines, do the dither in Python (Pillow) instead and stream 1-bit.
