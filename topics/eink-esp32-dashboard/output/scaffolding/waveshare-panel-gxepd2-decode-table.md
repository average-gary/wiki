# Waveshare/GoodDisplay Part-Number to GxEPD2 Class + BUSY Polarity Decode Table


# Panel decode table: part number to GxEPD2 class + BUSY polarity (Phase 1 unblock)

## The single most important fact (read this first)

**In GxEPD2 you do NOT set BUSY polarity yourself.** There is no "invert BUSY" flag in the display
constructor. The BUSY active level is **hardcoded inside each panel driver class** as the 5th argument
to the `GxEPD2_EPD` base-class constructor (`busy_level`). Example, from GxEPD2's own source:

```cpp
// src/epd/GxEPD2_750_T7.cpp, line 17
GxEPD2_EPD(cs, dc, rst, busy, LOW, 10000000, WIDTH, HEIGHT, panel, hasColor, hasPartialUpdate, hasFastPartialUpdate)
//                            ^^^ busy_level is LOW for this panel — baked in, not user-configurable
```

The wait loop uses it like this:

```cpp
// src/GxEPD2_EPD.cpp, _waitWhileBusy()
if (digitalRead(_busy) != _busy_level) break;   // stop waiting once BUSY leaves its active level
```

**Consequence for us:** "getting BUSY polarity right" is *identical to* "selecting the exact driver class
that matches the panel's controller." Pick the right class → correct polarity, correct init sequence,
correct waveforms, all at once. This is why the ESPHome-style "invert BUSY manually or you'll damage the
panel" warning does **not** translate to a knob you flip in GxEPD2 — instead it becomes **"do not pick the
wrong driver class."** (In ESPHome's `waveshare_epaper` platform BUSY inversion *is* a manual pitfall; on
this GxEPD2 fork it is not.)

> Grounding: GxEPD2 `src/epd/*.cpp` constructors and `src/GxEPD2_EPD.cpp` (github.com/ZinggJM/GxEPD2);
> wiki `raw/repos/2026-07-20-gxepd2.md` ("BUSY pin mandatory... library handles it if BUSY wired correctly").

---

## How to determine the right class SAFELY (never by trial-and-error)

Wrong-class selection is the damage path, so decode it from **markings + datasheet**, never by "try it and
see if the screen looks right":

1. **Read the FPC ribbon marking and any silkscreen on the panel glass.** The GoodDisplay part number
   (GDExxxxxx) is the ground truth. GxEPD2's class comments list, for each class, both the GoodDisplay part
   *and* the FPC/flex-cable marking in parentheses, e.g. `GxEPD2_750_T7 // GDEW075T7 800x480, EK79655 (GD7965), (WFT0583CZ61)`.
   So a ribbon stamped **WFT0583CZ61** → `GxEPD2_750_T7`. A ribbon stamped **FPC-C001 20.08.20** →
   `GxEPD2_750_GDEY075T7`.
2. **Waveshare product name → GoodDisplay part** (Waveshare panels *are* GoodDisplay panels; GxEPD2 README:
   "SPI e-paper boards from Waveshare having the same panels"):
   - Waveshare **7.5" e-Paper V2 (800x480, B/W)** → GDEW075T7 or the newer GDEY075T7.
   - Waveshare **7.5" e-Paper V1 (640x384, B/W)** → GDEW075T8.
   - Waveshare **7.5" e-Paper (B) (800x480, B/W/R)** → GDEW075Z08 / GDEY075Z08.
   - Waveshare **7.5" HD (880x528, B/W/R)** → GDEH075Z90.
   - Waveshare **4.2" e-Paper (400x300, B/W)** → GDEW042T2 (older) / GDEY042T81 (newer SSD1683).
3. **Cross-check resolution.** If the class WIDTHxHEIGHT does not match what the panel physically is,
   you have the wrong class — stop.
4. **If genuinely unsure between two candidate mono 800x480 classes** (GDEW075T7 vs GDEY075T7), it is safe
   to *test-boot* because **both are BUSY=LOW mono panels** — a mismatch there produces bad rendering, not
   damage. It is **NOT** safe to guess across mono↔color or across a BUSY-LOW↔BUSY-HIGH boundary (see the
   880x528 tri-color row below, which is the one BUSY=HIGH exception in our candidate set).
5. **Optional pre-flight sanity check with a multimeter/logic probe** before any refresh: on a correctly
   idle panel, BUSY sits at its *inactive* level. For BUSY-LOW panels (all our mono candidates) idle BUSY
   reads HIGH; it pulses LOW during refresh. For the BUSY-HIGH tri-color 880x528, idle reads LOW and it
   pulses HIGH. If your probe disagrees with the class you chose, the class is wrong.

**Why wrong polarity/class is dangerous:** if `_busy_level` is inverted relative to the real panel, GxEPD2's
`_waitWhileBusy()` either (a) thinks the panel is *always ready* and fires the next command/frame while the
panel is still driving a high-voltage waveform, defeating the panel's flow control, or (b) blocks/times out.
Path (a), combined with wrong init/LUT/waveform for the controller, is the realistic route to stressing or
damaging the panel. The safe move is always: match the class to the part number; never hand-edit `busy_level`.

---

## Wrong-class symptom decoder (what a mistake looks like on-screen)

| Symptom | Most likely cause |
|---|---|
| **Totally blank / no change, serial shows "Busy Timeout!"** | Wrong BUSY polarity (inverted `busy_level`) OR BUSY wire not on GPIO25 — driver waits forever. |
| **Image drawn shifted, wrapped, or only top strip fills** | Wrong resolution class (e.g. 640x384 `GxEPD2_750` on an 800x480 panel, or wrong `MAX_HEIGHT`/rotation). |
| **Heavy ghosting, faint/garbled, partial bands, "snow"** | Wrong controller family/waveform (right size, wrong class — e.g. `GxEPD2_750_T7` GD7965 waveforms on a UC8179 GDEY075T7, or a color class on a mono panel). |
| **Everything inverted (black↔white)** | Usually a `drawBitmap` vs `drawInvertedBitmap` / color-arg issue, **not** a class problem — cosmetic, not dangerous. |
| **Refresh works once then never again after deep sleep** | Not a class bug: partial-refresh-after-deep-sleep corruption; use full refresh per wake (see wiki power-and-refresh). |

If you see a **Busy Timeout** in serial on first boot, **power the panel down immediately** and re-check the
class + BUSY wiring before retrying — do not loop refreshes hunting for the right setting.

---

## THE DECODE TABLE

Scope: 7.5" 800x480 (primary), 7.5" 640x384, 4.2" 400x300 (fallback), plus the color siblings. `busy_level`
column is the value verified in each class's `.cpp` (the 5th arg to `GxEPD2_EPD(...)`). "GxEPD2 wrapper" is
the template you wrap the driver class in: `GxEPD2_BW` (mono), `GxEPD2_3C` (3-color B/W/R), `GxEPD2_7C` (7-color).

| Waveshare product | GoodDisplay part / FPC mark | Res | Color | GxEPD2 driver class | Wrapper | Controller | BUSY active level (verified) | Notes |
|---|---|---|---|---|---|---|---|---|
| **7.5" V2 (classic)** | GDEW075T7 / **WFT0583CZ61** | 800×480 | Mono | **`GxEPD2_750_T7`** | `GxEPD2_BW` | EK79655 (GD7965) | **LOW** | **Most likely panel for this board.** |
| **7.5" V2 (newer GD)** | GDEY075T7 / FPC-C001 20.08.20 | 800×480 | Mono | **`GxEPD2_750_GDEY075T7`** | `GxEPD2_BW` | UC8179 (GD7965) | **LOW** | What `esp32-weather-epd`'s `DISP_BW_V2` selects. |
| **7.5" V1** | GDEW075T8 / WF0583CZ09 | **640×384** | Mono | **`GxEPD2_750`** | `GxEPD2_BW` | UC8159c (IL0371) | **LOW** | `esp32-weather-epd`'s `DISP_BW_V1`. |
| **7.5" (B) tri-color** | GDEW075Z08 / GDEY075Z08 | 800×480 | B/W/R | **`GxEPD2_750c_GDEW075Z08`** (or `GxEPD2_750c_GDEY075Z08`) | `GxEPD2_3C` | UC8179 | **LOW** | `DISP_3C_B`. ~2 bit-planes → ~2× RAM. |
| **7.5" HD (B) tri-color** | GDEH075Z90 / HINK-E075A07-A0 | **880×528** | B/W/R | **`GxEPD2_750c_Z90`** | `GxEPD2_3C` | SSD1677 | **HIGH ⚠️** | **The one polarity exception here — do NOT guess this vs a LOW panel.** |
| **7.3" ACeP (F)** | GDEY073D46 / N-FPC-001 | 800×480 | 7-color | **`GxEPD2_730c_GDEY073D46`** | `GxEPD2_7C` | — | **LOW** | `DISP_7C_F`. ~4 bpp → too big for WROOM RAM; avoid. |
| **4.2" (fallback)** | GDEW042T2 / WFT042CZ15 | 400×300 | Mono | **`GxEPD2_420`** | `GxEPD2_BW` | UC8176 (IL0398) | **LOW** | Easiest fallback; ~15 KB buffer. |
| **4.2" (newer GD)** | GDEY042T81 (no inking) | 400×300 | Mono | **`GxEPD2_420_GDEY042T81`** | `GxEPD2_BW` | SSD1683 | **LOW** | Pick this only if ribbon says GDEY042T81. |
| **4.2" tri-color** | GDEW042Z15 / WFT0420CZ15 | 400×300 | B/W/R | **`GxEPD2_420c`** | `GxEPD2_3C` | UC8176 (IL0398) | **LOW** | — |
| **5.83"** (bonus, WROOM-safe) | GDEW0583T8 / WFT0583CZ61 | 648×480 | Mono | **`GxEPD2_583_T8`** | `GxEPD2_BW` | EK79655 (GD7965) | **LOW** | Fits WROOM comfortably. |

**Takeaway on polarity:** every mono/3C panel you're realistically going to plug in is **BUSY=LOW**. The
**only BUSY=HIGH** panel in the plausible set is the **880×528 HD tri-color (`GxEPD2_750c_Z90`, SSD1677)**.
That is the one you must not confuse with an 800×480 panel — different resolution AND different BUSY polarity.

> Class list + part numbers + FPC marks: GxEPD2 `examples/GxEPD2_Example/GxEPD2_display_selection_new_style.h`
> (lines 66–107, verified this session). `busy_level` values verified in `src/epd/GxEPD2_750_T7.cpp`,
> `GxEPD2_750.cpp`, `GxEPD2_420.cpp`, `GxEPD2_583_T8.cpp`, `src/epd3c/GxEPD2_750c_Z90.cpp` (**HIGH**),
> `GxEPD2_420c.cpp`, `GxEPD2_750c_GDEW075Z08.cpp`, `src/epd7c/GxEPD2_730c_GDEY073D46.cpp`.

---

## Exact declaration for the MOST LIKELY panel, with OUR pins

Assume the confirmed likely case: **Waveshare 7.5" V2, 800×480, mono → `GxEPD2_750_T7`**.
Pins are OUR board: BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14.

**Constructor argument order is `(CS, DC, RST, BUSY)`** — verified from GxEPD2's own Waveshare line:

```cpp
// GxEPD2_wiring_examples.h, line 238 (verbatim):
// GxEPD2_DISPLAY_CLASS<GxEPD2_DRIVER_CLASS, MAX_HEIGHT(GxEPD2_DRIVER_CLASS)> display(
//   GxEPD2_DRIVER_CLASS(/*CS=*/ 15, /*DC=*/ 27, /*RST=*/ 26, /*BUSY=*/ 25)); // Waveshare ESP32 Driver Board
```

### Display declaration (paged mode for the WROOM RAM ceiling)

```cpp
#include <GxEPD2_BW.h>          // mono wrapper

// Pin map for the Waveshare e-Paper ESP32 Driver Board (this board).
#define EPD_CS   15   // GPIO15 — also a strapping pin
#define EPD_DC   27
#define EPD_RST  26
#define EPD_BUSY 25
#define EPD_SCK  13
#define EPD_MOSI 14
#define EPD_MISO 12   // not used by e-paper (no MISO), but SPI.begin() wants a pin

// Paged drawing: page_height = HEIGHT/2 (~240 rows) keeps the framebuffer ~24 KB so WiFi+TLS still fit.
// Use ::HEIGHT for a full 48 KB buffer only if you have confirmed the heap headroom.
GxEPD2_BW<GxEPD2_750_T7, GxEPD2_750_T7::HEIGHT / 2> display(
    GxEPD2_750_T7(/*CS=*/ EPD_CS, /*DC=*/ EPD_DC, /*RST=*/ EPD_RST, /*BUSY=*/ EPD_BUSY));
```

### SPI remap + init — two proven patterns

**Pattern A — dedicated HSPI bus (GxEPD2's own Waveshare example, `GxEPD2_WS_ESP32_Driver.ino`):**

```cpp
#include <SPI.h>
SPIClass hspi(HSPI);

void setup() {
  Serial.begin(115200);
  // Remap HW SPI to the board's FPC pins. Note SCK/MOSI are "swapped" vs stock HSPI.
  // hspi.begin(SCK, MISO, MOSI, SS):
  hspi.begin(13, 12, 14, 15);                                          // verbatim: hspi.begin(13, 12, 14, 15);
  display.epd2.selectSPI(hspi, SPISettings(4000000, MSBFIRST, SPI_MODE0));
  display.init(115200);
  // ... draw ...
}
```

**Pattern B — remap the global SPI (how `esp32-weather-epd`'s `initDisplay()` does it):**

```cpp
#include <SPI.h>
void initDisplay() {
  display.init(115200, true, 2, false);   // reset_duration = 2 for the Waveshare "clever reset" board
  SPI.end();
  SPI.begin(EPD_SCK /*13*/, EPD_MISO /*12*/, EPD_MOSI /*14*/, EPD_CS /*15*/);
  display.setRotation(0);
  display.setFullWindow();
  display.firstPage();                     // enter paged drawing (also fillScreen white)
}
```

**Init signature (why the `(115200, true, 2, false)` form):**
`virtual void init(uint32_t serial_diag_bitrate, bool initial, uint16_t reset_duration = 10, bool pulldown_rst_mode = false);`
The **`reset_duration = 2`** (ms) is the value both GxEPD2's hardware notes and `esp32-weather-epd`'s
`DRIVER_WAVESHARE` path use for Waveshare boards with a "clever reset circuit" (DESPI-C02 uses `10`). Verified
in `GxEPD2_EPD.h` line 37 and `esp32-weather-epd/platformio/src/renderer.cpp` (`display.init(115200, true, 2, false);`).

### The paged draw loop (mono full-refresh per wake)

```cpp
display.setFullWindow();
display.firstPage();
do {
  display.fillScreen(GxEPD_WHITE);
  // ... draw Bitcoin (largest region) + weather here; the callback runs once per page/strip ...
} while (display.nextPage());
display.hibernate();   // power the panel down after refresh (manufacturer rule; avoids damage)
```

> Grounding: display decl + SPI patterns from GxEPD2 `examples/GxEPD2_WS_ESP32_Driver/GxEPD2_WS_ESP32_Driver.ino`
> (lines 34, 155, 178, 189–190, 194) and `esp32-weather-epd/platformio/src/renderer.cpp` (lines 40–46, 218–241);
> init signature from GxEPD2 `src/GxEPD2_EPD.h`; pin map from wiki `hardware-platform.md` + confirmed hardware header.

---

## If your ribbon says something else — quick swap

Change **only the driver class** (and its wrapper). Pins/SPI/init are identical across all these panels on
this board:

```cpp
// 800x480 mono, newer GoodDisplay panel (esp32-weather-epd DISP_BW_V2 default):
GxEPD2_BW<GxEPD2_750_GDEY075T7, GxEPD2_750_GDEY075T7::HEIGHT / 2> display(
    GxEPD2_750_GDEY075T7(EPD_CS, EPD_DC, EPD_RST, EPD_BUSY));

// 640x384 mono (Waveshare 7.5" V1):
GxEPD2_BW<GxEPD2_750, GxEPD2_750::HEIGHT / 2> display(
    GxEPD2_750(EPD_CS, EPD_DC, EPD_RST, EPD_BUSY));

// 4.2" 400x300 mono fallback (fits full-buffer easily, no paging needed):
GxEPD2_BW<GxEPD2_420, GxEPD2_420::HEIGHT> display(
    GxEPD2_420(EPD_CS, EPD_DC, EPD_RST, EPD_BUSY));
```

`esp32-weather-epd` exposes these as compile-time switches in `platformio/include/config.h`
(`#define DISP_BW_V2` [default] / `DISP_3C_B` / `DISP_7C_F` / `DISP_BW_V1`) and picks the GxEPD2 class in
`platformio/src/renderer.cpp` — so in the fork you flip the `DISP_*` define rather than editing the class
directly. If you fork it, keep that abstraction and point `DISP_BW_V2` at `GxEPD2_750_T7` if your panel is the
classic GDEW075T7 rather than the GDEY075T7 the upstream ships.

---

## RAM reality check (mono 800×480 on WROOM-32E, no PSRAM)

Full buffer = 800×480/8 ≈ **48 KB**. With WiFi + TLS live, that's tight. Use **paged drawing**
(`page_height = HEIGHT/2` → ~24 KB, or `/4` → ~12 KB) so the draw callback runs per strip. `GxEPD2_3C`
tri-color needs a second bit-plane (~2×) and `GxEPD2_7C` is ~4 bpp — **do not run 7C on this WROOM board.**
(wiki `hardware-platform.md`, `limitations-and-gotchas.md`.)


---
## Risky claims flagged for verification

- **The most likely panel is the classic Waveshare 7.5" V2 = GDEW075T7 = GxEPD2_750_T7, but esp32-weather-epd's DISP_BW_V2 actually selects GxEPD2_750_GDEY075T7 (GDEY075T7, UC8179). Both are 800x480 mono BUSY=LOW, but they are DIFFERENT controller classes (EK79655/GD7965 vs UC8179).**
  - risk: If the user copies esp32-weather-epd's default expecting the classic Waveshare panel, or vice versa, the panel may ghost/garble due to wrong waveforms even though resolution and BUSY polarity match. The correct class depends on the exact FPC marking (WFT0583CZ61 -> _T7; FPC-C001 -> _GDEY075T7), which we cannot see.
- **BUSY polarity in GxEPD2 is NOT user-settable; it is hardcoded per driver class as busy_level (5th arg to GxEPD2_EPD). All plausible mono/3C candidates are BUSY=LOW; the ONLY BUSY=HIGH exception in the candidate set is the 880x528 HD tri-color GxEPD2_750c_Z90 (SSD1677).**
  - risk: This reframes the user's 'invert BUSY or damage the panel' requirement: on this GxEPD2 fork there is no invert knob, so the real risk is choosing the wrong class. If this is wrong and some class does expose polarity, guidance would be misdirected. Verified against src/epd/*.cpp and src/epd3c/GxEPD2_750c_Z90.cpp this session.
- **Constructor argument order is (CS, DC, RST, BUSY) and the correct board line is display(GxEPD2_750_T7(/*CS=*/15, /*DC=*/27, /*RST=*/26, /*BUSY=*/25)).**
  - risk: A swapped RST/DC or CS/BUSY produces a dead or damaged-looking panel and could send commands with wrong framing. Order taken verbatim from GxEPD2_wiring_examples.h line 238 'Waveshare ESP32 Driver Board'.
- **Use display.init(115200, true, 2, false) with reset_duration=2 ms for this Waveshare board ('clever reset circuit'); DESPI-C02 uses 10.**
  - risk: Wrong reset_duration can leave the panel un-reset or unstable on this specific board. Value confirmed in esp32-weather-epd renderer.cpp DRIVER_WAVESHARE path and GxEPD2 init signature, but is board-adapter-specific and may differ on the user's exact adapter.
- **The specific mechanism by which wrong BUSY polarity 'permanently damages' the panel is that _waitWhileBusy() stops respecting the panel's busy state and fires the next frame mid-waveform.**
  - risk: The permanent-damage framing is inherited from the wiki/ESPHome guidance; the concrete, well-documented damage vectors are actually over-refresh and not sleeping the panel. Overstating BUSY-polarity-as-sole-cause could misdirect debugging. Flagged as plausible mechanism, not proven.
- **SPI must be remapped to non-default pins via hspi.begin(13,12,14,15)+selectSPI, or SPI.end()+SPI.begin(13,12,14,15/*CS*/); MISO=GPIO12 is a dummy (e-paper has no MISO).**
  - risk: The board 'swaps SCK and MOSI' vs stock HSPI per GxEPD2's comment; getting the SPI.begin arg order (SCK,MISO,MOSI,SS) wrong yields no display output. Verified from GxEPD2_WS_ESP32_Driver.ino lines 189-190 and renderer.cpp lines 237-241.
