---
title: "Porting Frostsnap to other hardware"
category: topic
sources:
  - raw/articles/2026-08-10-frostsnap-devicehal-pr-513.md
  - raw/articles/2026-08-10-frostsnap-device-crate-platform-bindings.md
  - raw/articles/2026-08-10-embedded-rust-portability-limits.md
  - raw/notes/2026-08-10-frostsnap-multiboard-history-esp32s3.md
  - raw/notes/2026-08-10-wallet-firmware-port-precedents.md
  - raw/notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md
  - raw/notes/2026-08-10-port-thesis-confounders-and-steelman.md
  - raw/data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md
created: 2026-08-10
updated: 2026-08-10
tags: [frostsnap, porting, firmware-portability, esp32c3, stm32l4, embedded-rust, feasibility, devicehal]
aliases: ["Frostsnap port", "porting Frostsnap"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "Synthesis of what it takes to move Frostsnap's device firmware to other silicon, organised by the three difficulty tiers the evidence actually supports. Tier 1, a new board on the same chip, is roughly 200 lines — the Jade analogue, and Frostsnap already ships a per-board feature matrix. Tier 2, a new chip inside the same HAL vendor, is what Frostsnap has done: the esp32s3 branch crossed RISC-V to Xtensa in 27 files, +1,579/-570, about 2 engineers for 3 weeks, because esp-hal absorbed the ISA change behind a chip feature flag. Tier 3, a new vendor and a new HAL, is where the reference class says 7 to 10 months and roughly 20,000 lines, and is what an STM32 target means. On top of Tier 3, targeting the shipping Coldcard Mk4 adds a category the reference class contains no successful instance of: a locked third-party device whose bootloader cannot be replaced, whose secure elements are reachable only through a foreign callgate ABI, and which bricks on early-boot bugs. The portable fraction is real but small and specific — the FROST core, the protocol crates, and embedded-hal 1.0 drivers such as mipidsi — while the widget tree assumes Rgb565 across 45 of 80 files. PR #513's DeviceHal trait is the most consequential development for portability, and it is open rather than merged."
---

# Porting Frostsnap to other hardware

Frostsnap's firmware portability question has one recurring failure mode: people cite the cheap kind of
port as evidence for the expensive kind. The evidence supports three distinct tiers, and the difference
between them is roughly two orders of magnitude.

## Tier 1 — new board, same chip: ~200 lines

Frostsnap already does this. Commit `69780387` (2023-07-07) introduced a two-board feature matrix with
per-board `[[bin]]` targets, and `69e377b8` (2022-10-10) added the ESP32-C3-DevKitC-02 BSP. The Jade
analogue quantifies it: PR #290 (ESP32-S3-DevKitC-1 + ST7789 + OV2640) is **4 files, +217/−0**; PR #221
(Waveshare Touch LCD 2) is **9 files, +202/−43**.

Pin maps, display dimensions, a BSP entry. Nothing architectural.

## Tier 2 — new chip, same HAL vendor: ~3 weeks

This is what Frostsnap's `origin/esp32s3` branch (Apr–May 2026) did, and it is genuinely impressive:
**27 files, +1,579/−570**, ~1,000 new peripheral lines, 2 engineers, ~3 weeks — with `3b183b6e`
"Frostsnap firmware working in QEMU" and `9df1953c` "Waveshare S3 pinout support" as milestones.

Note that this crossed an **ISA boundary** — RISC-V RV32IMC to Xtensa LX7 — and was still cheap. That is
the single strongest pro-portability datapoint available, and it is worth understanding exactly why it
worked: **`esp-hal` absorbed the change.** The port was `chip-esp32c3` → `chip-esp32s3`, one HAL crate,
one linker script family, one vendor's peripheral model. The ISA change was handled by the compiler and
the runtime crate, not by the application.

The corollary is the one people skip: *ISA is not the expensive variable. The HAL is.*

## Tier 3 — new vendor, new HAL: 7–10 months, ~20,000 lines

Here the reference class is unambiguous — see
[Wallet firmware port outcomes](../references/wallet-firmware-port-outcomes.md):

- Jade ESP32 → ESP32-S3 (same vendor!): **~10.5 months**, 114 files, +9,222/−11,340
- Trezor STM32F4 → STM32U5 (same vendor, M4→M33): **~7 months**, 256 files, +17,547/−1,118
- Trezor core → Model One (same vendor, same ISA, own hardware): **abandoned after 6 years**
- Krux off K210: **unstarted after 4 years** despite being a funded, stated goal

For Frostsnap specifically, an STM32 target means replacing: `esp-hal` → `embassy-stm32`, `riscv-rt` →
`cortex-m-rt`, `linkall.x` → a hand-written script, `esp-alloc` → `embedded-alloc`, plus every
chip-specific device file (`efuse.rs`, `ds.rs`, `secure_boot.rs`, `partitions.rs`, `flash.rs`, `ota.rs`,
`uart_interrupt.rs`, `stack_guard.rs`, `firmware_size.rs`, `esp32_run.rs`).

Measured coupling and why the naive 7.9% figure undercounts by ~3× is covered in
[Platform coupling and the DeviceHal seam](../concepts/platform-coupling-and-the-devicehal-seam.md).
**Honest estimate: 15,000–20,000 lines touched.**

Calibration from Frostsnap's own tree: PR #457 "[device] Port to esp-hal v1.1.0" is **40 files,
+3,055/−2,731** — for a *minor version bump inside the same HAL*.

## Tier 4 — a locked third-party product: no successful precedent

Targeting the shipping Coldcard Mk4 is Tier 3 **plus** a class of obstacle the reference class contains
no successful instance of:

- The bootloader cannot be replaced and always runs first; it rejects any image without magic
  `0xCC001234` and a valid `uECC_verify` against one of 6 known pubkeys.
- Secure elements are reachable only through `firewall_dispatch()`, ~25 fixed methods, `good_addr()`
  pointer-checked — and that ABI offers no equivalent of the read-protected-eFuse HMAC primitive
  Frostsnap's identity derivation requires.
- DFU is fused off at RDP level 2; `flash_lockdown_hard()` is "a one-way trip."
- Bring-up bugs brick the device, and SD recovery "cannot load **new** code."
- Key-zero firmware carries a permanent 25-second boot warning with no bless escape on Mk4.
- MIT + Commons Clause bars a commercial result.

Details in [Custom firmware on locked devices](../concepts/custom-firmware-on-locked-devices.md).

## What actually is portable

| Portable | Why |
|----------|-----|
| `frostsnap_core`, `schnorr_fun`, `secp256kfun` | `#![no_std]`, no C dependency, already build for bare-metal `riscv32imc` — **but FROST needs `alloc`** |
| `frostsnap_comms` | protocol-level, though `BAUDRATE = 19_200` encodes an ESP32-C3 erratum |
| `mipidsi` / ST7789, `cst816s` | depend only on `embedded-hal ^1.0`; `ssd1306` 0.10.0 proves one driver crate can serve both `esp-hal` and `embassy-stm32` |
| `frostsnap_widgets` | ⚠️ **45 of 80 files reference `Rgb565`** (318 occurrences); `frostsnap_fonts` emits Gray4 — a mono target is a rendering-model change, not a driver swap |

## The most consequential development: `DeviceHal`

PR #513 (`frostsnap-embedded-lift`, head `102efb5cb10b`, **open, not merged**) lifts the run loop behind
a six-associated-type trait, with the stated intent that "the portable run-loop only ever sees these
traits — never `esp_hal`."

If merged, a port implements six traits rather than rewriting a run loop. But `Secrets` is the whole
key-custody design, `Firmware` is secure boot and OTA, `Storage` is a flash driver. **The seam tells you
where the work is; it does not make the work small.**

Frostsnap's maintainer has already voiced the underlying tension, in commit `91cdb937`: *"Not really
happy with this since they have different dependencies and so should be different crates."*

## The sane path, if the goal is FROST on Coldcard-class hardware

Build a **new** device on an unlocked STM32L4/U5: reuse `frostsnap_core` + `schnorr_fun` +
`frostsnap_widgets` (rewriting the colour assumptions), implement `DeviceHal` on `embassy-stm32`
(which has an exact `stm32l4s5vi` feature), and design key custody around whatever secure element you
actually solder down. Prior art exists — `PoneBiometrics/JavGar_master` runs **FROST 2-of-3 on a
Nucleo-L476RG**, the same core family as the Mk4's MCU.

That is Tier 3 work — hard, months, tractable — and it yields a device you can iterate on.

Alternatively, if the goal is threshold signing *on a Coldcard*, the shorter path does not involve
Frostsnap's firmware at all. See
[Threshold signing paths on Coldcard](threshold-signing-paths-on-coldcard.md).

## See Also

- [Thesis: Frostsnap firmware on Coldcard Mk4](../theses/frostsnap-firmware-on-coldcard-mk4.md)
- [Platform coupling and the DeviceHal seam](../concepts/platform-coupling-and-the-devicehal-seam.md)
- [Root-of-trust portability](../concepts/root-of-trust-portability.md)
- [Custom firmware on locked devices](../concepts/custom-firmware-on-locked-devices.md)
- [Embedded Rust portability matrix](../references/embedded-rust-portability-matrix.md)
- [Frostsnap-on-Mk4 resource budget](../references/frostsnap-on-mk4-resource-budget.md)
- [Wallet firmware port outcomes](../references/wallet-firmware-port-outcomes.md)
