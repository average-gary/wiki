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

## [2026-07-20] plan | "self-hosted BYOS + Waveshare firmware fork → calendar/Bitcoin/weather dashboard" → output/plan-byos-waveshare-dashboard-2026-07-20.md (12 articles consulted, 5 decisions, 6 phases)

Roadmap-format plan. Interview locked the forks: server retained (BYOS justified over serverless; on LAN box
over SSH), byos_next (wiki's pick for coded custom screens), iCloud `.ics` calendar (no on-device OAuth),
combined layout with Bitcoin as largest region, USB power for v1 (battery out of scope — ~1.4mA stock).
Phase 0 = explicit hardware-ID first (serial port CP2102/CH343, esptool chip/flash, panel model/resolution)
since the plan branches on the panel. Decision 5 (which of 3 olivrrrr init sequences) + BUSY polarity resolved
empirically in Phase 3. Risk table grounded in Limitations + Power/Refresh (ghosting, 1-bit dithering, LAN
HTTP-vs-HTTPS, 180s refresh floor).

## [2026-07-20] plan (pivot) | "no server — self-contained + portable, drop calendar if heavy" → output/plan-ondevice-waveshare-dashboard-2026-07-20.md (13 sources, 5 decisions, 6 phases)

User dropped the server requirement. Pivoted to fully on-device (Rendering Architecture pole A): fork
esp32-weather-epd (GxEPD2), fetch mempool.space + Open-Meteo directly, combined BTC-emphasis layout, USB power.
Stays inside the WROOM RAM ceiling via mono panel + paged drawing + TLS discipline (setInsecure + delete-the-client
to dodge the heap leak) + streamed/filtered JSON. Portability via WiFiManager captive portal (runtime WiFi/location/
currency in NVS, KEY-button GPIO12 reset) — no reflash to move networks. Calendar dropped for v1 (heaviest on-device
source); light re-add path = public .ics parse (no OAuth). Prior BYOS plan marked superseded. Phases: 0 HW-ID →
1 panel bring-up/first-bitmap → 2 weather fork → 3 add Bitcoin + layout → 4 WiFiManager portability → 5 deep-sleep
loop/RTC-hash/hardening. Free-heap stability is a per-phase validation check.
