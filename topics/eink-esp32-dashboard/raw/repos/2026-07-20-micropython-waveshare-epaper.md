---
title: "micropython-waveshare-epaper (mcauser) — MicroPython e-paper drivers"
source: https://github.com/mcauser/micropython-waveshare-epaper
type: repo
tags: [micropython, e-paper, waveshare, framebuf, esp32, drivers]
date: 2026-07-20
quality: 4
confidence: medium
summary: "MicroPython drivers for ~24 Waveshare panels (1.54in-7.5in incl. tri-color), built on framebuf.FrameBuffer. Viable for small/medium mono panels on WROOM but heap-tight; no rich layout engine. Buffer math decides feasibility."
---

# micropython-waveshare-epaper (mcauser)

Confirms MicroPython is a real (if memory-tight) option on WROOM-32E.

- Drivers cover **~24 Waveshare models** (1.54"–7.5", incl. red/yellow tri-color); built on `framebuf.FrameBuffer`.
- Buffer math is the constraint: 7.5" (640×384) ≈ **30.7KB mono**; dual/color variants push toward ~120KB; 1.54" (152×152) ≈ 2.9KB. Small panels comfortable; large color tight under MicroPython's already-reduced heap (runtime + framebuf + WiFi/TLS).
- Full-refresh times ~1.5–31s depending on model.
- No explicit PSRAM guidance in README → WROOM heap headroom must be validated empirically.
- framebuf gives basic text/shape drawing but **no rich layout engine** — for elaborate dashboards, Arduino/GxEPD2 or server-render is better.

**Takeaway**: MicroPython works for small/medium **mono** panels and rapid prototyping; not the choice for large color panels or complex layouts.
