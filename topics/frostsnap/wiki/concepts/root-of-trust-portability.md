---
title: "Root-of-trust portability"
category: concept
sources:
  - raw/data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md
  - raw/notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md
  - raw/articles/2026-08-10-frostsnap-device-provisioning.md
  - raw/articles/2026-08-10-frostsnap-key-derivation-design.md
created: 2026-08-10
updated: 2026-08-10
tags: [root-of-trust, efuse, hmac, secure-element, key-custody, secure-boot-v2, firewall, atecc608, ds28c36b]
aliases: ["key custody", "eFuse HMAC", "firewall_dispatch"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "The least portable part of a hardware-wallet firmware is not its HAL but its root of trust. Frostsnap derives its device identity keypair by HMAC over a key held in read-protected ESP32-C3 eFuse (KeyPurpose::HmacUpstream, blocks 4-9) that software never sees: device/src/flash/header.rs:22 computes hmac.hash('frostsnap-device-keypair', &device_id_seed) then Scalar::from_slice_mod_order. HMAC also gates share encryption (ENCRYPTION_KEYID = Key2) and RNG seeding (FIXED_ENTROPY_KEYID = Key3), so 18 of 86 esp_hal:: references are esp_hal::hmac::KeyId alone. Coldcard Mk4 solves the same problem with an incompatible mechanism: secrets live in two external secure elements plus a 32-byte pairing secret behind an STM32 firewall and PCROP, reachable only through firewall_dispatch() with roughly 25 fixed method numbers and a good_addr() pointer check. Neither root of trust can emulate the other, so porting means redesigning key custody rather than translating calls. A frequently-cited blocker — that STM32L4S5 lacks an HMAC peripheral — is false: HASH_BASE is present and HASH_CR_MODE bit 6 selects HMAC mode, with HAL_HMACEx_SHA256_Start exposed. The real obstacle is key storage, not acceleration: STM32's HASH block has no key store and must be fed the key from flash or RAM."
---

# Root-of-trust portability

Porting a signing firmware between MCUs is usually discussed as a HAL problem. It is not. The HAL is
tedious; the root of trust is the part that cannot be translated at all, because the two designs
disagree about *where a secret can exist*.

## How Frostsnap anchors trust

The device identity keypair is **derived, not stored**. `device/src/flash/header.rs:22`:

```rust
hmac.hash("frostsnap-device-keypair", &device_id_seed)
// -> Scalar::from_slice_mod_order(...)
```

The HMAC key lives in **ESP32-C3 eFuse blocks 4–9** with `KeyPurpose::HmacUpstream` (purpose 8). Per
Espressif, such a key "can be made completely inaccessible for any resources outside the cryptographic
modules, thus avoiding key leakage." With read-protection set, **firmware never sees the root secret** —
it can only ask the HMAC peripheral to use it.

The same mechanism carries two more load-bearing jobs:

- **Share encryption** — `EfuseHmacKeys::ENCRYPTION_KEYID = Key2`
- **RNG seeding** — `mix_in_rng` → `ChaCha20Rng::from_seed`, `FIXED_ENTROPY_KEYID = Key3`

Hence **18 of 86** `esp_hal::` references in the device crate are `esp_hal::hmac::KeyId` alone. HMAC is
not an optimization here; it is the identity system.

Above it sit ESP32 Secure Boot v2 (RSA-3072-PSS, signature block magic `0xE7,0x02,0x00,0x00`) and the
DS peripheral for factory attestation.

## How Coldcard Mk4 anchors trust

Two external secure elements — **SE1 = Microchip ATECC608**, **SE2 = Maxim DS28C36B** — plus a 32-byte
**pairing secret** held in bootloader flash behind the **STM32 firewall** and **PCROP**. `secrets.h`
holds `pairing_secret[32]`, `mcu_hmac_key[32]`, and an SE2 struct (`pairing[32]`, `pubkey_A[64]`,
`auth_pubkey[64]`), whose contents "cannot be changed once unit is 'bagged' and flash protection set."

Application code cannot touch any of it directly. The only path is `firewall_dispatch()` in
`dispatch.c` — roughly **25 fixed method numbers** (login with PIN = 18, trick PINs = 22, sign digest =
132, ECDH = 133), guarded by `if(len_in > 1024)` and a `good_addr()` pointer check that rejects
anything outside `SRAM1..BL_SRAM_BASE` with `EPERM`/`EACCES`, commented *"range check pointers so we
aren't tricked into revealing our secrets."*

`enable.c` states the reason verbatim: *"when RDP=2, this protection still important or else python can
read pairing secret."*

## Why these don't compose

The two designs are not more-and-less secure versions of each other; they are **different shapes**:

| | Frostsnap / ESP32-C3 | Coldcard Mk4 |
|---|---|---|
| Secret location | read-protected eFuse, on-die | two external SEs + firewalled flash |
| Access | HMAC peripheral, key invisible to software | callgate ABI, ~25 fixed methods |
| Identity | *derived* from an unreadable key | *stored* and gated by PIN machinery |
| Attack surface reduction | key never enters CPU-visible memory | secrets never leave the firewall region |
| Per-device hardening | none beyond the chip secret | PIN, trick PINs, anti-phishing words, RDP2 |

Foreign firmware on Mk4 hardware could not drive the secure elements directly; it would have to beg the
resident bootloader for every operation through an ARM-specific ABI it does not implement. And nothing
in that ABI provides the "HMAC with a key I cannot read" primitive Frostsnap's identity derivation is
built on.

**Porting therefore means rebuilding key custody around a different root of trust — a
security-architecture rewrite, not a HAL call swap.**

## Two claims to stop repeating

**"STM32L4S5 has no HMAC peripheral."** False. From ST's own CMSIS header `stm32l4s5xx.h`: `HASH_BASE`
present at `AHB2PERIPH_BASE + 0x08060400`, `AES_BASE` and `RNG_BASE` likewise; `HASH_CR_MODE` bit 6
selects HMAC mode; `HASH_ALGOMODE_HMAC = HASH_CR_MODE`; ST's HAL exposes `HAL_HMACEx_SHA256_Start`,
`_Start_IT`, `_Start_DMA`. HMAC-SHA256 is hardware-accelerated on this exact part.

What *is* absent, verified: **PKA, CRYP, OTFDEC**. So RSA-3072 would be software bignum — but RSA is
verify/attestation-only in Frostsnap (`secure_boot.rs` RSA-PSS verify, called once from `ota.rs:450`;
`ds.rs` factory attestation), while Bitcoin signing is Schnorr/secp256k1 in `frostsnap_core`. Missing
PKA costs boot latency, not signing.

**The real difference is key custody, not acceleration.** STM32's HASH block has **no key store**. You
feed it the key from flash or RAM, where firmware — and an attacker with code execution — can read it.
That is precisely the property Frostsnap's eFuse design exists to avoid.

## See Also

- [Platform coupling and the DeviceHal seam](platform-coupling-and-the-devicehal-seam.md)
- [Custom firmware on locked devices](custom-firmware-on-locked-devices.md)
- coldcard wiki: [Dual secure element design](../../../coldcard/wiki/concepts/dual-secure-element-design.md)
- coldcard wiki: [Security architecture](../../../coldcard/wiki/topics/security-architecture.md)
- [Thesis: Frostsnap firmware on Coldcard Mk4](../theses/frostsnap-firmware-on-coldcard-mk4.md)
