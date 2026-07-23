# esp32-weather-epd fork surgery: exact files/edits to remap pins, set panel, use Open-Meteo

> ### ✅ VERIFIED CORRECTIONS (apply these — they OVERRIDE the draft body below)
> Adversarial verify pass, high confidence, checked against the primary Waveshare schematic:
> - **GPIO4 rail polarity is RESOLVED: active-HIGH is CORRECT.** Keep `digitalWrite(PIN_EPD_PWR, HIGH)` = ON. The board wires IO4 → Q32 (S8050 NPN) → Q31 (AO3401 P-FET); the NPN pre-driver inverts, so HIGH conducts. **Ignore the draft's "may be inverted / jumper it on" hedge in §2 and §7** — do NOT flip the writes; LOW would leave the panel dark.
> - **Panel class (C5): your panel `075BN-T7-D2` = Waveshare 7.5" V2 = classic GDEW075T7 (GD7965) → `GxEPD2_750_T7`, NOT the repo default `GxEPD2_750_GDEY075T7` (GDEY075T7/UC8179).** Same 800×480 / BUSY=LOW / same constructor, so wiring is unaffected — but the waveform differs, so the repo default may ghost. Try the repo default first in Phase 1; if it ghosts/blanks, switch the class to `GxEPD2_750_T7` in `renderer.h`/`renderer.cpp`.
> - **PIN_EPD_PWR=4 is mandatory** (upstream default 26 collides with RST=26 on this board) — the draft §2 has this right; keep it.
> - Full C1–C7 correction list: `../buildlog-phase0-2026-07-20.md`.

# esp32-weather-epd fork surgery — exact files & edits

**Repo:** `lmarzen/esp32-weather-epd` · verified against branch `main` this session (2026-07-20) via `gh api` + `raw.githubusercontent.com`. Pinned deps in `platformio.ini`: `espressif32 @ 6.13.0`, `zinggjm/GxEPD2 @ 1.6.8`, `bblanchon/ArduinoJson @ 7.4.3`. License GPL-3.0.

**Target board (ground truth this session):** Waveshare e-Paper ESP32 Driver Board, ESP32-D0WD-V3 (WROOM-32E die), 4 MB flash, **no PSRAM**. SPI remap: BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14. GPIO4 gates the e-paper 3.3 V rail (AO3401 P-MOSFET). KEY=GPIO12. Panel assumed mono 7.5" 800×480.

---

## ⚠️ Read this first — the premise correction that changes the plan

The task brief says this repo "supports OWM and others — confirm how to select keyless Open-Meteo." **It does not.** I read the entire fetch/config path on `main`:

- `platformio/src/config.cpp` defines only `OWM_APIKEY`, `OWM_ENDPOINT`, `OWM_ONECALL_VERSION`, `LAT`, `LON` — no provider variable.
- `platformio/src/client_utils.cpp` has exactly two fetch functions, `getOWMonecall()` and `getOWMairpollution()`, both hardcoded to `api.openweathermap.org` (`/data/3.0/onecall` and `/data/2.5/air_pollution/history`).
- `platformio/src/main.cpp` calls only those two. `platformio/include/api_response.h` structs are all `owm_*_t` and the parsers are `deserializeOneCall()` / `deserializeAirQuality()`.
- A code search for "meteo" in the repo returns **only** "meteorological" wind-direction icons and locale files — zero Open-Meteo integration.
- There is **no provider-selection macro anywhere** (no `WEATHER_PROVIDER`, no `USE_OPEN_METEO`). Branches are only `main` and `cyrillic-alphabet-test`.

So there are two honest paths, and you must pick one before touching code:

| Path | Effort | Notes |
|------|--------|-------|
| **A. Keep OpenWeatherMap** (fastest to a working screen) | ~30 min of config edits | Requires a free OWM "One Call by Call" 3.0 subscription (1,000 calls/day free, credit card on file, cap set to 1000). Everything below "just works." |
| **B. Migrate to keyless Open-Meteo** (matches your architecture) | Real C++ work: new fetch fn + new parser + rewire structs | Not a config toggle. You write it. Prior art: the fork `neuhausf/esp32-weather-epd` added a *MeteoSwiss* provider alongside OWM — a template for how to add a keyless provider cleanly, but it is **not** Open-Meteo. |

The edits in **§1–§4 and §6–§8 apply to both paths.** The Open-Meteo work is isolated in **§5**.

---

## 0. Repo layout (verified paths — everything lives under `platformio/`)

```
platformio/
  platformio.ini                      <- build envs, deps, board
  include/
    config.h                          <- ALL compile-time macros (panel, driver, units, locale, HTTP mode, pin externs)
    api_response.h                    <- owm_*_t structs + deserialize*() decls
    client_utils.h                    <- getOWMonecall/getOWMairpollution decls
    renderer.h                        <- GxEPD2 class typedef + `extern ... display;`  (panel selection)
    display_utils.h
    locales/  locale_en_US.inc ...     (10 locales)
  src/
    config.cpp                        <- pin numbers, WiFi creds, API key, lat/lon, timezone, sleep cadence, battery thresholds
    main.cpp                          <- setup() = the whole program; beginDeepSleep(); NO loop()
    client_utils.cpp                  <- startWiFi/killWiFi, SNTP, getOWMonecall(), getOWMairpollution()
    renderer.cpp                      <- `display` object instantiation + initDisplay()/powerOffDisplay() (SPI remap lives here)
    api_response.cpp                  <- deserializeOneCall()/deserializeAirQuality()
    display_utils.cpp, conversions.cpp, locale.cpp, _strftime.cpp
  lib/esp32-weather-epd-assets/       <- fonts/*.h, icons/*.h (generated)
```

There is **no separate `secrets.h`** — WiFi SSID/password and the API key live directly in `src/config.cpp`. (Good candidate to `.gitignore` if you publish your fork.)

---

## 1. `platformio/platformio.ini` — add a WROOM-32E env + handle the flashing quirk

Current file targets FireBeetle boards only:

```ini
[platformio]
default_envs = dfrobot_firebeetle2_esp32e

[env]
platform = espressif32 @ 6.13.0
framework = arduino
build_unflags = '-std=gnu++11'
build_flags = '-Wall' '-std=gnu++17'
lib_deps =
  adafruit/Adafruit BME280 Library @ 2.3.0
  adafruit/Adafruit BME680 Library @ 2.0.6
  adafruit/Adafruit BusIO @ 1.17.4
  adafruit/Adafruit Unified Sensor @ 1.1.15
  bblanchon/ArduinoJson @ 7.4.3
  zinggjm/GxEPD2 @ 1.6.8

[env:dfrobot_firebeetle2_esp32e]
board = dfrobot_firebeetle2_esp32e
monitor_speed = 115200
board_build.partitions = huge_app.csv
board_build.f_cpu = 80000000L
```

**Edit:** point `default_envs` at a new WROOM env and append it. Generic WROOM-32 = board id `esp32dev`.

```ini
[platformio]
default_envs = waveshare_esp32_driver

; ... [env] block unchanged ...

[env:waveshare_esp32_driver]
board = esp32dev                 ; ESP32-D0WD-V3 / WROOM-32E, 4MB flash
monitor_speed = 115200
board_build.partitions = huge_app.csv   ; single-app, no OTA — this firmware is large; keep it
board_build.f_cpu = 80000000L           ; 80MHz for lower power (upstream default)
upload_port = /dev/cu.usbmodem59090511351
monitor_port = /dev/cu.usbmodem59090511351
upload_speed = 115200            ; conservative — see flashing-quirk note below
```

**Flashing quirk (confirmed on your board):** the esptool **stub** flasher fails with `Failed to write to target RAM (Checksum error)`; `--no-stub` works. PlatformIO runs esptool *with* the stub by default and does not cleanly expose `--no-stub` (it's a global esptool flag that PlatformIO tends to append in the wrong position). Two robust workarounds, in order of preference:

1. **Conservative baud first.** `upload_speed = 115200` (set above) sidesteps the stub checksum error in most reports. Try `pio run -t upload` and see if it syncs.
2. **Build in PlatformIO, flash manually with `--no-stub`.** If (1) still fails:
   ```bash
   ~/.platformio/penv/bin/pio run -e waveshare_esp32_driver          # build only
   # offsets for arduino-esp32 / 4MB: bootloader@0x1000, partitions@0x8000, boot_app0@0xe000, app@0x10000
   esptool.py --chip esp32 --port /dev/cu.usbmodem59090511351 --baud 115200 --no-stub \
     --before default_reset --after hard_reset write_flash -z \
     0x1000  .pio/build/waveshare_esp32_driver/bootloader.bin \
     0x8000  .pio/build/waveshare_esp32_driver/partitions.bin \
     0xe000  ~/.platformio/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin \
     0x10000 .pio/build/waveshare_esp32_driver/firmware.bin
   ```
   Verify the exact offsets against PlatformIO's own upload log (it prints them). If the chip won't sync, hold **GPIO0→GND during EN/reset**.

---

## 2. `platformio/src/config.cpp` — remap SPI to OUR pins + the GPIO4 power gate

Current values are FireBeetle pins. Replace the PINS block:

```cpp
// ---- BEFORE (FireBeetle) ----
const uint8_t PIN_BAT_ADC  = A2;
const uint8_t PIN_EPD_BUSY = 14;
const uint8_t PIN_EPD_CS   = 13;
const uint8_t PIN_EPD_RST  = 21;
const uint8_t PIN_EPD_DC   = 22;
const uint8_t PIN_EPD_SCK  = 18;
const uint8_t PIN_EPD_MISO = 19;
const uint8_t PIN_EPD_MOSI = 23;
const uint8_t PIN_EPD_PWR  = 26;
const uint8_t PIN_BME_SDA  = 17;
const uint8_t PIN_BME_SCL  = 16;
const uint8_t PIN_BME_PWR  =  4;
const uint8_t BME_ADDRESS  = 0x76;
```

```cpp
// ---- AFTER (Waveshare e-Paper ESP32 Driver Board) ----
const uint8_t PIN_BAT_ADC  = 36;   // no onboard divider on this board; irrelevant if BATTERY_MONITORING 0
const uint8_t PIN_EPD_BUSY = 25;
const uint8_t PIN_EPD_CS   = 15;   // strapping pin — fine as an output after boot
const uint8_t PIN_EPD_RST  = 26;
const uint8_t PIN_EPD_DC   = 27;
const uint8_t PIN_EPD_SCK  = 13;
const uint8_t PIN_EPD_MISO = -1;   // e-paper is write-only; -1 = unused on ESP32 SPI.begin()
const uint8_t PIN_EPD_MOSI = 14;
const uint8_t PIN_EPD_PWR  = 4;    // GPIO4 -> AO3401 gates the panel 3.3V rail (SEE POLARITY WARNING)
const uint8_t PIN_BME_SDA  = 21;   // unused (no BME on this board) — park on any free GPIO
const uint8_t PIN_BME_SCL  = 22;   // unused
const uint8_t PIN_BME_PWR  = 23;   // unused — MUST NOT be 4, or it will fight the EPD rail gate
const uint8_t BME_ADDRESS  = 0x76;
```

Notes that will bite you:
- `PIN_EPD_MISO = -1` is intentional. `renderer.cpp::initDisplay()` calls `SPI.begin(PIN_EPD_SCK, PIN_EPD_MISO, PIN_EPD_MOSI, PIN_EPD_CS)`; ESP32's `SPI.begin` accepts `-1` for an unused MISO. (`PIN_EPD_MISO` is declared `uint8_t`; `-1` becomes `255`, which the ESP32 core also treats as "no pin." If your toolchain warns, change the type in `config.h`/`config.cpp` to `int8_t` for that one, or use a genuinely free GPIO.)
- **Do not leave `PIN_BME_PWR = 4`.** `main.cpp` drives `PIN_BME_PWR` HIGH→read→LOW *before* the display init; if that pin is GPIO4 it will toggle your e-paper rail mid-boot. Park BME pins on unused GPIOs (done above). Better: compile the BME out entirely (see §3).
- **GPIO4 polarity is the #1 hardware risk.** `initDisplay()` does `digitalWrite(PIN_EPD_PWR, HIGH)` to enable and `powerOffDisplay()` does `LOW` to disable — i.e. the firmware assumes **active-HIGH** enable. An AO3401 is a **P-channel** MOSFET; a textbook P-FET high-side load switch conducts when its gate is pulled **LOW**. If your board wires GPIO4 straight to the AO3401 gate with no inverting transistor, the logic is **inverted** and driving it HIGH will leave the panel **unpowered** → `display.init()` hangs waiting on BUSY. Verify on the bench (measure the panel VCC while toggling GPIO4). If inverted, flip both writes in `renderer.cpp` (§7) or, for bring-up, jumper the rail permanently on and treat GPIO4 gating as a later power phase. **Flagged as a risky claim.**

WiFi / location / cadence in the same file:

```cpp
const char *WIFI_SSID     = "YOUR_SSID";       // hardcoded — no captive portal upstream (see §9)
const char *WIFI_PASSWORD = "YOUR_PASS";
...
const String LAT = "40.7128";                  // your coordinates
const String LON = "-74.0060";
const String CITY_STRING = "New York";
const char *TIMEZONE = "EST5EDT,M3.2.0,M11.1.0";  // POSIX TZ from nayarsystems/posix_tz_db zones.csv
const int SLEEP_DURATION = 30;                 // minutes between wakes (range 2–1440); 15–30 is the sweet spot
```

---

## 3. `platformio/include/config.h` — panel, driver, HTTP mode, units, locale, sensor

All of these are `#define` toggles. Uncomment exactly one per group (the file has `#error` validation guards that enforce this).

### 3a. Panel (mono 7.5" 800×480) — already the default, confirm it
```c
#define DISP_BW_V2          // 7.5" v2, 800x480, B/W  <-- keep this
// #define DISP_3C_B        // 7.5" B, 800x480, B/W/R
// #define DISP_7C_F         // 7.3" ACeP 7-color
// #define DISP_BW_V1        // 7.5" v1, 640x384
```
`DISP_BW_V2` selects the GxEPD2 mono class in `renderer.h` (see §4). This is the only WROOM-safe choice — 800×480×1bpp ≈ 48 KB.

### 3b. Driver board — switch to Waveshare
```c
// #define DRIVER_DESPI_C02   // upstream default
#define DRIVER_WAVESHARE      // <-- our board
```
This changes the `display.init()` timing in `renderer.cpp`: `DRIVER_WAVESHARE` → `display.init(115200, true, 2, false)` (reset pulse 2 ms), matching the GxEPD2 note that Waveshare "clever reset circuit" boards want a short reset. `DRIVER_DESPI_C02` uses 10 ms. (This macro governs *only* the init-pulse timing — it does **not** set pins; pins come from `config.cpp`.)

### 3c. HTTP mode — use insecure HTTPS for keyless public APIs
```c
// #define USE_HTTP
#define USE_HTTPS_NO_CERT_VERIF          // <-- recommend this
// #define USE_HTTPS_WITH_CERT_VERIF
```
Upstream default is `USE_HTTPS_WITH_CERT_VERIF`, which pins the **Sectigo** root that matches `openweathermap.org` (embedded in `cert.h`, regenerated by `cert/cert.py`). That cert will **not** match `api.open-meteo.com` or `mempool.space`, and it expires (forcing reflashes). For public read-only keyless APIs, `USE_HTTPS_NO_CERT_VERIF` (which does `client.setInsecure()` in `main.cpp`) is the pragmatic choice and matches your data-sources guidance. If you keep OWM *and* want verification, leave the default and update `cert.h` via `cert.py`.

### 3d. Units / locale (US example — set to taste)
```c
#define LOCALE en_US                     // options: de_DE en_GB en_US et_EE fi_FI fr_FR it_IT nl_BE pt_BR es_ES
#define UNITS_TEMP_FAHRENHEIT            // or UNITS_TEMP_CELSIUS / UNITS_TEMP_KELVIN
#define UNITS_SPEED_MILESPERHOUR         // or KILOMETERSPERHOUR / METERSPERSECOND / KNOTS / BEAUFORT / FEETPERSECOND
#define UNITS_PRES_INCHESOFMERCURY       // or MILLIBARS / HECTOPASCALS / PASCALS / ...
#define UNITS_DIST_MILES                 // or UNITS_DIST_KILOMETERS
```
For metric: `en_GB` + `UNITS_TEMP_CELSIUS` + `UNITS_SPEED_KILOMETERSPERHOUR` + `UNITS_PRES_MILLIBARS` + `UNITS_DIST_KILOMETERS`.

### 3e. Sensor / battery (no BME, USB power)
There is **no** compile-out for the sensor group (validation requires exactly one of `SENSOR_BME280`/`SENSOR_BME680`). Leave `#define SENSOR_BME280` — with no chip present, `bme.begin()` fails and the indoor tiles show a dash `-`; harmless. To reclaim those two widget slots, repoint `POS_INTEMP`/`POS_INHUMIDITY` to other metrics (e.g. `POS_DEWPOINT`, `POS_MOONPHASE`) in the WIDGET POSITIONS block.

Battery monitoring: this board has no charger/divider and you're on USB. Set:
```c
#define BATTERY_MONITORING 0
```
This makes `main.cpp` skip the ADC read (`batteryVoltage = UINT32_MAX`) and the low-battery deep-sleep branch — important, since `PIN_BAT_ADC = 36` reads garbage here.

---

## 4. GxEPD2 panel class — verify, usually no edit needed

The class typedef is selected automatically by `DISP_BW_V2` in `platformio/include/renderer.h` (declaration) and `platformio/src/renderer.cpp` (definition). **Verified current name (GxEPD2 1.6.8):**

`renderer.h`:
```cpp
#ifdef DISP_BW_V2
  #define DISP_WIDTH  800
  #define DISP_HEIGHT 480
  #include <GxEPD2_BW.h>
  extern GxEPD2_BW<GxEPD2_750_GDEY075T7,
                   GxEPD2_750_GDEY075T7::HEIGHT> display;
#endif
```

`renderer.cpp`:
```cpp
#ifdef DISP_BW_V2
  GxEPD2_BW<GxEPD2_750_GDEY075T7,
            GxEPD2_750_GDEY075T7::HEIGHT> display(
    GxEPD2_750_GDEY075T7(PIN_EPD_CS, PIN_EPD_DC, PIN_EPD_RST, PIN_EPD_BUSY));
#endif
```

Notes:
- The class is **`GxEPD2_750_GDEY075T7`** (Good Display GDEY075T7, the current 7.5" 800×480 mono), **not** the older `GxEPD2_750_T7` (GDEW075T7) that some docs/wikis cite. Both headers exist in GxEPD2 1.6.8 (`gdey/GxEPD2_750_GDEY075T7.h` and `epd/GxEPD2_750_T7.h`), and they're compatible controllers, but leave the upstream choice of `GDEY075T7` unless you have the older GDEW075T7 panel and see artifacts — then switch both lines to `GxEPD2_750_T7`.
- `GxEPD2_750_GDEY075T7::HEIGHT` as the second template arg = **full-height buffer** (~48 KB for 800×480 1bpp). On the WROOM-32E without PSRAM this is tight-but-fits after WiFi/TLS. If you hit allocation failures (heap fragmentation with TLS), reduce to paged strips, e.g. `GxEPD2_750_GDEY075T7::HEIGHT / 2`; GxEPD2 then runs the `firstPage()/nextPage()` loop (already how `main.cpp` renders) over more, smaller pages. **Flagged: the full-buffer-fits-with-TLS margin is the thing most likely to bite; keep `/2` in your back pocket.**
- The constructor arg order is fixed: `(CS, DC, RST, BUSY)` — these resolve to your `PIN_EPD_*` from `config.cpp`, so **no pin edits here**.

The actual SPI-bus remap is in `renderer.cpp::initDisplay()` and needs **no change** — it already reads your `config.cpp` pins:
```cpp
SPI.end();
SPI.begin(PIN_EPD_SCK, PIN_EPD_MISO, PIN_EPD_MOSI, PIN_EPD_CS);
```

---

## 5. Weather provider — the real work if you want Open-Meteo (Path B)

There is no toggle. To go keyless Open-Meteo you replace the OWM fetch+parse layer. Scope:

1. **New fetch function** in `src/client_utils.cpp` (+ decl in `include/client_utils.h`), e.g. `int getOpenMeteo(WiFiClientSecure &client, ...)`. Model it on `getOWMonecall()`: it already does the right memory-safe pattern — `http.begin(client, host, 443, uri)`, `http.GET()`, then `deserialize…(http.getStream(), r)` streaming straight off the socket, `client.stop()`, `http.end()`, 3-retry loop.
   - Endpoint: `https://api.open-meteo.com/v1/forecast?latitude=<LAT>&longitude=<LON>&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=<TZ>&forecast_days=8`.
   - Set `http.useHTTP10(true)` before `GET()` so ArduinoJson can stream (Open-Meteo otherwise chunk-encodes), and apply a `DeserializationOption::Filter` to skip the big hourly arrays you don't render — this is what keeps you inside the WROOM heap.
2. **New response structs + parser.** `include/api_response.h` structs are OWM-shaped (`owm_current_t`, `owm_hourly_t`, `owm_daily_t`, arrays indexed like `owm_onecall.daily[0]`). Open-Meteo returns **parallel arrays** (`hourly.time[]`, `hourly.temperature_2m[]`), not arrays-of-objects — so you either write an adapter that fills the existing `owm_*_t` structs (least churn; `renderer.cpp` keeps working unchanged) or add new structs and rewrite the `draw*` calls. **Adapter into the existing structs is the far smaller diff.**
3. **Weather codes differ.** OWM uses its own condition ids; Open-Meteo uses **WMO weather codes**. The icon-selection logic in `display_utils.cpp` maps OWM ids → icons; you must add a WMO→icon map.
4. **Drop the air-pollution call** (`getOWMairpollution` / `deserializeAirQuality`) or replace it with Open-Meteo's separate Air-Quality API (`https://air-quality-api.open-meteo.com/v1/air-quality`). Remove the second fetch + its error screen in `main.cpp` (lines ~276–289) if you skip AQI.
5. **Config vars.** Replace the `OWM_*` externs (`config.h` lines ~338–340) and definitions (`config.cpp` ~59–77) with an Open-Meteo host/endpoint; keep `LAT`/`LON`/`TIMEZONE`.

**Prior-art template:** the fork `neuhausf/esp32-weather-epd` (description: "Utilizes the MeteoSwiss or OpenWeatherMap API") shows how someone factored a second, keyless provider into this exact codebase. It's MeteoSwiss, not Open-Meteo, but the *structure* of the change (provider fetch fn + parser + config) is the pattern to copy. **Flagged: I did not read neuhausf's diff line-by-line; verify it still compiles against `platform 6.13.0` / GxEPD2 1.6.8 before leaning on it.**

If you'd rather ship fast: **Path A (keep OWM)** needs only a One Call 3.0 key in `config.cpp` (`OWM_APIKEY`) and the §1–§4/§6–§8 edits — zero C++ work.

---

## 6. Where the power-management + deep-sleep loop lives (for later phases to hook)

There is **no `loop()`** — the whole program is `setup()` in `platformio/src/main.cpp`, ending in deep sleep. The wake→sleep cycle:

```
setup():                                        # main.cpp
  Serial.begin → disableBuiltinLED()
  prefs.begin(NVS_NAMESPACE)                     # NVS = "weather_epd"
  [if BATTERY_MONITORING] readBatteryVoltage() + low-batt deep-sleep branch  (skipped when 0)
  startWiFi(wifiRSSI)                            # client_utils.cpp  <-- WiFiManager hook (§9)
  configTzTime(TIMEZONE, NTP_SERVER_1, _2) + waitForSNTPSync()   # NTP each wake
  getOWMonecall(client, owm_onecall)             # client_utils.cpp  <-- your fetch layer (§5)
  getOWMairpollution(...)                        #   ""
  killWiFi()
  [BME read block]                               # main.cpp ~293–338 (harmless no-op w/o sensor)
  initDisplay()                                  # renderer.cpp: PWR HIGH, display.init(), SPI remap
  do { drawCurrentConditions(); drawOutlookGraph(); drawForecast();
       drawLocationDate(); drawStatusBar(); } while (display.nextPage());   # paged full refresh
  powerOffDisplay()                              # renderer.cpp: display.hibernate() + PWR LOW
  beginDeepSleep(startTime, &timeInfo)           # main.cpp
```

Key functions and files for hooking:
- **`beginDeepSleep()`** — `main.cpp` (~line 56). Computes sleep aligned to `SLEEP_DURATION` with `BED_TIME`/`WAKE_TIME` quiet hours, then `esp_sleep_enable_timer_wakeup()` + `esp_deep_sleep_start()`. This is where you'd add a **content-hash-in-RTC** skip-redraw optimization or an ext0 KEY-button (GPIO12) wake source.
- **`initDisplay()` / `powerOffDisplay()`** — `renderer.cpp` (~223 / ~254). `powerOffDisplay()` already does `display.hibernate()` **and** `digitalWrite(PIN_EPD_PWR, LOW)` — i.e. the GPIO4 rail-gating hook is **already wired** to `PIN_EPD_PWR`; you only need to confirm polarity (§2).
- **`disableBuiltinLED()`** — called first in `setup()`; note this kills the *ESP32 dev-LED*, not the Waveshare board's always-on power LED (~700 µA, hardware-only fix per your power notes).
- Cadence knobs are all in `config.cpp`: `SLEEP_DURATION`, `BED_TIME`, `WAKE_TIME`.

---

## 7. GPIO4 rail-gate polarity — the one-line fix if inverted

If bench testing shows the panel stays unpowered with `PIN_EPD_PWR=4` driven HIGH, swap the two writes in `renderer.cpp` (P-FET active-LOW enable):

```cpp
// initDisplay():   digitalWrite(PIN_EPD_PWR, HIGH);  ->  LOW
// powerOffDisplay(): digitalWrite(PIN_EPD_PWR, LOW); ->  HIGH
```
Leave them as-is (HIGH=on) if the panel powers correctly. This is the single most likely bring-up snag on this board.

---

## 8. WiFi captive portal (WiFiManager) — NOT in upstream

Your architecture calls for a WiFiManager captive portal, but **upstream hardcodes** `WIFI_SSID`/`WIFI_PASSWORD` in `config.cpp` and has no WiFiManager dependency. For v1 bring-up, hardcode creds. To add the portal later:
- Add `tzapu/WiFiManager` (or `esp32-wifi-manager`) to `lib_deps` in `platformio.ini`.
- Hook it inside **`startWiFi()` in `client_utils.cpp`** (replace `WiFi.begin(WIFI_SSID, WIFI_PASSWORD)` with a `wm.autoConnect()` fallback), and persist creds in the existing NVS namespace (`prefs`, `"weather_epd"`) rather than `config.cpp`.
- Watch RAM: WiFiManager's AP + web server on top of GxEPD2's ~48 KB buffer + TLS is tight on WROOM. Only start the portal on connect-failure, and tear it down before rendering.

---

## 9. Documented driver-board / HAT wiring caveats (from the live README)

- **"The DESPI-C02 is the only officially supported driver board."** `config.h` comments call Waveshare rev 2.2/2.3 support **deprecated**; rev 2.2 is out of production; **rev 2.3 users report low-contrast issues.** You're on the all-in-one *ESP32 driver board*, not a passive HAT, so this caveat is about adapter HATs — but expect to be off the supported path and to verify contrast yourself.
- **README wiring note:** "Waveshare now ships revision 2.3 of their e-paper HAT... Rev 2.3 has an additional `PWR` pin (not depicted in the wiring diagrams); connect this pin to 3.3V." (Passive HAT only.)
- **Physical switches:** "The DESPI-C02 adapter has one physical switch that MUST be set correctly"; "The Waveshare E-Paper Driver HAT has two physical switches that MUST be set correctly for the display to work." If your panel is dead-blank, check the FPC-adapter switch position before debugging firmware.
- **Download mode:** README documents `Wrong boot mode detected (0x13)` → tie GPIO0→GND and power-cycle. Matches your board's GPIO0→GND-during-reset requirement.
- **3.3 V logic only**; a 7.5" panel wants a solid supply, not a weak pin-sourced rail — relevant given GPIO4 gates the rail through a MOSFET.

---

## 10. Minimal edit checklist (Path A / keep OWM, fastest to a lit screen)

1. `platformio.ini`: add `[env:waveshare_esp32_driver]` (board `esp32dev`, `upload_speed 115200`, ports) + set `default_envs`. (§1)
2. `src/config.cpp`: replace PINS block with our GPIO map; `PIN_EPD_PWR=4`; keep BME pins off GPIO4; set WiFi creds, LAT/LON, TIMEZONE, `SLEEP_DURATION`. (§2)
3. `include/config.h`: keep `DISP_BW_V2`; `DRIVER_WAVESHARE`; `USE_HTTPS_NO_CERT_VERIF`; set units/locale; `BATTERY_MONITORING 0`. (§3)
4. `src/config.cpp`: set `OWM_APIKEY` (real One Call 3.0 key). (§5, Path A)
5. Build; if stub-checksum error on upload, flash `firmware.bin` with `esptool --no-stub`. (§1)
6. Bench-check GPIO4 polarity; flip §7 if the panel won't power.

Path B adds the §5 Open-Meteo fetch/parse work on top.

---
## Risky claims flagged for verification

- **Upstream lmarzen/esp32-weather-epd (branch main) is OpenWeatherMap-ONLY — there is no Open-Meteo (or any) provider-selection macro. Switching to keyless Open-Meteo requires writing a new fetch function, a new WMO-code parser, and struct adapters — it is not a config toggle.**
  - risk: The task premise assumes an Open-Meteo option exists. Believing that would send the harness hunting for a nonexistent #define and waste a build cycle. Verified by reading config.cpp (only OWM_* vars), client_utils.cpp (only getOWMonecall/getOWMairpollution hardcoded to api.openweathermap.org), main.cpp, and a repo-wide 'meteo' code search that returns only wind-icon/locale files.
- **The GxEPD2 mono 7.5in 800x480 panel class selected by DISP_BW_V2 is GxEPD2_750_GDEY075T7 (GDEY075T7), instantiated as GxEPD2_BW<GxEPD2_750_GDEY075T7, GxEPD2_750_GDEY075T7::HEIGHT> display(GxEPD2_750_GDEY075T7(PIN_EPD_CS,PIN_EPD_DC,PIN_EPD_RST,PIN_EPD_BUSY)) — NOT the older GxEPD2_750_T7 that some docs cite.**
  - risk: Wrong class name = compile error or a driver mismatch that produces a garbled/damaged image on a live panel. If the physical panel is an older GDEW075T7, the code must instead use GxEPD2_750_T7. Constructor arg order (CS,DC,RST,BUSY) also matters.
- **GPIO4 on this board gates the e-paper 3.3V rail via an AO3401 P-channel MOSFET; the firmware assumes ACTIVE-HIGH enable (initDisplay drives PIN_EPD_PWR HIGH). A bare P-FET high-side switch conducts on a LOW gate, so the polarity may be INVERTED and driving GPIO4 HIGH could leave the panel unpowered, hanging display.init() on BUSY.**
  - risk: If polarity is wrong the panel never powers and bring-up appears as a dead board / init hang — easily misdiagnosed as bad wiring or a dead panel. Must be measured on the bench; if inverted, both digitalWrite(PIN_EPD_PWR, ...) calls in renderer.cpp must be flipped. I could not confirm the gate-drive circuit from the schematic this session.
- **PlatformIO flashing must account for the confirmed stub-checksum failure: use conservative upload_speed=115200, and if that still fails, build with PlatformIO then flash firmware.bin manually with esptool --no-stub at offsets 0x1000/0x8000/0xe000/0x10000.**
  - risk: PlatformIO runs esptool WITH the stub by default and does not cleanly pass --no-stub, so a naive 'pio run -t upload' can hard-fail with the exact checksum error the board is known to throw. The manual offsets are the arduino-esp32 4MB defaults and should be cross-checked against PlatformIO's own upload log before use.
- **board=esp32dev with board_build.partitions=huge_app.csv is the correct WROOM-32E env, and the full-height GxEPD2 buffer (~48KB for 800x480x1bpp) fits alongside WiFi+TLS on the no-PSRAM WROOM — but with little margin; drop to HEIGHT/2 paged strips if heap allocation fails.**
  - risk: If the full framebuffer plus TLS handshake buffers exhausts heap, the device boots, connects, then crashes/reboots at render — an intermittent failure that looks like a networking bug. huge_app.csv (no OTA) is required because the firmware+assets are large; a wrong partition table causes upload-size overflow.
