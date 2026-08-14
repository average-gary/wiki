# references Index

> Compiled references articles for frostsnap.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [wallet-firmware-port-outcomes.md](wallet-firmware-port-outcomes.md) | Reference class of every documented hardware-wallet MCU port with dated outcomes and diffstats — Jade ~10.5mo, Trezor F4→U5 ~7mo, Trezor→Model One abandoned after 6 years, Krux unstarted after 4, SeedSigner emulator-only. Establishes new board ≈200 LOC vs new chip ≈20,000 lines. | reference-class-forecasting, trezor, jade, krux, porting-cost | 2026-08-10 |
| [embedded-rust-portability-matrix.md](embedded-rust-portability-matrix.md) | Layer-by-layer table of what survives an MCU vendor change in `no_std` Rust: `embedded-hal` 1.0 drivers portable, HAL/runtime/linker/allocator not. Includes the exact `stm32l4s5vi` embassy feature, the zero `thumbv*-none-*` CI gap for the crypto crates, and FROST's `alloc` requirement. | embedded-rust, embedded-hal, embassy, stm32l4s5, thumbv7em, alloc | 2026-08-10 |
| [frostsnap-on-mk4-resource-budget.md](frostsnap-on-mk4-resource-budget.md) | Byte-level flash and RAM accounting: the firmware fits (1,419,688 vs 1392K after stripping 55,948 bytes of ESP MMU padding), fonts are only 4.7%, the OTA partition layout is what actually doesn't fit, and RAM favours Mk4 at 632 KiB vs 313 KiB. | flash-budget, esp-image-format, ota, psram, sram, resource-fit | 2026-08-10 |

## Categories

- **porting-cost**: wallet-firmware-port-outcomes.md, embedded-rust-portability-matrix.md
- **hardware-budgets**: frostsnap-on-mk4-resource-budget.md

## Recent Changes

- 2026-08-10: First three references compiled from thesis research on `frostsnap-firmware-on-coldcard-mk4`.
- 2026-08-10: Directory created by topic init.
