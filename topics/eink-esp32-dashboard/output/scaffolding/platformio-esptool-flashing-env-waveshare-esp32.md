# PlatformIO + esptool Flashing Environment — Waveshare e-Paper ESP32 Driver Board (ESP32-D0WD-V3, CH343 CDC, --no-stub)

> ### ✅ VERIFIED CORRECTIONS (apply — refine the draft below)
> Adversarial verify pass, high confidence, vs PlatformIO `builder/main.py` source:
> - **The draft's *reason* for the `post: extra_scripts` hook is backwards**, but it's harmless. PlatformIO core runs `env.Prepend(UPLOADERFLAGS=['$UPLOAD_FLAGS'])` AFTER the platform's `env.Replace`, so a plain `upload_flags = --no-stub` prepends to the FRONT (before `write_flash`) and should work. The docs claim it's appended (which would break a global flag) — so **whichever method you use, VERIFY by reading the printed `esptool … UPLOADERFLAGS` line on the first upload and confirm `--no-stub` appears BEFORE `write_flash`.**
> - With `--no-stub` on this original ESP32, **prefer explicit `--flash-size 4MB` over `detect`** (ROM auto-detect is less reliable without the stub).
> - **CH343 auto-reset is NOT guaranteed for this unit** — keep the manual **GPIO0→GND during reset** procedure on hand.
> - ⚠️ **Serial-port contention (learned this session): only ONE process may touch `/dev/cu.usbmodem*` at a time**; a concurrent esptool call with `--after hard_reset` re-enumerated the CDC port and killed an in-flight read. Use `--after no_reset` for reads.
> - Full C1–C7 list: `../buildlog-phase0-2026-07-20.md`.

## PlatformIO + esptool flashing environment for the Waveshare e-Paper ESP32 Driver Board

Target board (confirmed over USB this session): **ESP32-D0WD-V3 rev3.1** (WROOM-32E die), **4 MB flash, no PSRAM**, USB-UART is a **CH343/CH9102 native CDC-ACM** at **`/dev/cu.usbmodem59090511351`**. The stub flasher fails on this unit (`Failed to write to target RAM (Checksum error)`) so **all flashing must run `--no-stub`** and/or a conservative baud.

This guide is for the on-device GxEPD2 fork of `lmarzen/esp32-weather-epd`. That upstream repo targets a DFRobot FireBeetle; the sections below replace its `platformio.ini` env with one for a **generic ESP32-WROOM-32E** and bolt on the `--no-stub` workaround.

> **Tooling version split you must know about.** PlatformIO `platform = espressif32 @ 6.13.0` bundles **esptool.py 4.11.0**, which uses the *underscore* CLI (`write_flash`, `--flash_size`). A fresh standalone `pip install esptool` in 2026 gives **esptool 5.3.1**, which uses the *hyphen* CLI (`write-flash`, `--flash-size`); the old underscore forms still work but print a deprecation warning. Section 2's one-liners are given in the v5 hyphen form (primary) with the underscore alias noted. Section 1 (PlatformIO-driven) rides on the bundled 4.11.0, which is why the injected flag/command strings there use `--no-stub` (a global flag, spelled the same in both) and the platform's own `write_flash`. Sources: PlatformIO espressif32 6.13.0 release notes (esptoolpy v4.11.0); esptool v5 migration guide ("Old command and option names are deprecated … will work for now with a warning").

---

### 1. `platformio.ini` for this board

Key facts that drive the config, pulled from the platform builder (`platform-espressif32 @ v6.13.0`, `builder/main.py`):

- For `upload_protocol = esptool` (the default), the builder does `env.Replace(UPLOADERFLAGS=[...])`, hardcoding this ordered list:
  `--chip <mcu> --port "$UPLOAD_PORT" --baud $UPLOAD_SPEED --before <before_reset> --after <after_reset> write_flash -z --flash_mode ... --flash_freq ... --flash_size <upload.flash_size|detect>` and `UPLOADCMD = "$PYTHONEXE" "$UPLOADER" $UPLOADERFLAGS $ESP32_APP_OFFSET $SOURCE`.
- **Two consequences that make the naive fixes fail:** (a) that `env.Replace` **clobbers anything you put in `upload_flags`**, and (b) even if it didn't, `upload_flags` are *appended*, i.e. they land **after** `write_flash` — but `--no-stub` is a **global option that must precede the subcommand** (esptool docs: "Global options must be placed **before** the subcommand"). So `upload_flags = --no-stub` does **not** work here. You need an `extra_scripts` hook that inserts `--no-stub` into `UPLOADERFLAGS` *before* `write_flash`.
- `--before` / `--after` reset behavior **is** exposed as board knobs: the builder reads `board.get("upload.before_reset", "default_reset")` and `board.get("upload.after_reset", "hard_reset")`, so `board_upload.before_reset` / `board_upload.after_reset` are the clean way to set them.

`platformio.ini`:

```ini
[platformio]
default_envs = waveshare_epd_esp32

; Shared build/lib settings (kept from upstream esp32-weather-epd)
[env]
platform = espressif32 @ 6.13.0
framework = arduino
build_unflags = '-std=gnu++11'
build_flags = '-Wall' '-std=gnu++17'
lib_deps =
  bblanchon/ArduinoJson @ 7.4.3
  zinggjm/GxEPD2 @ 1.6.8
  ; (add Adafruit BME* libs here only if you keep the weather-epd sensor code)

[env:waveshare_epd_esp32]
; Generic ESP32-WROOM-32E, 4 MB, no PSRAM. NOT firebeetle/esp32dev-specific pins:
; the panel SPI pins (BUSY25/RST26/DC27/CS15/SCK13/MOSI14) are remapped in firmware,
; not by the board file, so the plain esp32dev board profile is correct here.
board = esp32dev
board_build.flash_size = 4MB
board_build.partitions = huge_app.csv     ; single 3 MB app, no OTA slot (weather-epd default)
board_build.f_cpu = 80000000L             ; 80 MHz for power; drop this line for full 240 MHz

; --- Ports (this exact board on this Mac) ---
upload_port  = /dev/cu.usbmodem59090511351
monitor_port = /dev/cu.usbmodem59090511351
monitor_speed = 115200

; --- Flashing reliability for THIS unit ---
upload_speed = 115200                      ; conservative; ROM loader (no stub) is happier slow
board_upload.before_reset = default_reset  ; DTR/RTS auto-enter download via CH343
board_upload.after_reset  = hard_reset

; --- The --no-stub injection (see no_stub.py below) ---
extra_scripts = post:no_stub.py

; Decode panics in the monitor, and re-emit the reset when you open it
monitor_filters = esp32_exception_decoder, time
monitor_rts = 0
monitor_dtr = 0
```

`no_stub.py` (same directory as `platformio.ini`) — the `post:` prefix guarantees it runs **after** the platform builder has populated `UPLOADERFLAGS`, so the prepend survives:

```python
# no_stub.py — force esptool to skip the stub loader for this board.
# The stub upload fails on this unit with "Failed to write to target RAM
# (Checksum error)"; --no-stub talks directly to the ROM loader instead.
Import("env")

# --no-stub is a GLOBAL esptool option and must appear before the "write_flash"
# subcommand. Prepending puts it at the very front of UPLOADERFLAGS, ahead of
# --chip/--port/.../write_flash, which is a valid position.
flags = env.get("UPLOADERFLAGS", [])
if "--no-stub" not in flags:
    env.Prepend(UPLOADERFLAGS=["--no-stub"])

# Optional belt-and-suspenders: if you still see a RAM/checksum or timeout at the
# write step, also disable compressed transfer (some ROM loaders choke on it).
# Uncomment the next two lines to add --no-compress right after write_flash:
# if "-z" in env["UPLOADERFLAGS"]:
#     env["UPLOADERFLAGS"][env["UPLOADERFLAGS"].index("-z")] = "--no-compress"

print(">> no_stub.py: UPLOADERFLAGS = %s" % " ".join(env["UPLOADERFLAGS"]))
```

Build, upload, monitor:

```bash
# Build only
pio run -e waveshare_epd_esp32

# Build + flash (uses --no-stub via no_stub.py). Watch stdout: it should print
# ">> no_stub.py: UPLOADERFLAGS = --no-stub --chip esp32 --port ... write_flash -z ..."
pio run -e waveshare_epd_esp32 -t upload

# Open serial monitor
pio device monitor -e waveshare_epd_esp32
```

If `pio run -t upload` still stalls at "Connecting…", drop into the GPIO0 procedure in §3, or fall back to the manual esptool path in §2 (which lets you tweak baud/reset independently of the platform build).

---

### 2. esptool one-liners (erase + manual multi-binary flash)

Use these when you want to flash the artifacts PlatformIO already built in `.pio/build/waveshare_epd_esp32/`, or to erase. **On macOS always use `/dev/cu.*`, never `/dev/tty.*`** (the `tty.*` node blocks on carrier-detect and hangs esptool).

Confirm the port and chip first:

```bash
ls /dev/cu.usbmodem*
esptool --port /dev/cu.usbmodem59090511351 --before default_reset chip-id
```

**Erase entire flash** (do this before a fresh firmware if you suspect stale NVS/partition state):

```bash
esptool --chip esp32 --port /dev/cu.usbmodem59090511351 --baud 115200 --no-stub erase-flash
```

**Manual multi-binary flash** at the standard ESP32 (original, not S3/C3) Arduino offsets. `bootloader.bin`, `partitions.bin`, and `firmware.bin` are in the PlatformIO build dir; `boot_app0.bin` ships inside the Arduino framework package:

```bash
BUILD=.pio/build/waveshare_epd_esp32
BOOTAPP0=$HOME/.platformio/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin

esptool --chip esp32 --port /dev/cu.usbmodem59090511351 --baud 115200 \
  --before default_reset --after hard_reset --no-stub \
  write-flash --flash-mode dio --flash-freq 40m --flash-size 4MB \
  0x1000  "$BUILD/bootloader.bin" \
  0x8000  "$BUILD/partitions.bin" \
  0xe000  "$BOOTAPP0" \
  0x10000 "$BUILD/firmware.bin"
```

Offset map (ESP32-D0WD, 4 MB): `0x1000` bootloader, `0x8000` partition table, `0xe000` boot_app0 (OTA-select stub), `0x10000` application.

If the `write-flash` step throws a RAM/checksum or "Timed out waiting for packet" under `--no-stub`, add `--no-compress` right after `write-flash` and/or drop `--baud` to `74880`/`57600`.

**esptool 4.11.0 (the version PlatformIO bundles) equivalents** — underscore CLI, in case you invoke the bundled binary directly:

```bash
~/.platformio/packages/tool-esptoolpy/esptool.py \
  --chip esp32 --port /dev/cu.usbmodem59090511351 --baud 115200 --no-stub erase_flash

~/.platformio/packages/tool-esptoolpy/esptool.py \
  --chip esp32 --port /dev/cu.usbmodem59090511351 --baud 115200 \
  --before default_reset --after hard_reset --no-stub \
  write_flash --flash_mode dio --flash_freq 40m --flash_size 4MB \
  0x1000 "$BUILD/bootloader.bin" 0x8000 "$BUILD/partitions.bin" \
  0xe000 "$BOOTAPP0" 0x10000 "$BUILD/firmware.bin"
```

Read back the flash ID / detected size to sanity-check the 4 MB assumption:

```bash
esptool --port /dev/cu.usbmodem59090511351 --no-stub flash-id
```

---

### 3. Manual download-mode procedure (GPIO0 → GND)

The CH343 drives EN (reset) and GPIO0 through the auto-reset transistors, so `--before default_reset` normally enters the download ROM by itself. When it doesn't (esptool sits on "Connecting….\_\_\_\_"), force it manually:

1. Leave the USB cable connected (`/dev/cu.usbmodem59090511351` stays enumerated — this board's CDC is on the ESP32-side bridge, so it survives).
2. **Hold GPIO0 to GND** (jumper GPIO0 to any GND pin, or hold the BOOT/IO0 button if the board has one).
3. **While GPIO0 is held low, pulse EN/RST** — tap the reset button, or briefly bridge EN to GND and release. (If no buttons: momentarily unplug/replug USB while keeping GPIO0 grounded.)
4. **Release GPIO0.** The chip is now in serial download (ROM) mode.
5. Immediately run the flash/erase command. On success esptool prints `Chip is ESP32-D0WD-V3 (revision v3.1)` and `Uploading stub…` is **skipped** (because `--no-stub`), going straight to `Writing at 0x…`.
6. After flashing, `--after hard_reset` (or press EN) reboots into the app.

Note: KEY/user button is on **GPIO12**, which is *not* the boot strap — do not use it for download mode. GPIO0 is the boot strap. GPIO12 is also a flash-voltage strap on the die, so leave it alone during boot.

---

### 4. Serial monitor + healthy boot log

Open the monitor (either tool works):

```bash
pio device monitor -p /dev/cu.usbmodem59090511351 -b 115200 -f esp32_exception_decoder
# or, if you prefer raw esptool's sibling:
python3 -m serial.tools.miniterm /dev/cu.usbmodem59090511351 115200
```

Press EN/reset (or `Ctrl-T Ctrl-R` in miniterm) to re-trigger a boot after the monitor is attached.

**What a healthy boot looks like.** First the ESP32 second-stage ROM bootloader banner at 115200 (this is emitted before your firmware runs — its presence confirms the chip boots and the app image is valid):

```
rst:0x1 (POWERON_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0xee
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3fff0030,len:1184
load:0x40078000,len:13232
load:0x40080400,len:3028
entry 0x400805e4
```

- `rst:0x1 (POWERON_RESET)` on a fresh power-up; after `--after hard_reset` you may see `rst:0x7 (TG0WDT_SYS_RESET)`-style codes or `rst:0xc (SW_CPU_RESET)` — those are normal reset causes, not errors.
- `mode:DIO` and `clock div:2` should match your `--flash-mode dio --flash-freq 40m`. A mismatch here (e.g. `mode:QIO`) with a bad flash config is what produces a boot loop.

Then your firmware. For the esp32-weather-epd fork, `setup()` calls `Serial.begin(115200)` and the earliest app lines come from its localized `TXT_*` strings (from `platformio/src/main.cpp`), e.g. battery voltage then, at the end of the wake cycle, the awake/deep-sleep report:

```
Battery Voltage: 4102mv
... (WiFi connect, NTP, HTTP fetch, e-paper draw) ...
Awake for 12.acknowledged
Entering deep sleep for 1800s
```

(Exact wording depends on the `TXT_AWAKE_FOR` / `TXT_ENTERING_DEEP_SLEEP_FOR` locale strings; the numeric seconds and `mv` suffix are literal in `main.cpp`.)

**Bad signs / triage:**
- Continuous `rst:0x10 (RTCWDT_RTC_RESET)` loop → bad flash image or wrong offset; re-erase and re-flash (§2).
- Garbage/mojibake instead of the banner → monitor baud wrong (must be **115200**), or you left `/dev/tty.*` instead of `/dev/cu.*`.
- `invalid header: 0xffffffff` repeating → no valid app at `0x10000`; the firmware write didn't land.
- Monitor shows nothing at all but LED is on → the always-on power LED (~700 µA) is unrelated to boot; check that the app actually calls `Serial.begin(115200)` and that you're on the CDC port.

---

### Notes carried from the hardware/wiki grounding

- SPI pin remap is done **in firmware**, not the board profile: `BUSY=25, RST=26, DC=27, CS=15, SCK=13, MOSI=14` (non-default VSPI). CS=GPIO15 is a strapping pin. GPIO4 gates the panel 3.3 V rail. GPIO12 = user KEY. (Wiki: `concepts/hardware-platform.md`, `raw/data/2026-07-20-waveshare-driver-board-pinout.md`.) These do not affect flashing but the firmware `GxEPD2` constructor must set them or you'll flash successfully and see a blank/garbled panel.
- Panel class for the assumed 7.5" 800×480 mono is `GxEPD2_750_T7` (GDEW075T7) in GxEPD2 1.6.x — set in the firmware display selection, not here. (Wiki: `raw/repos/2026-07-20-gxepd2.md`.)
- This is a USB-powered desk build (battery out of scope), so the deep-sleep/LED power caveats in the wiki don't affect the flashing workflow.


---
## Risky claims flagged for verification

- **The `--no-stub` injection must go via a `post:` extra_scripts Python that Prepends to UPLOADERFLAGS; plain `upload_flags = --no-stub` in platformio.ini will NOT work because the platform's env.Replace(UPLOADERFLAGS=...) clobbers upload_flags and --no-stub is a global flag that must precede the write_flash subcommand.**
  - risk: If the Prepend timing or SCons ordering is wrong, the flag is silently dropped and PlatformIO still uploads the stub → the board keeps failing with the RAM checksum error and the user wastes cycles thinking they're on --no-stub. Verified against builder/main.py v6.13.0 source but the post-script ordering/prepend behavior should be confirmed by watching the printed UPLOADERFLAGS line on the real board.
- **Manual flash offsets for this ESP32-D0WD-V3 (original ESP32, 4MB) are bootloader=0x1000, partitions=0x8000, boot_app0=0xe000, app=0x10000.**
  - risk: These are the classic original-ESP32 Arduino offsets, but flashing at S3/C3 offsets (bootloader 0x0) or a wrong app offset produces an unbootable image / boot loop. If the partition scheme differs from huge_app.csv the partition-table offset assumptions could also shift.
- **Compressed transfer (`-z`, hardcoded by PlatformIO) works over the ESP32 ROM loader with --no-stub; only if it fails should you switch to --no-compress.**
  - risk: Some ROM loaders reject compressed writes without the stub. If the ESP32-D0WD-V3 ROM chokes on FLASH_DEFL under --no-stub, the write step fails and the user needs the commented-out --no-compress fallback. Not definitively confirmed for this exact silicon this session.
- **`--flash-size detect` / `--flash_size 4MB` and reset behavior via `board_upload.before_reset=default_reset` / `after_reset=hard_reset` will correctly auto-enter and exit download mode on the CH343 without manual GPIO0 grounding in the common case.**
  - risk: CH343 auto-reset wiring varies; if DTR/RTS aren't wired to EN/IO0 as assumed, every upload needs the manual GPIO0->GND procedure and the board knobs are moot. The stub-checksum quirk also suggests this unit has nonstandard timing.
- **PlatformIO espressif32 6.13.0 bundles esptool.py 4.11.0 (underscore CLI: write_flash/--flash_size), while a standalone 2026 `pip install esptool` gives 5.3.1 (hyphen CLI: write-flash/--flash-size, underscores deprecated-but-working).**
  - risk: If the user's standalone esptool is actually v4 or a v6 that removed the underscore aliases, the §2 one-liners in the wrong dialect will error out. Version numbers taken from release notes/PyPI this session but the user's local install may differ.
- **`board = esp32dev` with build_flags remapping SPI in firmware is the correct profile; the panel pins are NOT set by the board file.**
  - risk: If someone assumes esp32dev sets the Waveshare SPI pins, they'll flash fine but get a blank/garbled panel. Also esp32dev defaults could set a different flash size/mode than the explicit 4MB/dio/40m, causing a mode-mismatch boot loop if overrides are dropped.
