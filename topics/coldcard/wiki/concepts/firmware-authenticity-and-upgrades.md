---
title: "Firmware authenticity and upgrades"
category: concept
sources:
  - raw/articles/2026-08-10-coldcard-upgrade-recovery.md
  - raw/articles/2026-08-10-coldcard-bootloader-readme.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-memory-map.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, firmware-upgrade, world-checksum, psram, genuine-light, code-signing, pcrop, flash-ecc, recovery]
aliases: ["world checksum", "green light", "genuine light", "PSRAM upgrade"]
confidence: medium
volatility: cold
verified: 2026-08-10
summary: "On Mk4/Mk5/Q the upgrade image is staged in volatile PSRAM, factory-signature-checked, then bound to the device by a 'world checksum' written to SE1 before flash is touched — so the green genuine light survives a normal upgrade and a swapped PSRAM image cannot be substituted. Covers the recovery paths after power failure, the deliberate absence of a recovery key sequence, and why flash ECC defeats bit-flip attacks."
---

# Firmware authenticity and upgrades

> The green light means one thing: **the code running on this device is the code that was signed, on
> this device, with these secrets.** The mechanism that makes that statement possible during an
> upgrade is the *world checksum* — a hash over the new firmware *and* the current flash contents,
> written into SE1 before a single byte of flash is erased.

This applies to **Mk4, Mk5 and Q**. Mk1–Mk3 used a different approach: they had a slow external SPI
serial flash chip, which Mk4 replaced with a 64 Mbit quad-SPI PSRAM (**ESP-PSRAM64H**).

## Why PSRAM created a problem

PSRAM is fast and large — excellent as PSBT working space, which is why Mk4 can handle 2MB PSBTs. But
it is **volatile**: it forgets everything at power-down. Staging a firmware image there means a
badly-timed power failure can leave the device with neither the old firmware intact nor the new one
complete. Most products would call that a brick and print a warning. The upgrade-recovery document
exists to explain why the Coldcard does not.

## The upgrade sequence

1. The DFU image (up to about **1.5 MB**) is copied in by USB or SD card.
2. It is staged in **PSRAM**.
3. The user approves and **enters the main PIN**.
4. The image's **factory signature** is checked. Nothing proceeds without a legitimate signing key.
5. A **world checksum** is computed over the new firmware *plus* the current flash contents — including
   the bootloader code, **its secrets**, and the MCU's **unique identity bits**.
6. **Before anything else**, that checksum is written to SE1 (the 608C). Knowledge of the world
   checksum is required at boot to light the green genuine light.
7. At this point the light is still green and the device could **still boot the old firmware**.
8. Flash erase and write begin — about **15 seconds**, because flash is slow.
9. The system resets, re-verifies the signature at boot, and comes up green because the checksum was
   written in advance.

Step 5 is what makes the scheme device-specific: the checksum covers secrets and identity bits unique
to this unit, so a valid checksum for one Coldcard is meaningless on another.

## Recovery cases

At every boot the firmware signature is checked. If it is corrupt or missing, recovery is attempted.

### PSRAM still holds the new image

If the reset happened before flash was fully written, the image may still be in PSRAM. A **full
signature check** runs (so bitrot is caught) — **and** the image must reconstruct the world checksum
already stored in the 608. If it does not, the PSRAM contents are discarded.

That second condition is not belt-and-braces; it defeats a specific documented attack:

1. Corrupt the main firmware slightly — **UV-C light on the bare die**; a single bit flip is enough,
   purely to trigger recovery mode.
2. Replace the PSRAM contents with a different **factory-signed** image — perhaps an older version with
   a feature the attacker wants to abuse.
3. Power up; the device tries to restore from PSRAM.

Signature checking alone would permit step 2, because the substituted image *is* legitimately signed.
The world checksum blocks it: only **the intended image** reconstructs the stored value, and flipping a
few bits with UV-C cannot alter the rest of the firmware to compensate.

### Power failure during the 15-second window

The most likely failure. PSRAM forgets, and no complete copy of firmware exists anywhere on the
device. The Coldcard reads **SD cards** to load replacement firmware — no special preparation needed,
though erasing and formatting FAT32 with just the firmware on it is recommended. The screen shows
**"Insert Card"**; all DFU files found are considered.

The catch, and it is important operationally: you must supply **the exact firmware you were upgrading
to**, because the world checksum is recomputed per candidate image. **You cannot substitute a newer
version.** Signatures are checked as well.

## No recovery key sequence — deliberately

There is **no key combination** to force recovery mode. The reasoning, quoted in substance:

- Recovery only ever replaces the bits you had with **the exact same bits**, so if the firmware is
  already present there is nothing to recover.
- Attackers would not need a key sequence anyway — they can **glitch the clock** or use **UV-C on the
  bare die**.

Coinkite acknowledges this would be "nice to have" for recovering from major firmware bugs, and
declines it because the security model does not allow it. That is a real usability cost accepted for a
security property, and it is worth reading alongside the 2026 entropy advisory: a firmware defect is
precisely the case where a recovery sequence would have helped, and by design there is none. See
[[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](entropy-advisory-2026.md)).

## Flash ECC closes the bit-flip door

The document's closing point, and the most satisfying one: flipping a few flash bits is **not actually
possible**, because the STM32's flash cells all carry **ECC**. Single-bit errors auto-correct;
double-bit errors **stop execution completely**. So the UV-C attack that motivates the world-checksum
policy is itself blocked one layer down — "So good luck attackers, have a nice day!"

Note the belt-and-braces structure this creates: ECC makes the trigger hard, and the world checksum
makes the payload useless even if the trigger works.

## The bootloader side

The verification code lives in the **PCROP-protected bootloader**, which is execute-only — readable
neither by the main firmware nor by a debugger — and is **never field-upgradable**. That is why the
bootloader holds the pairing secrets and enforces login delays: it is the one region an attacker with
firmware-level access still cannot read or modify. Layout and addresses are in
[[memory-map-and-key-slots|Memory map and key slots]]
([Memory map and key slots](../references/memory-map-and-key-slots.md)).

The bootloader README's candid framing of PCROP's value is worth carrying here: it protects the
currency **only indirectly** — the real barrier is the secure element, and PCROP's job is to keep the
code and secrets that talk to it opaque.

## Related menu and version notes

- `Advanced > Danger Zone > Bless Firmware` — accept the currently-running firmware as blessed.
- `Advanced > Upgrade Firmware` in normal operation; **DFU Upgrade** appears in factory mode.
- A live **Spending Policy blocks firmware updates entirely** — see
  [[spending-policy-and-two-factor|Spending Policy and two-factor]]
  ([Spending Policy and two-factor](spending-policy-and-two-factor.md)).
- **3.1.0** carried the blunt warning: "This release is NOT COMPATIBLE with Mk1 hardware. It will
  brick Mk1 Coldcards." Version gating on this device is not advisory.
- **5.0.7** shipped alongside **bootrom 3.1.5**, which addressed the 7+-Trick-PIN lockout.

## Evidence status

`confidence: medium`. The upgrade sequence, the world-checksum policy and the recovery decision tree
are first-party and unusually well-reasoned — the document argues *against* an obvious feature request
and explains why, which is a good sign. The ECC claim is a property of the STM32 part rather than of
Coldcard's code, and is checkable against ST documentation, though nothing here does so. Not covered:
what happens if SE1 is replaced or its stored checksum is lost, and whether a downgrade to an older
signed release is possible outside the recovery path.

## See Also

- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — the bootloader/PCROP layer and its stated limits
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](dual-secure-element-design.md)) — SE1 stores the world checksum and gates the genuine light
- [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](anti-phishing-words.md)) — the complementary check, before login rather than at boot
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — PCROP regions, bootloader addresses, PSRAM
- [[reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](reproducible-builds-and-developer-access.md)) — verifying that a signed binary matches the published source
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](entropy-advisory-2026.md)) — the firmware-defect case where no recovery sequence exists
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](spending-policy-and-two-factor.md)) — an active policy blocks upgrades
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — product context
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — PSRAM is Mk4 and later only
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — bootrom versions and the Mk1-bricking 3.1.0 note

## Sources

- [Upgrade and recovery](../../raw/articles/2026-08-10-coldcard-upgrade-recovery.md) — PSRAM staging, the world checksum, the UV-C/PSRAM substitution attack, power-fail recovery, no-key-sequence rationale, flash ECC
- [Bootloader README](../../raw/articles/2026-08-10-coldcard-bootloader-readme.md) — PCROP protection, never-field-upgradable bootloader, pairing secret handling
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — genuine light and code-signing in the layered model
- [Memory map](../../raw/articles/2026-08-10-coldcard-memory-map.md) — bootloader and PSRAM addresses
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — bootrom 3.1.5 alongside 5.0.7, Bless Firmware
