---
title: "Security architecture"
category: topic
sources:
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-pin-entry.md
  - raw/articles/2026-08-10-coldcard-memory-map.md
  - raw/articles/2026-08-10-coldcard-bootloader-readme.md
  - raw/articles/2026-08-10-coldcard-upgrade-recovery.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, security-model, threat-model, secure-element, bootloader, pcrop, defence-in-depth]
aliases: ["Coldcard security model", "Coldcard threat model"]
confidence: medium
volatility: warm
verified: 2026-08-10
summary: "How the Coldcard's defences compose: the stated threat model (attacker has the device open on a bench, can probe buses and mount an active MiTM), the four layers (MCU flash, SE1, SE2, PCROP bootloader), what each layer is trusted for, and where the design admits its own limits. Confidence medium: this is Coinkite's design intent with no third-party audit attached."
---

# Security architecture

> The organising claim, stated by Coinkite: on Mk4/Mk5/Q, **SE1, SE2 and the MCU must all three be
> compromised** before the master seed can be extracted. Everything below is the machinery that
> claim rests on, and the places the documents themselves concede it is thinner than it looks.

## The stated threat model

The secure-elements document is explicit about the adversary it designs against, and it is a strong
one. The attacker is assumed to:

- have physical possession, with the case opened (Coinkite treats case damage as detectable, not
  preventive);
- be able to probe the buses between MCU and secure elements;
- be able to de-solder parts and mount an **active man-in-the-middle** on the one-wire and I²C
  links;
- know the device's public data — XPUB, XFP, address history — for example from a recovered
  Electrum wallet file.

What is *not* in the model: an attacker who can defeat the secure elements' own die-level
protections, or who has the factory-secret signing keys. Those are assumed hard.

Two hardware-level attacks are named and specifically countered: UV-C erasure of flash cells (met
with Flash ECC and the world checksum) and PSRAM substitution during an interrupted upgrade (met
with the world checksum). See
[[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]]
([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)).

## Four layers, four jobs

| Layer | Holds | Trusted for |
|-------|-------|-------------|
| MCU internal flash | encrypted seed, settings, 256 write-once MCU keys | keeping the ciphertext; consuming a key slot per Fast Wipe |
| SE1 (ATECC608) | pairing secret, PIN hashes, attempt counter, firmware "world checksum" | PIN validation, rate limiting, the 13-attempt brick, the genuine light |
| SE2 (DS28C36B) | Trick PIN slots, spare secrets, long secret, key shares | holding coercion machinery and one share of the seed key — explicitly **not** PIN validation |
| Bootloader (PCROP flash) | code that talks to both SEs; per-system unique secrets | firmware signature checks, delay enforcement, callgate discipline |

The seed itself is AES-256-CTR encrypted in MCU flash. The key is never stored: it is
`HMAC-SHA256` over secrets drawn from all three chips. The exact construction, the 15-slot key
table and the vendor-diversity argument are in
[[dual-secure-element-design|Dual secure-element design]]
([Dual secure-element design](../concepts/dual-secure-element-design.md)).

## Where rate limiting lives, and why that matters

SE2 **cannot validate a PIN**. It has no rate limiting and answers at roughly a 6ms cadence. So the
entire rate-limiting burden rests on SE1: its attempt counter, its usage-limited HMAC keys, and the
bootloader's 500ms-increment delay loop. This is a deliberate asymmetry, not an oversight — SE2's
job is storage of shares and Trick PIN data, not authentication — but it means SE1 is a
single point of failure for brute-force resistance in a way SE2 is not for confidentiality.

Details, including the measured ~4 second real cost of a PIN attempt and the pre-Mk3 punitive
delay table, are in [[pin-entry-and-rate-limiting|PIN entry and rate limiting]]
([PIN entry and rate limiting](../concepts/pin-entry-and-rate-limiting.md)).

## Generational shift: one element to two

Mk1 through Mk3 had a single secure element (ATECC508A, then 608A on Mk3) holding 72 bytes of
secret behind a 4-to-12-digit PIN. The seed's confidentiality rested on that one chip plus the
pairing secret in MCU flash.

Mk4 added SE2 from a different vendor, with fifteen 32-byte slots, and moved the seed to encrypted
MCU flash with the key split three ways. The design argument is vendor diversity: a break in
Microchip's part is unlikely to also be a break in Maxim's. Mk4 also removed the external SPI
serial flash — a bus an attacker could read — in favour of 8MB PSRAM for transaction staging plus
AES-encrypted settings in MCU flash.

Three capabilities arrived with SE2 that were not possible before: Trick PINs with real
bootloader-level enforcement, Fast Wipe via 256 replaceable MCU key slots, and Fast Brick by
rotating SE1's pairing secret to a random value nobody knows.

## Physical and side-channel posture

- **PCROP / internal firewall.** The bootloader is linked into its own reserved region at the start
  of flash and protected from readback. Accessing the bootloader range from outside triggers a chip
  reset; the callgate wipes bootloader SRAM on both entry and exit. The bootloader README is candid
  that this "protects your currency, but only indirectly. It's more about making your key storage
  per-system unique."
- **Never field-upgradable.** The bootloader cannot be replaced in the field. That removes a whole
  attack class and also means bootloader bugs ship forever — the 5.0.7 note about a bootrom
  workaround for a 7+ Trick PIN failure mode is exactly this cost being paid.
- **LEDs wired to the secure element.** The genuine/caution light is driven from the SE, not from
  firmware, so compromised firmware cannot forge a green light.
- **UART requires case damage.** The developer serial REPL is on test points inside the case.
- **Flash ECC.** 8 bits per 64-bit word, correcting single-bit and detecting double-bit errors,
  raising an NMI crash on failure — explicitly framed as an anti-UV-C-attack measure.
- **Signature grinding and context randomization.** From 5.4.0 libsecp256k1's context is
  re-randomized before each signing session for side-channel resistance.

## Coercion is a separate axis

Physical security answers "can they extract the seed". It does not answer "can they make you open
it". That is the Trick PIN family, Delta Mode, the login countdown, the Kill Key and the brick-me
PIN — see [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)). Note the game
theory Coinkite itself states for Spending Policy: **assume the attacker already has your main
PIN.**

## Admitted limits

Read honestly, the documents concede a fair amount:

- **Temporary seeds bypass the model.** Coinkite writes that they "*completely* defeat the design of
  Coldcard's security model" — a temporary seed lives in RAM, not behind the secure elements.
- **Backups are only as strong as one 12-word passphrase.** ~132 bits, and the 7z container's own
  salt and stretching are explicitly not relied upon.
- **Plausible deniability of backups is limited**, and was weaker before 4.0.0 when the inner
  filename was the fixed `ckcc-backup.txt`.
- **Key zero's private half is published in the GitHub tree.** Custom-firmware builds are a
  supported path; the mitigation is a permanent warning and a delay, not prevention. On Mk4 the
  alert is unconditional.
- **Deliberately no upgrade-recovery key sequence.** If an upgrade is interrupted, only the exact
  interrupted image can be reloaded — chosen over a recovery mechanism an attacker could invoke.
- **NFC traffic is unencrypted** and exposes a 64-bit tag ID during transfers.
- **Web2FA trusts a Coinkite-run server** with an ECC keypair whose public half ships in firmware,
  because the device has no real-time clock.
- **No third-party audit** accompanies any of this.

## Evidence status

`confidence: medium` throughout. These are first-party design documents describing an adversarial
design, without independent verification. The dated release histories are firmer evidence, and they
corroborate the general posture: security fixes ship (4.0.1, 5.0.6 Virtual Disk hardening, the
5.5.1/1.4.1Q legacy input amount spoofing fix) and are described plainly rather than buried. See
[[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)).

## See Also

- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](coldcard-overview.md)) — the anchor article for this topic
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](../concepts/dual-secure-element-design.md)) — the split-key construction in detail
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](../concepts/pin-entry-and-rate-limiting.md)) — where brute-force resistance actually comes from
- [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](../concepts/anti-phishing-words.md)) — detecting a substituted device
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)) — the coercion axis
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)) — code signing, genuine light, world checksum
- [[temporary-seeds-and-seed-vault|Temporary seeds and the Seed Vault]] ([Temporary seeds and the Seed Vault](../concepts/temporary-seeds-and-seed-vault.md)) — the documented exception to the model
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — addresses, slot tables, PCROP regions
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)) — the one failure that defeated all of the above
- [[reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](../concepts/reproducible-builds-and-developer-access.md)) — verifying that the shipped binary is the published source
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — the interfaces each layer has to defend
- frostsnap wiki: [Root-of-trust portability](../../../frostsnap/wiki/concepts/root-of-trust-portability.md) — this architecture contrasted with a threshold-distribution design: `firewall_dispatch()`'s ~25-method callgate versus deriving identity from a read-protected eFuse key, and why neither root of trust can emulate the other
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — what leaves the device, and under what encryption
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — which hardware implements which layer
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)) — the Web2FA server trust exception

## Sources

- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — generational architecture, Trick PINs, Delta Mode, PSRAM, Flash ECC
- [Secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — threat model, key table, why SE2 cannot validate a PIN
- [PIN entry](../../raw/articles/2026-08-10-coldcard-pin-entry.md) — login sequence, delays, genuine light, code signing
- [Memory map](../../raw/articles/2026-08-10-coldcard-memory-map.md) — flash layout, firewall behaviour, boot verification
- [Bootloader README](../../raw/articles/2026-08-10-coldcard-bootloader-readme.md) — PCROP, never-upgradable, candid scope statement
- [Upgrade and recovery](../../raw/articles/2026-08-10-coldcard-upgrade-recovery.md) — world checksum, UV-C and PSRAM-substitution defences
