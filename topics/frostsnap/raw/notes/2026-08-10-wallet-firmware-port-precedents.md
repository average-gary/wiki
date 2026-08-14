---
title: "Hardware-wallet firmware port precedents — measured outcomes"
source: "https://github.com/trezor/trezor-firmware/issues/24"
type: notes
ingested: 2026-08-10
tags: [reference-class-forecasting, trezor, jade, krux, seedsigner, porting-cost, firmware-portability, prior-art]
summary: "Reference-class survey of every documented attempt to port hardware-wallet signing firmware across MCU families, with dated outcomes and diffstats. Trezor issue #24 '[Epic] Port Core codebase to Trezor One hardware' opened 2018-10-02 and closed 2024-09-24 - abandoned after six years - with closing comment 'After 6 years we can close this issue as we do not have any intention to do such thing anymore. Moreover, recent split of the core firmware made it impossible to port core to model One.' At close, HAL (display, touch, usb) and all five modtrezor* modules were checked done, but boardloader/bootloader and hardware optimalization were not; PR #4188 'Core firmware split' (merged 2024-09-24, 328 files, +12,944/-5,703) split firmware into a privileged kernel and unprivileged coreapp behind ~100 syscalls, actively destroying portability to weaker hardware. Trezor still ships two separate codebases (legacy/ for Model One, core/ for T and Safe models) after 12 years. Trezor STM32F4 to STM32U5 (same vendor, M4 to M33) took a ~7-month epic, PR #3370 = 256 files, +17,547/-1,118, four months in review, with fix-ups into June 2025. Blockstream Jade ESP32 to ESP32-S3 (same vendor, Xtensa LX6 to LX7) took ~10.5 months request-to-experimental-merge (issue #93 opened 2023-09-27; JamieDriver 2024-08-05: 'We have finally merged the branch adding (still early days / experimental, at this point ...) esp32s3 support'), enabling commit 6217e66c = 114 files, +9,222/-11,340, including deletion of the entire bespoke TFT stack (components/tft/tft.c 3,199 lines, spi_master_lobo.c 1,156 lines) to re-base on esp_lcd. Crucially, once the seam existed, new boards were cheap: PR #290 (ESP32-S3-DevKitC-1 + ST7789 + OV2640) = 4 files, +217/-0; PR #221 (Waveshare Touch LCD 2) = 9 files, +202/-43. So new board ~200 LOC, new chip ~20,000 lines. Krux discussion #170 'Groundwork for porting to other platforms/chipsets' (opened 2022-08-18) aimed at Krux as an 'open-source device-agnostic signing OS'; as of 2026 Krux remains K210-only across every supported device. odudex, 2022-08-18, on ESP32: 'ESP32s @240MHz may lead to poor performance or a hard to achieve level of optimization.' SeedSigner ESP32 port (Summer of Bitcoin 2026) spent six full-time funded weeks, described as ahead of schedule, and reached only QEMU/Wokwi emulator boot with secure boot unproven on silicon; author's summary: 'The most challenging problem was managing the strict memory limits and execution contexts on the ESP32 while trying to load an external payload statelessly', with failure modes 'Cache-22 scenario, IRAM corruption, stack self-overwrites'. Trezor issue #1919 (Raspberry Pico) shows a hobbyist got 'Mostly the basics, key and mnemonic generation, key derivation, display addresses' working - the portable crypto fraction - but upstream policy (matejcik, 2021-11-23) refuses intrusive port patches: 'If it's anything more significant or intrusive, then no, because that would effectively be dead code in our repo that is likely to get broken.' The one successful cross-platform wallet port, PiTrezor, cheats by running on Linux on a Pi Zero rather than bare metal, and is widely regarded as insecure."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: measured-outcomes
direction: opposes
credibility: high
confidence: high
fetched: 2026-08-10
---

# Hardware-wallet firmware port precedents

## The reference class

| Port | Difficulty class | Outcome |
|------|------------------|---------|
| Jade ESP32 → ESP32-S3 | same vendor, same ISA family | **~10.5 months**, 20.5k lines churn, "experimental" at merge |
| Trezor STM32F4 → STM32U5 | same vendor, adjacent ISA (M4→M33) | **~7-month epic**, 256 files, +17,547/−1,118, 4 months in review |
| Trezor core → Model One | same vendor, same ISA, own hardware | **abandoned after 6 years** |
| Krux off K210 | new vendor, new ISA | **unstarted after 4 years** |
| SeedSigner → ESP32 | Linux → bare metal | 6 full-time weeks → **emulator only** |
| Frostsnap → Coldcard Mk4 | new vendor + new ISA + new HAL + immutable third-party bootrom + foreign dual-SE trust model + no safe iteration loop | *thesis claims "easy"* |

## Trezor issue #24 — the most damaging datapoint

Opened 2018-10-02, closed 2024-09-24. Closing comment (Hannsek), verbatim:

> "After 6 years we can close this issue as we do not have any intention to do such thing anymore.
> Moreover, recent split of the core firmware made it impossible to port core to model One."

This was the *easy* version: same vendor, same ISA (Cortex-M), STM32F2→STM32F4, in-house team, full
documentation and schematics, no adversarial bootloader. It still failed. The checklist state at
close is the instructive part — HAL (display, touch, usb) ✅ and all five `modtrezor*` modules ✅,
but **`boardloader/bootloader` ❌ and "Hardware optimalization" ❌**. The application layer ported;
the boot/hardware-trust layer is what killed it.

PR #4188 "Core firmware split" (merged 2024-09-24, **328 files, +12,944/−5,703**) split firmware
into a privileged `kernel` and unprivileged `coreapp` via ~100 syscalls — architectural evolution
actively *destroying* portability. Trezor still maintains `legacy/` and `core/` as separate
codebases after 12 years.

## Jade ESP32 → ESP32-S3 — the chip-vs-board distinction

Issue #93 opened 2023-09-27. Dated maintainer quotes:

- 2023-09-28: "There are some pre-requisites we need to address first - the display library/code
  being the main issue."
- 2023-10-27: "hopefully we'll have support for this chip in the next release or two."
- **2024-01-23 (4 months in): "No, there's a fair amount of work to get it to work on this chip ...
  but that work is being done when nothing more urgent takes priority. Hopefully mid-year ..."**
- 2024-08-05 (JamieDriver): "We have finally merged the branch adding (still early days /
  experimental, at this point ...) esp32s3 support."

Enabling commit `6217e66c`: **114 files, +9,222/−11,340** (20,562 lines churn), including 30 files
deleted totalling 10,722 lines — the entire bespoke TFT stack (`components/tft/tft.c` 3,199 lines,
`spi_master_lobo.c` 1,156 lines, all bitmap fonts) ripped out and re-based on Espressif's `esp_lcd`.
**A chip port forced a rewrite of the whole display subsystem.**

The favorable nuance: once the seam existed, *new boards* were cheap — PR #290 (ESP32-S3-DevKitC-1 +
ST7789 + OV2640) is **4 files, +217/−0**; PR #221 (Waveshare Touch LCD 2) is **9 files, +202/−43**.

> **New board ≈ 200 LOC. New chip ≈ 20,000 lines.** Frostsnap→Coldcard is emphatically the second
> kind, and worse. This is the distinction the thesis conflates.

Security caveat that applies to any port onto unlocked hardware — greenaddress, 2024-09-24: "Do not
use the DIY flasher other than for testing/evaluation purposes. these devices in debug mode aren't
really safe and the web page can't setup secure boot for you (at least for now)."

## Krux — a portability goal that went unrealized for 4 years

Discussion #170, opened 2022-08-18, ambition stated as Krux being "the Linux (or perhaps Ubuntu ...)
of hardware wallet firmware, an open-source device-agnostic signing 'OS' you can install on any
platform capable of running Micropython." As of 2026, **Krux remains K210-only** — every supported
device (Maix Amigo/Bit/Dock, M5StickV, WonderMV, Yahboom) is the same Kendryte K210 SoC. A stated,
prioritized, OpenSats-funded portability goal, unrealized after four years.

The blocker is the same one a Frostsnap port hits: the signing app is welded to SoC-specific runtime
modules. MaixPy supplies `sensor`, `lcd`, `image` via OpenMV, which "(currently) doesn't support
ESP32 devices and is instead focused on STM32."

odudex, 2022-08-18: "ESP32s @240MHz may lead to poor performance or a hard to achieve level of
optimization."

## SeedSigner → ESP32 — six focused weeks reached an emulator

Summer of Bitcoin 2026, described as *ahead of schedule*. Six full-time funded weeks produced a
literature review, a secure-boot prototype **on QEMU**, an SD-card third-stage loader, and "an
interactive REPL prompt on ESP32-S3 via Wokwi emulation." **Not yet running on physical hardware.**

Author's summary of the core difficulty: "The most challenging problem was managing the strict memory
limits and execution contexts on the ESP32 while trying to load an external payload statelessly."
Concrete failure modes, verbatim: "Cache-22 scenario, IRAM corruption, stack self-overwrites";
"Hidden MMU misalignment bugs caused by the 256-byte Specter header"; SPI SRAM panics and I2C NACK
spam. Workarounds required "forcing the loader into unicore mode, dynamically rewriting the Cache MMU
logic" and relocating the bootloader jump into RTC memory.

Note the direction of travel: SeedSigner is moving *toward* ESP32 because it has secure boot. Nobody
is moving *off* ESP32 onto a locked commercial device.

## The honest counterweight — Trezor issue #1919 (RP2040)

A hobbyist got some of Trezor legacy firmware onto RP2040 unaided: "Mostly the basics, key and
mnemonic generation, key derivation, display addresses." That is the strongest pro-thesis signal in
the reference class — **the portable ~20% is pure-compute crypto**, with no secure boot, no secure
element, no PIN/anti-tamper path.

Upstream policy is a hard blocker for maintenance (matejcik, 2021-11-23): "If it's just a matter of
adding some headers, or changes that are portable, then yes, this would be OK. **If it's anything
more significant or intrusive, then no, because that would effectively be dead code in our repo that
is likely to get broken.**" The issue closed 8 days after opening; a follow-up 5 months later went
unanswered. No port materialized.

**PiTrezor**, the one genuinely successful cross-platform wallet port, cheats: the Pi Zero runs
Linux, so the "port" is compiling Trezor One's code as a Linux userspace program. Not bare-metal MCU
porting, and widely regarded as insecure. Coldcard offers no Linux escape hatch.

## See Also

- [Frostsnap multi-board history and the ESP32-S3 port](2026-08-10-frostsnap-multiboard-history-esp32s3.md)
- [Coldcard Mk4 custom-firmware constraints](2026-08-10-coldcard-mk4-custom-firmware-constraints.md)
