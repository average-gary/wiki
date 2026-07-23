# 800x480 Mono Combined Layout: Bitcoin-Emphasis Region Map, Fonts, Icons, Paged Draw

## 800x480 Combined Screen: Bitcoin-Dominant Layout Spec

Target: Waveshare e-Paper ESP32 Driver Board (ESP32-D0WD-V3 / WROOM-32E die, 4 MB flash, **no PSRAM**) driving a **mono 7.5" 800x480** panel via GxEPD2, forked from `lmarzen/esp32-weather-epd`. Landscape, `display.setRotation(0)`, origin top-left `(0,0)`, x -> right (0..799), y -> down (0..479). Full-refresh-per-wake only; **no partial-update sub-regions**.

Everything below is grounded in the wiki playbook and verified against live upstream (repo files, GxEPD2 headers) and live API responses this session — see "Risky claims" for the items most worth an independent check.

---

### 1. Region map (ASCII wireframe, pixel coordinates)

Vertical budget: Bitcoin **62.5%** (y 0..299), weather 33% (y 306..457), footer 4.5% (y 458..479). Bitcoin is unambiguously the largest region.

```
(0,0)                                                                      (799,0)
+============================================================================+
|  [BTC LOGO 96x96]   BTC / USD                    BLOCK HEIGHT              | y 0
|  x24 y20..116       $65,407                       958,913                  |
|                     ^price 48pt bold, baseline y104    ^18pt bold, right   |
|                     as of 14:32 UTC   (9pt, y132)                          | y~140
|                                                                            |
|  MEMPOOL FEES (sat/vB)   (11pt, baseline y176, x24)                        | y 150
|  +------------------+   +------------------+   +------------------+        | y 186
|  |    Fastest       |   |     30 min       |   |     1 hour       |        |
|  |       4          |   |        3         |   |        1         |        | <-tiles
|  |     sat/vB       |   |     sat/vB       |   |     sat/vB       |        |
|  +------------------+   +------------------+   +------------------+        | y 292
|  center x=150            center x=400           center x=650               |
+============================================================================+ y 300 (HLine)
|  [WX ICON 64x64]  82{deg}   |  Mon      Tue      Wed                       | y 306
|  x24 y320..384    Clear sky |  [48x48]  [48x48]  [48x48]  (icons y340..388)|
|                   Hum 31%   |  84/60    84/68    87/72   (hi/lo 11pt y410) |
|  temp 24pt bold, baseline y360   day labels 11pt baseline y330             |
|                             |  col centers x=450, x=590, x=730             |
+----------------------------------------------------------------------------+ y 458 (HLine)
|  Updated 14:32  |  tip 958,913  |  RSSI -62 dBm  |  btc+wx dashboard        | y 474 (9pt)
+============================================================================+ (799,479)
```

Divider rules: `display.drawFastHLine(0, 300, 800, GxEPD_BLACK);` and `display.drawFastHLine(0, 458, 800, GxEPD_BLACK);`. Optional light vertical separator between current-weather and forecast at `display.drawFastVLine(360, 306, 152, GxEPD_BLACK);`. Fee-tile boxes: `display.drawRect(x, 186, 232, 106, GxEPD_BLACK)` at x = 24, 284, 544.

**Do not hardcode text widths.** Every value (price, block height, temps, fees) is variable-width. Follow upstream's pattern: measure with `display.getTextBounds(str, 0, 0, &x1, &y1, &w, &h)` then compute x for left/right/center alignment. The baseline-y values above are fixed anchors; horizontal placement is computed at runtime.

---

### 2. Fonts and sizes per element

Use **Adafruit GFX `...pt8b` fonts** (this is what upstream uses; U8g2 is an alternative discussed below). The repo aliases sizes behind `FONT_*pt8b` macros that point at a chosen family — recommend **FreeSans / FreeSansBold** for a clean glanceable dashboard. The upstream asset pack ships each family at 4–26 pt plus a digits-only `..._48pt8b_temperature.h` subset (`platformio/lib/esp32-weather-epd-assets/fonts/`).

| Element | Text example | Font | pt size | Notes |
|---|---|---|---|---|
| BTC price (hero) | `$65,407` | FreeSansBold | **32 pt** (bold) | Do NOT use the shipped `48pt8b_temperature` subset here — it only contains digits/`-`/degree, no `$` or `,`. Either generate a full FreeSansBold 48pt with the repo's `fonts/fontconvert`, or use the shipped **26 pt** and it still dominates. 32 pt is the sweet spot. |
| "BTC / USD" label | `BTC / USD` | FreeSans | 12 pt | above price, baseline y40 |
| Price timestamp | `as of 14:32 UTC` | FreeSans | 9 pt | baseline y132 |
| Block height value | `958,913` | FreeSansBold | 18 pt | right-aligned to x=776, baseline y48 |
| "BLOCK HEIGHT" label | `BLOCK HEIGHT` | FreeSans | 9 pt | right-aligned, baseline y24 |
| Fees section label | `MEMPOOL FEES (sat/vB)` | FreeSans | 11 pt | baseline y176 |
| Fee tier name | `Fastest` / `30 min` / `1 hour` | FreeSans | 11 pt | tile top, baseline y206 |
| Fee value (sat/vB) | `4` | FreeSansBold | **24 pt** | tile center, baseline y262 |
| Fee unit | `sat/vB` | FreeSans | 9 pt | tile bottom, baseline y286 |
| Current temp | `82` + degree ring | FreeSansBold | 24 pt | baseline y360 |
| Current condition text | `Clear sky` | FreeSans | 12 pt | baseline y386 |
| Humidity | `Hum 31%` | FreeSans | 9 pt | baseline y408 |
| Forecast day label | `Mon` | FreeSans | 11 pt | baseline y330 |
| Forecast hi/lo | `84/60` | FreeSans | 11 pt | baseline y410 |
| Footer status | `Updated 14:32 | ...` | FreeSans | 9 pt | baseline y474 |

**Degree symbol — ASCII-safe handling.** Do not emit a non-ASCII `°` byte. Two safe options: (a) draw a small ring with `display.drawCircle(x, y, 2, GxEPD_BLACK)` just after the temperature digits (compute x from `getTextBounds`), or (b) use the shipped `FreeSans_..._48pt8b_temperature.h` subset for weather temps, which bakes the degree glyph at a known code point. Option (a) is the most robust and keeps the whole text pipeline ASCII-only, matching the wiki's "ASCII-only on-device fonts" gotcha.

**Alternative — U8g2_for_Adafruit_GFX.** If you would rather not pre-generate large GFX fonts, add `U8g2_for_Adafruit_GFX` and use e.g. `u8g2Fonts.setFont(u8g2_font_logisoso42_tn)` (42px digit font) for the hero price. It draws onto the same GxEPD2 paged buffer. Trade-off: a second font engine in flash and you must call `u8g2Fonts.setForegroundColor(GxEPD_BLACK)`. GFX-only is simpler and is the upstream default; pick one, not both.

---

### 3. Static assets to bake as 1-bit arrays

**Reuse, do not re-bake, the weather glyphs.** The upstream repo already ships the full Erik Flowers "Weather Icons" set as 1-bit GFX headers at 32/48/64/128/196 px (`platformio/lib/esp32-weather-epd-assets/icons/`, included via `renderer.cpp`'s `#include "icons/icons_64x64.h"` etc.). Use those directly. Upstream draws them with `display.drawInvertedBitmap(x, y, wi_day_sunny_64x64, 64, 64, GxEPD_BLACK)` — its source PNGs are white-on-black, hence *inverted* draw. Each icon is stored in PROGMEM/flash (64x64 = 512 B, 48x48 = 288 B), negligible RAM.

WMO `weather_code` -> icon (from Open-Meteo `current.weather_code` / `daily.weather_code[]`):

| WMO code | Condition text | Icon symbol (upstream) | Current size | Forecast size |
|---|---|---|---|---|
| 0 | Clear sky | `wi_day_sunny` | 64x64 | 48x48 |
| 1,2 | Partly cloudy | `wi_day_cloudy` | 64x64 | 48x48 |
| 3 | Overcast | `wi_cloudy` | 64x64 | 48x48 |
| 45,48 | Fog | `wi_fog` | 64x64 | 48x48 |
| 51,53,55,56,57 | Drizzle | `wi_sprinkle` | 64x64 | 48x48 |
| 61,63,65,66,67 | Rain | `wi_rain` | 64x64 | 48x48 |
| 71,73,75,77 | Snow | `wi_snow` | 64x64 | 48x48 |
| 80,81,82 | Rain showers | `wi_showers` | 64x64 | 48x48 |
| 85,86 | Snow showers | `wi_snow` | 64x64 | 48x48 |
| 95 | Thunderstorm | `wi_thunderstorm` | 64x64 | 48x48 |
| 96,99 | Thunderstorm + hail | `wi_thunderstorm` | 64x64 | 48x48 |

**Must bake fresh: the Bitcoin logo** (not in the repo). Bake **one 96x96** 1-bit array via [image2cpp](https://javl.github.io/image2cpp/). Exact settings:

- Canvas size: **96 x 96** (scale: "scale to fit, keeping proportions").
- **Invert image colors: OFF.** Background color: **white**.
- Brightness/alpha threshold: **~128, dithering OFF** (a logo is line-art, not a photo — dithering muddies it; Floyd-Steinberg is only for photos).
- Code output format: "Arduino code, single bitmap".
- **Draw mode: "Horizontal - 1 bit per pixel".** This byte order is what Adafruit GFX `drawBitmap`/`drawInvertedBitmap` expect.
- Pair with **`display.drawBitmap(24, 20, epd_bitmap_btc_logo, 96, 96, GxEPD_BLACK);`** — with `invert=OFF`, bits set to 1 (the dark source pixels) render as black, giving a black logo on white. Store the array `const unsigned char ... PROGMEM` (96x96 = **1152 B** flash).

> Invert mismatch is the classic footgun: if you keep image2cpp `invert=ON` you must switch to `drawInvertedBitmap`, and vice-versa, or you get a negative image. Bake the BTC logo with invert OFF + `drawBitmap`; leave the upstream weather icons as invert-baked + `drawInvertedBitmap`. See risky claim #4.

If you insist on baking your own weather glyphs instead of reusing upstream's, use the same image2cpp settings but at 64x64 (current) and 48x48 (forecast), source = black-glyph-on-white PNG, invert OFF, and draw with `drawBitmap`. Curated minimum set of 7: sunny, partly-cloudy, cloudy, fog, rain, snow, thunderstorm.

---

### 4. GxEPD2 display object + pin remap (this board)

```cpp
#include <GxEPD2_BW.h>
#include <SPI.h>

// This board's non-default VSPI pins (ground truth this session):
#define PIN_EPD_BUSY 25
#define PIN_EPD_RST  26
#define PIN_EPD_DC   27
#define PIN_EPD_CS   15   // strapping pin
#define PIN_EPD_SCK  13
#define PIN_EPD_MOSI 14
#define PIN_EPD_MISO -1   // e-paper is write-only; MISO unused
#define PIN_EPD_PWR   4   // AO3401 P-MOSFET gates the 3.3V e-paper rail (verify polarity!)

// Mono 7.5" 800x480 V2 panel. Constructor arg order is (CS, DC, RST, BUSY).
// page_height = full HEIGHT (480) -> single 48 KB buffer, single page pass.
GxEPD2_BW<GxEPD2_750_GDEY075T7, GxEPD2_750_GDEY075T7::HEIGHT> display(
    GxEPD2_750_GDEY075T7(PIN_EPD_CS, PIN_EPD_DC, PIN_EPD_RST, PIN_EPD_BUSY));

void initDisplay() {
  pinMode(PIN_EPD_PWR, OUTPUT);
  digitalWrite(PIN_EPD_PWR, LOW);   // enable rail; P-MOSFET high-side switch is active-LOW (VERIFY)
  // Waveshare "clever reset circuit" branch: reset_duration = 2 ms (upstream value)
  display.init(115200, true, 2, false);
  // remap SPI to this board's pins AFTER init (init begins default SPI first)
  SPI.end();
  SPI.begin(PIN_EPD_SCK, PIN_EPD_MISO, PIN_EPD_MOSI, PIN_EPD_CS);
  display.setRotation(0);           // 800 wide x 480 tall
  display.setTextWrap(false);
  display.setTextColor(GxEPD_BLACK);
}

void powerOffDisplay() {
  display.hibernate();              // powerOff + controller deep sleep (protects panel)
  digitalWrite(PIN_EPD_PWR, HIGH);  // cut e-paper rail (P-MOSFET off); inverse of enable above
}
```

- `GxEPD2_BW` = mono base template; `GxEPD2_750_GDEY075T7` = the 7.5" 800x480 mono V2 class (verified in GxEPD2 `src/gdey/`, `WIDTH=800 HEIGHT=480`). **If your physical panel is the older GDEW075T7 rev**, swap to `GxEPD2_750_T7` (also 800x480) — same layout, different LUTs. See risky claim #1.
- `display.init(115200, true, 2, false)` mirrors upstream's `#ifdef DRIVER_WAVESHARE` branch (reset pulse 2 ms for the board's reset circuit). The DESPI-C02 branch uses `10`. See risky claim #2.
- CS=GPIO15 is a strapping pin — fine here (Arduino/GxEPD2 has no strapping-warning abort; that warning is an ESPHome-only concern).
- GPIO4 rail gate polarity is the one hardware detail I cannot confirm from the schematic this session — treat the `LOW=on / HIGH=off` above as a hypothesis to verify on the bench (risky claim #3).

---

### 5. Paged-draw structure (fits the RAM ceiling)

**RAM math.** 1 bpp full frame = 800 x 480 / 8 = **48,000 B (~48 KB)**. With `page_height == HEIGHT` the GxEPD2 object holds one 48 KB buffer; on the ~200–320 KB of heap free after WiFi/BT that leaves ample room. This is the upstream configuration for the mono panel and is the recommended default here.

**The picture loop.** All drawing goes inside a single `firstPage()/nextPage()` loop. Every draw function is called **once per page** and must be idempotent and use absolute coordinates — GxEPD2 clips to the current page window automatically, so off-page draws are simply skipped.

```cpp
void renderDashboard(const BtcData& btc, const WxData& wx, const char* updatedStr, int rssi) {
  initDisplay();
  display.setFullWindow();          // full refresh only; NEVER setPartialWindow on a sleep-per-wake dashboard
  display.firstPage();
  do {
    // fillScreen(WHITE) is implicit on firstPage()
    drawBitcoinRegion(btc);         // logo, price, block height, 3 fee tiles  (y 0..299)
    display.drawFastHLine(0, 300, 800, GxEPD_BLACK);
    drawWeatherRegion(wx);          // current + 3-day forecast               (y 306..457)
    display.drawFastHLine(0, 458, 800, GxEPD_BLACK);
    drawFooter(updatedStr, btc.tipHeight, rssi);                            // (y 458..479)
  } while (display.nextPage());
  powerOffDisplay();
}
```

**If the TLS handshake OOMs** (WiFiClientSecure buffers are the real memory tax, not JSON), drop `page_height` to `HEIGHT/2` (240 -> 24 KB buffer) or `HEIGHT/4` (120 -> 12 KB) in the template:

```cpp
GxEPD2_BW<GxEPD2_750_GDEY075T7, GxEPD2_750_GDEY075T7::HEIGHT / 2> display(/* ... */);
```

The layout coordinates are unchanged; GxEPD2 just runs the `do{...}while` body 2 (or 4) times, each pass rendering one horizontal strip. Cost is redraw time (more SPI traffic), not visual change. Fetch and free all network buffers **before** entering the picture loop so peak heap (TLS buffers) and peak framebuffer never coincide — and remember to `delete` the `WiFiClientSecure` (not just `stop()`) to avoid the repeated-connect heap leak.

---

### 6. Refresh-model constraints as they shape the layout

- **>=180 s refresh floor + full-refresh-per-wake** (manufacturer rule; the controller's previous-image RAM is lost across deep sleep, so partial updates corrupt). Consequence for layout: **there are no independently-updating regions.** The entire 800x480 frame is redrawn and flashes (~1.2 s controller full-refresh time per the panel header `full_refresh_time`, ~2–5 s wall-clock incl. paging) on every wake. Design for a single coherent snapshot, not live tickers.
- Because everything redraws anyway, there is **zero benefit to reserving "static" vs "dynamic" zones** — lay out purely for glanceability with Bitcoin dominant.
- **Skip needless redraws:** hash the rendered content (price bucket + tip height + fee tiers + condition + hi/lo) into an `RTC_DATA_ATTR` variable; if unchanged since last wake, skip the whole picture loop and the refresh flash, and go straight back to deep sleep. Bitcoin price changes most often, so quantize it (e.g., round to nearest $50) before hashing or you will refresh every wake.
- **Poll cadence:** align the wake interval to the 180 s floor and mempool's "minutes not seconds" rate limit — a 5-min wake for a USB-powered desk unit is comfortable; the layout does not change with cadence.
- `display.hibernate()` after every refresh (in `powerOffDisplay()`) — leaving the panel energized risks permanent damage.

---

### 7. Data -> field mapping (endpoints verified live this session)

- **Fees** `GET https://mempool.space/api/v1/fees/recommended` -> `{"fastestFee":4,"halfHourFee":3,"hourFee":1,"economyFee":1,"minimumFee":1}`. Tiles map: Fastest=`fastestFee`, 30 min=`halfHourFee`, 1 hour=`hourFee`.
- **Block height** `GET https://mempool.space/api/blocks/tip/height` -> **bare integer text** `958913` (no JSON) -> `atoi()` / `.toInt()`. Format with grouping for display.
- **Price** `GET https://mempool.space/api/v1/prices` -> `{"time":1784567712,"USD":65407,"EUR":57328,"GBP":48785,...}`. Use `doc["USD"]`; `time` is the price epoch for the "as of" line.
- **Weather** `GET https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current=temperature_2m,weather_code,relative_humidity_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&timezone=auto&forecast_days=3`. Current temp = `current.temperature_2m`; humidity = `current.relative_humidity_2m`; condition icon from `current.weather_code`; forecast columns from `daily.temperature_2m_max[i]`/`min[i]` and `daily.weather_code[i]` for i=0..2. Apply an ArduinoJson `Filter` to drop `*_units` and any hourly block; stream with `deserializeJson(doc, http.getStream())` + `http.useHTTP10(true)`.

mempool.space is HTTPS; use `WiFiClientSecure` with `setInsecure()` for these public read-only endpoints (per the wiki HTTPS note) or maintain a CA cert.

---

### 8. Files to touch in the fork (orientation)

- `platformio/src/renderer.cpp` — swap the `#ifdef DISP_BW_V2` display template if needed, replace `drawCurrentConditions/drawForecast/...` calls with `drawBitcoinRegion/drawWeatherRegion/drawFooter`.
- `platformio/src/config.cpp` — set `PIN_EPD_BUSY=25, CS=13->15, RST=21->26, DC=22->27, SCK=18->13, MOSI=23->14, MISO=-1, PWR=4`. (Upstream ships FireBeetle defaults 14/13/21/22/18/19/23/26 — all must change for this board.)
- `platformio/include/config.h` — `#define DRIVER_WAVESHARE` (not `DRIVER_DESPI_C02`), keep `#define DISP_BW_V2`.
- New: `include/icons/btc_logo_96x96.h` (your baked array). Reuse existing `icons/icons_48x48.h` / `icons_64x64.h` for weather.
- Flashing note (this board's stub-flasher quirk): flash with `--no-stub` or a conservative `115200` baud; hold GPIO0->GND during EN/reset if it won't sync.


---
## Risky claims flagged for verification

- **The correct GxEPD2 panel class for the mono 7.5in 800x480 V2 panel is GxEPD2_750_GDEY075T7 (used in a GxEPD2_BW<...> template with page_height = HEIGHT). The wiki cited the older name GxEPD2_750_T7.**
  - risk: Both names exist in GxEPD2 and are both 800x480, but they load different waveform LUTs for physically different panel revisions (GDEY075T7 vs GDEW075T7). Picking the class that does not match the actual glass produces ghosting, garbled output, or a blank screen and wastes flash cycles. Verified GxEPD2_750_GDEY075T7 exists in upstream src/gdey/ and is what current esp32-weather-epd uses for DISP_BW_V2, but the operator must confirm which rev their panel actually is.
- **display.init(115200, true, 2, false) is the right init call for this board — reset_duration=2 ms, matching esp32-weather-epd's DRIVER_WAVESHARE branch (the DESPI-C02 branch uses 10).**
  - risk: The reset-pulse duration parameter is a workaround for the board's reset circuit. Wrong value can leave the controller un-reset so BUSY never deasserts and init hangs or the panel never updates. Verified against upstream renderer.cpp initDisplay(), but not bench-tested on this exact unit.
- **GPIO4 gates the e-paper 3.3V rail via an AO3401 P-MOSFET high-side switch and is active-LOW (drive LOW to power the panel, HIGH to cut it before deep sleep).**
  - risk: Polarity is inferred from AO3401 being a P-channel high-side switch, not confirmed from the schematic this session. If inverted, the panel is never powered (nothing draws) or the rail is never gated off (wastes the intended low-power hook). Must be verified on the board before relying on it.
- **Bake the BTC logo in image2cpp with invert=OFF, white background, dithering OFF, 'Horizontal - 1 bit per pixel', and draw it with display.drawBitmap(...,GxEPD_BLACK); upstream weather icons instead use drawInvertedBitmap because their source PNGs are inverted.**
  - risk: drawBitmap and drawInvertedBitmap interpret the 1-bits oppositely. If the image2cpp invert setting does not match the chosen draw call, the logo renders as a negative (black box with white glyph), forcing a re-bake and re-flash.
- **Live endpoint shapes: /api/v1/fees/recommended returns {fastestFee,halfHourFee,hourFee,economyFee,minimumFee}; /api/blocks/tip/height returns a BARE INTEGER (not JSON); /api/v1/prices returns {time,USD,EUR,GBP,...}.**
  - risk: Parsing code depends on these exactly — feeding the bare-integer height response to a JSON deserializer, or reading a wrong price key, yields blank or garbage fields. Verified by hitting all three live this session, but mempool.space could change response shape.
- **A single full 48 KB (800x480/8) page buffer with page_height=HEIGHT fits alongside WiFi+TLS on this PSRAM-less WROOM; if the TLS handshake OOMs, reduce page_height to HEIGHT/2 or /4 with no layout change.**
  - risk: Free heap after WiFi/BT/TLS is only ~200-320 KB and TLS handshake buffers are the largest transient consumer. If fetch buffers and the 48 KB framebuffer coincide, the device can crash mid-render; the mitigation (smaller page_height, free network buffers before drawing) must actually be applied.
