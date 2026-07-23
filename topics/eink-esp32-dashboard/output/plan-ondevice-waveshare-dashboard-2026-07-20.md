---
title: "Plan: Self-contained on-device Waveshare ESP32 dashboard (Bitcoin + weather, no server)"
type: plan
format: roadmap
supersedes: plan-byos-waveshare-dashboard-2026-07-20.md
sources:
  - reference/build-playbook.md
  - reference/turnkey-projects.md
  - concepts/rendering-architecture.md
  - concepts/firmware-stacks.md
  - concepts/hardware-platform.md
  - concepts/data-sources.md
  - concepts/power-and-refresh.md
  - concepts/limitations-and-gotchas.md
  - raw/repos/2026-07-20-esp32-weather-epd.md
  - raw/repos/2026-07-20-gxepd2.md
  - raw/articles/2026-07-20-arduinojson-httpclient.md
  - raw/articles/2026-07-20-esp32-https-requests.md
  - raw/data/2026-07-20-mempool-space-api.md
generated: 2026-07-20
---

# Plan: Self-contained on-device Waveshare ESP32 dashboard

> Generated from the [eink-esp32-dashboard](../_index.md) wiki. **Supersedes the BYOS/server plan** — architecture pivoted to fully on-device (no server) per user decision: "I don't want a server… self-contained and portable… happy to drop calendar if heavy."

## Executive Summary

Build a **self-contained, portable** e-ink dashboard entirely **on the ESP32** — no server anywhere. A **Waveshare e-Paper ESP32 Driver Board (ESP32-WROOM-32E)** drives a **mono** panel, fetches **Bitcoin (mempool.space)** and **weather (Open-Meteo)** directly over WiFi, and draws a **combined screen with Bitcoin emphasized** using GxEPD2. **Calendar is dropped for v1** (it's the one source that wants a server/OAuth; a public `.ics` is the light way to add it back later). Runs on **USB power**. Portability comes from a **WiFiManager captive portal** — set WiFi/location/currency at runtime, no reflash to move it to a new network.

We fork the wiki's recommended no-server reference, [`esp32-weather-epd`](../raw/repos/2026-07-20-esp32-weather-epd.md), which already drives Waveshare 800×480 panels with GxEPD2 and documents the exact driver-board wiring caveats we'll hit — then add a mempool.space Bitcoin layer and redesign the layout.

**Environment:** the board is on THIS Mac over USB; the harness installs the toolchain (PlatformIO/esptool), builds, flashes, and reads the serial monitor directly. Your only manual step is the physical USB connection and, at runtime, joining the device's captive-portal WiFi setup once.

## How this stays inside the hardware constraints

| Constraint (from wiki) | How the on-device plan lives within it |
|---|---|
| **No PSRAM** — ~200–320 KB free heap ([Hardware Platform](../concepts/hardware-platform.md)) | **Mono panel** (7.5" 800×480 1bpp ≈ 48 KB) + **GxEPD2 paged drawing** (`firstPage()/nextPage()` renders in strips, trading time for RAM). |
| **TLS is the real memory tax** ([Data Sources](../concepts/data-sources.md), [Limitations](../concepts/limitations-and-gotchas.md)) | `setInsecure()` for public read-only APIs (encrypted, unauthenticated — fine here); **`delete` the `WiFiClientSecure`** each cycle (not `stop()`) to avoid the heap leak; do one HTTPS fetch at a time. |
| **JSON on a constrained heap** ([ArduinoJson how-to](../raw/articles/2026-07-20-arduinojson-httpclient.md)) | Stream: `deserializeJson(doc, http.getStream())`; `http.useHTTP10(true)`; apply a **Filter** to keep only rendered fields; block height needs no JSON at all (bare integer → `atoi`). |
| **ASCII-only fonts by default** ([Limitations](../concepts/limitations-and-gotchas.md)) | Numerics (fees, price, temp) are ASCII — fine. Bake the BTC logo + weather glyphs as 1-bit arrays via **image2cpp**. |
| **~180 s refresh floor + ghosting** ([Power & Refresh](../concepts/power-and-refresh.md)) | Deep-sleep loop, **full-refresh per wake**, 15–30 min interval, RTC content-hash to skip redundant redraws. |
| **Device depends on nothing external** | Self-contained: only dependency is WiFi + two public HTTPS APIs. No server to run, maintain, or reach. |

---

## Architecture Decisions

### Decision 1 (revised): On-device rendering, no server
**Context**: [Rendering Architecture](../concepts/rendering-architecture.md) frames the central fork — (A) on-device fetch+draw vs (B) server-side thin client. The prior plan chose (B); you've chosen self-contained + portable, which is (A).
**Options considered**:
- **(B) Server-side (prior plan)**: trivial firmware, but requires an always-on server the device depends on — the opposite of self-contained/portable.
- **(A) On-device**: fully self-contained; works anywhere with WiFi; no server. Costs RAM (framebuffer + TLS + fonts), firmware churn on layout/API change, ASCII-only text. The wiki's stated cons are **OAuth pain and layout tedium** — both are dodged here by dropping calendar and keeping the layout to numerics + a few baked icons.
**Decision**: **(A) On-device GxEPD2.** For two tiny, stable-schema feeds (Bitcoin, weather) with no auth, on-device is exactly the case the wiki says works well: "Data is easy where it's small (mempool.space, Open-Meteo)."
**Consequences**: You reflash to change layout or feeds (acceptable — the harness drives flashing here). No server to maintain and nothing to be "down." The device is the whole system.

### Decision 2: Fork `esp32-weather-epd` (lmarzen) as the base
**Context**: [Turnkey Projects](../reference/turnkey-projects.md) ranks `esp32-weather-epd` as the **"best on-device / no-server reference"**: GxEPD2-based, supports Waveshare 800×480, ships real power-management code, and **its README documents the exact driver-board/HAT wiring caveats we'll hit**. GPL-3.0.
**Options considered**:
- **Blank GxEPD2 sketch**: maximum control, maximum boilerplate (WiFi, NTP, deep-sleep, fetch, paged draw all from scratch).
- **`esp32-weather-epd` fork**: start from a working weather dashboard on our panel class; add Bitcoin; redesign layout. The [Build Playbook](../reference/build-playbook.md) names this exact move as the "fallback if no server desired": *"fork esp32-weather-epd, add mempool + calendar, on-device GxEPD2 full-refresh per wake."*
**Decision**: **Fork `esp32-weather-epd`.** It already solves the hard 80% (panel driving, Open-Meteo, deep-sleep, power). We add the Bitcoin layer and a combined layout.
**Consequences**: Inherit its GPL-3.0 license and its config structure. We must **remap SPI to our board's pins** (it targets a FireBeetle-style wiring by default) and possibly swap its config-portal story for WiFiManager (Decision 4).

### Decision 3 (revised): Drop calendar for v1 — public `.ics` is the light re-add path
**Context**: [Data Sources](../concepts/data-sources.md) calls calendar "the source that most wants offloading." On-device, its three poles are: server-render (rejected — no server), **on-device OAuth** (the "OAuth pain" — token refresh across deep sleep), and **public `.ics` parse** (viable but adds an ICS parser + more TLS/heap pressure).
**Decision**: **Drop calendar from v1.** Ship Bitcoin + weather solid first. This removes the single heaviest on-device burden and keeps the heap headroom for the framebuffer + TLS.
**Consequences**: If you want calendar back, the **lightest on-device path is a public/secret `.ics` URL** parsed on-device (still no OAuth) — added as a later phase, heap permitting. On-device OAuth stays rejected.

### Decision 4: WiFiManager captive portal for runtime config (the portability enabler)
**Context**: "Portable" means moving the device to a new network/location without reflashing. Stock `esp32-weather-epd` uses **compile-time** WiFi creds + location.
**Options considered**:
- **Compile-time config**: simplest, but every network/location change = reflash. Not portable.
- **WiFiManager captive portal**: on first boot (or on WiFi failure) the device raises an AP; you join it and enter WiFi + latitude/longitude + fiat currency via a web form, persisted to **NVS**. (This is the same captive-portal pattern the TRMNL firmware uses.)
**Decision**: **Add WiFiManager**, storing WiFi creds + location + currency in NVS.
**Consequences**: True portability — plug in anywhere, join the setup AP once, done. Small firmware addition; a well-trodden library. Persists across deep sleep via NVS.

### Decision 5: Panel = mono 7.5" 800×480, paged drawing (confirmed in Phase 0)
**Context**: [Hardware Platform](../concepts/hardware-platform.md) makes the panel the governing choice given no PSRAM. 7.5" mono 1bpp ≈ 48 KB fits "but tight with WiFi/TLS" → **paged drawing** is the safety margin.
**Decision**: Target **mono 7.5" 800×480** with GxEPD2 **paged drawing**; the exact **GxEPD2 class typedef** (e.g. `GxEPD2_750_T7`) is set once Phase 0 confirms the panel part number.
**Consequences**: Choosing the class typedef is the on-device analog of "picking the init sequence" — wrong class → ghosting/blank, resolved empirically in Phase 1. A smaller mono panel (4.2" 400×300) only relaxes the RAM pressure; the plan holds with a different class + render dimensions.

---

## Implementation Phases

Each phase has an explicit **"confirm it worked on the actual hardware"** check.

### Phase 0: Hardware identification (FIRST — the plan branches on it)
**Goal**: Ground truth on the board before any build choice — panel model sets the GxEPD2 class and layout dimensions; the USB-UART chip sets the flashing path.
**Tasks**:
- [ ] **Detect the serial port**: `ls /dev/cu.*` before/after plugging in (`cu.usbserial-*` ⇒ CP2102/SLAB; `cu.wchusbserial*` ⇒ CH343) ([Hardware Platform](../concepts/hardware-platform.md)).
- [ ] **Install tooling**: `pip install esptool`; PlatformIO Core (`brew install platformio` or the installer script).
- [ ] **Read chip + flash**: `esptool.py --port <port> chip_id` and `flash_id` → confirm **ESP32-WROOM-32E**, **4 MB flash**, record the **MAC**.
- [ ] **Enter download mode if needed**: hold **GPIO0→GND during reset (EN)**, release ([Build Playbook](../reference/build-playbook.md) step 2).
- [ ] **Identify the panel**: read the FPC ribbon / silkscreen part number + resolution + color type; map to the GxEPD2 class ([Firmware Stacks](../concepts/firmware-stacks.md)). **Branch point** — record it.
- [ ] **Note the adapter** (DESPI-C02 vs Waveshare HAT rev 2.2/2.3 with its PWR-pin caveat) ([Hardware Platform](../concepts/hardware-platform.md)).
**Dependencies**: None.
**Validation (on hardware)**: `esptool chip_id` prints `ESP32… (WROOM-32E)` + real MAC; `flash_id` shows 4 MB; panel part number + resolution written down. Proceed only once the panel is confirmed.
**Wiki grounding**: [Hardware Platform](../concepts/hardware-platform.md), [Build Playbook](../reference/build-playbook.md) step 0.

### Phase 1: Minimal panel bring-up — first bitmap (nail pins, class, BUSY)
**Goal**: A known test pattern renders crisp on the physical panel — isolating panel driving from any app logic. This is the "first bitmap on panel" milestone.
**Tasks**:
- [ ] Create a minimal PlatformIO project with **GxEPD2** ([GxEPD2](../raw/repos/2026-07-20-gxepd2.md)).
- [ ] Set the **SPI remap** explicitly: **BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14** (non-default VSPI) ([Hardware Platform](../concepts/hardware-platform.md)).
- [ ] Uncomment the **GxEPD2 class typedef** for the Phase-0 panel (e.g. `GxEPD2_750_T7`). Draw a high-contrast test pattern (border + grid + text) using **paged drawing** (`firstPage()/nextPage()`).
- [ ] Flash (`pio run -t upload`; GPIO0→GND if needed); watch `pio device monitor` for **BUSY timeout** warnings.
- [ ] If ghosted/blank/garbled: try the alternate class typedef for the panel family. **Only invert BUSY if the panel's known-good config requires it — wrong BUSY polarity risks *permanent damage*** ([Limitations](../concepts/limitations-and-gotchas.md)). Change one variable at a time.
- [ ] Confirm `hibernate()`/`powerOff()` sleeps the panel after the refresh (never leave it energized) ([Firmware Stacks](../concepts/firmware-stacks.md), [Power & Refresh](../concepts/power-and-refresh.md)).
**Dependencies**: Phase 0.
**Validation (on hardware)**: Test pattern appears **crisp, correctly oriented, full-contrast, no ghosting**. Lock the working class typedef + BUSY polarity into the config.
**Wiki grounding**: [Firmware Stacks](../concepts/firmware-stacks.md), [GxEPD2](../raw/repos/2026-07-20-gxepd2.md), [Limitations](../concepts/limitations-and-gotchas.md).

### Phase 2: Fork esp32-weather-epd — weather rendering on our board
**Goal**: The full app path working end-to-end for weather, proving on-device HTTPS + JSON + paged draw on our exact board.
**Tasks**:
- [ ] Fork/clone [`esp32-weather-epd`](../raw/repos/2026-07-20-esp32-weather-epd.md); open in PlatformIO.
- [ ] **Remap SPI** to our board's pins (Phase 1 values) and set the **panel class** (Phase 1 result). Heed its README driver-board/HAT wiring caveats.
- [ ] Configure it for **Open-Meteo** (keyless) — request only the `current`/`daily` fields rendered, apply an ArduinoJson **Filter** to skip the big `hourly` arrays ([Data Sources](../concepts/data-sources.md)).
- [ ] Apply the **HTTPS discipline**: `setInsecure()`, `useHTTP10(true)`, `deserializeJson(doc, http.getStream())`, and **`delete` the secure client** each cycle ([HTTPS](../raw/articles/2026-07-20-esp32-https-requests.md), [ArduinoJson](../raw/articles/2026-07-20-arduinojson-httpclient.md)).
- [ ] Temporarily hardcode WiFi + location (captive portal comes in Phase 4); flash and monitor.
**Dependencies**: Phase 1.
**Validation (on hardware)**: The panel shows **current weather from Open-Meteo**; values match a `curl` of the same Open-Meteo request at that moment. Serial log shows a clean fetch → parse → paged draw → panel sleep with **stable free-heap** across several cycles (no leak — confirms the `delete`-the-client fix).
**Wiki grounding**: [esp32-weather-epd](../raw/repos/2026-07-20-esp32-weather-epd.md), [Data Sources](../concepts/data-sources.md), [ArduinoJson](../raw/articles/2026-07-20-arduinojson-httpclient.md), [HTTPS](../raw/articles/2026-07-20-esp32-https-requests.md).

### Phase 3: Add Bitcoin (mempool.space) + combined BTC-emphasis layout
**Goal**: The real dashboard — Bitcoin dominant, weather secondary, on one 800×480 frame.
**Tasks**:
- [ ] Add a mempool.space fetch layer ([mempool API](../raw/data/2026-07-20-mempool-space-api.md)): `/api/v1/fees/recommended` (fees), `/api/blocks/tip/height` (**bare integer → `atoi`, no JSON**), `/api/v1/prices` (BTC/USD). Reuse the Phase-2 HTTPS/JSON discipline.
- [ ] **Rate-limit respect**: don't poll faster than a few minutes — HTTP 429/ban on abuse ([Data Sources](../concepts/data-sources.md)). The deep-sleep interval (Phase 5) already enforces this.
- [ ] Bake the **BTC logo + weather glyphs** as 1-bit arrays via image2cpp ([tooling](../raw/articles/2026-07-20-image2cpp-conversion.md)); GFX/U8g2 fonts for numerics.
- [ ] Design the **combined layout**: Bitcoin (fees + height + price) as the **largest region**, weather secondary. Render with paged drawing.
**Dependencies**: Phase 2.
**Validation (on hardware)**: Panel shows the **combined dashboard** — live BTC fees/height/price dominant + current weather — all legible. Cross-check the on-panel mempool numbers against a live `curl mempool.space/api/v1/fees/recommended`. Free heap still stable with the second HTTPS source added.
**Wiki grounding**: [Data Sources](../concepts/data-sources.md), [mempool API](../raw/data/2026-07-20-mempool-space-api.md), [Firmware Stacks](../concepts/firmware-stacks.md) (image2cpp/fonts).

### Phase 4: Portability — WiFiManager captive portal
**Goal**: Move the device to any network/location without reflashing.
**Tasks**:
- [ ] Integrate **WiFiManager**: no stored creds → raise an AP + captive portal; web form collects **WiFi SSID/pass + latitude/longitude + fiat currency**; persist to **NVS**.
- [ ] Add a **config-reset trigger** (e.g. hold the board's **KEY button on GPIO12** at boot) to re-open the portal on a new network.
- [ ] Ensure NVS values survive deep sleep and are read on each wake.
**Dependencies**: Phase 3.
**Validation (on hardware)**: Fresh-flashed (or config-reset) device raises the setup AP; after entering creds + location it fetches and renders. **Move it to a second WiFi network** (phone hotspot) via the portal — it reconnects and renders **without a reflash**. This proves "portable."
**Wiki grounding**: [Build Playbook](../reference/build-playbook.md) (captive-portal pattern), [Hardware Platform](../concepts/hardware-platform.md) (KEY button GPIO12).

### Phase 5: Deep-sleep loop, change-skipping & hardening
**Goal**: A stable self-contained dashboard that respects panel physics and API limits, running unattended on USB.
**Tasks**:
- [ ] Implement the loop: **wake (RTC timer) → WiFi → NTP → fetch (weather + BTC) → paged draw → deep sleep**; keep awake ~5–15 s ([Power & Refresh](../concepts/power-and-refresh.md)).
- [ ] Set the interval to **15–30 min** (never below the **~180 s panel-protection floor**); **full-refresh per wake** (partial refresh corrupts after deep sleep — controller RAM lost).
- [ ] **RTC content-hash**: store a hash of the rendered content in `RTC_DATA_ATTR`; **skip the redraw** (and the refresh flash) when nothing changed ([Power & Refresh](../concepts/power-and-refresh.md)).
- [ ] **NTP each wake** (clock drift over long uptime); align wakes to clock boundaries so displayed times are accurate.
- [ ] **Fail-safe**: on WiFi/fetch failure, keep the **last image** (e-paper is bistable — holds at zero power) rather than blanking; add retry with backoff.
- [ ] **USB soak test** over multiple hours (battery explicitly out of scope for v1 — board is ~1.4 mA sleep stock, no LED/LDO mods).
**Dependencies**: Phase 4.
**Validation (on hardware)**: Multi-hour USB soak: panel updates on interval with **no ghosting accumulation**, **skips redraws** when data is unchanged (serial log shows hash-match/skip), stays on the **last good image** through a brief WiFi outage, and free heap is stable across dozens of cycles. This is the "it just runs, self-contained" end state.
**Wiki grounding**: [Power & Refresh](../concepts/power-and-refresh.md), [Limitations](../concepts/limitations-and-gotchas.md).

---

## Risks & Mitigations

Grounded in [Limitations & Gotchas](../concepts/limitations-and-gotchas.md), [Power & Refresh](../concepts/power-and-refresh.md), [Data Sources](../concepts/data-sources.md).

| Risk | Source | Mitigation |
|------|--------|------------|
| **RAM exhaustion** — framebuffer + TLS + fonts exceed free heap | [Hardware Platform](../concepts/hardware-platform.md), [Limitations](../concepts/limitations-and-gotchas.md) | Mono panel + **paged drawing**; one HTTPS fetch at a time; Filter JSON; monitor free heap each phase — it's a first-class validation check. |
| **TLS heap leak** — repeated HTTPS connects crash after N cycles | [Data Sources](../concepts/data-sources.md) | **`delete` the `WiFiClientSecure`** each cycle (not `stop()`); verify stable free heap over dozens of cycles in Phase 5. |
| **Wrong GxEPD2 class / BUSY polarity → ghosting, blank, or *permanent damage*** | [Limitations](../concepts/limitations-and-gotchas.md), [Firmware Stacks](../concepts/firmware-stacks.md) | Resolve empirically in Phase 1 with a test pattern; change one variable at a time; only invert BUSY if the panel's known-good config calls for it. |
| **Non-default SPI pins not remapped → nothing draws** | [Hardware Platform](../concepts/hardware-platform.md) | Explicitly set BUSY25/RST26/DC27/CS15/CLK13/DIN14 in Phase 1 before anything else. |
| **mempool.space 429 / ban** | [Data Sources](../concepts/data-sources.md), [mempool API](../raw/data/2026-07-20-mempool-space-api.md) | Poll only on the 15–30 min wake; block height needs no JSON; if ever abused, self-host mempool or use MQTT from a node. |
| **~180 s refresh floor + ghosting from over-refreshing** | [Power & Refresh](../concepts/power-and-refresh.md) | 15–30 min interval; full-refresh per wake; hibernate the panel after each refresh; RTC hash to skip needless redraws. |
| **Partial-refresh corruption after deep sleep** | [Power & Refresh](../concepts/power-and-refresh.md) | Full-refresh per wake (controller image RAM is lost across deep sleep). |
| **ASCII-only fonts** — no Unicode/emoji for labels/glyphs | [Limitations](../concepts/limitations-and-gotchas.md) | Numerics are ASCII; pre-bake BTC logo + weather icons as 1-bit arrays via image2cpp. |
| **WiFi/NTP flakiness on wake** | [Limitations](../concepts/limitations-and-gotchas.md) | Retry with backoff; keep last image (bistable) on failure; NTP each wake. |
| **Board ~1.4 mA sleep — not battery-friendly stock** | [Power & Refresh](../concepts/power-and-refresh.md) | **v1 runs on USB** (in scope). Battery deferred; would need LED desolder + GPIO4 display-gating first. |

## Open Questions

- **Exact panel model/resolution/color** — resolved in **Phase 0** on the hardware; the plan assumes mono 7.5" 800×480 but adapts (class typedef + render dimensions).
- **GxEPD2 class typedef + BUSY polarity** — resolved empirically in **Phase 1**; not documented per-unit in the corpus.
- **CP2102 vs CH343 driver** — if the port doesn't enumerate in Phase 0, a CH343 macOS driver install may be needed.
- **Calendar (deferred)** — if you later want it, the light on-device path is a **public/secret `.ics`** parsed on-device (no OAuth). Feasible only if Phase 5 shows comfortable free-heap headroom; otherwise it's the one feature that argues for reintroducing a tiny proxy.
- **`esp32-weather-epd` config-portal state** — confirm whether the current upstream already has a runtime config portal (would simplify Phase 4) or whether we add WiFiManager ourselves.

## Sources Consulted

- [Build Playbook](../reference/build-playbook.md) — names the exact no-server fallback (fork esp32-weather-epd + mempool), on-device JSON/HTTPS steps, image2cpp.
- [Rendering Architecture](../concepts/rendering-architecture.md) — the on-device vs server fork; why on-device fits small stable feeds.
- [Firmware Stacks](../concepts/firmware-stacks.md) — GxEPD2 class typedefs, paged drawing, hibernate, fonts.
- [Hardware Platform](../concepts/hardware-platform.md) — pin map, RAM ceiling, paged drawing, download mode, KEY button GPIO12.
- [Data Sources](../concepts/data-sources.md) — mempool.space + Open-Meteo on-device; JSON streaming + Filter; TLS `setInsecure`/`delete` discipline; calendar poles.
- [Power & Refresh](../concepts/power-and-refresh.md) — deep-sleep loop, 180 s floor, full-refresh-per-wake, RTC hash, USB power.
- [Limitations & Gotchas](../concepts/limitations-and-gotchas.md) — the risk-table backbone (RAM, TLS, BUSY damage, ASCII fonts, ghosting).
- [Turnkey Projects](../reference/turnkey-projects.md) — esp32-weather-epd as best no-server reference.
- [esp32-weather-epd](../raw/repos/2026-07-20-esp32-weather-epd.md), [GxEPD2](../raw/repos/2026-07-20-gxepd2.md), [ArduinoJson](../raw/articles/2026-07-20-arduinojson-httpclient.md), [HTTPS](../raw/articles/2026-07-20-esp32-https-requests.md), [mempool API](../raw/data/2026-07-20-mempool-space-api.md) — implementation-level grounding.
