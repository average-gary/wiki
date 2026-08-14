---
title: "Frostsnap-on-Mk4 resource-fit audit — two popular claims refuted"
source: "https://api.github.com/repos/frostsnap/frostsnap/releases"
type: data
ingested: 2026-08-10
tags: [frostsnap, coldcard, mk4, flash-budget, esp-image-format, stm32l4s5, hmac, hash-peripheral, resource-fit, refuted-claims]
summary: "Adversarial numeric audit that refutes two claims which would otherwise look like decisive anti-port arguments. Claim one, that Frostsnap's 1,482,752-byte firmware.bin does not fit Coldcard Mk4's 1392K (1,425,408-byte) FLASH_TEXT, is arithmetically true but analytically inverted. Parsing the ESP image header (magic 0xe9, 5 segments, chip_id 5 = ESP32-C3, append_digest 1) shows segment 3 loads at address 0x00000000 and is 55,948 bytes of verified all-zero MMU-page alignment padding emitted by esptool (IROM_ALIGN = 65536; ESP32FirmwareImage.save() writes ImageSegment(0, b'\\x00' * pad_len)). Stripping ESP-only packaging - 55,948-byte pad plus its 8-byte header, 64 bytes of image and segment headers, 12 bytes align/checksum (checksum 0x78 at 0x16847f), 32-byte appended SHA-256 (verified sha256(d[:0x168480]) matches the stored digest), 2,912 bytes of 0xff gap to the sector boundary, and a 4,096-byte Secure Boot v2 signature block with magic e7020000 at sector-aligned 0x169000 - leaves 1,419,680 bytes; the four real segments sum to 1,419,688 bytes (1386.4 KiB), which is 5,720 bytes UNDER the 1392K FLASH_TEXT and about 533 KB under Coldcard's own FW_MAX_LENGTH_MK4 of 1,966,080. Segment breakdown: DROM 0x3c130020 196,612; DRAM 0x3fc80be0 6,516; IRAM 0x40380000 3,036; pad 0x0 55,948; IROM 0x42000020 1,213,524. firmware.bin contains no bootloader and no partition table (shipped separately), and no ESP-IDF app descriptor (offset 0x20 reads magic 0x00000000, not 0xabcd5432) - it is a bare esp-hal Rust build. The corollary that deleting graphics would make it fit is also wrong: counting 0xNN byte literals across the eleven frostsnap_fonts/src/noto_*.rs faces gives 67,051 bytes (65.5 KiB) = 4.7 percent of the image and 34 percent of DROM, while IROM text is 1,213,524 bytes = 82.2 percent. What genuinely does not fit is the OTA layout: two 1724K app slots plus 512K nvs (about 4.2 MB) cannot coexist with Mk4's 1984K FLASH region. Claim two, that STM32L4S5 has no HMAC peripheral, is refuted: ST's own CMSIS header stm32l4s5xx.h shows HASH_BASE at AHB2PERIPH_BASE + 0x08060400, AES_BASE + 0x08060000 and RNG_BASE + 0x08060800 all present, with HASH_CR_MODE bit 6 selecting HMAC mode, HASH_ALGOMODE_HMAC = HASH_CR_MODE, HASH_ALGOSELECTION_SHA256 = HASH_CR_ALGO, CSR[54] context-swap registers, and ST's HAL exposing HAL_HMACEx_SHA256_Start/_Start_IT/_Start_DMA. So HMAC-SHA256 is hardware-accelerated on this exact part. The no-RSA-accelerator half is verified: PKA, CRYP and OTFDEC are all absent. But RSA is not load-bearing for signing - both Frostsnap RSA sites are verification/attestation only (secure_boot.rs uses esp_hal::rsa Op3072 for RSA-PSS verify of the firmware image, called once from ota.rs:450; ds.rs uses the DS peripheral for factory attestation), while Bitcoin signing is Schnorr/secp256k1 in frostsnap_core. HMAC, by contrast, is load-bearing: device/src/flash/header.rs:22 derives the device identity keypair via hmac.hash('frostsnap-device-keypair', &device_id_seed) then Scalar::from_slice_mod_order, and HMAC also gates share encryption (EfuseHmacKeys::ENCRYPTION_KEYID = Key2) and RNG seeding (mix_in_rng, FIXED_ENTROPY_KEYID = Key3). The real obstacle is key custody, not acceleration: ESP32-C3 HMAC keys live in read-protected eFuse blocks 4-9 (KeyPurpose::HmacUpstream = purpose 8) so software never sees the root secret, whereas STM32's HASH block has no key store and must be fed the key from flash or RAM. Verified Mk4 PSRAM: psram.h defines PSRAM_BASE 0x90000000 and PSRAM_SIZE 0x00800000 (8 MB, ESP-PSRAM64H on OCTOSPI1, GPIOE PE10-PE15 AF10, HAL_OSPI_MemoryMapped) but it is RAM not flash, cannot host XIP firmware, and is already committed to a USB-MSC RAM disk (psramdisk.c, PSRAM_SIZE 0x400000, top half only) and firmware-upgrade staging, and is RNG-wiped on boot. Internal SRAM favors Mk4: RAM region 0x9e000 = 632 KiB versus the ESP32-C3's 313 KiB DRAM, against a 256 KiB Frostsnap heap."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: measured-primary-artifact
direction: nuances
credibility: high
confidence: high
fetched: 2026-08-10
---

# Resource-fit audit — two anti-port claims refuted

This note exists to stop two wrong-but-plausible arguments from propagating into the verdict. Both
would have supported the "hard" conclusion; both fail on inspection. The port is hard for other
reasons.

## Claim 1: "the 1.41 MiB firmware doesn't fit in 1392K FLASH_TEXT" — REFUTED

The byte count is right. `firmware.bin` v0.3.0 = **1,482,752 bytes** (sha256
`43da5e97655fb39329ad8e01f23cea4f76a463eb20bae19b3601488f71440e51`, matching the signed `CHECKSUMS`
asset). FLASH_TEXT = 1392K = **1,425,408 bytes**. Difference: 57,344 bytes over.

But the comparison is between a *packaged, signed, sector-padded ESP flash artifact* and a *raw
linker output region*. Parsing the image header (magic `0xe9`, 5 segments, `chip_id=5` → ESP32-C3,
`append_digest=1`):

| Segment | Load addr | Bytes | What it is |
|---------|-----------|-------|------------|
| 0 | `0x3c130020` | 196,612 | DROM (rodata) |
| 1 | `0x3fc80be0` | 6,516 | DRAM (data) |
| 2 | `0x40380000` | 3,036 | IRAM |
| 3 | **`0x00000000`** | **55,948** | **all-zero padding** (verified `set(seg3) == {0}`) |
| 4 | `0x42000020` | 1,213,524 | IROM (text) |

Segment 3 is esptool's MMU-page alignment filler — `IROM_ALIGN = 65536`, and
`ESP32FirmwareImage.save()` emits `ImageSegment(0, b"\x00" * pad_len, f.tell())`. Confirmed
arithmetically: IROM lands at file offset `0x40020` (`0x20 mod 0x10000`); strip the pad and it lands
at `0x2594 mod 0x10000`, unaligned. This padding exists **only** because of ESP32 flash-cache MMU
paging. An STM32 image has no equivalent.

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

Sum of the four real segments = **1,419,688 bytes (1386.4 KiB)** → **5,720 bytes UNDER** the 1392K
FLASH_TEXT, and ~533 KB under Coldcard's own `FW_MAX_LENGTH_MK4` (1,966,080). "Doesn't fit" does not
survive contact with the image format.

Two structural confirmations: esptool's `firmware.bin` contains **no bootloader and no partition
table** (shipped separately as `bootloader-legacy.bin` and `partitions.csv`), and there is **no
ESP-IDF app descriptor** — offset `0x20` reads magic `0x00000000`, not `0xabcd5432`. It is a bare
`esp-hal` Rust build.

### The "delete the fonts and it fits" corollary is also wrong

Counting `0xNN` byte literals across the eleven `frostsnap_fonts/src/noto_*.rs` faces: **67,051 bytes
(65.5 KiB)** — **4.7%** of the image, 34% of DROM. The weight is IROM text at **1,213,524 bytes
(82.2%)**: schnorr_fun/secp256k1, bincode, the 80-file widget tree. Fonts are not the bloat.

### What genuinely does not fit

The **OTA layout**, not the code. Frostsnap's `partitions.csv` sizes each app slot at **1724K**;
two slots plus 512K `nvs` ≈ **4.2 MB**, against Mk4's **1984K** total FLASH region. One slot alone
(1724K) exceeds it. A/B OTA is impossible; single-image-only would be forced.

## Claim 2: "STM32L4S5 has no HMAC peripheral" — REFUTED (RSA half verified)

From ST's own CMSIS header `STMicroelectronics/cmsis_device_l4`, `Include/stm32l4s5xx.h`:

| Peripheral | Result |
|------------|--------|
| AES | `AES_BASE (AHB2PERIPH_BASE + 0x08060000)` — **present** |
| HASH | `HASH_BASE (AHB2PERIPH_BASE + 0x08060400)` — **present** |
| RNG | `RNG_BASE (AHB2PERIPH_BASE + 0x08060800)` — **present** |
| PKA | **absent** |
| CRYP | **absent** |
| OTFDEC | **absent** |

The HASH block does HMAC in hardware: `HASH_CR_MODE` bit 6 selects HMAC mode,
`HASH_ALGOMODE_HMAC = HASH_CR_MODE`, `HASH_ALGOSELECTION_SHA256 = HASH_CR_ALGO`, with `CSR[54]`
context-swap registers and a separate `HASH_DIGEST_TypeDef { HR[8] }`. ST's HAL exposes
**`HAL_HMACEx_SHA256_Start`**, `_Start_IT`, `_Start_DMA` in `stm32l4xx_hal_hash_ex.h`. SHA-256 *and*
HMAC-SHA256 are both hardware-accelerated on this exact part.

"No RSA accelerator" is **true** — no PKA, no CRYP. RSA-3072 would be software bignum.

### But the load-bearing dependency is the reverse of what the claim assumed

- **RSA is not used for signing.** Both Frostsnap RSA sites are verification/attestation only:
  `secure_boot.rs` uses `esp_hal::rsa::{Op3072, RsaModularExponentiation}` for RSA-PSS *verify* of
  the firmware image (`verify_secure_boot`, called once from `ota.rs:450`); `ds.rs` uses the DS
  peripheral for factory attestation (`HardwareDs::sign`, 3072-bit). Bitcoin signing is
  Schnorr/secp256k1 in `frostsnap_core`. Missing PKA costs boot-verify latency, not signing.
- **HMAC is load-bearing** — more than the claim suggested. `device/src/flash/header.rs:22` derives
  the *device identity keypair*: `hmac.hash("frostsnap-device-keypair", &device_id_seed)` →
  `Scalar::from_slice_mod_order(...)`. It also gates share encryption
  (`EfuseHmacKeys::ENCRYPTION_KEYID = Key2`) and RNG seeding (`mix_in_rng` → `ChaCha20Rng::from_seed`,
  `FIXED_ENTROPY_KEYID = Key3`). 18 of 86 `esp_hal::` references are `esp_hal::hmac::KeyId` alone.

### The real obstacle is key custody, not acceleration

ESP32-C3 HMAC keys live in **eFuse blocks 4–9**; per Espressif's docs a key "can be made completely
inaccessible for any resources outside the cryptographic modules, thus avoiding key leakage"
(`KeyPurpose::HmacUpstream` = purpose 8). With read-protection set, **software never sees the root
secret** — the device key is unextractable by construction.

STM32's HASH peripheral has **no key store**. You must feed it the key from flash or RAM, where
firmware — and an attacker with code execution — can read it. Coldcard solves the same problem
differently, with two external secure elements plus trick-PIN machinery (`mk4-bootloader/se2.c`,
DS28C36B; `NUM_TRICKS 14`, `TC_WIPE`, `TC_BRICK`, `TC_XPRV_WALLET`).

Porting therefore means rebuilding the entire key-custody design around a different root of trust —
a security-architecture rewrite, not a HAL call swap. This is the strongest anti-thesis point the
audit produced.

## Verified: 8 MB PSRAM on Mk4 (does not help)

`stm32/mk4-bootloader/psram.h`:

```c
// 8 megabytes of RAM
#define PSRAM_BASE      0x90000000
#define PSRAM_SIZE      0x00800000
```

`psram.c` confirms OCTOSPI1, ESP-PSRAM64H, GPIOE PE10–PE15 `GPIO_AF10_OCTOSPIM_P1`, and
`HAL_OSPI_MemoryMapped(&qh, &mmap)` — memory-mapped and CPU-addressable. Corroborated by
`OCTOSPI1_BASE (0x90000000UL)` in CMSIS.

It changes nothing for flash fit: PSRAM is RAM, and you cannot execute XIP firmware from it. It is
also largely committed — `psramdisk.c` carves it into a USB-MSC RAM disk (`PSRAM_SIZE 0x400000`,
"using top half of chip only"), `psram.c` uses it as the firmware-upgrade staging buffer
(`psram_recover_firmware`, `psram_do_upgrade`, `RECHDR_POS`), and boot wipes it with RNG data
(`memset4(PSRAM_BASE, rng_sample(), PSRAM_SIZE)`).

## Where Mk4 is genuinely ahead

Internal SRAM. Coldcard's `RAM` region is `0x9e000` = **632 KiB** (STM32L4S5: 192+64+384 = 640 KiB
across SRAM1/2/3) versus the ESP32-C3's **313 KiB** DRAM. Frostsnap allocates
`esp_alloc::heap_allocator!(256 * 1024)` in all three binaries. RAM is the one axis with comfortable
headroom, with 8 MB PSRAM behind it.

## Could not confirm

- ST's datasheet and product pages for STM32L4S5VI timed out; the peripheral inventory rests on ST's
  own CMSIS and HAL source (equally authoritative for presence/absence).
- GitHub code-search rate-limited unauthenticated, so whether Coldcard's *existing* firmware uses the
  AES/HASH blocks is unverified — only that the silicon has them.
- The exact Mk4 STM32 order code (e.g. `STM32L4S5VIT6`) is not stated in the repo; `"STM32L4SxVI"`
  and `stm32l4s5_af.csv` imply the 100-pin VI/2MB suffix.

## See Also

- [Device crate platform bindings](../articles/2026-08-10-frostsnap-device-crate-platform-bindings.md)
- [Coldcard Mk4 custom-firmware constraints](../notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md)
