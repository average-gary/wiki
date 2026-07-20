# Log — e-Ink ESP32 Dashboard

## [2026-07-20] init | topic wiki created

New hub topic created for research into building a slowly-updating e-paper dashboard
on a Waveshare e-Paper ESP32 Driver Board (Rev3) with an ESP32-WROOM-32E.

## [2026-07-20] research | "e-ink ESP32 dashboard (calendar/bitcoin/weather)" → 22 sources ingested, 7 articles compiled

5 parallel agents (hardware/firmware, data-source integration, turnkey/OSS projects, power/refresh,
frameworks/limitations). Compiled 6 concept articles + 2 reference articles (Build Playbook, Turnkey
Projects). Key verdict: feasible and mainstream; use a mono panel (no PSRAM), deep-sleep with ~15–30 min
updates + full-refresh per wake, and prefer server-side (thin-client) rendering for a multi-source
dashboard. Progress score: ~88 (strong).

## [2026-07-20] research r2 (gap-closing --plan) | gaps 1,2,4 → +8 sources, +2 articles, key corrections

3 parallel paths: (1) Rev3 board internals & real power, (2) TRMNL BYOS + Waveshare walkthrough,
(4) grayscale/upgrade path. New articles: concepts/grayscale-and-upgrade-path.md, reference/trmnl-byos-walkthrough.md.
**Corrections to round 1** (from the official board schematic + forum measurements): regulators are RT9193
(not AMS1117); NO onboard battery connector / charger / GPIO36 divider; no official "Rev3" (Rev2.3/PWR-pin
= the passive HAT, not this board); **real deep-sleep ~1.4mA stock (~700µA power LED), so plan weeks-not-months
or run on USB — the 6–12mo figure was a FireBeetle, not this board.** Updated hardware-platform, power-and-refresh,
limitations articles + Build Playbook accordingly.
