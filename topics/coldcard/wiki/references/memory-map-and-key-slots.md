---
title: "Memory map and key slots"
category: reference
sources:
  - raw/articles/2026-08-10-coldcard-memory-map.md
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-bootloader-readme.md
  - raw/articles/2026-08-10-coldcard-upgrade-recovery.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, memory-map, stm32l4, flash-layout, sram, pcrop, firewall, key-slots, atecc608, ds28c36b, reference]
aliases: ["flash layout", "address space", "key table", "keyslot 10", "SRAM2"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "Lookup tables: the STM32L4 address-space layout for Mk3 and Mk4 (bootloader, pairing-secret page, MCU key slots, main firmware, filesystem, SRAM regions), the fifteen named keys with their chip, type and holder, and the SE2 page assignments. Includes the bootloader attestation range and the flash-level security measures."
---

# Memory map and key slots

> Reference tables for where things live. The MCU is from the **STM32L4** family — 1–2 MB flash,
> 128 k–512 k SRAM depending on Mk2/3/4 — and **all memory types share one 32-bit address space**.
> Prose explanation of what these regions *do* is in
> [[dual-secure-element-design|Dual secure-element design]]
> ([Dual secure-element design](../concepts/dual-secure-element-design.md)) and
> [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]]
> ([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)).

## Flash and SRAM layout

### Mk3

| Start | Size | Contents |
|-------|------|----------|
| `0x0800 0000` | `0x7800` | Mapped at zero briefly at boot. Bootloader code (`stm32/bootloader`) |
| `0x0800 7800` | `0x0800` | Sensitive **pairing secret** flash page (2 k) |
| `0x0800 8000` | 16 k | Interrupt handlers, file header (MicroPython and Coldcard code) |
| `0x0800 c000` | 848 k | Main flash for MicroPython / Coldcard C code |
| `0x080e 0000` | 128 k | Internal FAT filesystem — the "patch" area, for custom Python |
| `0x1000 0000` | `0x6000` | SRAM2 used by MicroPython: disk caches, byte arrays, stack |
| `0x1000 6000` | `0x1c00` | SRAM2 used by the bootloader |
| `0x1000 7c00` | `0x0400` | **Read-only.** "Root seed" (once-per-boot nonce), copy of the firmware signature |
| `0x2000 0000` | 96 k | SRAM1: heap and working SRAM for MicroPython |

### Mk4

| Start | Size | Contents |
|-------|------|----------|
| `0x0800 0000` | 112 k | Bootloader code including the reset vector (`stm32/mk4-bootloader`) |
| `0x0801 c000` | 8 k | Sensitive **pairing secrets** for SE1 and SE2 |
| `0x0801 e000` | 8 k | **MCU keys**, consumable: **256 × 32-bit write-once slots** |
| `0x0802 0000` | 16 k | Interrupt handlers, file header |
| `0x0802 4000` | ~2 MB | Main flash for MicroPython / Coldcard C code |
| `0x0818 0000` | 512 k | Internal **LFS** filesystem (holds settings) |
| `0x2000 0000` | 640 k | SRAM1,2,3: disk caches, byte arrays, stack |
| `0x2009 e000` | 8 k | Top of SRAM3 reserved for the bootloader |

Two changes between the generations are worth noting as design signals: the MCU-key slot region is
**new in Mk4** (it is the storage behind Fast Wipe), and the settings filesystem moved from **FAT to
LFS** while growing from 128 k to 512 k.

## Reading and attesting the bootloader

- The bootloader runs first and enables **hardware firewall** features covering parts of the address
  space. The firewall **resets the chip** on inappropriate access, so bootloader flash cannot be read
  back at all.
- To verify the bootloader anyway: supply a **32-bit nonce** and receive a **SHA256 of the bootloader
  with that nonce as prefix**. The hash covers `0x0800 0000` → `0x0800 7800`
  (Mk4: → `0x0801 c000`).
- Flash **above** `0x0800 8000` (Mk4: `0x0802 0000`) can be examined directly from Python.

The nonce is what makes this an attestation rather than a static checksum — a replayed hash from an
earlier query proves nothing.

## Flash-level security measures

- **Mk1–Mk3**: on entry the bootloader wipes its **entire** SRAM2 working area. You may use it for very
  temporary storage, but it is destroyed once the bootloader callgate is accessed.
- **Mk4**: the bootloader wipes its allocated SRAM **before and after** use.
- **All of SRAM** is cleared at boot and on "secure logout".
- **DFU updates can only affect areas at and above the bootrom.** A DFU that changes another area has
  no effect. Built-in DFU is **disabled once the unit leaves the factory**.
- Erasing the entire chip's flash (Coinkite is "not clear that's possible") loses the pairing secret at
  `0x0800 7800` / `0x0800 c000`, leaving the MCU **unable to talk to the secure elements at all**.
- Boot verification does a **double-SHA256 over all of flash** — including the pairing-secret area —
  plus a few registers loaded from flash cells (`verify.c` in `stm32/bootloader`).

That last item is the mechanism behind the world checksum and the green light.

## The fifteen keys

All are **32 bytes**, picked with the hardware RNG. Mk4/Mk5/Q.

| Symbol | Chip's name | Type | Holder | Purpose |
|--------|-------------|------|--------|---------|
| `SE1 pairing` | slot 1 | HMAC | SE1, MCU | protects SE1↔MCU comms |
| `SE2 pairing` | secret A | HMAC | SE2, MCU | pairing for SE2 |
| `SE2 comms` | keypair A | ECC | SE2 | MCU captures the pubkey half; used in ECDH |
| `SE joiner` | slot 7, pubkey C | ECC | SE1/SE2 | SE2 knows only the public part; SE1 has the privkey |
| `pin stretch` | slot 2 | HMAC | SE1 | key stretching for PIN entry **and** anti-phishing words |
| `firmware` | slot 14 | SHA256d | SE1 | firmware checksum; controls the green/red LEDs |
| `nonce/chksum` | slot 10 | data | SE1 | AES nonce and MAC tag, protected by the PIN |
| `SE2 easy key` | page 14 | AES via HMAC | SE2 | part of the AES seed key |
| `SE2 hard key` | page 15 | AES via ECC | SE2 | part of the AES seed key; ECC unlocks it |
| `tpin key` | `tpin_key` | HMAC(key) | MCU | encrypts Trick PINs |
| `trick PIN slots` | pages 0–12 | HMAC | SE2 | duress wallet seeds and PINs (6 spots) |
| `SE2 trash` | secret B | HMAC | SE2 | used to destroy values; only SE2 knows it |
| `hash cache secret` | `hash_cache_secret` | XOR/AES | MCU | in-memory encryption of the PIN while unlocked |
| `mcu hmac key` | `mcu_hmac_key` | HMAC | MCU | HMAC key used to compress the other keys |
| `replaceable mcu key` | `MCU_KEYS` | AES | MCU | replaceable up to **256** times |

Derived seed key:

```text
k = HMAC-SHA256(key = mcu hmac key,
                msg = SE2 easy key ‖ SE2 hard key ‖ current replaceable mcu key)
```

AES-256-**CTR**. Authentication is by appending **32 zero bytes** and checking they decrypt correctly;
the MAC (encrypted zeros) lives in **keyslot 10**. The CTR nonce is a fixed random value: **the first
15 bytes of `mcu hmac key` followed by a zero**, incrementing past 16 bytes of data.

## SE2 page assignments

| Pages | Use |
|-------|-----|
| 0–12 | Trick PIN slots — **even** pages hold the PIN hash, the **adjacent odd** page the secret |
| 14 | `SE2 easy key` |
| 15 | `SE2 hard key` |
| secret A | `SE2 pairing` |
| secret B | `SE2 trash` |

**14 slots** are compared against each entered PIN. Mk4 avoids slot 10, giving **13** usable; Q has
**14**. See [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)).

## SE1 spare storage

Moving duress and Brick-Me PINs to SE2 freed SE1 storage:

| Name | Size | Notes |
|------|------|-------|
| **Spare Secrets** | 3 × 72 bytes | same protection as the seed words |
| **Long Secret** | 416 bytes | still supported on Mk4/Q, **API changed** — fetching in 32-byte blocks was slow because the primary AES seed key had to be reconstructed per call |

## Captured values

The MCU records these and refuses to let them change, so that swapping a part is detected:

- SE1 and SE2 **chip serial numbers** (used in most HMAC responses; fully public)
- the **public keys** of the `SE joiner` and `SE2 comms` keypairs

Read-back out of the secure element is blocked where possible.

## PSRAM (Mk4 and later)

**ESP-PSRAM64H**, 64 Mbit quad-SPI, external and **volatile**. Used as PSBT working space (hence 2 MB
PSBTs) and as the staging area for firmware upgrades. It is not part of the internal address-space
tables above.

## Evidence status

`confidence: medium`. Addresses, sizes and slot assignments are first-party and precise, and the
`verify.c` reference gives a code path a reader could check — though that file is not in this
collection. The Mk3 table lists two different addresses for the pairing secret in different places in
the upstream document (`0x0800 7800` in the layout table, `0x0800 7800 / 0x0800 c000` in the security
notes); both are recorded above as written rather than reconciled. Mk5 and Q layouts are not given
separately upstream — the Mk4 table is the closest available and may differ in detail for those
models.

## See Also

- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](../concepts/dual-secure-element-design.md)) — what these keys do and how they combine
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)) — the world checksum over flash, PSRAM staging
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](../concepts/pin-entry-and-rate-limiting.md)) — the `pin stretch` slot in use
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)) — SE2 page layout and slot accounting
- [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](../concepts/anti-phishing-words.md)) — shares the `pin stretch` slot
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — the firewall and PCROP layer
- [[reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](../concepts/reproducible-builds-and-developer-access.md)) — the firmware/bootrom split `signit` operates on
- [[device-limits|Device limits]] ([Device limits](device-limits.md)) — the operational ceilings these regions produce
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](model-and-version-matrix.md)) — which layout applies to which model
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context

## Sources

- [Memory map](../../raw/articles/2026-08-10-coldcard-memory-map.md) — Mk3 and Mk4 address tables, bootloader attestation range, flash security measures
- [Dual secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — the fifteen-key table, AES-CTR details, SE2 pages, Spare Secrets and Long Secret, captured values
- [Bootloader README](../../raw/articles/2026-08-10-coldcard-bootloader-readme.md) — PCROP and firewall protection of the pairing-secret region
- [Upgrade and recovery](../../raw/articles/2026-08-10-coldcard-upgrade-recovery.md) — PSRAM part number and role
