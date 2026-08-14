---
title: "Platform coupling and the DeviceHal seam"
category: concept
sources:
  - raw/articles/2026-08-10-frostsnap-devicehal-pr-513.md
  - raw/articles/2026-08-10-frostsnap-device-crate-platform-bindings.md
  - raw/articles/2026-08-10-embedded-rust-portability-limits.md
  - raw/notes/2026-08-10-frostsnap-multiboard-history-esp32s3.md
created: 2026-08-10
updated: 2026-08-10
tags: [frostsnap, esp-hal, devicehal, portability, embedded-rust, no-std, riscv32imc, rgb565]
aliases: ["DeviceHal", "frostsnap-embedded-lift", "platform coupling"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "Frostsnap's firmware is being deliberately refactored so that the portable run loop only sees traits, never esp_hal — PR #513 lifts it behind a six-associated-type DeviceHal (Storage/Upstream/Downstream/Rng/Secrets/Firmware). That seam is real and reduces the port surface, but it is open not merged, and it relocates work rather than removing it: each associated type still needs a full concrete implementation per platform. Measured coupling in the current tree is 110 esp_* occurrences on 104 lines across 20 of 32 device files, 86 of them esp_hal:: paths concentrated in hmac (28) and sha (10). The naive workspace share is 7.9%, but that undercounts roughly threefold because 58% of device/ lines are architecture-specific end-to-end and 45 of 80 frostsnap_widgets files reference Rgb565 across 318 occurrences. Honest estimate for a cross-vendor port: 15,000-20,000 lines touched."
---

# Platform coupling and the DeviceHal seam

The single most important structural fact about Frostsnap's firmware portability is that the project is
actively building a portability seam — and that the seam does not yet exist in a merged form.

## The seam: `DeviceHal`

PR #513, branch `frostsnap-embedded-lift` (head `102efb5cb10b`), **open, not merged**, lifts the device
run loop out of ESP-specific code and behind one trait:

```rust
type Storage:    NorFlash + ReadNorFlash
type Upstream:   SerialPort
type Downstream: SerialPort
type Rng:        RngCore + CryptoRng
type Secrets:    DeviceSecretDerivation
type Firmware:   FirmwareServices
```

The module doc states the intent plainly: *"the portable run-loop only ever sees these traits — never
`esp_hal`."* The diffstat shows the direction of travel — `esp32_run.rs` −766, `ui.rs` −159,
`touch_handler.rs` −67 deleted, against `frostsnap_embedded/src/device_loop.rs` +1,196,
`framed_serial.rs` +218 — with ESP remnants isolated into `esp_ui.rs` (+85) and `firmware.rs` (+149).

**Why this matters, and why it is not a solution.** A port with this seam merged implements six traits
instead of rewriting a run loop. But every one of those associated types is a real subsystem:
`Secrets` is the whole key-custody design, `Firmware` is secure-boot verification and OTA, `Storage`
is a flash driver. The trait boundary tells you *where* the work is; it does not make the work small.

## Measured coupling in the current tree

| Measure | Value |
|---------|-------|
| `esp_*` occurrences | **110** on 104 lines, across **20 of 32** `device/` files |
| `esp_hal::` paths | **86** — hmac 28, sha 10, timer 8, uart 4, reset 4, efuse 4, rsa 2, gpio 2, spi 1, `Trng` 1, DS 1 |
| `device/` size | 5,949 lines (+ `cst816s/` 330) |
| Workspace | 270 files, 79,282 lines |
| **Naive ESP share** | **7.9%** |

The build itself is pinned to the platform. `device/.cargo/config.toml`:

```toml
target = "riscv32imc-unknown-none-elf"
rustflags = ["-C", "link-arg=-Tlinkall.x"]
build-std = ["alloc", "core"]
panic = "abort"
```

`linkall.x` is Espressif's linker script; `esp-hal` itself is pinned to a **private fork**
(`github.com/frostsnap/esp-hal`, rev `6ecaa2eb`). A port begins from a fork, not a release.

## Why 7.9% is the wrong number

Three corrections, all pushing the same direction:

1. **58% of `device/` lines are architecture-specific end-to-end** — not a sprinkling of `esp_hal::`
   calls but whole files whose reason for existing is the chip: `efuse.rs`, `ds.rs`, `esp32_run.rs`,
   `secure_boot.rs`, `partitions.rs`, `flash.rs`, `ota.rs`, `uart_interrupt.rs`, `stack_guard.rs`,
   `firmware_size.rs`.
2. **The widget tree assumes color.** **45 of 80 `frostsnap_widgets` files reference `Rgb565`** — 318
   occurrences. `frostsnap_fonts` generates Gray4 4-bit anti-aliased glyphs. Against a 128×64
   **1-bit mono** target, that is not a driver swap; it is a rendering-model change.
3. **Peripheral bring-up is bespoke.** ST7789 240×280 over SPI2 at 80 MHz, CST816S over I2C0 at
   400 kHz, UART1 upstream on GPIO18/19, UART0 downstream on GPIO21/20, presence detect on
   GPIO0/GPIO10, `Trng::new(RNG, ADC1)`, `ASSIST_DEBUG` stack guard. And a protocol constant tuned to
   silicon: `frostsnap_comms` `BAUDRATE = 19_200`, chosen around an ESP32-C3 flash-erase interrupt
   erratum (~30 ms blocking).

**Honest estimate for a cross-vendor port: 15,000–20,000 lines touched.**

## What genuinely is portable

The crypto and protocol core. `frostsnap_core`, `schnorr_fun`, `secp256kfun` are `#![no_std]` with no
C dependency, and `mipidsi`/`embedded-graphics` drivers depend only on `embedded-hal ^1.0`. See
[Embedded Rust portability limits](../references/embedded-rust-portability-matrix.md) for what that
does and does not buy — including the fact that FROST requires the `alloc` feature, so a port must
supply a global allocator.

## Calibration from Frostsnap's own history

- **PR #457, "[device] Port to esp-hal v1.1.0": 40 files, +3,055/−2,731.** That is a *minor version
  bump inside the same HAL*.
- The `origin/esp32s3` branch — a genuine cross-ISA move (RISC-V → Xtensa) — is **27 files,
  +1,579/−570**, roughly 2 engineers × 3 weeks. Cheap, but it stayed inside Espressif on `esp-hal`
  behind a chip feature flag.

The maintainer's own verdict on the multi-board arrangement, from commit `91cdb937`: *"Not really happy
with this since they have different dependencies and so should be different crates."*

## See Also

- [Root-of-trust portability](root-of-trust-portability.md)
- [Porting Frostsnap to other hardware](../topics/porting-frostsnap-to-other-hardware.md)
- [Embedded Rust portability matrix](../references/embedded-rust-portability-matrix.md)
- [Thesis: Frostsnap firmware on Coldcard Mk4](../theses/frostsnap-firmware-on-coldcard-mk4.md)
