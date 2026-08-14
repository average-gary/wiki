---
title: "Embedded Rust portability matrix"
category: reference
sources:
  - raw/articles/2026-08-10-embedded-rust-portability-limits.md
  - raw/articles/2026-08-10-frostsnap-device-crate-platform-bindings.md
  - raw/data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md
created: 2026-08-10
updated: 2026-08-10
tags: [embedded-rust, embedded-hal, embassy, esp-hal, stm32l4s5, thumbv7em, riscv32imc, alloc, ci-targets, mipidsi]
aliases: ["embedded-hal 1.0", "embassy-stm32 stm32l4s5vi", "thumbv7em-none-eabihf"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "Layer-by-layer reference for which parts of a no_std Rust firmware survive a change of MCU vendor. Portable: embedded-hal 1.0.0 (released 2024-01-09, stable, no 2.0 planned) drivers, including mipidsi/ST7789 which depends only on embedded-hal ^1.0 plus embedded-graphics-core; ssd1306 0.10.0 is a proven single-crate-both-vendors case running on esp-hal and embassy-stm32 over embedded-hal-async. Not portable: the HAL implementation and the application/init layer, which the Rust Embedded Book says 'requires the most adaptation efforts' because peripheral initialization 'differs, sometimes drastically so'. Target-side facts for the Coldcard MCU: confirmed STM32L4S5VI from Coinkite's own build files, and embassy-stm32 carries an exact stm32l4s5vi feature among 139 STM32L4 features — cm4, 2 MB flash, 640 KB SRAM, RNG/AES/HASH/USB_OTG_FS/SPI1/I2C1/OCTOSPI1 present, erase_size 4096 / write_size 8. stm32l4xx-hal by contrast is dead (last release 2022-04-11, embedded-hal 0.2 only, no stm32l4s5 feature). Crypto-crate caveat: secp256kfun, schnorr_fun and frostsnap_core are genuinely no_std with no C dependency and already build for bare-metal riscv32imc, but docs.rs builds x86_64 only and upstream CI's ARM entry is hosted armv7-unknown-linux-gnueabihf under cross, giving zero thumbv*-none-* coverage; FROST also requires the alloc feature, so a global allocator is mandatory."
---

# Embedded Rust portability matrix

## The canonical limit

The Rust Embedded Book's portability chapter: `embedded-hal` traits make **drivers** portable, but the
**HAL implementation** and the **application/init layer** must be rewritten per chip — the app binding
"requires the most adaptation efforts" since peripheral initialization "differs, sometimes drastically
so."

**`no_std` removes the OS, not the chip.**

## Layer by layer

| Layer | Portable? | Notes |
|-------|-----------|-------|
| FROST/crypto (`frostsnap_core`, `schnorr_fun`, `secp256kfun`) | ✅ with `alloc` | `#![no_std]`, no C dependency; needs a global allocator |
| Protocol (`frostsnap_comms`) | ✅ mostly | but `BAUDRATE = 19_200` is tuned to an ESP32-C3 flash-erase erratum |
| Widgets (`frostsnap_widgets`) | ⚠️ colour-coupled | 45 of 80 files reference `Rgb565` (318 occurrences); `frostsnap_fonts` emits Gray4 |
| Display driver (`mipidsi` / ST7789) | ✅ | depends only on `embedded-hal ^1.0` + `embedded-graphics-core`; only the SPI handle is ESP-typed |
| Touch driver (`cst816s`) | ✅ interface, ⚠️ interrupts | `no_std`, but ESP32-C3 interrupt wiring is chip-specific |
| HAL (`esp-hal`) | ❌ | Espressif parts only; Frostsnap pins a **private fork** (`frostsnap/esp-hal`, rev `6ecaa2eb`) |
| Runtime / linker | ❌ | `riscv-rt` + `linkall.x` → `cortex-m-rt` + a written-from-scratch script |
| Allocator | ❌ | `esp-alloc` → `embedded-alloc` |
| Secure boot / eFuse / DS / OTA / partitions | ❌ | chip-specific by definition — see [Root-of-trust portability](../concepts/root-of-trust-portability.md) |

## What is genuinely portable, with proof

`embedded-hal` **1.0.0** shipped 2024-01-09. Announcement, verbatim: generically-written drivers "work on
any microcontroller with an `embedded-hal` implementation **without modifying them**." Traits are stable;
"there are no plans for a 2.0 release."

Both endpoints implement it — Frostsnap's workspace pins `embedded-hal = "1.0"` (plus
`embedded-hal-nb`, `embedded-hal-bus`); `embassy-stm32` and `esp-hal 1.1.x` both pull `embedded-hal 1.0`
+ `embedded-hal-async 1.0`.

Existence proof of a single driver crate serving both vendors: **`ssd1306` 0.10.0** with the `async`
feature runs on `esp-hal` (ESP32) *and* `embassy-stm32`, over `embedded-hal-async 1.0`.

## The destination MCU is a first-class Rust target

Confirmed from Coinkite's own build files — `stm32/COLDCARD_MK4/mpconfigboard.mk`:
`CMSIS_MCU = STM32L4S5xx`, `AF_FILE = boards/COLDCARD_MK4/stm32l4s5_af.csv`; `mpconfigboard.h`:
`MICROPY_HW_MCU_NAME "STM32L4SxVI"`.

`embassy-stm32` has **139 STM32L4 chip features including an exact `stm32l4s5vi`** (plus
`stm32l4s5ai/qi/zi`) — the precise part, not a subfamily approximation. From embassy's `stm32-data`:

| Property | Value |
|----------|-------|
| Core | `cm4` (Cortex-M4) |
| Flash | 2 MB (single-bank or 2×1 MB dual-bank) |
| SRAM | 640 KB (655,360 bytes) |
| Peripherals | `RNG`, `AES`, `HASH`, `USB_OTG_FS`, `SPI1`, `I2C1`, `OCTOSPI1` — all present |
| Flash geometry | `erase_size: 4096`, `write_size: 8` |
| Absent | `PKA`, `CRYP`, `OTFDEC` |

So a hardware TRNG (to seed `ChaCha20Rng`), hash/HMAC acceleration, USB transport and the SPI/I2C buses
all exist, and an `embedded-storage` `NorFlash` impl is mechanical. Embassy ships in-tree
`examples/stm32l4` for `stm32l4r5zi` (an L4+ sibling sharing `rcc/l.rs`), including async
`Rng::new(p.RNG, Irqs)` + `rng.async_fill_bytes().await`, targeting `thumbv7em-none-eabi(hf)`.

**Use `embassy-stm32`, not `stm32l4xx-hal`** — the latter is a dead end: last release 2022-04-11,
`embedded-hal` 0.2 only, no `stm32l4s5` feature.

## The crypto-crate caveat

Does the FROST stack compile for `thumbv7em-none-eabihf`? **Probably yes; not verified anywhere.**

For: `secp256kfun`, `schnorr_fun`, `frostsnap_core` are all `#![no_std]` with no C or `libsecp256k1`
dependency in the default path (pure-Rust `digest`, `subtle-ng`, `rand_core`) — and Frostsnap already
builds this exact stack for a bare-metal `-none-elf` target (`riscv32imc`), so almost no host-OS
assumptions remain to break on ARM.

Against:

- **docs.rs builds only `x86_64-unknown-linux-gnu`** for both crypto crates.
- Upstream `secp256kfun` CI is `x86_64-unknown-linux-gnu` + `armv7-unknown-linux-gnueabihf`, where the
  ARM entry is **hosted Linux with `std`, run under `cross`** — **zero `thumbv*-none-*` coverage**.
  `test-minimal`/`test-alloc` prove `--no-default-features` and `alloc`-only configs work, but on
  x86_64 only.
- **FROST requires `alloc`**: `schnorr_fun/src/lib.rs` gates it `#[cfg(feature = "alloc")] pub mod
  frost;`, and `frostsnap_core` pulls `schnorr_fun` with `features = ["bincode","serde","alloc",
  "share_backup","libsecp_compat_0_29","vrf_cert_keygen"]`. A global allocator is **mandatory** —
  "pure `no_std`, no heap" is false for this stack.

## Prior art: FROST on this core family

`PoneBiometrics/JavGar_master` runs **FROST 2-of-3 on an STM32 Nucleo-L476RG (Cortex-M4)** — same core
family as the Mk4's L4S5 — in C under Zephyr, over UART. FROST on a Cortex-M4 is a solved feasibility
question on an open board. No published performance or memory figures.

## Churn calibration

Frostsnap PR #457 "[device] Port to esp-hal v1.1.0": **40 files, +3,055/−2,731** — for a *minor version
bump inside the same HAL family*. Useful as a floor.

Ecosystem churn note: `esp-hal-embassy` is deprecated in favour of `esp-rtos 0.3.0`. **No published
ESP-HAL → embassy-STM32 port retrospective exists.**

## See Also

- [Platform coupling and the DeviceHal seam](../concepts/platform-coupling-and-the-devicehal-seam.md)
- [Frostsnap-on-Mk4 resource budget](frostsnap-on-mk4-resource-budget.md)
- [Porting Frostsnap to other hardware](../topics/porting-frostsnap-to-other-hardware.md)
