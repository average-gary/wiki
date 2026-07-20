---
title: Power Management & E-Paper Refresh Mechanics
type: concept
created: 2026-07-20
updated: 2026-07-20
tags: [power, deep-sleep, battery, refresh, ghosting, partial-refresh, rtc-memory, temperature]
confidence: high
---

# Power Management & E-Paper Refresh

The "dynamic (slowly)" requirement lives here: cadence, deep sleep, battery life, and refresh quality.

## The deep-sleep loop

The standard battery-dashboard loop, not an always-on program:

```
wake (RTC timer) → WiFi connect → NTP sync → fetch data → draw panel → deep sleep
```

- `esp_sleep_enable_timer_wakeup()` for the lowest-power wake source
  ([~6–10 µA timer-only](../raw/data/2026-07-20-esp32-sleep-power.md); ext0 is 50–100 µA).
- Keep the **awake window short (~5–15 s)** — the WiFi burst (**up to ~240 mA TX**) is the entire energy budget; deep sleep (~10–15 µA) is essentially free.
- **RTC memory persists across sleep** — store boot count, last-drawn content hash, partial-refresh counter, and NTP epoch in `RTC_DATA_ATTR` variables to skip redundant redraws.
- Sync **NTP each wake** (RTC drift matters over months) and align wakes to clock boundaries so displayed times are accurate.

## Battery-life math

`runtime (h) = capacity (mAh) ÷ average current (mA)`. Duty-cycle the active load. But **the idle
current, not the active bursts, dominates on this board** — and here the board matters enormously.

> ### ⚠️ This Waveshare board is NOT a low-power board out of the box
> The often-quoted "**6–12 months on 5000 mAh**" figure is the measured
> [esp32-weather-epd](../raw/repos/2026-07-20-esp32-weather-epd.md) result on a **FireBeetle** (a
> low-quiescent board at ~14 µA sleep). The **Waveshare e-Paper ESP32 Driver Board is different**
> ([measurements](../raw/notes/2026-07-20-board-power-measurements.md)):
>
> | State | Deep-sleep current |
> |-------|-------------------|
> | Stock (power LED intact) | **~1.4 mA** |
> | Power LED desoldered | **~700 µA** |
> | + display rail gated (GPIO4/`hibernate()`) | **~150–250 µA** |
> | + serial chip disabled | ~100–200 µA |
> | External ultra-low-Iq LDO (bypass board) | ~20–50 µA (theoretical floor) |
>
> Stock ~1.4 mA ≈ **60 days of pure idle** on a 2000 mAh pack before you even count refresh energy.

**Mods in payoff order** ([source](../raw/notes/2026-07-20-board-power-measurements.md)):
1. **Desolder the power LED** (2.2 kΩ to 3.3 V, always on) → ~700 µA saved instantly — the #1 fix.
2. **Gate the display rail** before sleep via GPIO4/AO3401 or `display.hibernate()` → up to ~450–520 µA.
3. **Disable/cut the CP2102/CH343** VBUS power → ~80 µA.
4. For sub-50 µA / "year+" life, **bypass the RT9193 LDOs with an external low-Iq LDO**.

- **Interval is the other dominant lever**: 5-min → weeks; 30-min → months (once modded); hourly/daily → longest.
- **Reality check**: unmodified, plan on **weeks, not months**; with the LED removed + display gated, months are achievable. Or just run it **USB-powered** — for a wall/desk dashboard that's the pragmatic choice, and the board has no charger anyway.

## Refresh cadence tuned to data volatility

| Data | Suggested interval |
|------|-------------------|
| Calendar | hourly or daily |
| Weather | 10–30 min |
| Bitcoin fees/price | a few minutes (if truly needed) |

For a battery build, **15–30 min is the sweet spot** for months of life.

## E-paper refresh mechanics (manufacturer rules)

From [Waveshare + Good Display guidelines](../raw/data/2026-07-20-epaper-refresh-guidelines.md):

- **Minimum ~180 s between updates** to protect panel lifetime — never refresh faster than ~3 min on many panels.
- **Full clear after every 5 partial refreshes** (and ≥1 full/24 h for color) or ghosting worsens and "may even damage the screen."
- **Sleep or power off the panel after each refresh** — leaving it energized continuously can cause **irreversible damage**.
- **Temperature**: color panels **cannot operate sub-zero**; below 0 °C requires wide-temp B/W panels (or heating film). Range 0–50 °C.
- **Bistable**: holds the image at **zero power** — mid-cycle power loss / dead battery leaves the last frame intact. This is why e-paper suits slow dashboards.

## Full vs partial refresh — and the deep-sleep gotcha

Refresh timings ([thoughts.gohu.org](../raw/articles/2026-07-20-partial-refresh-after-deepsleep.md)):
**partial ≈ 0.5 s** (no flicker), **fast ≈ 1.5 s**, **full ≈ 4–5 s** (flickers, best contrast).

**Critical gotcha for deep-sleep dashboards**: after deep sleep the display controller's previous-image
RAM (the `0x10` buffer) is **lost**, so partial updates corrupt unless you save/restore the buffer or
**re-init with a full refresh** on each wake. For a sleep-per-cycle dashboard this makes
**full-refresh-per-wake the pragmatic default** — and at multi-minute intervals there's no benefit to
partial refresh anyway (it just accumulates ghosting).

## See also

- [Hardware Platform](hardware-platform.md)
- [Data Sources](data-sources.md) — poll cadence
- [Rendering Architecture](rendering-architecture.md) — server ETag/304 can skip refreshes entirely
- [Build Playbook](../reference/build-playbook.md)
