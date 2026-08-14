---
title: "Frostsnap device crate — platform bindings and non-portable surface"
source: "https://github.com/frostsnap/frostsnap/tree/master/device"
type: articles
ingested: 2026-08-10
tags: [frostsnap, esp32c3, riscv32imc, esp-hal, peripherals, st7789, cst816s, uart-daisy-chain, efuse, digital-signature-peripheral, porting]
summary: "Primary-source audit of what welds Frostsnap firmware to ESP32-C3 silicon. Build target is hardcoded in device/.cargo/config.toml as riscv32imc-unknown-none-elf with rustflags -C link-arg=-Tlinkall.x (the esp-hal linker script) and build-std = [alloc, core], panic = abort. Dependencies include esp-hal pinned to a private Frostsnap fork (git = https://github.com/frostsnap/esp-hal, rev 6ecaa2eb), plus esp-alloc, esp-storage (esp32c3, bytewise-read), esp-partition-table. Display is an ST7789 driven via mipidsi with display_size(240,280), display_offset(0,20), ColorInversion::Inverted, on SPI2 at 80 MHz Mode2 (SCK=GPIO8, MOSI=GPIO7, DC=GPIO9, RST=GPIO6); backlight on LEDC PWM GPIO1 at 24 kHz 10-bit. Input is a CST816S capacitive touch controller on I2C0 at 400 kHz (SDA=GPIO4, SCL=GPIO5), interrupt-driven on GPIO2/GPIO3. Inter-device transport is a UART daisy chain: UART1 upstream (GPIO18/19), UART0 downstream (GPIO21/20), presence detect active-low on GPIO0/GPIO10, with UsbSerialJtag as alternate upstream. frostsnap_comms sets BAUDRATE = 19_200 with the comment that the esp32c3 freezes interrupts during flash erase cycles sometimes ~30ms. Crypto peripherals used directly: Sha, Hmac, DS (digital signature), RSA, EFUSE, Trng::new(RNG, ADC1). Exact esp_* call-site counts in device/src: 110 token occurrences on 104 lines across 20 of 32 files; 86 fully-qualified esp_hal:: paths, of which hmac accounts for 28 (KeyId 18), sha 10, timer 8, uart 4, reset::software_reset 4, efuse 4, rsa 2, gpio 2, spi 1, rng::Trng 1, peripherals::DS 1. device/ is 32 .rs files / 5,949 lines; cst816s/ is 1 file / 330 lines; workspace total is 270 .rs files / 79,282 lines, so the two chip-bound crates are 7.9 percent of workspace Rust. The workspace root Cargo.toml excludes device and cst816s from default-members with the comment 'device, cst816s require riscv32'."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: primary-source-code
direction: opposes
credibility: high
confidence: high
authors: [frostsnap contributors]
fetched: 2026-08-10
---

# Frostsnap device crate — platform bindings

## Build target and toolchain

```toml
# device/.cargo/config.toml
target = "riscv32imc-unknown-none-elf"
rustflags = ["-C", "link-arg=-Tlinkall.x"]   # esp-hal linker script
build-std = ["alloc", "core"]
panic = "abort"
```

`esp-hal` is pinned to a **private Frostsnap fork** — `git = "https://github.com/frostsnap/esp-hal",
rev = 6ecaa2eb…` — alongside `esp-alloc`, `esp-storage` (features `esp32c3`, `bytewise-read`) and
`esp-partition-table`. `esp-hal` upstream supports only Espressif parts (ESP32/C2/C3/C5/C6/C61/H2/
P4/S2/S3): no ARM, no STM32.

## Peripheral bindings

| Function | Binding |
|----------|---------|
| Display | ST7789 via `mipidsi`, 240×280, offset (0,20), inverted; SPI2 @ 80 MHz Mode2 — SCK=GPIO8, MOSI=GPIO7, DC=GPIO9, RST=GPIO6 |
| Backlight | LEDC PWM GPIO1, 24 kHz, 10-bit, `start_duty_fade(0,100,500)` |
| Touch | CST816S on I2C0 @ 400 kHz — SDA=GPIO4, SCL=GPIO5; interrupts GPIO2/GPIO3 |
| Upstream link | UART1, GPIO18/19; presence detect GPIO0 (pull-up, active-low) |
| Downstream link | UART0, GPIO21/20; presence detect GPIO10 |
| Alt upstream | `UsbSerialJtag` |
| Crypto | `Sha`, `Hmac`, `DS`, `RSA`, `EFUSE`, `Trng::new(RNG, ADC1)` |
| Stack guard | ESP32-C3 `ASSIST_DEBUG` peripheral (default feature) |

`frostsnap_comms` sets `BAUDRATE = 19_200`, chosen because "esp32c3 freezes interrupts during flash
erase cycles somtimes ~30ms" — the wire speed is tuned to an ESP32-C3 erratum.

## The non-portable surface, counted

Method: `git clone --depth 1` at master, then `find`/`wc -l`/`grep -oE` over the tree.

- **110** `esp_*` token occurrences on **104** lines across **20 of 32** files in `device/src`
- **86** fully-qualified `esp_hal::` paths — `hmac` 28 (of which `KeyId` 18), `sha` 10, `timer` 8,
  `uart` 4, `reset::software_reset` 4, `efuse` 4, `rsa` 2, `gpio` 2, `spi` 1, `rng::Trng` 1,
  `peripherals::DS` 1
- **29** distinct `use esp*` statements
- `device/` = 32 files / **5,949 lines**; `cst816s/` = 1 file / **330 lines**
- Workspace = 270 `.rs` files / **79,282 lines** → the two chip-bound crates are **7.9%**

The workspace root `Cargo.toml` excludes `device` and `cst816s` from `default-members` with the
comment `# device, cst816s require riscv32`.

## Why the 7.9% figure understates the work

**Concentration.** Roughly 3,474 of 5,949 device lines (58%) sit in files that are ESP-architecture-
specific end to end, not merely ESP-API-calling: `esp32_run.rs` 787, `efuse.rs` 546, `ota.rs` 459,
`secure_boot.rs` 359, `firmware_size.rs` 319, `peripherals.rs` 317, `uart_interrupt.rs` 221,
`partitions.rs` 139, `ds.rs` 119. `firmware_size.rs` exists solely to parse the ESP image format.
These are rewrites, not mechanical substitutions.

**Display coupling lives outside the counted crates.** In `frostsnap_widgets/src`, **45 of 80 files**
reference `Rgb565` (**318 occurrences**) and 18 reference `Gray4`; `DefaultTextStyle = Gray4TextStyle`.
Six hardcoded 240/280 dimension constants appear in widget source (e.g. `const FRAMEBUFFER_WIDTH:
u32 = 240;` in `backup/alphabetic_keyboard.rs`). The backup quiz flow sets `TOTAL_SCREENS = 26` for
a 240×280 canvas.

So an honest port estimate is `device/` (5,949) plus a substantial fraction of `frostsnap_widgets`
(20,435) — **roughly 15,000–20,000 lines touched, not 6,279**. The `esp_*` grep undercounts by ~3×.

## Storage layout

`device/partitions.csv`: `ota_0` and `ota_1` at **1724K each** (offsets `0x20000`, `0x1d0000`),
`nvs` 512K at `0x37f000`, `factory_cert` 16K, `otadata` 8K — total ≈ **8 MB flash**, implying an
ESP32-C3FH8X. Heap: `esp_alloc::heap_allocator!(256 * 1024)`, `CpuClock::max()` (160 MHz).

## See Also

- [PR #513 — DeviceHal trait lift](2026-08-10-frostsnap-devicehal-pr-513.md)
- [Flash and resource fit audit](../data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md)
- [Device Firmware Build (device crate)](2026-08-10-frostsnap-device-firmware-readme.md)
