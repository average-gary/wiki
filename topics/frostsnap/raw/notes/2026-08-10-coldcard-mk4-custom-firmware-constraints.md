---
title: "Coldcard Mk4 custom-firmware constraints — bootloader enforcement read from source"
source: "https://github.com/Coldcard/firmware/tree/master/stm32/mk4-bootloader"
type: notes
ingested: 2026-08-10
tags: [coldcard, mk4, bootloader, code-signing, rdp2, pcrop, firewall, pairing-secret, dfu, custom-firmware, brick-risk]
summary: "Enforcement-level audit of what the Coldcard Mk4 bootloader will and will not run, read from the shipping C source rather than docs. verify.c warn_fishy_firmware() sets const int wait = 100 under #if RELEASE, looping delay_ms(250) - 25 seconds of forced warning on every boot - triggered by else if(FW_HDR->pubkey_num == 0) with the comment 'Publically-shared signing key used; firmware is not from Coinkite!'. verify_header() rejects any image whose hdr->magic_value != FW_HEADER_MAGIC where FW_HEADER_MAGIC is 0xCC001234, and further requires a version_string, a timestamp bounds check, pubkey_num < NUM_KNOWN_PUBKEYS (6 keys, index 0 being the shared 'Internet Rando's' key), and uECC_verify(approved_pubkeys[hdr->pubkey_num], fw_check, 32, ...); anti-downgrade is enforced via an OTP min-version check in check_is_downgrade(). Header geometry is FW_HEADER_SIZE 128 at FW_HEADER_OFFSET (0x4000 - FW_HEADER_SIZE). So a raw ELF or bare .bin never boots. firewall.c configures FIREWALL_InitTypeDef with NonVDataSegmentStartAddress = BL_NVROM_BASE and enable.c states the threat model verbatim: 'when RDP=2, this protection still important or else python can read pairing secret'. secrets.h holds pairing_secret[32], mcu_hmac_key[32], and an SE2 struct (pairing[32], pubkey_A[64], auth_pubkey[64]), with contents that 'cannot be changed once unit is bagged and flash protection set'. The only route to the secure elements is firewall_dispatch() in dispatch.c, roughly 25 fixed method numbers (login with PIN = case 18, trick PINs = 22, sign digest = 132, ECDH = 133), guarded by if(len_in > 1024) and a good_addr() pointer check rejecting anything outside SRAM1..BL_SRAM_BASE with EPERM/EACCES, commented 'range check pointers so we aren't tricked into revealing our secrets.' DFU is dead on production units: dispatch.c case 2 returns EPERM with 'we cannot support DFU in secure mode anymore' when flash_is_security_level2(), and main.c has 'LATER: none of this is useful with RDP=2, but okay in the office/factory' plus if(flash_is_security_level2()) { LOCKUP_FOREVER(); }. storage.c flash_lockdown_hard() is documented as 'a one-way trip' and dispatch.c case 102 comments 'production units will be: flash_lockdown_hard(OB_RDP_LEVEL_2); // No change possible after this.' main.c also force-ratchets to level 2 if a bag number is set while the chip is not yet locked. Historical ratchet: commit 58edd613, 2022-01-26, Peter D. Gray, 'Updates for Mk4' deleted from docs/dev-access.md the pre-Mk4 text 'you can take factory-fresh Coldcards, destroy the tamper-evident bag, and load your firmware onto them before shipping to your customers' and the bless-for-green-light path, along with the entire Medium Core REPL/boot2.py override workflow. Licensing: firmware is MIT plus the Commons Clause (COPYING-CC), which strips the right to Sell; hardware/README.md retains Coinkite copyright over schematics and states Coinkite 'does NOT grant license of this information for comercial use'. Verified flash budget from stm32/COLDCARD_MK4/layout.ld: FLASH_TEXT (rx) ORIGIN 0x08024000 LENGTH 1392K, plus FLASH_ISR 16K and FLASH_FS 512K inside a 1984K FLASH region at 0x08020000; stm32/sigheader.h gives FW_MAX_LENGTH_MK4 = 0x200000 - 0x20000 = 1,966,080 bytes."
thesis: frostsnap-firmware-on-coldcard-mk4
relevance: direct
evidence_strength: primary-source-code
direction: opposes
credibility: high
confidence: high
authors: [Coinkite Inc., Peter D. Gray]
fetched: 2026-08-10
---

# Coldcard Mk4 custom-firmware constraints, read from the bootloader

The `coldcard` topic wiki already holds the vendor *docs* for this
([dev-access](../../../coldcard/raw/articles/2026-08-10-coldcard-dev-access.md),
[memory-map](../../../coldcard/raw/articles/2026-08-10-coldcard-memory-map.md),
[secure-elements](../../../coldcard/raw/articles/2026-08-10-coldcard-secure-elements.md)). This note
records what the *enforcing code* does, which is what a port would actually collide with.

## A foreign binary never boots

`verify.c` `verify_header()` requires all of:

- `hdr->magic_value == FW_HEADER_MAGIC` where **`FW_HEADER_MAGIC 0xCC001234`**
- a non-empty `version_string`
- a `timestamp` bounds check
- `pubkey_num < NUM_KNOWN_PUBKEYS` — **6 keys**, index 0 being the shared *"Internet Rando's"* key
- `uECC_verify(approved_pubkeys[hdr->pubkey_num], fw_check, 32, ...)`
- `check_is_downgrade()` against an OTP-held minimum version

Header geometry: `FW_HEADER_SIZE 128` at `FW_HEADER_OFFSET (0x4000 - FW_HEADER_SIZE)`. A raw
`riscv32imc` ELF, or any bare `.bin`, is rejected before execution. An image must be wrapped in a
128-byte Coldcard header and secp256k1-signed.

## The 25-second penalty, quantified in code

`verify.c` `warn_fishy_firmware()`:

```c
const int wait = 100;        // under #if RELEASE
// loops delay_ms(250)  ->  25 seconds
...
else if(FW_HDR->pubkey_num == 0) {
    // "Publically-shared signing key used; firmware is not from Coinkite!"
}
```

Every boot, forever, for key-zero-signed firmware. `docs/dev-access.md` confirms there is no escape:
"in versions before the Mk4, if you had the green light set, via blessing the custom firmware, this
delay/warning could be avoided, **but that is no longer the case**."

## The secure elements are unreachable except through a callgate

`firewall.c` configures `FIREWALL_InitTypeDef` with `NonVDataSegmentStartAddress = BL_NVROM_BASE`.
`enable.c` states the threat model verbatim: **"when RDP=2, this protection still important or else
python can read pairing secret."**

`secrets.h` holds `pairing_secret[32]`, `mcu_hmac_key[32]`, and an SE2 struct (`pairing[32]`,
`pubkey_A[64]`, `auth_pubkey[64]`), whose "contents cannot be changed once unit is 'bagged' and flash
protection set."

The only access path is `firewall_dispatch()` in `dispatch.c` — roughly **25 fixed method numbers**
(login w/ PIN = case 18, trick PINs = 22, sign digest = 132, ECDH = 133), guarded by
`if(len_in > 1024)` and a `good_addr()` pointer check rejecting anything outside `SRAM1..BL_SRAM_BASE`
with `EPERM`/`EACCES`, commented "range check pointers so we aren't tricked into revealing our
secrets."

Consequence for a port: Frostsnap could not drive ATECC608B/DS28C36B directly. It would have to beg
the bootloader for every crypto operation through an ARM-specific ABI it does not implement.

## DFU is fused off and the lockdown is one-way

`dispatch.c` case 2 returns `EPERM` — "we cannot support DFU in secure mode anymore" — when
`flash_is_security_level2()`. `main.c`:

```c
// LATER: none of this is useful with RDP=2, but okay in the office/factory
if(flash_is_security_level2()) {
    // cannot do DFU in RDP=2, so just die. Helps to preserve screen
    LOCKUP_FOREVER();
}
```

`storage.c` `flash_lockdown_hard()` is documented as "a one-way trip," protecting "first 128k-8k
against any writes" (quadrupled from Mk1–3's first 32k). `dispatch.c` case 102: "production units
will be: `flash_lockdown_hard(OB_RDP_LEVEL_2);` // No change possible after this." `main.c`
force-ratchets to level 2 if a bag number is set while the chip is not yet locked — with a candid
comment that this path "has only been called once, and it left the unit with RDP=0xff(1) and not
functional. See issue #1268."

## No iteration loop — bring-up work bricks devices

`docs/dev-access.md`: "your COLDCARD will be bricked if your code crashes before it gets running
'enough' that you can upload a corrected version. Bugs in the boot & login sequence are fatal in that
sense." And SD recovery cannot help: "You cannot load **new** code via the SD Card firmware recovery
mode. It requires the new firmware ... to have a checksum that already matches the value found in
SE1."

Bring-up is precisely a long stream of early-boot crashes. This is the mechanism by which Trezor's
and Krux's ports stalled at exactly the boot/HAL layer.

## The lockdown was a dated, deliberate ratchet

Commit **`58edd613`, 2022-01-26, Peter D. Gray, "Updates for Mk4"** deleted from `docs/dev-access.md`
the pre-Mk4 text, verbatim:

> "- to get green light, the user (who knows the main PIN) must do the **"bless" operation**
> - you can distrubute your DFU file to the world
> - **you can take factory-fresh Coldcards, destroy the tamper-evident bag, and load your firmware
>   onto them before shipping to your customers.**"

A vendor-blessed path for shipping third-party firmware on Coldcard hardware existed from 2018-07-24
(`9f04ac1b`, "Making whole firmware public with single, signed commit") until January 2022, and was
removed for Mk4. The same commit deleted the entire "Medium Core" workflow (virtual disk, REPL,
`lib/boot2.py` overrides), replacing it with "Develop against the Simulator / Submit a PR."

`bless_flash()` still exists in `shared/actions.py` (calling `pa.greenlight_firmware()`), but no
longer buys delay-free custom firmware.

## Licensing bars a commercial result

- Firmware is **MIT + Commons Clause** (`COPYING-CC`), which explicitly strips the right to "Sell."
  Frostsnap is genuinely MIT. A commercial Frostsnap-on-Coldcard product is a license conflict.
- `hardware/README.md`: "Copyright of these files, and all design elements of the Coldcard remain
  with Coinkite Inc… **Coinkite does NOT grant license of this information for comercial use.**"

## Verified flash budget

From `stm32/COLDCARD_MK4/layout.ld`: `FLASH_TEXT (rx) : ORIGIN = 0x08024000, LENGTH = 1392K`, plus
`FLASH_ISR` 16K and `FLASH_FS` 512K within a 1984K `FLASH` region at `0x08020000`.
`stm32/sigheader.h`: `FW_MAX_LENGTH_MK4 = 0x200000 - 0x20000 = 1,966,080` bytes (1920K).

## Absence of prior art

Three independent search engines returned **zero** instances of anyone running third-party,
community, or ported firmware on any Coldcard. The only "forks" found are passive GitHub mirrors of
Coinkite's own tree (`carsonwlee/cold-card-firmware`, `xulytiengviet/Coldcard-firmware`). Key zero
has shipped publicly *specifically to enable custom builds* since 2018 — seven years with no known
third-party Coldcard firmware is a strong signal that the practical barrier is prohibitive.

## See Also

- [Wallet firmware port precedents](2026-08-10-wallet-firmware-port-precedents.md)
- [Flash and resource fit audit](../data/2026-08-10-frostsnap-coldcard-resource-fit-audit.md)
- coldcard wiki: [Security architecture](../../../coldcard/wiki/topics/security-architecture.md)
- coldcard wiki: [Firmware authenticity and upgrades](../../../coldcard/wiki/concepts/firmware-authenticity-and-upgrades.md)
