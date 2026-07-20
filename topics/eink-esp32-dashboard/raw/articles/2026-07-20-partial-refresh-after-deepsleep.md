---
title: "Fixing Waveshare partial updates after deep sleep (thoughts.gohu.org)"
source: https://thoughts.gohu.org/posts/2025/epaper-partial-updates/
type: article
tags: [e-paper, partial-refresh, full-refresh, deep-sleep, ghosting, controller-ram, timing]
date: 2026-07-20
quality: 4
confidence: high
summary: "Explains WHY partial refresh breaks after deep sleep: the display controller's previous-image RAM (the 0x10 buffer) is lost, so partial updates corrupt unless you re-init with a full refresh (or save/restore the buffer) on each wake. Also gives exact per-refresh-type timings: partial ~0.5s, fast ~1.5s, full ~4-5s."
---

# Fixing Waveshare partial updates (thoughts.gohu.org)

The key deep-sleep + partial-refresh gotcha.

## Refresh timings (concrete)
- **Partial ≈ 0.5s** (no flicker), **fast ≈ 1.5s** (flickers once, draws negative first), **full ≈ 4–5s** (flickers multiple times, best contrast/no afterimage).
- Practical mixed cadence: full hourly, fast every 10min, partial every minute → 9/10 updates flicker-free while keeping the panel healthy.

## The deep-sleep gotcha
- After deep sleep the display controller's **previous-image RAM (the `0x10` buffer) is lost**, so partial updates break unless you **save/restore the buffer or re-init with a full refresh** after sleep.
- For a sleep-per-cycle dashboard this makes **full-refresh-per-wake the pragmatic default**. (Corroborated by GxEPD2 discussions #191/#98 and esp32-weather-epd issue #48: "re-init with a full refresh after deep sleep before partial refreshes work.")
- Partial-only refreshing → poor contrast, afterimages, possible damage over time (matches manufacturer guidance).
