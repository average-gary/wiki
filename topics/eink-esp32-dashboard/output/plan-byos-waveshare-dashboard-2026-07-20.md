---
title: "Plan: Self-hosted TRMNL BYOS + Waveshare ESP32 firmware dashboard (calendar + Bitcoin + weather)"
type: plan
format: roadmap
sources:
  - reference/build-playbook.md
  - reference/trmnl-byos-walkthrough.md
  - reference/turnkey-projects.md
  - concepts/hardware-platform.md
  - concepts/rendering-architecture.md
  - concepts/firmware-stacks.md
  - concepts/data-sources.md
  - concepts/power-and-refresh.md
  - concepts/limitations-and-gotchas.md
  - raw/repos/2026-07-20-trmnl-byos-implementations.md
  - raw/repos/2026-07-20-trmnl-firmware-config.md
  - raw/repos/2026-07-20-calendar-integration-repos.md
generated: 2026-07-20
superseded_by: plan-ondevice-waveshare-dashboard-2026-07-20.md
status: superseded
---

> **⚠️ Superseded** by [the on-device plan](plan-ondevice-waveshare-dashboard-2026-07-20.md). The user chose a self-contained, portable, no-server architecture and dropped calendar. This BYOS plan is retained for reference only.

# Plan: Self-hosted TRMNL BYOS + Waveshare ESP32 firmware dashboard

> Generated from the [eink-esp32-dashboard](../_index.md) wiki (12 articles/sources consulted)

## Executive Summary

Build a slow, glanceable e-ink dashboard on a **Waveshare e-Paper ESP32 Driver Board (ESP32-WROOM-32E)** driving a **mono** panel, showing a **combined calendar + Bitcoin + weather** screen with Bitcoin emphasized. The device is a **thin client**: a self-hosted **TRMNL BYOS** server (`byos_next`) on your always-on LAN machine fetches all data, composes an 800×480 1-bit bitmap, and serves it; the ESP32 wakes on a timer, downloads the BMP, blits it, and deep-sleeps. This dodges the WROOM RAM ceiling, keeps auth/layout/API-drift off the microcontroller, and lets you add feeds by editing a server recipe instead of reflashing ([Rendering Architecture](../concepts/rendering-architecture.md), [Build Playbook](../reference/build-playbook.md)).

**Key decisions locked with you:** BYOS retained (server justified below); `byos_next` React recipes; iCloud/`.ics` calendar (no on-device OAuth); combined layout with Bitcoin as the largest region; server on the LAN-colocated box over SSH; **USB power for v1** (this board is ~1.4 mA in deep sleep stock — battery is out of scope, no LED/LDO mods).

**Environment note:** the board is on THIS Mac over USB and the harness drives it directly — install toolchains, build/flash via PlatformIO/esptool, and open the serial monitor. The BYOS server runs on the separate always-on box; the harness deploys and manages it over SSH. Your only manual step is the physical USB connection.

---

## Architecture Decisions

### Decision 1: Keep the server (BYOS thin client), don't go serverless
**Context**: You asked whether the ESP32 could just query the internet directly and whether BYOS is a hard requirement. [Rendering Architecture](../concepts/rendering-architecture.md) documents both poles: (A) on-device fetch+draw (GxEPD2, the `esp32-weather-epd` pattern) and (B) server-side render / thin client (TRMNL BYOS).

**Options considered**:
- **Serverless / on-device (A)**: No server to run. But the WROOM-32E has **no PSRAM** (~200–320 KB free heap), so the ICS parser + TLS handshake buffers + 48 KB framebuffer + fonts all compete; layout is "tedious and ASCII-only by default"; and every layout change means a reflash ([Limitations](../concepts/limitations-and-gotchas.md), [Hardware Platform](../concepts/hardware-platform.md)).
- **Server-side thin client (B)**: Firmware becomes trivial and near-permanent; auth/fonts/layout/dithering all move to a maintainable server; sidesteps the RAM ceiling because the device never holds structured data. Its only real con is "you must run a server the device depends on."

**Decision**: **Server-side (B).** Your goal (combined multi-source layout + a calendar) is exactly the case the wiki says server-side wins, and the sole con — needing an always-on host — is dissolved by your **LAN-colocated always-on machine**. Serverless is technically viable but pays in RAM pressure, ASCII-only rendering, and reflash-per-tweak for no benefit here.

**Consequences**: You maintain one small server (containerized, low effort). The device's uptime depends on that box being reachable on the LAN — acceptable given it's colocated and always on. **Documented fallback** if you ever want zero servers: fork [`esp32-weather-epd`](../raw/repos/2026-07-20-esp32-weather-epd.md) (GxEPD2), add mempool + a `.ics` parse, on-device full-refresh per wake ([Build Playbook](../reference/build-playbook.md) step 1, "fallback if no server desired").

### Decision 2: `byos_next` (coded React recipes) over `byos_django` (push-HTML)
**Context**: You deferred to the wiki. [BYOS implementations](../raw/repos/2026-07-20-trmnl-byos-implementations.md) and the [BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) present three servers; the two approachable ones are `byos_django` (Playwright/Firefox HTML→bitmap; `POST /api/v1/generate_screen`) and `byos_next` (typed React "recipes" + playlists, `takumi`/`satori`/`browser` renderers).

**Options considered**:
- **byos_django**: "Easiest push-HTML path" — fetch in Python, POST arbitrary HTML. Great if you'd rather write HTML/CSS. Heavier render backend (headless Firefox).
- **byos_next**: The wiki explicitly tags it **"Best for coding a custom Bitcoin screen"** — recipes are code (`paramsSchema`, `dataSchema`, `definition`) in `app/(app)/recipes/screens/<slug>/`, playlists rotate screens, `takumi` renderer produces the bitmap without a full browser.

**Decision**: **`byos_next`.** A combined, BTC-emphasized, multi-widget dashboard with per-feed schemas and data-fetching logic is precisely the "coded custom screen" case the wiki flags `byos_next` for. Typed recipes make the three feeds composable and testable.

**Consequences**: Node/Postgres stack (`docker-compose`, `:3000`, `AUTH_ENABLED=false` for single-user, `REACT_RENDERER=takumi`). You write TypeScript/React for the screen. **The 1-bit fidelity burden is on you**: the `takumi` render must dither/palette-snap to true 1-bit @ 800×480 or the panel looks wrong ([Walkthrough](../reference/trmnl-byos-walkthrough.md) friction point #3). If React-in-recipes fights the layout, `byos_django` push-HTML is the escape hatch — same 3-endpoint device contract, so **the firmware doesn't change**.

### Decision 3: iCloud/`.ics` calendar — no on-device OAuth, fetched server-side
**Context**: You have an iCloud/Outlook/other `.ics` calendar. [Data Sources](../concepts/data-sources.md) and [calendar-integration repos](../raw/repos/2026-07-20-calendar-integration-repos.md) lay out three poles: server-render, on-device OAuth (avoid), and Apps Script proxy.

**Options considered**:
- **On-device OAuth** (0015/Fridge-Calendar): the "OAuth pain" — token refresh across deep sleep in NVS. Rejected (and irrelevant for a non-Google `.ics` anyway).
- **Apps Script proxy** (rogarmu8): clean flat text, but it's a Google-specific pattern; you don't have Google Calendar.
- **Public/secret `.ics` URL, parsed server-side**: iCloud "Public Calendar" and Outlook "Publish" both expose a subscription `.ics` link. BYOS (running on the server, not the MCU) fetches and parses it.

**Decision**: **Fetch the `.ics` in the `byos_next` recipe on the server.** Because rendering is server-side, ICS parsing never touches the ESP32 — the "avoid on-device OAuth/ICS parsing" guidance is satisfied automatically.

**Consequences**: You publish the calendar and give the server its secret `.ics` URL (store it as a recipe env var / secret, not in the repo). Parse with a Node ICS library server-side. Treat the URL as a secret — anyone with it sees your events.

### Decision 4: Panel = mono 7.5" 800×480 (pending Phase 0 confirmation)
**Context**: The WROOM-32E has no PSRAM, so [Hardware Platform](../concepts/hardware-platform.md) makes the panel the governing choice. A 7.5" 800×480 mono buffer is ~48 KB (fits, "tight with WiFi/TLS"); tri-color/7-color blow the RAM budget and refresh 15–35 s.

**Decision**: Target **mono 7.5" 800×480** (matches the olivrrrr fork's default and the BYOS 800×480 BMP). **But this is confirmed on the actual hardware in Phase 0** — the plan branches on your real panel's model/resolution, which sets the GxEPD2 init class and the server's render dimensions.

**Consequences**: If Phase 0 reveals a different mono panel (e.g. 4.2" 400×300), we adjust the render resolution and the GxEPD2 class typedef — everything else in the plan holds. If it's a color panel, we either render server-side to 1-bit anyway (color wasted) or revisit ([Grayscale & Upgrade Path](../concepts/grayscale-and-upgrade-path.md)).

### Decision 5: Which of the 3 olivrrrr panel init sequences — resolved empirically
**Context**: The [firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md) notes the olivrrrr/firmwareesp32 fork ships **3 selectable panel init/timing sequences** for the Waveshare 7.5"; the wrong one → ghosting or blank refresh. The wiki cannot know which matches your unit's panel revision.

**Decision**: **Determine by test-flashing** in Phase 3 — flash sequence #1, push a known high-contrast test bitmap, inspect the panel; if ghosted/blank, try #2, then #3. This is a hardware-in-the-loop decision, not a documentation lookup.

**Consequences**: Budget one short flash-and-look iteration per sequence (≤3). Also verify **BUSY polarity** here — inverting BUSY on a panel that requires it risks *permanent damage* ([Limitations](../concepts/limitations-and-gotchas.md)), so change one variable at a time and watch the serial log for BUSY timeouts before assuming an init-sequence problem.

---

## Implementation Phases

Each phase has an explicit **"confirm it worked on the actual hardware"** check, per your deliverable #1.

### Phase 0: Hardware identification (do this FIRST — the plan branches on it)
**Goal**: Establish ground truth about the physical board before any build decision. Per deliverable #2, this precedes everything because panel model/resolution sets the GxEPD2 class *and* the server render size, and the USB-UART chip sets the flashing toolchain.
**Tasks**:
- [ ] **Detect the serial port**: `ls /dev/cu.*` before and after plugging in the board (`/dev/cu.usbserial-*` ⇒ CP2102/SLAB driver; `/dev/cu.wchusbserial*` ⇒ CH343). This tells us CP2102 vs CH343 ([Hardware Platform](../concepts/hardware-platform.md)) and whether a macOS driver install is needed.
- [ ] **Install tooling**: `pip install esptool` (or `pipx`), and `brew install platformio` / the PlatformIO Core installer.
- [ ] **Read chip + flash info**: `esptool.py --port <port> chip_id` and `esptool.py --port <port> flash_id` → confirm **ESP32-WROOM-32E**, **4 MB flash**, MAC address (the MAC becomes the device's BYOS `ID:` header — record it).
- [ ] **Enter download mode if needed**: if esptool can't sync, hold **GPIO0→GND during reset (EN)** then release ([Build Playbook](../reference/build-playbook.md) step 2, [Hardware Platform](../concepts/hardware-platform.md)).
- [ ] **Identify the panel**: read the FPC ribbon label / silkscreen part number (e.g. `GDEY075T7`, `GDEW075T7`) and its documented resolution. Cross-reference to the GxEPD2 class (`GxEPD2_750_T7` = 7.5" 800×480) via [Firmware Stacks](../concepts/firmware-stacks.md). **This is the branch point** — record model + resolution + color type (expect mono).
- [ ] **Note the adapter**: check whether it's the DESPI-C02 or a Waveshare HAT rev 2.2/2.3 (the latter needs its PWR pin handled) ([Hardware Platform](../concepts/hardware-platform.md) adapter caveat).
**Dependencies**: None — first thing.
**Validation (on hardware)**: `esptool.py chip_id` prints `Chip is ESP32-D0WD... (WROOM-32E)`, a real MAC, and `flash_id` shows 4 MB. Panel part number and resolution written down. **We proceed only once the panel model is confirmed**, because Phases 3–5 depend on it.
**Wiki grounding**: [Hardware Platform](../concepts/hardware-platform.md) (chip/flash/UART/pinout), [Build Playbook](../reference/build-playbook.md) step 0 ("pick your panel — do this first").

### Phase 1: Stand up the BYOS server (`byos_next`) on the LAN box
**Goal**: A reachable BYOS server on the always-on machine, serving the 3-endpoint device contract, before the device exists in software.
**Tasks**:
- [ ] Over SSH to the LAN box: clone `usetrmnl/byos_next`, `cp .env.example .env`.
- [ ] Set `POSTGRES_PASSWORD`, `BETTER_AUTH_SECRET` (`openssl rand -base64 32`), `AUTH_ENABLED=false` (single-user), `REACT_RENDERER=takumi`, `DATABASE_URL` ([BYOS implementations](../raw/repos/2026-07-20-trmnl-byos-implementations.md)).
- [ ] `docker-compose up -d`; confirm it listens on `:3000`. First account at `/setup` becomes admin.
- [ ] **Record the server's LAN IP:port** — this is the firmware's `API_BASE_URL` (e.g. `http://192.168.1.50:3000`). Plain **HTTP on the LAN** is fine and avoids the self-signed-cert pain ([Walkthrough](../reference/trmnl-byos-walkthrough.md) friction #2).
- [ ] Verify the box's firewall lets the ESP32's subnet reach `:3000`.
**Dependencies**: Phase 0 (need the render resolution to configure screens later; server itself can start now).
**Validation (on hardware/network)**: From the Mac, `curl http://<box-ip>:3000/` returns the BYOS UI, and `curl -H "ID: <device-MAC-from-Phase-0>" http://<box-ip>:3000/api/setup` returns a JSON body with `api_key`/`status` (the contract from [Walkthrough](../reference/trmnl-byos-walkthrough.md)). The device isn't flashed yet — this proves the server answers the contract.
**Wiki grounding**: [BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) step A, [BYOS implementations](../raw/repos/2026-07-20-trmnl-byos-implementations.md).

### Phase 2: Build & flash the olivrrrr Waveshare firmware, pointed at BYOS
**Goal**: Firmware on the device that phones YOUR server, not `trmnl.app`.
**Tasks**:
- [ ] Clone [`olivrrrr/firmwareesp32`](../raw/repos/2026-07-20-trmnl-firmware-config.md) (Waveshare fork) on the Mac.
- [ ] In `include/config.h`: change **`API_BASE_URL`** from `https://trmnl.app` to `http://<box-ip>:3000` — **critical**, else it phones home ([firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md)). Set `DEVICE_MAC`/`DEVICE_MODEL` from Phase 0.
- [ ] Confirm the SPI remap matches the board: **BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14** (non-default VSPI — must be explicit). Note CS=GPIO15 is a strapping pin ([Hardware Platform](../concepts/hardware-platform.md)).
- [ ] Pick an initial panel init sequence (start with #1 of the fork's 3 — resolved for real in Phase 3).
- [ ] Build & flash: `pio run -e <waveshare-env> -t upload` (GPIO0→GND if it won't enter download mode); then `pio device monitor -e <waveshare-env>`.
- [ ] On boot, connect via the **WiFiManager captive portal**: enter WiFi creds (and server URL if the build exposes it).
**Dependencies**: Phase 0 (port, MAC, panel), Phase 1 (server URL).
**Validation (on hardware)**: Serial monitor shows WiFi connect + NTP, then a `GET /api/setup` to your box; **the BYOS admin UI shows the device auto-appearing under Devices** with its MAC ([Walkthrough](../reference/trmnl-byos-walkthrough.md) step B). Pair it. If it appears, firmware↔server comms are proven end-to-end.
**Wiki grounding**: [BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) step B, [firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md).

### Phase 3: First bitmap on the panel (nail the init sequence)
**Goal**: A known image renders correctly on the physical e-paper — resolving Decision 5 (which of 3 init sequences) and BUSY polarity.
**Tasks**:
- [ ] Assign the paired device a **simple built-in/test screen** in BYOS (or push a high-contrast 800×480 1-bit test BMP — e.g. a border + grid + text) so the expected output is unambiguous.
- [ ] Trigger a display cycle; watch the serial log for the download of the **1-bit BMP** and the GxEPD2 render, and for any **BUSY timeout** warnings.
- [ ] If ghosted/blank/garbled: try init sequence **#2**, then **#3**, reflashing between. Change **one variable at a time**; do **not** flip BUSY inversion casually — wrong BUSY polarity risks *permanent panel damage* ([Limitations](../concepts/limitations-and-gotchas.md)). Only invert BUSY if the panel's datasheet/known-good config calls for it.
- [ ] Confirm the panel is **slept/hibernated after the refresh** (never left energized — irreversible-damage risk per [Power & Refresh](../concepts/power-and-refresh.md)).
**Dependencies**: Phase 2.
**Validation (on hardware)**: The test image appears **crisp, correctly oriented, full-contrast, no ghosting** on the panel. Record which init sequence worked — that's the locked firmware config. This is the "first bitmap on panel" milestone from deliverable #1.
**Wiki grounding**: [firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md) (3 sequences), [Limitations](../concepts/limitations-and-gotchas.md) (BUSY damage, ghosting), [Power & Refresh](../concepts/power-and-refresh.md) (sleep the panel).

### Phase 4: Author the combined screen — Bitcoin (emphasis) + weather + calendar
**Goal**: The real dashboard content, rendered server-side to true 1-bit, laid out combined with Bitcoin as the largest region.
**Tasks**:
- [ ] Create a `byos_next` recipe at `app/(app)/recipes/screens/dashboard/` with `paramsSchema` (location, `.ics` URL secret, fiat currency), `dataSchema`, and a `definition` that fetches all three feeds server-side.
- [ ] **Bitcoin** (largest region): `mempool.space/api/v1/fees/recommended` (`fastestFee`/`halfHourFee`/`hourFee`), `/api/blocks/tip/height` (bare integer), `/api/v1/prices` (BTC/USD). Poll **every few minutes at most** — HTTP 429 on abuse ([Data Sources](../concepts/data-sources.md)).
- [ ] **Weather** (secondary region): Open-Meteo `/v1/forecast`, keyless; request only the `current`/`daily` fields you render ([Data Sources](../concepts/data-sources.md)).
- [ ] **Calendar** (secondary region): fetch the iCloud/Outlook **secret `.ics`** URL (from a server-side secret/env var), parse with a Node ICS lib, show the next N events. No OAuth, no on-device parsing (Decision 3).
- [ ] Lay out the three regions on 800×480 (BTC largest) and ensure the `takumi` render **dithers/palette-snaps to true 1-bit** — verify no anti-aliased grays leak through ([Walkthrough](../reference/trmnl-byos-walkthrough.md) friction #3).
- [ ] Add the screen to a playlist (single screen for combined view) and set `refresh_rate`.
**Dependencies**: Phase 3 (known-good render path).
**Validation (on hardware)**: The panel shows the **combined dashboard** — live Bitcoin fees/height/price dominant, current weather, next calendar events — all legible at 1-bit, matching the server's preview render. Cross-check: mempool numbers on the panel equal what `curl mempool.space/api/v1/fees/recommended` returns at that moment. Calendar events match the source calendar.
**Wiki grounding**: [BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) step C, [Data Sources](../concepts/data-sources.md), [calendar-integration repos](../raw/repos/2026-07-20-calendar-integration-repos.md).

### Phase 5: Refresh cadence, change-skipping, and hardening
**Goal**: A stable, well-behaved always-on dashboard that respects panel physics and doesn't hammer APIs.
**Tasks**:
- [ ] Set `refresh_rate` to **~15–30 min** (server owns cadence via the `/api/display` response) — never below the **~180 s panel-protection floor** ([Power & Refresh](../concepts/power-and-refresh.md)). BTC is volatile but e-paper can't chase it; 15 min is the honest sweet spot.
- [ ] **Full-refresh per wake** (partial refresh corrupts after deep sleep — controller image RAM is lost) ([Power & Refresh](../concepts/power-and-refresh.md)). Confirm the firmware does a full refresh each cycle.
- [ ] Enable **ETag/304 + Cache-Control** so the device **skips the e-paper refresh when the image is unchanged** — saves screen wear and avoids the refresh flash ([Rendering Architecture](../concepts/rendering-architecture.md), [calendar-integration repos](../raw/repos/2026-07-20-calendar-integration-repos.md) ETag pattern).
- [ ] Fail-safe: on server-unreachable or fetch error, keep the **last image** (e-paper is bistable — it holds with zero power) rather than blanking ([Power & Refresh](../concepts/power-and-refresh.md)); add WiFi/NTP retry.
- [ ] Confirm **USB power** operation is stable over a multi-hour soak (battery explicitly out of scope for v1 — this board is ~1.4 mA sleep stock, no LED/LDO mods).
- [ ] Set up the server container to **restart on boot** (`restart: unless-stopped`) so the dashboard survives a box reboot.
**Dependencies**: Phase 4.
**Validation (on hardware)**: Over a multi-hour soak on USB, the panel updates on the interval with **no ghosting accumulation**, skips redraws when data is unchanged (observe the serial log reporting 304/no-change), and recovers gracefully after you briefly stop and restart the server container (shows stale image, then resumes). This is the "add screens + it just runs" end state from deliverable #1.
**Wiki grounding**: [Power & Refresh](../concepts/power-and-refresh.md), [Rendering Architecture](../concepts/rendering-architecture.md), [Limitations](../concepts/limitations-and-gotchas.md).

---

## Risks & Mitigations

Grounded in [Limitations & Gotchas](../concepts/limitations-and-gotchas.md) and [Power & Refresh](../concepts/power-and-refresh.md), per deliverable #4.

| Risk | Source | Mitigation |
|------|--------|------------|
| **Wrong panel init sequence → ghosting/blank** | [firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md), [Limitations](../concepts/limitations-and-gotchas.md) | Phase 3 test-flash cycle through the fork's 3 sequences with a known test image; lock the one that renders clean. |
| **BUSY-polarity error → permanent panel damage** | [Limitations](../concepts/limitations-and-gotchas.md) | Do NOT flip BUSY inversion casually; change one variable at a time; only invert if the panel's known-good config requires it. Watch serial for BUSY timeouts. |
| **1-bit dithering fidelity** — `takumi`/HTML render leaks anti-aliased grays; panel shows muddy text | [BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) #3 | Force true 1-bit @ 800×480 in the recipe render (palette-snap/dither); inspect the server preview at 100% before pushing to the panel. |
| **LAN HTTP-vs-HTTPS / self-signed cert friction** | [BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) #2, [firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md) | Serve plain **HTTP on the trusted LAN** — avoids cert handling entirely. Only introduce TLS if you later expose the server beyond the LAN (then it's `setCACert` vs `setInsecure`, [Data Sources](../concepts/data-sources.md)). |
| **~180 s refresh floor + ghosting from over-refreshing** | [Power & Refresh](../concepts/power-and-refresh.md), [Limitations](../concepts/limitations-and-gotchas.md) | Never set `refresh_rate` below ~180 s; use 15–30 min; full-refresh per wake; sleep the panel after each refresh. BTC volatility can't be chased — accept the interval. |
| **Partial-refresh corruption after deep sleep** | [Power & Refresh](../concepts/power-and-refresh.md) | Full-refresh per wake (controller image RAM is lost across deep sleep); don't attempt partial refresh in this loop. |
| **mempool.space rate-limit / 429 ban** | [Data Sources](../concepts/data-sources.md) | Poll server-side every few minutes max (device polls at 15–30 min anyway); consider a self-hosted mempool later if abused. |
| **Non-default SPI pins not remapped → nothing draws** | [Hardware Platform](../concepts/hardware-platform.md) | Explicitly set BUSY25/RST26/DC27/CS15/CLK13/DIN14 in firmware; verify against the fork's config before flashing. |
| **Server is a single point of failure (device depends on it)** | [Rendering Architecture](../concepts/rendering-architecture.md) | `restart: unless-stopped` on the container; e-paper bistability holds the last image on outage; device retries. LAN-colocated always-on box makes this low-probability. |
| **Board is ~1.4 mA in deep sleep — not battery-friendly stock** | [Power & Refresh](../concepts/power-and-refresh.md), [Hardware Platform](../concepts/hardware-platform.md) | **v1 runs on USB** (explicitly in scope). Battery deferred; if pursued later, do LED desolder + GPIO4 display-gating mods first. |
| **Adapter caveat (HAT rev 2.2/2.3 PWR pin)** | [Hardware Platform](../concepts/hardware-platform.md) | Identify the adapter in Phase 0; if it's a HAT rev needing the PWR pin tied high, handle it before blaming the init sequence. |

## Open Questions

- **Exact panel model/resolution** — resolved in **Phase 0** on the hardware (the plan assumes mono 7.5" 800×480 but adapts). *No web research can answer this; it's a physical read.*
- **Which of the 3 init sequences** — resolved empirically in **Phase 3**; not documented per-revision anywhere in the corpus.
- **iCloud `.ics` publish mechanics** — confirm your iCloud calendar's "Public Calendar" toggle produces a `webcal://`/`https://` `.ics` the server can fetch; if you're on Outlook instead, use its "Publish" ICS link. Minor, resolved during Phase 4.
- **CP2102 vs CH343 macOS driver** — if the port doesn't enumerate in Phase 0, a CH343 driver install may be needed (CP2102 is usually built into recent macOS). Not yet known which chip your unit has.
- **Follow-up research** (optional): if you later want grayscale/richer visuals, run `/wiki:plan` again against [Grayscale & Upgrade Path](../concepts/grayscale-and-upgrade-path.md) (server-side dithering vs GxEPD2_4G vs Inkplate/epdiy hardware).

## Sources Consulted

- [Build Playbook](../reference/build-playbook.md) — recommended stack, step 0–5 skeleton, SPI remap, USB-power guidance, serverless fallback.
- [TRMNL BYOS Walkthrough](../reference/trmnl-byos-walkthrough.md) — 3-endpoint contract, byos_next vs byos_django, flash steps, Bitcoin recipe, friction points.
- [Rendering Architecture](../concepts/rendering-architecture.md) — the on-device vs server-side fork; ETag/304 cadence; why thin client fits.
- [Hardware Platform](../concepts/hardware-platform.md) — pin map, chip/flash/UART, RAM ceiling, GPIO0 download mode, adapter caveat, ~1.4 mA reality.
- [Firmware Stacks](../concepts/firmware-stacks.md) — GxEPD2 class typedefs, panel selection, hibernate.
- [Data Sources](../concepts/data-sources.md) — mempool.space endpoints, Open-Meteo, calendar three poles, JSON/HTTPS reality.
- [Power & Refresh](../concepts/power-and-refresh.md) — deep-sleep loop, 180 s floor, full-refresh-per-wake gotcha, corrected battery math, panel-sleep damage rule.
- [Limitations & Gotchas](../concepts/limitations-and-gotchas.md) — the risk table backbone (BUSY damage, dithering, TLS, ghosting).
- [Turnkey Projects](../reference/turnkey-projects.md) — olivrrrr fork as best-fit, esp32-weather-epd fallback, MagInkDash/BTClock data-layer references.
- [BYOS implementations](../raw/repos/2026-07-20-trmnl-byos-implementations.md) — byos_next config/env, recipe folder structure.
- [firmware config](../raw/repos/2026-07-20-trmnl-firmware-config.md) — API_BASE_URL, PlatformIO envs, WiFiManager, 3 panel init sequences.
- [calendar-integration repos](../raw/repos/2026-07-20-calendar-integration-repos.md) — server-render vs OAuth vs Apps Script; ETag/Cache-Control pattern.
