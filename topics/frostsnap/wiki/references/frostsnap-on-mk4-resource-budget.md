---
title: "Frostsnap-on-Mk4 resource budget"
category: reference
sources:
  - raw/data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md
  - raw/notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md
created: 2026-08-10
updated: 2026-08-10
tags: [flash-budget, esp-image-format, ota, psram, sram, resource-fit, stm32l4s5, esp32c3]
aliases: ["does it fit", "FLASH_TEXT 1392K", "IROM_ALIGN"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "Byte-level accounting of whether Frostsnap's firmware fits Coldcard Mk4's flash, and where the real resource limits actually are. Headline: it fits. firmware.bin v0.3.0 is 1,482,752 bytes against a 1,425,408-byte FLASH_TEXT, which looks 57,344 bytes over — but 55,948 of those bytes are a verified all-zero segment loaded at address 0x0, esptool's MMU-page alignment padding (IROM_ALIGN = 65536), and the rest is ESP-only packaging: image and segment headers, checksum, appended SHA-256, sector padding, and a 4,096-byte Secure Boot v2 signature block. The four real segments sum to 1,419,688 bytes, which is 5,720 bytes UNDER FLASH_TEXT and about 533 KB under Coldcard's own FW_MAX_LENGTH_MK4 of 1,966,080. The 'delete the fonts' corollary is also wrong: all eleven noto_*.rs faces total 67,051 bytes, 4.7% of the image, while IROM text is 82.2%. What genuinely does not fit is the OTA layout — two 1724K app slots plus 512K nvs is about 4.2 MB against Mk4's 1984K FLASH region, so A/B OTA is impossible and single-image-only would be forced. RAM favours Mk4 decisively: 632 KiB internal SRAM versus the ESP32-C3's 313 KiB DRAM, against a 256 KiB Frostsnap heap, with 8 MB of memory-mapped PSRAM behind it — though that PSRAM cannot host XIP firmware and is already committed to a USB-MSC RAM disk and upgrade staging, and is RNG-wiped on boot."
---

# Frostsnap-on-Mk4 resource budget

This page exists mainly to retire a wrong argument. "The firmware doesn't fit" is the most commonly
reached-for objection, and it is false. The port is hard for other reasons — see
[Custom firmware on locked devices](../concepts/custom-firmware-on-locked-devices.md) and
[Root-of-trust portability](../concepts/root-of-trust-portability.md).

## Flash: it fits

`firmware.bin` v0.3.0 = **1,482,752 bytes** (sha256 `43da5e97…40e51`, matching the signed `CHECKSUMS`
asset). Mk4 `FLASH_TEXT` = 1392K = **1,425,408 bytes**. Naive difference: 57,344 over.

But that compares a *packaged, signed, sector-padded ESP flash artifact* to a *raw linker region*.
Parsing the image header (magic `0xe9`, 5 segments, `chip_id=5` → ESP32-C3, `append_digest=1`):

| Segment | Load addr | Bytes | What it is |
|---------|-----------|-------|------------|
| 0 | `0x3c130020` | 196,612 | DROM (rodata) |
| 1 | `0x3fc80be0` | 6,516 | DRAM (data) |
| 2 | `0x40380000` | 3,036 | IRAM |
| 3 | **`0x00000000`** | **55,948** | **all-zero padding** (verified `set(seg3) == {0}`) |
| 4 | `0x42000020` | 1,213,524 | IROM (text) |

Segment 3 is esptool's MMU-page alignment filler — `IROM_ALIGN = 65536`, and
`ESP32FirmwareImage.save()` emits `ImageSegment(0, b"\x00" * pad_len, f.tell())`. Confirmed
arithmetically: IROM lands at file offset `0x40020` (`0x20 mod 0x10000`); strip the pad and it lands at
`0x2594 mod 0x10000`, unaligned. This padding exists **only** because of ESP32 flash-cache MMU paging.
An STM32 image has no equivalent.

```
1,482,752   firmware.bin
  -55,948   zero pad segment (ESP MMU alignment)
       -8   its segment header
      -64   image header + 5 segment headers
      -12   16-byte align + checksum byte (0x78 at 0x16847f)
      -32   appended SHA-256 (verified against stored digest)
   -2,912   0xff gap padding to 4K sector boundary
   -4,096   Secure Boot v2 signature block (magic e7020000 at 0x169000)
= 1,419,680  loadable content
```

Sum of the four real segments = **1,419,688 bytes (1386.4 KiB)** → **5,720 bytes under** `FLASH_TEXT`,
and ~533 KB under Coldcard's own `FW_MAX_LENGTH_MK4` (1,966,080).

Two structural confirmations: `firmware.bin` contains **no bootloader and no partition table** (shipped
separately as `bootloader-legacy.bin` and `partitions.csv`), and there is **no ESP-IDF app descriptor** —
offset `0x20` reads magic `0x00000000`, not `0xabcd5432`. It is a bare `esp-hal` Rust build.

*Caveat: this is the fit of the **current ESP build's code size**, not of a hypothetical ARM build. A
Thumb-2 recompile changes text size in ways not measured here, and the ~5.7 KB margin is thin enough
that the honest statement is "roughly at parity," not "comfortably fits."*

## The "delete the fonts" corollary is also wrong

Counting `0xNN` byte literals across the eleven `frostsnap_fonts/src/noto_*.rs` faces: **67,051 bytes
(65.5 KiB)** — **4.7%** of the image, 34% of DROM. The weight is IROM text at **1,213,524 bytes
(82.2%)**: schnorr_fun/secp256k1, bincode, the 80-file widget tree. Fonts are not the bloat.

## What genuinely does not fit: the OTA layout

Frostsnap's `partitions.csv` sizes each app slot at **1724K**. Two slots plus 512K `nvs` ≈ **4.2 MB**,
against Mk4's **1984K** total FLASH region at `0x08020000`. **One slot alone exceeds it.** A/B OTA is
impossible; single-image-only would be forced — which in turn means no safe rollback, on a device where
a bad image is unrecoverable.

Mk4 flash layout for reference, from `stm32/COLDCARD_MK4/layout.ld`:

| Region | Origin | Length |
|--------|--------|--------|
| `FLASH_ISR` | — | 16K |
| `FLASH_TEXT` | `0x08024000` | 1392K |
| `FLASH_FS` | — | 512K |
| `FLASH` (total) | `0x08020000` | 1984K |

`stm32/sigheader.h`: `FW_MAX_LENGTH_MK4 = 0x200000 - 0x20000 = 1,966,080` bytes (1920K).

## RAM: Mk4 wins comfortably

| | Mk4 (STM32L4S5) | Frostsnap (ESP32-C3) |
|---|---|---|
| Internal SRAM | **632 KiB** (`RAM` region `0x9e000`; 192+64+384 across SRAM1/2/3) | **313 KiB** DRAM |
| Frostsnap heap | — | `esp_alloc::heap_allocator!(256 * 1024)` |
| External | 8 MB PSRAM (memory-mapped) | none |

This is the one axis with genuine headroom.

## PSRAM: verified, but doesn't help

`stm32/mk4-bootloader/psram.h`:

```c
// 8 megabytes of RAM
#define PSRAM_BASE      0x90000000
#define PSRAM_SIZE      0x00800000
```

`psram.c` confirms OCTOSPI1, ESP-PSRAM64H, GPIOE PE10–PE15 `GPIO_AF10_OCTOSPIM_P1`, and
`HAL_OSPI_MemoryMapped(&qh, &mmap)` — memory-mapped and CPU-addressable. Corroborated by
`OCTOSPI1_BASE (0x90000000UL)` in CMSIS.

It changes nothing for flash fit: PSRAM is RAM, and XIP firmware cannot execute from it. It is also
largely committed — `psramdisk.c` carves it into a USB-MSC RAM disk (`PSRAM_SIZE 0x400000`, "using top
half of chip only"), `psram.c` uses it as the firmware-upgrade staging buffer (`psram_recover_firmware`,
`psram_do_upgrade`, `RECHDR_POS`), and boot wipes it with RNG data
(`memset4(PSRAM_BASE, rng_sample(), PSRAM_SIZE)`).

## Could not confirm

- ST's datasheet and product pages for STM32L4S5VI timed out; the peripheral inventory rests on ST's own
  CMSIS and HAL source (equally authoritative for presence/absence).
- Whether Coldcard's *existing* firmware uses the AES/HASH blocks — GitHub code search was rate-limited.
  Only the silicon's capability is established.
- The exact Mk4 STM32 order code (e.g. `STM32L4S5VIT6`); `"STM32L4SxVI"` and `stm32l4s5_af.csv` imply
  the 100-pin VI / 2 MB suffix.

## See Also

- [Embedded Rust portability matrix](embedded-rust-portability-matrix.md)
- [Root-of-trust portability](../concepts/root-of-trust-portability.md)
- coldcard wiki: [Memory map and key slots](../../../coldcard/wiki/references/memory-map-and-key-slots.md)
- coldcard wiki: [Device limits](../../../coldcard/wiki/references/device-limits.md)
