---
title: "Wallet firmware port outcomes"
category: reference
sources:
  - raw/notes/2026-08-10-wallet-firmware-port-precedents.md
  - raw/notes/2026-08-10-frostsnap-multiboard-history-esp32s3.md
created: 2026-08-10
updated: 2026-08-10
tags: [reference-class-forecasting, trezor, jade, krux, seedsigner, pitrezor, porting-cost, diffstats]
aliases: ["port reference class", "porting cost table"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "Every documented attempt to move hardware-wallet signing firmware across MCU families, with dated outcomes and diffstats, as a reference class for effort estimation. Jade ESP32 to ESP32-S3 took ~10.5 months request-to-experimental-merge (114 files, +9,222/-11,340). Trezor STM32F4 to STM32U5 took a ~7-month epic (256 files, +17,547/-1,118, four months in review). Trezor core to Model One was abandoned after six years with HAL complete but boardloader/bootloader unfinished. Krux's device-agnostic goal remains unrealized after four years, still K210-only. SeedSigner to ESP32 spent six full-time funded weeks and reached emulator boot only. The load-bearing distinction the table establishes: a new BOARD on an existing chip is about 200 lines (Jade PR #290 = 4 files, +217/-0), while a new CHIP is about 20,000 lines. Frostsnap's own esp32s3 branch is the cheap kind — 27 files, +1,579/-570 — because it stayed inside Espressif on esp-hal behind a chip feature flag. The one genuinely successful cross-platform wallet port, PiTrezor, avoids the problem by running Linux on a Pi Zero rather than bare metal, and is widely regarded as insecure."
---

# Wallet firmware port outcomes

A reference class for anyone estimating what it costs to move signing firmware to different silicon.

## The table

| Port | Difficulty class | Outcome |
|------|------------------|---------|
| Jade ESP32 → ESP32-S3 | same vendor, same ISA family | **~10.5 months**, 20.5k lines churn, "experimental" at merge |
| Trezor STM32F4 → STM32U5 | same vendor, adjacent ISA (M4→M33) | **~7-month epic**, 256 files, +17,547/−1,118, 4 months in review |
| Trezor core → Model One | same vendor, same ISA, own hardware | **abandoned after 6 years** |
| Krux off K210 | new vendor, new ISA | **unstarted after 4 years** |
| SeedSigner → ESP32 | Linux → bare metal | 6 full-time weeks → **emulator only** |
| Frostsnap C3 → S3 | same vendor, cross-ISA, same HAL | **~3 weeks**, 27 files, +1,579/−570 |
| Frostsnap → new board (same chip) | board only | Jade analogue: **~200 LOC** |

## Trezor issue #24 — the most instructive failure

Opened 2018-10-02, closed 2024-09-24. Closing comment (Hannsek), verbatim:

> "After 6 years we can close this issue as we do not have any intention to do such thing anymore.
> Moreover, recent split of the core firmware made it impossible to port core to model One."

This was the *easy* version — same vendor, same ISA (Cortex-M), STM32F2→F4, in-house team, full
schematics, no adversarial bootloader — and it still failed. The checklist state at close is the point:
**HAL (display, touch, USB) ✅** and all five `modtrezor*` modules ✅, but **`boardloader/bootloader` ❌**
and "Hardware optimalization" ❌. The application layer ported; the boot and hardware-trust layer killed
it.

PR #4188 "Core firmware split" (merged 2024-09-24, **328 files, +12,944/−5,703**) then split firmware
into a privileged `kernel` and unprivileged `coreapp` behind ~100 syscalls — architectural evolution
actively *destroying* portability to weaker hardware. Trezor still maintains `legacy/` and `core/` as
separate codebases after 12 years.

## Jade — where the board-vs-chip distinction comes from

Issue #93 opened 2023-09-27; experimental merge announced 2024-08-05 (JamieDriver): "We have finally
merged the branch adding (still early days / experimental, at this point ...) esp32s3 support." Enabling
commit `6217e66c`: **114 files, +9,222/−11,340**, including 30 files deleted totalling 10,722 lines —
the entire bespoke TFT stack (`components/tft/tft.c` 3,199 lines, `spi_master_lobo.c` 1,156 lines, all
bitmap fonts) ripped out and re-based on Espressif's `esp_lcd`. **A chip port forced a rewrite of the
whole display subsystem.**

Once the seam existed, new *boards* were trivial: PR #290 (ESP32-S3-DevKitC-1 + ST7789 + OV2640) is
**4 files, +217/−0**; PR #221 (Waveshare Touch LCD 2) is **9 files, +202/−43**.

> **New board ≈ 200 LOC. New chip ≈ 20,000 lines.**

Mid-project honesty from the maintainers, 2024-01-23, four months in: "No, there's a fair amount of work
to get it to work on this chip ... but that work is being done when nothing more urgent takes priority.
Hopefully mid-year ..."

## Krux — a funded portability goal, unrealized

Discussion #170 (2022-08-18) framed Krux as "the Linux ... of hardware wallet firmware, an open-source
device-agnostic signing 'OS' you can install on any platform capable of running Micropython." As of
2026 **Krux remains K210-only** — every supported device (Maix Amigo/Bit/Dock, M5StickV, WonderMV,
Yahboom) is the same Kendryte K210 SoC. The blocker is the same one any port hits: the signing app is
welded to SoC-specific runtime modules (MaixPy's `sensor`, `lcd`, `image` via OpenMV, which "doesn't
support ESP32 devices and is instead focused on STM32").

odudex, 2022-08-18: "ESP32s @240MHz may lead to poor performance or a hard to achieve level of
optimization."

## SeedSigner → ESP32 — six focused weeks reached an emulator

Summer of Bitcoin 2026, described as *ahead of schedule*. Six full-time funded weeks produced a
literature review, a secure-boot prototype **on QEMU**, an SD-card third-stage loader, and "an
interactive REPL prompt on ESP32-S3 via Wokwi emulation." **Not yet running on physical hardware.**

Author's summary of the difficulty: "The most challenging problem was managing the strict memory limits
and execution contexts on the ESP32 while trying to load an external payload statelessly." Failure
modes, verbatim: "Cache-22 scenario, IRAM corruption, stack self-overwrites"; "Hidden MMU misalignment
bugs caused by the 256-byte Specter header."

## Frostsnap's own history

| Commit / branch | Date | What |
|---|---|---|
| `82050de1` | 2022-09-16 | initial device firmware |
| `69e377b8` | 2022-10-10 | ESP32-C3-DevKitC-02 BSP |
| `b65f24db` | 2023-06-20 | created the `esp32_run.rs` seam |
| `69780387` | 2023-07-07 | two-board feature matrix, per-board `[[bin]]` |
| `origin/esp32s3` | Apr–May 2026 | cross-ISA port to Xtensa: `2dc22549`, `3b183b6e` "Frostsnap firmware working in QEMU", `9df1953c` "Waveshare S3 pinout support" |

The S3 branch measured **27 files, +1,579/−570**, ~1,000 new peripheral lines, 2 engineers, ~3 weeks.
The essential qualifier: **every Frostsnap port so far stayed inside Espressif on `esp-hal`**
(`chip-esp32c3` vs `chip-esp32s3`), not `esp` vs `stm32`.

Maintainer's own dissatisfaction with the multi-board arrangement, `91cdb937`: "Not really happy with
this since they have different dependencies and so should be different crates."

## The honest counterweight

Trezor issue #1919: a hobbyist got some of Trezor legacy firmware onto RP2040 unaided — "Mostly the
basics, key and mnemonic generation, key derivation, display addresses." That is the strongest
pro-portability signal in the class: **the portable ~20% is pure-compute crypto**, with no secure boot,
no secure element, no PIN or anti-tamper path.

Upstream policy blocks maintenance regardless (matejcik, 2021-11-23): "If it's just a matter of adding
some headers, or changes that are portable, then yes, this would be OK. **If it's anything more
significant or intrusive, then no, because that would effectively be dead code in our repo that is
likely to get broken.**"

**PiTrezor**, the one genuinely successful cross-platform wallet port, cheats: the Pi Zero runs Linux, so
the "port" is compiling Trezor One's code as a Linux userspace program. Not bare-metal MCU porting, and
widely regarded as insecure. Coldcard offers no Linux escape hatch.

## See Also

- [Porting Frostsnap to other hardware](../topics/porting-frostsnap-to-other-hardware.md)
- [Custom firmware on locked devices](../concepts/custom-firmware-on-locked-devices.md)
- [Platform coupling and the DeviceHal seam](../concepts/platform-coupling-and-the-devicehal-seam.md)
