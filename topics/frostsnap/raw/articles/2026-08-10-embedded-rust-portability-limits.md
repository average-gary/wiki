---
title: "Embedded Rust portability — what no_std does and does not buy you"
source: "https://docs.rust-embedded.org/book/portability/index.html"
type: articles
ingested: 2026-08-10
tags: [embedded-rust, no-std, portability, embedded-hal, embassy, stm32l4s5, cortex-m, riscv, linker-scripts, allocator, ci-targets]
summary: "Ecosystem-level assessment of how far Rust's no_std portability actually carries an MCU port. The Rust Embedded Book's portability chapter states that embedded-hal traits make drivers portable, but the HAL implementation and the application/init layer must be rewritten per chip, with the app binding requiring 'the most adaptation efforts' because peripheral initialization 'differs, sometimes drastically so.' embedded-hal 1.0.0 released 2024-01-09 and its announcement states that generically-written drivers 'work on any microcontroller with an embedded-hal implementation without modifying them', with stable traits and no plans for a 2.0. Both endpoints implement it: Frostsnap's workspace pins embedded-hal 1.0 and device/ uses embedded-hal-nb and embedded-hal-bus; embassy-stm32 pulls embedded-hal 1.0 plus embedded-hal-async 1.0, as does esp-hal 1.1.x. Frostsnap's display driver is already portable in principle - it uses mipidsi with models::ST7789, and mipidsi depends only on embedded-hal ^1.0 plus embedded-graphics-core, so only the SPI bus handle is ESP-typed. A concrete single-crate-both-vendors proof exists: ssd1306 0.10.0 with the async feature runs on both esp-hal and embassy-stm32 over embedded-hal-async 1.0. On the destination side, the Coldcard Mk4 MCU is confirmed as STM32L4S5VI from Coinkite's own build files (stm32/COLDCARD_MK4/mpconfigboard.mk has CMSIS_MCU = STM32L4S5xx and AF_FILE = boards/COLDCARD_MK4/stm32l4s5_af.csv; mpconfigboard.h has MICROPY_HW_MCU_NAME 'STM32L4SxVI'), and embassy-stm32 has 139 STM32L4 chip features including an exact stm32l4s5vi - not a subfamily approximation. From embassy's stm32-data, STM32L4S5VI is cm4 with 2 MB flash (single-bank or 2x1 MB dual-bank) and 640 KB SRAM (655,360 bytes), with RNG, AES, HASH, USB_OTG_FS, SPI1, I2C1 and OCTOSPI1 all present, and flash geometry erase_size 4096 / write_size 8 making an embedded-storage NorFlash impl mechanical. Embassy ships in-tree examples/stm32l4 built for stm32l4r5zi, an L4+ sibling sharing rcc/l.rs, including async Rng::new(p.RNG, Irqs) with rng.async_fill_bytes().await; target thumbv7em-none-eabi(hf). By contrast stm32l4xx-hal is a dead end: last release 2022-04-11, embedded-hal 0.2 only, and no stm32l4s5 feature. Where the portability intuition breaks, concretely: esp-hal supports only Espressif parts (ESP32/C2/C3/C5/C6/C61/H2/P4/S2/S3) with no ARM or STM32; Frostsnap pins esp-hal to a private fork (git = https://github.com/frostsnap/esp-hal, rev 6ecaa2eb); the build needs linkall.x, build-std = [alloc, core] and panic = abort; and even frostsnap_widgets carries [target.'cfg(target_arch = 'riscv32')'.dependencies] esp-alloc. Crate-level verification of the steelman claim that the crypto compiles for thumbv7em: secp256kfun, schnorr_fun and frostsnap_core are all genuinely #![no_std] with no C or libsecp256k1 dependency in the default path (pure-Rust digest, subtle-ng, rand_core), and Frostsnap already compiles the stack for a bare-metal -none-elf target today, so ARM should hold - but docs.rs builds only x86_64-unknown-linux-gnu for both crypto crates, and the upstream secp256kfun CI matrix is x86_64-unknown-linux-gnu plus armv7-unknown-linux-gnueabihf, where the ARM entry is hosted Linux with std run under cross, giving zero thumbv*-none-* CI coverage. FROST specifically requires alloc: schnorr_fun/src/lib.rs gates it as #[cfg(feature = 'alloc')] pub mod frost;, and frostsnap_core pulls schnorr_fun with features bincode, serde, alloc, share_backup, libsecp_compat_0_29, vrf_cert_keygen - so a port must supply a global allocator (embedded-alloc on Cortex-M, standing in for esp-alloc). Prior art that FROST runs on this exact core family: PoneBiometrics/JavGar_master demonstrates FROST 2-of-3 on an STM32 Nucleo-L476RG (Cortex-M4) in C with Zephyr over UART - so FROST on a Cortex-M4 is a solved feasibility question on an open board. Calibration datapoint on HAL churn cost from Frostsnap's own history: PR #457 '[device] Port to esp-hal v1.1.0' is 40 files, +3055/-2731 for a minor-version bump within the same HAL family. Also noted: esp-hal-embassy is deprecated in favor of esp-rtos 0.3.0, so the ESP-side Embassy story is churning. No published ESP-HAL to embassy-STM32 port retrospective exists."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: official-docs
direction: nuances
credibility: high
confidence: high
fetched: 2026-08-10
---

# Embedded Rust portability — what `no_std` does and does not buy

## The canonical statement of the limit

The Rust Embedded Book's portability chapter: `embedded-hal` traits make **drivers** portable, but the
**HAL implementation** and the **application/init layer** must be rewritten per chip — the app binding
"requires the most adaptation efforts" since peripheral initialization "differs, sometimes drastically
so."

`no_std` removes the **OS**, not the **chip**.

## What genuinely is portable

`embedded-hal` **1.0.0** shipped 2024-01-09. Announcement, verbatim: drivers written generically "work
on any microcontroller with an `embedded-hal` implementation **without modifying them**." Traits are
stable; "there are no plans for a 2.0 release."

Both endpoints implement it. Frostsnap's workspace pins `embedded-hal = "1.0"` and `device/` uses
`embedded-hal-nb`, `embedded-hal-bus`. `embassy-stm32` pulls `embedded-hal 1.0` +
`embedded-hal-async 1.0`; `esp-hal 1.1.x` likewise.

Frostsnap's **display driver is already portable in principle**: `mipidsi` with `models::ST7789`
depends only on `embedded-hal ^1.0` + `embedded-graphics-core`. Only the SPI bus handle is ESP-typed.
Concrete single-crate-both-vendors proof: **`ssd1306` 0.10.0** with the `async` feature runs on
`esp-hal` (ESP32) *and* `embassy-stm32`, over `embedded-hal-async 1.0`.

## The destination MCU is a first-class Rust target

Coldcard Mk4's MCU is confirmed **STM32L4S5VI** from Coinkite's own build files —
`stm32/COLDCARD_MK4/mpconfigboard.mk`: `CMSIS_MCU = STM32L4S5xx`, `AF_FILE =
boards/COLDCARD_MK4/stm32l4s5_af.csv`; `mpconfigboard.h`: `MICROPY_HW_MCU_NAME "STM32L4SxVI"`.

`embassy-stm32` has **139 STM32L4 chip features including an exact `stm32l4s5vi`** (plus
`stm32l4s5ai/qi/zi`) — the precise part, not a subfamily approximation. From embassy's stm32-data:

| Property | Value |
|----------|-------|
| Core | `cm4` (Cortex-M4) |
| Flash | 2 MB (single-bank, or 2×1 MB dual-bank) |
| SRAM | 640 KB (655,360 bytes) |
| Peripherals | `RNG`, `AES`, `HASH`, `USB_OTG_FS`, `SPI1`, `I2C1`, `OCTOSPI1` all `True` |
| Flash geometry | `erase_size: 4096`, `write_size: 8` |

So a hardware TRNG (to seed `ChaCha20Rng`), hash acceleration, USB transport, and the SPI/I2C buses
for display+touch all exist, and the `embedded-storage` `NorFlash` impl is mechanical.

Embassy ships in-tree `examples/stm32l4` for `stm32l4r5zi` (an L4+ sibling sharing `rcc/l.rs`),
including async `Rng::new(p.RNG, Irqs)` + `rng.async_fill_bytes().await`. Target:
`thumbv7em-none-eabi(hf)`.

By contrast `stm32l4xx-hal` is a **dead end** — last release 2022-04-11, `embedded-hal` 0.2 only, no
`stm32l4s5` feature.

## Where the portability intuition breaks

- **`esp-hal` supports only Espressif parts** (ESP32/C2/C3/C5/C6/C61/H2/P4/S2/S3). No ARM, no STM32.
- Frostsnap pins `esp-hal` to a **private fork**: `git = "https://github.com/frostsnap/esp-hal",
  rev = 6ecaa2eb…`. A port starts from a fork, not a release.
- The build needs `linkall.x`, `build-std = ["alloc","core"]`, `panic = "abort"` — linker script,
  vector table and runtime crate (`riscv-rt` vs `cortex-m-rt`) all swap.
- Even `frostsnap_widgets` carries `[target.'cfg(target_arch = "riscv32")'.dependencies] esp-alloc`,
  though gated on **architecture** rather than chip and commented "Only needed for memory debug on
  ESP32" — it would simply not apply on `thumbv7em`.
- Chip-specific-by-name device files that are rewrites, not substitutions: `efuse.rs`, `ds.rs`,
  `esp32_run.rs`, `secure_boot.rs`, `partitions.rs`, `flash.rs`, `ota.rs`, `uart_interrupt.rs`,
  `stack_guard.rs`, `firmware_size.rs`.

## Verifying the steelman: does the crypto compile for `thumbv7em`?

**Likely yes, but not CI-verified.** `secp256kfun`, `schnorr_fun` and `frostsnap_core` are all
genuinely `#![no_std]`, with no C or `libsecp256k1` dependency in the default path (pure-Rust
`digest`, `subtle-ng`, `rand_core`). The decisive argument: Frostsnap **already compiles this exact
stack for a bare-metal `-none-elf` target today** (riscv32imc), so essentially no host-OS assumptions
remain to trip on ARM.

Caveats:

- **docs.rs builds only `x86_64-unknown-linux-gnu`** for both crypto crates — no ARM, no thumb.
- The upstream `secp256kfun` CI matrix is `x86_64-unknown-linux-gnu` + `armv7-unknown-linux-gnueabihf`,
  where the ARM entry is **hosted Linux with std, run under `cross`** — **zero `thumbv*-none-*`
  coverage**. `test-minimal`/`test-alloc` prove `--no-default-features` and `alloc`-only configs work,
  but only on x86_64.
- **FROST requires `alloc`**: `schnorr_fun/src/lib.rs` gates it `#[cfg(feature = "alloc")] pub mod
  frost;`, and `frostsnap_core` pulls `schnorr_fun` with `features = ["bincode","serde","alloc",
  "share_backup","libsecp_compat_0_29","vrf_cert_keygen"]`. A port must supply a **global allocator**
  (`embedded-alloc` on Cortex-M, standing in for `esp-alloc`). Routine, but a real step — and it means
  "pure no_std, no heap" is false.

## Prior art: FROST already runs on this exact core family

`PoneBiometrics/JavGar_master` demonstrates **FROST 2-of-3 on an STM32 Nucleo-L476RG (Cortex-M4)** —
same core family as the Mk4's L4S5 — in C with Zephyr RTOS over UART. FROST on a Cortex-M4 is a solved
feasibility question **on an open board**. No published performance or memory figures.

## Calibration on HAL churn cost

From Frostsnap's own history: PR #457 "[device] Port to esp-hal v1.1.0" is **40 files, +3,055/−2,731**
— and that is a *minor-version bump within the same HAL family*. Useful as a floor estimate.

Also noted: `esp-hal-embassy` is deprecated in favor of `esp-rtos 0.3.0`, so the ESP-side Embassy
story is churning. **No published ESP-HAL → embassy-STM32 port retrospective exists.**

## See Also

- [Device crate platform bindings](2026-08-10-frostsnap-device-crate-platform-bindings.md)
- [PR #513 — DeviceHal trait lift](2026-08-10-frostsnap-devicehal-pr-513.md)
- [Resource-fit audit](../data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md)
