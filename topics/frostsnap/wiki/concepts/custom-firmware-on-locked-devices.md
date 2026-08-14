---
title: "Custom firmware on locked devices"
category: concept
sources:
  - raw/notes/2026-08-10-coldcard-mk4-custom-firmware-constraints.md
  - raw/notes/2026-08-10-wallet-firmware-port-precedents.md
created: 2026-08-10
updated: 2026-08-10
tags: [code-signing, rdp2, pcrop, dfu, brick-risk, key-zero, commons-clause, custom-firmware, iteration-loop]
aliases: ["key zero", "RDP level 2", "25-second warning", "bricking"]
confidence: high
volatility: cold
verified: 2026-08-10
summary: "A device can be open-source and still be closed to custom firmware. Coldcard Mk4 publishes its firmware under MIT plus the Commons Clause and ships a public non-production signing key ('key zero'), yet the shipping bootloader enforces four independent gates that together make third-party firmware impractical: verify_header() requires magic 0xCC001234, a version string, a timestamp bounds check, pubkey_num below NUM_KNOWN_PUBKEYS (6 keys) and a passing uECC_verify, plus an OTP anti-downgrade check; key-zero images trigger warn_fishy_firmware() with const int wait = 100 looping delay_ms(250) — 25 seconds of forced warning on every boot, forever, with the pre-Mk4 'bless' escape removed; DFU returns EPERM under flash_is_security_level2() and main.c calls LOCKUP_FOREVER(); and flash_lockdown_hard() is documented as 'a one-way trip' to OB_RDP_LEVEL_2. The decisive practical constraint is the missing iteration loop: docs/dev-access.md states bugs in the boot and login sequence brick the unit and SD recovery 'cannot load new code' because the image checksum must already match SE1. That is the exact layer where Trezor's six-year port attempt stalled with HAL complete but boardloader/bootloader unfinished. Seven years of a public key zero have produced zero known third-party Coldcard firmware."
---

# Custom firmware on locked devices

Open source licences describe what you may *do* with code. They say nothing about what the silicon will
*run*. Coldcard Mk4 is the clean illustration: the firmware is published, a public signing key exists
specifically to enable custom builds, and yet no third-party firmware exists after seven years.

## Four independent gates

**1. Header and signature verification.** `verify.c` `verify_header()` requires *all* of:

- `hdr->magic_value == FW_HEADER_MAGIC` — **`0xCC001234`**
- a non-empty `version_string`
- a `timestamp` bounds check
- `pubkey_num < NUM_KNOWN_PUBKEYS` — **6 keys**, index 0 being the shared *"Internet Rando's"* key
- `uECC_verify(approved_pubkeys[hdr->pubkey_num], fw_check, 32, ...)`
- `check_is_downgrade()` against an OTP-held minimum version

Geometry: `FW_HEADER_SIZE 128` at `FW_HEADER_OFFSET (0x4000 - FW_HEADER_SIZE)`. **A raw ELF or bare
`.bin` never boots** — any image must be wrapped in a 128-byte Coldcard header and secp256k1-signed.

**2. The permanent penalty for key zero.** `warn_fishy_firmware()`:

```c
const int wait = 100;        // under #if RELEASE
// loops delay_ms(250)  ->  25 seconds
else if(FW_HDR->pubkey_num == 0) {
    // "Publically-shared signing key used; firmware is not from Coinkite!"
}
```

Every boot, forever. `docs/dev-access.md` closes the escape: "in versions before the Mk4, if you had the
green light set, via blessing the custom firmware, this delay/warning could be avoided, **but that is no
longer the case**."

**3. DFU is fused off.** `dispatch.c` case 2 returns `EPERM` — "we cannot support DFU in secure mode
anymore" — when `flash_is_security_level2()`. `main.c`:

```c
if(flash_is_security_level2()) {
    // cannot do DFU in RDP=2, so just die. Helps to preserve screen
    LOCKUP_FOREVER();
}
```

**4. The lockdown is one-way.** `storage.c` `flash_lockdown_hard()` is documented as "a one-way trip";
`dispatch.c` case 102: "production units will be: `flash_lockdown_hard(OB_RDP_LEVEL_2);` // No change
possible after this." `main.c` force-ratchets to level 2 if a bag number is set on an unlocked chip.

## The decisive constraint is the missing iteration loop

Bring-up on new hardware is a long stream of early-boot crashes — dozens to hundreds of flash cycles.
Mk4 offers no cheap analogue. `docs/dev-access.md`:

> "your COLDCARD will be bricked if your code crashes before it gets running 'enough' that you can
> upload a corrected version. Bugs in the boot & login sequence are fatal in that sense."

And recovery cannot substitute: "You cannot load **new** code via the SD Card firmware recovery mode. It
requires the new firmware ... to have a checksum that already matches the value found in SE1."

This is not an additive cost; it is a **multiplier** on every other task. And it is precisely the layer
where the best-resourced comparable attempt died — Trezor issue #24 closed after six years with HAL
(display, touch, USB) ✅ and all five `modtrezor*` modules ✅, but **`boardloader/bootloader` ❌**.

## The lockdown was a dated, deliberate ratchet

Commit **`58edd613`, 2022-01-26, Peter D. Gray, "Updates for Mk4"** deleted this from
`docs/dev-access.md`:

> "- to get green light, the user (who knows the main PIN) must do the **'bless' operation**
> - you can distrubute your DFU file to the world
> - **you can take factory-fresh Coldcards, destroy the tamper-evident bag, and load your firmware onto
>   them before shipping to your customers.**"

A vendor-blessed path for shipping third-party firmware on Coldcard hardware existed from 2018-07-24
(`9f04ac1b`) until January 2022, and was **removed for Mk4**. The same commit deleted the entire "Medium
Core" workflow (virtual disk, REPL, `lib/boot2.py` overrides), replacing it with "Develop against the
Simulator / Submit a PR." `bless_flash()` survives in `shared/actions.py` but no longer buys
delay-free custom firmware.

## Licensing bars a commercial result

- Firmware is **MIT + Commons Clause** (`COPYING-CC`) — the Commons Clause explicitly strips the right
  to "Sell." Frostsnap is plain MIT, so a commercial Frostsnap-on-Coldcard product is a licence
  conflict.
- `hardware/README.md`: "Copyright of these files, and all design elements of the Coldcard remain with
  Coinkite Inc… **Coinkite does NOT grant license of this information for comercial use.**"

## Absence of prior art as evidence

Three independent search engines return **zero** instances of anyone running third-party, community, or
ported firmware on any Coldcard. The only "forks" are passive GitHub mirrors of Coinkite's own tree.
Key zero has shipped publicly *specifically to enable custom builds* since 2018. **Seven years, zero
results** — the strongest available signal that the practical barrier is prohibitive rather than merely
inconvenient.

Contrast the direction of travel elsewhere: SeedSigner is moving *toward* ESP32 because it has secure
boot. Nobody is moving *onto* a locked commercial device.

## See Also

- [Root-of-trust portability](root-of-trust-portability.md)
- [Porting Frostsnap to other hardware](../topics/porting-frostsnap-to-other-hardware.md)
- [Wallet firmware port outcomes](../references/wallet-firmware-port-outcomes.md)
- coldcard wiki: [Reproducible builds and developer access](../../../coldcard/wiki/concepts/reproducible-builds-and-developer-access.md)
- coldcard wiki: [Firmware authenticity and upgrades](../../../coldcard/wiki/concepts/firmware-authenticity-and-upgrades.md)
