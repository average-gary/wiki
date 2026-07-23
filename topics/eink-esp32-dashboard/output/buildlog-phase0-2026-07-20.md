---
title: "Build Log — Phase 0 hardware ID + repo recon (on-device plan)"
type: buildlog
plan: plan-ondevice-waveshare-dashboard-2026-07-20.md
created: 2026-07-20
---

# Build Log — Phase 0 (executed on the real board)

Session drove the physical board over USB from the Mac. Facts below are read from the
silicon / the actual `esp32-weather-epd` tree, not inferred.

## Confirmed hardware (from esptool)

| Fact | Value | How |
|------|-------|-----|
| Chip | **ESP32-D0WD-V3 rev v3.1** (WROOM-32E die), dual-core, 240 MHz, 40 MHz XTAL | `esptool chip-id` |
| Flash | **4 MB** (mfr `5e`, dev `4016`) | `esptool --no-stub flash-id` |
| MAC | `f0:24:f9:49:26:80` | eFuse |
| USB-UART | **CH343/CH9102 as native CDC-ACM** → port `/dev/cu.usbmodem59090511351`; **no macOS driver needed** | port name is `usbmodem`, not `usbserial`/`wchusbserial` |
| Panel label | **PENDING** — needs user to read the FPC ribbon/silkscreen part number | — |

## ⚠️ Flashing quirk (reproduced twice — ripples through every flash step)

- The esptool **stub flasher fails**: `A fatal error occurred: Failed to write to target RAM (result was 0107: Checksum error)`.
- **`--no-stub` works** (read chip-id, flash-id, read-flash all succeed). PlatformIO uploads must account for this (`--no-stub` equivalent / conservative baud like 115200; possibly `board_upload.use_1200bps_touch`/reset flags).
- `--no-stub` reads run at ROM-loader speed → a full 4 MB backup at 115200 exceeds 2 min; use `--baud 460800`.
- esptool version in use: **v5.3.1** (note: `chip_id`/`flash_id` are deprecated spellings → `chip-id`/`flash-id`).

## Repo recon (lmarzen/esp32-weather-epd, cloned to repos/e-ink)

Cross-checks that correct/confirm the plan's assumptions:

- **Project root is `platformio/`**; config split across `include/config.h` (compile-time `#define`s) and **`src/config.cpp`** (the actual pin constants + secrets).
- **Pins live in `src/config.cpp`** (currently FireBeetle defaults): `PIN_EPD_BUSY=14, CS=13, RST=21, DC=22, SCK=18, MISO=19, MOSI=23, PWR=26`. → **edit these to our board: BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14.**
- **Panel is pre-selected**: `config.h` has `#define DISP_BW_V2` (7.5" 800×480 B/W) — our target. Options: `DISP_BW_V2 / DISP_3C_B / DISP_7C_F / DISP_BW_V1(640×384)`.
- **GxEPD2 class for `DISP_BW_V2` = `GxEPD2_750_GDEY075T7`** (`src/renderer.cpp:43`). NOTE: this is the concrete class, *not* the wiki shorthand `GxEPD2_750_T7`. `DISP_BW_V1` → `GxEPD2_750` (the 640×384 one).
- **`DRIVER_WAVESHARE` vs `DRIVER_DESPI_C02` is a built-in switch** (`config.h:42-43`, used in `renderer.cpp:229`). Default is DESPI-C02 ("only officially supported driver board"). → set `DRIVER_WAVESHARE` and verify what it changes (PWR-rail handling around `renderer.cpp:227-232`).
- **platformio.ini `default_envs = dfrobot_firebeetle2_esp32e`**; also a `firebeetle32` env. `platform = espressif32@6.13.0`, `framework = arduino`, `GxEPD2@1.6.8`, `ArduinoJson@7.4.3`, `board_build.partitions = huge_app.csv`, `board_build.f_cpu = 80MHz`. → **add a Waveshare/esp32dev env** with our upload/monitor settings + the `--no-stub` workaround.
- **⚠️ Weather provider is OpenWeatherMap-ONLY.** `include/api_response.h` is entirely `owm_*` structs; `config.cpp`/`config.h` expose `OWM_APIKEY`, `OWM_ENDPOINT`, `OWM_ONECALL_VERSION`. **There is no Open-Meteo code path.** → "keyless Open-Meteo" is NOT a toggle; it requires either (a) adding an Open-Meteo client + parser + response structs, or (b) keeping OWM One Call 3.0 (needs a free API key, 1000 calls/day). **Decision for the user.**
- Units default to Fahrenheit/mph/inHg, `LOCALE en_US`, `FONT_HEADER "fonts/FreeSans.h"`. Battery monitoring + status bar are OWM/FireBeetle-oriented.
- `USE_HTTPS_WITH_CERT_VERIF` is the default TLS mode (cert in `cert.h`, needs manual renewal) — options `USE_HTTP` / `USE_HTTPS_NO_CERT_VERIF` also present (the latter = the wiki's `setInsecure()` path).

## Safety actions taken

- **Factory firmware backup: ✅ COMPLETE & VERIFIED** → `repos/e-ink/factory-backup-4MB.bin`
  - Full 4,194,304 bytes; SHA-256 `2d16c86699ed36984aefa4ea2119970202ba9146c1eeb8ae649eaf69d64cd355`; byte@0x1000 = `0xe9` (valid ESP32 image magic).
  - **Two straight `read-flash 0x0 0x400000` attempts FAILED** — first on port contention (`could not open port`), second on `OSError [Errno 83] Device error` (CH343 CDC drops during a long continuous no-stub read).
  - **What worked**: chunked read via `chunked_backup.sh` — 8 × 512 KB, `--baud 230400`, `--after no_reset`, 3× per-chunk retry, concatenated at the end. ~43 s/chunk. Per-chunk retry is the key: a dropped chunk retries itself instead of restarting 4 MB.
  - Restore (when needed): `esptool --no-stub write-flash 0x0 factory-backup-4MB.bin` (use --no-stub per this board's quirk).

## Decisions resolved with the user

1. **Weather provider → ADD OPEN-METEO (keyless).** Confirmed no Open-Meteo path exists in the repo; agents will add a fetch fn + WMO weather-code mapping + struct adapters. No API key/secret (fits the self-contained/portable goal).
2. **Panel → identified.** Back label `075BN-T7-D2`, ribbon `FPC-C001 21.08.30 HB`. Web lookup: **`075BN-T7-D2` = Waveshare 7.5" V2, 800×480 B/W** (matches the repo's `demo-waveshare75-version1.jpg`). ⚠️ See correction C5 below on which GxEPD2 class this actually implies.

## ⚠️ Corrections from the adversarial verify pass (MUST-FIX BEFORE FLASHING)

The scaffolding workflow's verify agents (high confidence, primary-source-checked) caught these. They override the drafts AND, in one case, the wiki:

- **C1 — GPIO4 e-paper rail is ACTIVE-HIGH, not active-low.** Topology is IO4 → Q32 (S8050 NPN) → Q31 (AO3401 P-MOSFET, R33/R34=100K). The NPN pre-driver **inverts** the bare-P-FET logic: **drive GPIO4 HIGH to power the panel, LOW to cut it.** `esp32-weather-epd` already does `digitalWrite(PIN_EPD_PWR, HIGH)` to enable — keep it. Two draft agents initially claimed active-low; refuted against the schematic. Driving LOW would leave the panel dark.
- **C2 — PIN_EPD_PWR collision.** Upstream default `PIN_EPD_PWR=26` — but on THIS board GPIO26 is **RST**. In `src/config.cpp` set **`PIN_EPD_PWR=4`** (the AO3401 gate) AND `PIN_EPD_RST=26`, or PWR drives RST and the rail never enables. Full remap: `BUSY=25, CS=15, RST=26, DC=27, SCK=13, MISO=12(dummy), MOSI=14, PWR=4`. Also flip `config.h`: `DRIVER_DESPI_C02` → `DRIVER_WAVESHARE`.
- **C3 — TLS `WiFiClientSecure::setTimeout()` unit is core-version-dependent.** SECONDS on Arduino-ESP32 core 2.x; the class is renamed `NetworkClientSecure` on core 3.x. **Do NOT call `client.setTimeout()`** — set timeouts only on `HTTPClient` (`setConnectTimeout`/`setTimeout`, ms). Hardcoding `ms/1000` → an 8 ms timeout on 3.x → every HTTPS handshake fails.
- **C4 — `--no-stub` injection reason was wrong (but verify by eye regardless).** PlatformIO core `env.Prepend(UPLOADERFLAGS=['$UPLOAD_FLAGS'])` runs AFTER the platform's `env.Replace`, so plain `upload_flags = --no-stub` prepends to the FRONT (before `write_flash`) and SHOULD work — the `post: extra_scripts` hook isn't strictly required. BUT PlatformIO docs claim `upload_flags` is appended (would break a global flag), contradicting the source. **Action: on first upload, read the printed `esptool … UPLOADERFLAGS` line and confirm `--no-stub` appears BEFORE `write_flash`.** Prefer explicit `--flash-size 4MB` over `detect` with `--no-stub`. Keep the GPIO0→GND manual procedure on hand (CH343 auto-reset unverified for this unit).
- **C5 — Panel class: `075BN-T7-D2` = Waveshare 7.5" V2 = the CLASSIC GDEW075T7 (GD7965 controller), which maps to `GxEPD2_750_T7` — NOT the repo default `GxEPD2_750_GDEY075T7` (GDEY075T7, UC8179).** Both are 800×480 mono, BUSY=LOW, and share the `(CS,DC,RST,BUSY)` constructor — so pins/wiring are unaffected — but they use different controllers/waveforms, so **the repo's `DISP_BW_V2`→`GxEPD2_750_GDEY075T7` may ghost on this classic-V2 panel.** In `renderer.cpp`/`renderer.h` be ready to switch the class to `GxEPD2_750_T7`. Resolve empirically in Phase 1: try the repo default first, and if it ghosts/blanks, switch to `GxEPD2_750_T7`. **This corrects the wiki**, which used `GxEPD2_750_T7` as generic shorthand — here it's the specifically-correct class for a V2 panel.
- **C6 — BUSY-polarity "permanent damage" framing is overstated.** Mechanism real (`_waitWhileBusy()` returns immediately with wrong polarity → next op mid-waveform → garble/timeouts), but no primary source shows a guaranteed brick. BUSY polarity is hardcoded per GxEPD2 class (not user-set) and is LOW for all plausible candidates here, so this is low-risk in practice. Still change one variable at a time.
- **C7 — There is NO button on GPIO12 per the official Waveshare schematic.** The two buttons are S2 `KEY_RST/USER` on EN/CHIP_PU (reset) and S1 `KEY_FLASH` on **GPIO0**. The wiki/ESPHome profile's "KEY on GPIO12" conflicts with the schematic. **For the WiFiManager config-reset trigger, read GPIO0 (S1) after a normal boot — do NOT gate boot behavior on GPIO12** (GPIO12/MTDI is a flash-voltage strap; safe on stock WROOM only because eFuse XPD_SDIO overrides it). Confirm your unit's button wiring with a meter before relying on it.
- **Also**: pin `tzapu/WiFiManager @ 2.0.17` (exact, not `^`); keep ArduinoJson v7 elastic `JsonDocument` (don't downgrade); parse `/api/blocks/tip/height` with `atoi` (bare integer); use `strtol`/long for price; close/`delete` the TLS client BEFORE the `firstPage()/nextPage()` render loop so framebuffer + TLS buffers don't coincide and OOM.

## ⛔ Phase 1 BLOCKED — write path fails (reads fine). Almost certainly cable/USB.

Panel-test firmware **built successfully** (`panel-test/`, RAM 21.3% / 69 KB, Flash 9.1%) with all verified corrections baked in (pins, GPIO4 active-high, `GxEPD2_750_T7`, 2 ms reset). Toolchain fully working: the `no_stub.py` `--no-stub` prepend AND the `-z`→`--no-compress` swap both injected correctly (C4 confirmed on real hardware). Also had to install `intelhex` into the **Homebrew** PlatformIO python (`/opt/homebrew/Cellar/platformio/6.1.18_3/libexec/bin/python`) — NOT the `~/.platformio/penv` — to generate `bootloader.bin`.

**But every flash WRITE fails at the protocol layer while every READ succeeds:**

| Operation | Direction | Result |
|---|---|---|
| chip-id, flash-id, 4 MB backup read | dev→host | ✅ works, even @460800 |
| stub upload (write to RAM) | host→dev | ❌ `0107` Checksum error |
| write-flash compressed (`-z`) | host→dev | ❌ `0105` invalid message format |
| write-flash `--no-compress` @115200/57600 | host→dev | ❌ `0105` / transfer stopped |
| @74880 | host→dev | ❌ Packet content transfer stopped |

Tried both esptool **4.11.0 (PIO bundled)** and **5.3.1 (standalone)**, stub + no-stub, compressed + not, baud 57600–115200. Reads-succeed/writes-fail across everything = **host→device data corruption over the CH343 USB link.** Board is undamaged (still enumerates + reads MAC `f0:24:f9:49:26:80` after every failure).

### What the USER needs to try (physical — the harness can't do these):
1. **Swap the USB cable** — #1 cause. Many USB-C cables are charge-only or marginal for data; a dropped/corrupted outbound byte trips the `0105`/`0107` checksum. Use a known-good data cable.
2. **Different USB port / powered hub** — try a direct port (not through a hub/monitor), or a powered hub if the board browns out during write bursts.
3. **Hold GPIO0→GND during EN/reset** to force clean download mode, then retry the flash immediately.
4. (If it persists) the CH343 bridge or board USB may be marginal — try another machine/cable to isolate.

Once a good cable/port is in, re-run: `cd panel-test && pio run -e waveshare_epd_esp32 -t upload`. The build artifacts are ready; only the physical link needs fixing.

### UPDATE — new cable + new port did NOT change anything → diagnosis refined
Re-tested on a fresh cable and USB port. **Byte-identical failures**, still 100% deterministic:
- stub RAM write → `0107` checksum; no-stub flash write (even a **3 KB** single block) → `0105` invalid format; erase-flash → "ROM does not support" (expected, stub-only cmd).
- Reads still 100% reliable (MAC/flash-id every time).

**Deterministic (not intermittent) + reads-OK/writes-fail + two different esptool versions failing identically ⇒ NOT a flaky cable.** Signature points to the **macOS built-in CDC-ACM driver mangling outbound SLIP-escape bytes (0xC0/0xDB)** for this **CH343** bridge — a known flashing-only failure mode (reads unaffected).

### RECOMMENDED FIX (user action): install the WCH VCP vendor driver
The board enumerates via macOS's built-in CDC-ACM (`/dev/cu.usbmodem59090511351`). Install **WCH's CH34x VCP driver for macOS** (`CH34xVCPDriver`, DriverKit app from wch-ic.com / wch.cn, also on the Mac App Store as "CH34xVCPDriver"). After install + approval in **System Settings → Privacy & Security → Allow**, the board should appear as **`/dev/cu.wchusbserial*`**; flash against that port. This vendor driver handles the write-path framing the built-in one corrupts.
- Alternative if the driver doesn't resolve it: flash from a **Linux box** (Linux CH343 CDC handles writes fine) or another Mac, then move the board back.

**Status: Phase 1 firmware built & verified-correct; flashing blocked pending the CH343 write-path driver fix. Board undamaged.**

### UPDATE 2 — dock RULED OUT; confirmed native-port; diagnosis now solid
USB descriptor scan found the board is a **CH343: VID `0x1a86` PID `0x55d3`** ("USB Single Serial", 12 Mb/s), and it had been nested inside a **VIA Labs hub + DisplayLink dock** (VID 0x2109 / 0x17e9) tree. Suspected the dock (they corrupt esptool write handshakes). User reattached **directly to the Mac** — Location ID changed `0x00121000` → **`0x01100000`** (confirmed different native bus, no hub parent).
- **Result: writes STILL fail byte-identically** (stub `0107`, no-stub 3 KB `0105`), reads still perfect.
- **All physical variables now eliminated:** cable (swapped), port (swapped), dock (bypassed, native bus confirmed), board (reads MAC/flash-id every time). ⇒ The cause is **the macOS built-in CDC-ACM driver's CH343 write path** — the last remaining variable.

### On "write our own driver" (user asked)
Not worth it: a real macOS driver is a **DriverKit `.dext`** needing an Apple `com.apple.developer.driverkit` entitlement (Apple-approved), signing + notarization + user approval — days/weeks to reimplement CDC-ACM. A **libusb userspace flasher** (libusb IS installed) is the only DIY path that makes sense, but it means reimplementing the CH343 register protocol + ESP32 SLIP over raw bulk endpoints AND detaching the kernel CDC claim (restricted on macOS) — high effort, marginal payoff, since esptool already IS the userspace protocol and the corruption is below it. **Use the free WCH vendor driver instead.**

### DEFINITIVE FIX (user action)
Install **WCH `CH34xVCPDriver`** (Mac App Store, free; or wch-ic.com) → approve in **System Settings → Privacy & Security** → replug → board appears as **`/dev/cu.wchusbserial*`** → flash against that port. This replaces the built-in CDC-ACM driver that mangles the outbound SLIP framing.
- Fallback: flash from a **Linux machine** (CH343 CDC writes work OOB there), then move the board back to the Mac for runtime serial monitoring (reads work fine on macOS).

### UPDATE 3 — CLI-only USB-passthrough path TESTED and BLOCKED at the OS level
User's bar: CLI-only on this Mac, no closed-source install. The only candidate was headless QEMU (open source) with libusb USB passthrough into a Linux guest. **Probed directly with pyusb/libusb:**
- libusb FINDS the CH343 (1a86:55d3), `set_configuration` OK, but **`detach_kernel_driver` and `claim_interface` → `USBError(13) Access denied`**.
- Root cause: macOS's built-in **CDC-ACM class driver owns interface 0**, and **libusb on macOS cannot detach a class driver** (IOKit restriction, not POSIX perms — `sudo` doesn't help; `detach_kernel_driver` is effectively unsupported on macOS).
- **QEMU/UTM passthrough uses libusb too → same `Access denied` → not viable.**

**CONCLUSION: there is no CLI-only, no-GUI, no-closed-source way to flash this board on this Mac.** Flashing requires EITHER the closed-source WCH driver (user declined; likely MDM-blocked anyway) OR a physically separate Linux host (out of "on this Mac" scope). Per the user's stated bar, Phase 1 flashing is **not worth pursuing on this machine**. Board undamaged; all build artifacts + factory backup preserved and resumable if a Linux host ever becomes available.

## ✅ FLASHING SOLVED (WCH driver) — ⛔ Phase 1 now blocked on panel BUSY timeout

**Flashing works** after installing WCH `CH34xVCPDriver` **DriverKit dext** (the `.dmg` from github.com/WCHSoftGroup/ch34xser_macos — the `.dmg` embeds `cn.wch.CH34xVCPDriver.dext`, notarized by Apple, signed by WCH team 5JZGQTGU4W; the `.pkg` in the same repo is the legacy KEXT — use the DMG). After app "Install" + System Settings approval + **replug**, port becomes **`/dev/cu.wchusbserial59090511351`** and esptool STUB writes work at 460k (`Hash of data verified`). Updated `panel-test/platformio.ini` upload_port/monitor_port to the wch name.
- Reliable serial capture method (pio monitor kept returning empty): pyserial in a venv, toggle DTR/RTS to reset, then read — see the one-liner used this session.

**Phase 1 blocked: panel never releases BUSY.** Serial log from `panel-test`:
```
display.init(...) -> init returned in ~31ms
Drawing... -> Busy Timeout!  _PowerOn : 100010xx   (then _Update_Full also times out)
```
Ruled out empirically (both reflashed + captured):
- **Panel class is NOT the cause** — `GxEPD2_750_T7` AND `GxEPD2_750_GDEY075T7` timeout identically.
- **Reset timing is NOT the cause** — 2 ms (`init(115200,true,2,false)`) AND default 10 ms (`init(115200)`) timeout identically.
- BUSY (GPIO25) read constant HIGH, never toggled (though the no-SPI probe was inconclusive — an idle panel also sits high).

⇒ **Root cause is physical/wiring-level**, not firmware. Ranked suspects for the USER to check (I cannot touch hardware):
1. **FPC ribbon seating/orientation** — the display ribbon (and the adapter-to-board FPC) not fully seated, or inserted with contacts facing the wrong way. Reseat both ends; ensure the connector latch is closed. **#1 cause of "BUSY never responds."**
2. **Adapter PWR/jumper** — earlier panel lookup called this a **Waveshare 7.5" Rev 2.3 HAT**; both the wiki (`hardware-platform.md`) and esp32-weather-epd warn **rev 2.3 needs its PWR pin tied to 3.3 V** and prefer the DESPI-C02 adapter. Check the small adapter board between the ESP32 board and the panel for a **display-config switch (e.g. "A"/"B") and a PWR pad/jumper.**
3. **Display-config switch on the adapter** — many Waveshare adapters have a mode switch that MUST match the panel (e.g. set to "A" for most SPI panels). Wrong position → no BUSY.
4. Confirm the panel FPC actually goes into the **adapter**, and the adapter's FPC into the **board's e-paper connector** (two ribbon junctions; either can be loose).

Board + flashing are fully working; only the panel link needs a physical fix. Firmware is staged to retry instantly.

## Serial-port contention lesson

The first background factory-backup died at 42% with `could not open port` because concurrent esptool calls (with `--after hard_reset`) re-enumerated the CH343 CDC port mid-read. **Only one process may touch `/dev/cu.usbmodem*` at a time**, and reads should use `--after no_reset`. Re-running isolated.
