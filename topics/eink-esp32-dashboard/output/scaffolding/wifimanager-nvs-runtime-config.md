# WiFiManager Captive Portal + NVS Runtime Config (portability enabler)

> ### ✅ VERIFIED CORRECTION (apply — OVERRIDES the draft's config-reset trigger)
> Adversarial verify pass, high confidence, vs the official Waveshare schematic:
> - **There is NO user button on GPIO12.** The board has exactly two buttons: **S2 `KEY_RST/USER` on EN/CHIP_PU** (reset) and **S1 `KEY_FLASH` on GPIO0**. The wiki/ESPHome profile's "KEY on GPIO12" is contradicted by the schematic. **Do NOT gate boot behavior on GPIO12** (GPIO12/MTDI is a flash-voltage strapping pin). For the config-reset trigger, **read GPIO0 (S1) after a normal boot**, or use the EN reset button. Confirm your unit's button wiring with a meter before relying on it.
> - Pin **`tzapu/WiFiManager @ 2.0.17`** exactly (not `^2.0.17`); verify the resolved lib in the build log.
> - `resetSettings()` clears only WiFi creds — call `prefs.clear()` explicitly to wipe the custom `cfg`/Preferences namespace too.
> - Full C1–C7 list: `../buildlog-phase0-2026-07-20.md`.

# WiFiManager Captive Portal + NVS Runtime Config

**Goal:** make the on-device Bitcoin/weather dashboard *portable* — set WiFi creds + latitude + longitude + fiat currency at runtime through a captive portal, persist them, and read them back on every deep-sleep wake with **no reflash** to move networks/locations. Base firmware is the [`lmarzen/esp32-weather-epd`](https://github.com/lmarzen/esp32-weather-epd) fork (GxEPD2, on-device render) per the wiki [on-device plan](/Users/garykrause/wiki/topics/eink-esp32-dashboard/output/plan-ondevice-waveshare-dashboard-2026-07-20.md), Decision 4.

Library: **tzapu/WiFiManager v2.0.17** (latest release, 2024-03-02 — verified against the repo). All method names below are from that version's `WiFiManager.h`.

---

## 0. The one storage fact that shapes everything

There are **two** persistent stores, and they are separate:

| What | Where it lives | Who writes it |
|------|----------------|---------------|
| **WiFi SSID + password** | ESP32 WiFi-stack NVS (`esp_wifi` credential store, namespace `nvs.net80211`) | **WiFiManager / the ESP32 SDK — automatically.** You never call `putString` for these. |
| **Custom fields** (lat, lon, currency) | *Your own* `Preferences` namespace (e.g. `"cfg"`) | **You** — WiFiManager only hands you the string via `getValue()`; the README states plainly: *"You are responsible for saving and loading these custom values."* |

So on wake: `autoConnect()` silently reuses the SDK-stored WiFi creds (no portal), and you re-read lat/lon/currency from your `Preferences` namespace. Both stores survive deep sleep **and** power loss (NVS is flash-backed).

---

## 1. `platformio.ini` — pin the deps

```ini
[env:waveshare_epd_esp32]
platform = espressif32
board = esp32dev            ; ESP32-D0WD-V3 / WROOM-32E, 4 MB, no PSRAM
framework = arduino
monitor_speed = 115200

; --- flashing quirk on THIS board: stub flasher fails with a RAM checksum error.
; Use a conservative baud; if PlatformIO still fails, flash with esptool --no-stub.
upload_speed = 115200

lib_deps =
    tzapu/WiFiManager @ ^2.0.17     ; captive portal + custom params
    bblanchon/ArduinoJson @ ^7.0.0  ; API parsing (already used by weather-epd)
    zinggjm/GxEPD2 @ ^1.5.8         ; panel driver (already used by weather-epd)

; WiFiManager transitively needs DNSServer + WebServer, both bundled with the ESP32 core.
```

> `WiFiManager @ ^2.0.17` is important — the pre-2.0 (tzapu 0.x/1.x) API does **not** have `setSaveParamsCallback`, `getWiFiIsSaved`, or `setEnableConfigPortal`. See risky-claims.

The default 4 MB partition table already contains an `nvs` partition — both credential stores share it, no partition change needed.

---

## 2. The runtime-config module

Drop this in as `runtime_config.h` / `runtime_config.cpp` (or inline into the weather-epd `config.cpp`). It is the complete portability layer.

### `runtime_config.h`

```cpp
#pragma once
#include <Arduino.h>

// Loaded from NVS on each wake; consumed by the fetch/draw layers.
struct RuntimeConfig {
  double lat;         // e.g. 40.7128
  double lon;         // e.g. -74.0060
  char   currency[4]; // 3-letter, one of the mempool price fields, e.g. "USD"
  bool   valid;       // true once lat/lon/currency have been set at least once
};

// Call ONCE at the very top of setup(). Handles: KEY-button reset detection,
// the captive portal (only when needed), WiFi connect, and loading the struct.
// Returns false only if we could not get online AND could not raise a portal
// (caller should keep the last e-paper image and go back to deep sleep).
bool runtimeConfigBegin(RuntimeConfig &cfg);
```

### `runtime_config.cpp`

```cpp
#include "runtime_config.h"
#include <WiFiManager.h>   // tzapu, v2.0.17
#include <Preferences.h>
#include <WiFi.h>

// ---- board / portal constants ----------------------------------------------
static const int      KEY_BTN_PIN      = 12;   // Waveshare user KEY button (active-LOW, pulls to GND)
static const uint32_t KEY_HOLD_MS      = 3000; // hold this long at boot to wipe config
static const char*    AP_NAME          = "BTC-EPD-Setup";
static const char*    AP_PASS          = "setup1234"; // >= 8 chars, or use "" for open AP
static const uint16_t PORTAL_TIMEOUT_S = 300;  // 5 min, then give up and deep-sleep

// ---- our Preferences (NVS) namespace ---------------------------------------
static const char* NVS_NS  = "cfg";
Preferences        prefs;

// ---- custom portal fields (file-scope so the save callback can read them) --
// WiFiManagerParameter(id, label/prompt, defaultValue, maxLength)
static char defLat[16]  = "0.0";
static char defLon[16]  = "0.0";
static char defCur[4]   = "USD";
static WiFiManagerParameter p_lat("lat",  "Latitude (-90..90)",   defLat, 15);
static WiFiManagerParameter p_lon("lon",  "Longitude (-180..180)",defLon, 15);
static WiFiManagerParameter p_cur("cur",  "Fiat (USD/EUR/GBP/CAD/CHF/AUD/JPY)", defCur, 3);

static bool s_shouldSave = false;

// mempool.space /api/v1/prices ONLY returns these fields (verified live 2026-07-20).
static bool currencyAllowed(const String &c) {
  return c == "USD" || c == "EUR" || c == "GBP" || c == "CAD" ||
         c == "CHF" || c == "AUD" || c == "JPY";
}

// Fires when the user hits Save on the portal form (WiFi page carries the
// custom params too). This is the single write path for our custom fields.
static void saveParamsCallback() {
  String lat = p_lat.getValue();
  String lon = p_lon.getValue();
  String cur = p_cur.getValue();
  cur.toUpperCase();
  if (!currencyAllowed(cur)) cur = "USD";   // validate against mempool field set

  prefs.begin(NVS_NS, /*readOnly=*/false);
  prefs.putString("lat", lat);              // store raw strings; parse to double on read
  prefs.putString("lon", lon);
  prefs.putString("cur", cur);
  prefs.putBool("valid", true);
  prefs.end();

  s_shouldSave = true;
  Serial.printf("[cfg] saved lat=%s lon=%s cur=%s\n", lat.c_str(), lon.c_str(), cur.c_str());
}

// Shown on the e-paper (via AP callback) so the user knows what AP to join.
static void apCallback(WiFiManager *wm) {
  Serial.printf("[cfg] portal up. Join SSID '%s', browse http://%s\n",
                AP_NAME, WiFi.softAPIP().toString().c_str());
  // OPTIONAL: draw a "Setup: join <AP_NAME>, open <IP>" screen on the panel here.
}

// ---- KEY button: reset trigger ---------------------------------------------
// SAFETY: GPIO12 is the ESP32 MTDI strapping pin (selects VDD_SDIO flash voltage;
// MUST be LOW at boot). The Waveshare KEY button pulls GPIO12 to GND, so holding
// it keeps the pin LOW = safe. We only enable INPUT_PULLUP AFTER boot, so the
// strap has already latched LOW (GPIO12's internal pulldown default). Never wire
// a button that pulls GPIO12 HIGH at boot. (See risky-claims #1.)
static bool resetButtonHeld() {
  pinMode(KEY_BTN_PIN, INPUT_PULLUP);
  if (digitalRead(KEY_BTN_PIN) != LOW) return false;     // not pressed
  uint32_t t0 = millis();
  while (digitalRead(KEY_BTN_PIN) == LOW) {              // require sustained hold
    if (millis() - t0 >= KEY_HOLD_MS) return true;
    delay(20);
  }
  return false;
}

static void loadConfig(RuntimeConfig &cfg) {
  prefs.begin(NVS_NS, /*readOnly=*/true);
  cfg.valid = prefs.getBool("valid", false);
  String lat = prefs.getString("lat", "0.0");
  String lon = prefs.getString("lon", "0.0");
  String cur = prefs.getString("cur", "USD");
  prefs.end();

  cfg.lat = lat.toDouble();
  cfg.lon = lon.toDouble();
  strncpy(cfg.currency, cur.c_str(), sizeof(cfg.currency) - 1);
  cfg.currency[sizeof(cfg.currency) - 1] = '\0';
}

bool runtimeConfigBegin(RuntimeConfig &cfg) {
  // Seed the portal field defaults from the last-saved values so the form is
  // pre-filled when re-opened.
  {
    prefs.begin(NVS_NS, true);
    prefs.getString("lat", "0.0").toCharArray(defLat, sizeof(defLat));
    prefs.getString("lon", "0.0").toCharArray(defLon, sizeof(defLon));
    prefs.getString("cur", "USD").toCharArray(defCur, sizeof(defCur));
    prefs.end();
    p_lat.setValue(defLat, 15);   // v2.0.x: setValue(const char*, int) — refresh field default
    p_lon.setValue(defLon, 15);
    p_cur.setValue(defCur, 3);
  }

  const bool resetRequested = resetButtonHeld();

  WiFiManager wm;
  wm.setSaveParamsCallback(saveParamsCallback);  // custom fields -> our NVS
  wm.setAPCallback(apCallback);
  wm.setConfigPortalTimeout(PORTAL_TIMEOUT_S);   // don't stay awake forever
  wm.setBreakAfterConfig(true);                  // exit even if the join later fails
  wm.addParameter(&p_lat);
  wm.addParameter(&p_lon);
  wm.addParameter(&p_cur);

  if (resetRequested) {
    Serial.println("[cfg] KEY held -> wiping WiFi creds + custom config");
    wm.resetSettings();                          // clears WiFi creds (see risky-claims #3)
    prefs.begin(NVS_NS, false);
    prefs.clear();                               // also wipe OUR custom fields
    prefs.end();
  }

  const bool needPortal = resetRequested || !wm.getWiFiIsSaved();

  bool online = false;
  if (needPortal) {
    // Blocking portal. Returns true if the user configured + we joined.
    online = wm.startConfigPortal(AP_NAME, AP_PASS);
    if (!online) {
      Serial.println("[cfg] portal timed out with no valid config");
      return false;                              // caller: keep last image, deep-sleep, retry
    }
  } else {
    // FAST PATH on every normal wake: reuse SDK-stored creds, DO NOT raise a portal.
    wm.setEnableConfigPortal(false);             // autoConnect returns false instead of blocking
    online = wm.autoConnect(AP_NAME, AP_PASS);
    if (!online) {
      Serial.println("[cfg] WiFi down this wake; not opening portal");
      return false;                              // caller: keep last image, deep-sleep, retry
    }
  }

  loadConfig(cfg);
  Serial.printf("[cfg] online. lat=%.4f lon=%.4f cur=%s valid=%d\n",
                cfg.lat, cfg.lon, cfg.currency, cfg.valid);
  return true;
}
```

---

## 3. Wiring it into the deep-sleep loop (`main.cpp` / weather-epd `setup()`)

The device is not a `loop()` program — it does everything in `setup()`, then deep-sleeps. WiFiManager is only *touched* when a portal is actually needed; the normal wake just connects and moves on.

```cpp
#include "runtime_config.h"
#include "esp_sleep.h"

#define WAKE_INTERVAL_S (20 * 60)      // 20 min; >= 180 s panel-protection floor
RTC_DATA_ATTR uint32_t bootCount = 0;  // survives deep sleep

static void goToDeepSleep() {
  // (weather-epd draws the panel, then hibernate()s it, before this)
  esp_sleep_enable_timer_wakeup((uint64_t)WAKE_INTERVAL_S * 1000000ULL);
  Serial.flush();
  esp_deep_sleep_start();
}

void setup() {
  Serial.begin(115200);
  bootCount++;

  RuntimeConfig cfg;
  if (!runtimeConfigBegin(cfg)) {
    // No WiFi and no portal completed. E-paper is bistable: leave the last good
    // frame on screen (do NOT clear it), and just sleep + retry next interval.
    goToDeepSleep();
  }

  if (!cfg.valid) {
    // Creds exist but user never set a location (shouldn't happen after portal).
    // Draw a "set location" hint, or just sleep.
    goToDeepSleep();
  }

  // ---- build the API URLs from runtime config -----------------------------
  char weatherUrl[256];
  snprintf(weatherUrl, sizeof(weatherUrl),
    "https://api.open-meteo.com/v1/forecast"
    "?latitude=%.4f&longitude=%.4f"
    "&current=temperature_2m,weather_code"
    "&daily=temperature_2m_max,temperature_2m_min,weather_code"
    "&timezone=auto",
    cfg.lat, cfg.lon);

  // mempool.space: fees + tip height need no config; price uses cfg.currency,
  // which is one of the fields /api/v1/prices actually returns.
  //   GET https://mempool.space/api/v1/prices     -> pick doc[cfg.currency]
  //   GET https://mempool.space/api/v1/fees/recommended
  //   GET https://mempool.space/api/blocks/tip/height   (bare integer -> atoi)

  // ... fetch (setInsecure + useHTTP10 + streamed deserializeJson + delete client),
  // ... GxEPD2 paged full-refresh draw, hibernate() the panel ...

  goToDeepSleep();
}

void loop() {}  // never reached
```

### Reading `cfg.currency` in the price fetch

```cpp
// after streaming /api/v1/prices into `doc`:
long btcPrice = doc[cfg.currency] | 0;   // e.g. doc["USD"]; 0 if the field is missing
```
Verified live 2026-07-20, `/api/v1/prices` →
`{"time":...,"USD":65428,"EUR":57328,"GBP":48785,"CAD":92135,"CHF":52999,"AUD":93454,"JPY":10628965}`.

---

## 4. Deep-sleep interaction — the rules that matter

- **Portal only when needed.** `needPortal = resetRequested || !wm.getWiFiIsSaved()`. Every ordinary timed wake takes the `setEnableConfigPortal(false)` + `autoConnect()` fast path: it connects using the SDK-stored creds in ~1–3 s and never raises an AP. This is what keeps the awake window short (the whole energy budget is the WiFi burst).
- **NVS/Preferences persist across deep sleep and power loss** — no need to re-enter config after a wake or a power cycle. `Preferences.getString(...)` on each wake is the "read them back" step.
- **Failure = keep the last frame.** E-paper is bistable, so if WiFi is momentarily down we return `false`, leave the panel untouched, and deep-sleep to retry — never blank the screen and never block in a portal on a transient failure.
- **`WiFiManager` is a stack local** — it's constructed and destroyed inside `runtimeConfigBegin()`, so it costs nothing (RAM or the ~always-listening DNS/web servers) on the fast path once the portal isn't running.
- **Portal timeout is mandatory** (`setConfigPortalTimeout(300)`) so a device that boots with no creds and no user present doesn't sit awake indefinitely — it gives up and sleeps.

## 5. Config-reset trigger (KEY button, GPIO12)

- Hold the **user KEY button (GPIO12) for ~3 s at/after boot** → `resetButtonHeld()` returns true → `wm.resetSettings()` wipes WiFi creds and `prefs.clear()` wipes lat/lon/currency → the portal comes up fresh. This is how you re-home the device to a new network.
- **Why GPIO12 is safe here (and how it could bite you):** GPIO12 is the ESP32 **MTDI strapping pin** that selects flash voltage (VDD_SDIO) and **must read LOW at boot**. The Waveshare KEY button pulls GPIO12 **to GND**, so holding it at boot keeps the strap LOW — safe. We only enable `INPUT_PULLUP` *after* boot, so the strap has already latched. **If your board's button instead pulled GPIO12 to 3.3 V, holding it at boot could select 1.8 V flash and fail to boot** — verify polarity (risky-claims #1).

---

## 6. Version-specific API notes (WiFiManager 2.0.17)

- `WiFiManagerParameter(id, label, default, maxLength)` — 4-arg form (confirmed in header line 218). A 5th arg (`const char *custom` for extra HTML attrs) and 6th (`labelPlacement`) exist if you want e.g. `type="number"` inputs.
- `setSaveParamsCallback(std::function<void()>)` fires when the portal form is saved — the reliable hook for custom fields. (`setSaveConfigCallback` fires only after a *successful WiFi connect* or `setBreakAfterConfig(true)`; less reliable for params-only edits.)
- `getWiFiIsSaved()`, `setEnableConfigPortal(bool)`, `resetSettings()`, `setConfigPortalTimeout(sec)`, `startConfigPortal(ap,pass)`, `autoConnect(ap,pass)` — all confirmed present in 2.0.17's `WiFiManager.h`.
- `WiFiManagerParameter::getValue()` returns `const char*`; `setValue(const char*, int)` updates the field default (used above to pre-fill the form). Confirmed in header.

---

## 7. Sources

- Wiki: [on-device plan](/Users/garykrause/wiki/topics/eink-esp32-dashboard/output/plan-ondevice-waveshare-dashboard-2026-07-20.md) (Decision 4), [hardware-platform.md](/Users/garykrause/wiki/topics/eink-esp32-dashboard/concepts/hardware-platform.md) (KEY button GPIO12, GPIO4 rail gate, no PSRAM), [power-and-refresh.md](/Users/garykrause/wiki/topics/eink-esp32-dashboard/concepts/power-and-refresh.md) (deep-sleep loop, RTC_DATA_ATTR, 180 s floor), [data-sources.md](/Users/garykrause/wiki/topics/eink-esp32-dashboard/concepts/data-sources.md) (mempool + Open-Meteo endpoints), [trmnl-firmware-config raw note](/Users/garykrause/wiki/topics/eink-esp32-dashboard/raw/repos/2026-07-20-trmnl-firmware-config.md) (same WiFiManager captive-portal pattern in production firmware).
- WiFiManager repo + header: <https://github.com/tzapu/WiFiManager> (v2.0.17, 2024-03-02); canonical custom-param example `examples/Parameters/SPIFFS/AutoConnectWithFSParameters/AutoConnectWithFSParameters.ino`.
- mempool.space live responses (fetched 2026-07-20): `/api/v1/prices`, `/api/v1/fees/recommended`, `/api/blocks/tip/height`.
- Open-Meteo forecast API: <https://open-meteo.com/en/docs> (keyless, HTTPS).
- ESP32 GPIO12 strapping / VDD_SDIO: Espressif GPIO docs + Random Nerd Tutorials pinout ("GPIO12 must be LOW during boot; boot fails if pulled high").

---
## Risky claims flagged for verification

- **The Waveshare user KEY button on GPIO12 pulls the pin to GND (active-LOW), which is what makes holding it at boot safe. GPIO12 is the ESP32 MTDI strapping pin that selects flash voltage (VDD_SDIO) and MUST be LOW at boot.**
  - risk: If the board actually wires the button to pull GPIO12 to 3.3V, holding it during boot could select 1.8V flash and brick the boot / cause a boot loop on a 3.3V-flash WROOM-32E. The wiki confirms 'KEY button on GPIO12' but not the pull direction. Verify against the board schematic before shipping the reset-at-boot feature; if it pulls high, move the reset trigger to a different pin or read the button only after a normal boot.
- **resetSettings() clears only the WiFi credentials, not our custom Preferences namespace 'cfg' — so the code explicitly calls prefs.clear() to wipe lat/lon/currency.**
  - risk: If the build defines WM_ERASE_NVS (a WiFiManager compile flag), resetSettings() erases the ENTIRE NVS partition, which would also wipe our 'cfg' namespace (and anything else in NVS). The flag is off by default in 2.0.17, but a fork or a global define could enable it, changing behavior.
- **WiFi SSID/password are persisted automatically by the ESP32 WiFi SDK NVS (separate from our Preferences namespace), so autoConnect() on each wake reconnects without a portal and we never save creds ourselves.**
  - risk: This relies on WiFi persistence being enabled (WiFi.persistent(true), the ESP32 default). If some other code calls WiFi.persistent(false) or erases nvs.net80211, autoConnect() would raise the portal on every wake, defeating the deep-sleep fast path and stranding a headless device.
- **mempool.space /api/v1/prices returns exactly these fiat fields: USD, EUR, GBP, CAD, CHF, AUD, JPY — so the currency field must be one of these and doc[cfg.currency] indexes them directly.**
  - risk: Verified by a live fetch on 2026-07-20, but the field set is not contractually documented and could change; a currency string outside this set (e.g. a user typing 'MXN') yields price 0 on the display. The code validates and defaults to USD, but the allowed list is hard-coded to today's observed response.
- **The API names setSaveParamsCallback, getWiFiIsSaved, and setEnableConfigPortal exist and behave as described in tzapu/WiFiManager v2.0.17 (pinned via '^2.0.17').**
  - risk: These methods do NOT exist in the pre-2.0 (0.x/1.x) tzapu API and some third-party forks. If the Library Manager resolves a different WiFiManager (there are several similarly-named libraries), the sketch will fail to compile or silently behave differently. Confirm the exact library and version resolved.
