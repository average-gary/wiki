---
title: "COLDCARD — overview"
category: topic
sources:
  - raw/repos/2026-08-10-collection-coldcard.md
  - raw/articles/2026-08-10-coldcard-firmware-readme.md
  - raw/articles/2026-08-10-coldcard-docs-index.md
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-hardware-details.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, coinkite, hardware-wallet, bitcoin, stm32l4, secure-element, product-lines, anchor]
aliases: ["Coldcard", "COLDCARD wallet", "Coinkite Coldcard"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "Anchor article for the COLDCARD topic. What Coinkite's Bitcoin signing device is, how the six product generations (Mk1–Mk3, Mk4, Mk5, Q) differ, what the firmware repo's docs tree does and does not cover, and the one thing to read before anything else: the 2021–July 2026 poor-entropy advisory. Every other article in this wiki hangs off this one."
---

# COLDCARD — overview

> A Bitcoin-only hardware signing device built by Coinkite Inc. (Toronto) on an STM32L4
> microcontroller with one or two secure elements. Its distinguishing bet is not a novel signing
> protocol but an unusually adversarial *storage* design: the seed is encrypted under a key split
> across three chips from two vendors, and the device is built to assume the attacker already has
> it open on a bench.

## Read this first

The repository README at revision `43b2139` opens with a live security advisory rather than a
product introduction. Firmware from 2021 through July 2026 generated **poor entropy**, and
Coinkite states that secrets created in that window should be regenerated with funds moved on
chain. See [[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)) for the fixed-version floors
per product line and what the advisory does and does not cover. Nothing else on this page matters
as much.

## What it is

COLDCARD is a PSBT signer. It holds a BIP-32 master secret, shows you a transaction on its own
screen, and signs — deliberately without ever being a wallet in the balance-tracking sense. The
watching, coin selection and broadcast all happen on a host, which is why the connectivity story
(MicroSD, USB, NFC, QR, virtual disk) gets as much design attention as the cryptography. See
[[airgap-signing-workflows|Air-gapped signing workflows]]
([Air-gapped signing workflows](airgap-signing-workflows.md)).

Coinkite's own framing for the docs tree is worth quoting, because it sets the register of every
source in this wiki:

> "for you hackers out there... but also for anyone who wants to understand why it's safe to put
> your moneys into Coldcard."

That is an argument, made by the vendor, and this wiki treats it as such. See *Evidence status*
below.

## Product generations

Six generations appear in these documents. They are not interchangeable, and a capability claim
without a model name is frequently wrong for some shipping device.

| Line | Secure elements | Notable hardware | Firmware line |
|------|-----------------|------------------|---------------|
| Mk1 | ATECC508A (SE1 only) | — | bricked by 3.1.0; last support 3.0.6 |
| Mk2 | ATECC508A | membrane keypad replaces touch | `v4-legacy` |
| Mk3 | ATECC608A | larger CPU; bricks after 13 wrong PINs | `v4-legacy`, through 4.2.0 |
| Mk4 | ATECC608 (SE1) + DS28C36B (SE2) | 8MB PSRAM replaces SPI flash; NFC; USB-C | 5.x |
| Mk5 | as Mk4 | revised board ("Mark4 rev F" lineage) | 5.x — same binary as Mk4 |
| Q (Q1) | as Mk4 | QWERTY keyboard, QR scanner, batteries, two SD slots | 1.x`Q` |

Two consequences that trip people up:

- **Mk4 and Mk5 share a firmware binary.** The repo states firmware built for Mk5 supports Mk4
  "with no functional differences", and `releases/History-Mk4.md` and `History-Mk5.md` are both
  git symlinks to the single `History-Mk.md` file. There is one Mk4/Mk5 release history, not two.
- **Q is a parallel version line, not a suffix.** Q releases carry their own numbering (`1.4.1Q`)
  that tracks the Mk4/Mk5 line feature-for-feature but not number-for-number: `1.4.1Q` is the
  sibling of `5.5.1`. See [[release-timeline|Release timeline]]
  ([Release timeline](../references/release-timeline.md)) for the pairing.

The per-feature, per-version breakdown lives in
[[model-and-version-matrix|Model and version matrix]]
([Model and version matrix](../references/model-and-version-matrix.md)).

## The architecture in one paragraph

The MCU holds the encrypted seed in its own internal flash. The AES-256-CTR key that decrypts it
is not stored anywhere: it is derived by HMAC over secrets held separately in SE1, SE2 and a
write-once slot of MCU flash, so all three must be compromised together. SE1 (Microchip) enforces
PIN rate limiting and bricks the device after 13 failures; SE2 (Maxim, deliberately a different
vendor) cannot validate a PIN at all and instead holds Trick PIN slots and spare secrets. The
bootloader lives in PCROP-protected flash, can never be field-upgraded, and gates every
firmware image against five signing keys. See
[[security-architecture|Security architecture]] ([Security architecture](security-architecture.md))
for how the layers compose, and
[[dual-secure-element-design|Dual secure-element design]]
([Dual secure-element design](../concepts/dual-secure-element-design.md)) for the key hierarchy.

## Distinctive features

Things this device does that are unusual enough to be worth naming:

- **Anti-phishing words.** Two BIP-39 words derived from your PIN prefix and a per-chip key,
  shown before you type the rest of your PIN, as an evil-maid detector. See
  [[anti-phishing-words|Anti-phishing words]]
  ([Anti-phishing words](../concepts/anti-phishing-words.md)).
- **Trick PINs.** A menagerie of alternate PINs that wipe, brick, look blank, count down, or open
  a BIP-85-derived duress wallet — enforced in the bootloader and SE2, not in Python. Includes
  Delta Mode, which differs from your real PIN in its last four digits and produces deliberately
  invalid signatures. See [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]]
  ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)).
- **Seed XOR.** Split one BIP-39 seed into N parts that are each themselves a valid BIP-39 seed,
  so every part can plausibly be "the" wallet. See [[seed-xor|Seed XOR]]
  ([Seed XOR](../concepts/seed-xor.md)).
- **Key Teleport.** Move a seed, note, PSBT or whole backup between two Q devices over QR/NFC with
  ECDH plus a spoken 8-character password. See
  [[encrypted-backup-and-transfer|Encrypted backup and transfer]]
  ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)).
- **Spending Policy.** The device signs autonomously inside magnitude, velocity, whitelist and
  2FA limits — the former CCC/HSM feature. See
  [[spending-policy-and-two-factor|Spending Policy and two-factor]]
  ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)).
- **Reproducible builds.** `make repro` rebuilds the published DFU in Docker and hexdump-diffs it
  against the release. See
  [[reproducible-builds-and-developer-access|Reproducible builds and developer access]]
  ([Reproducible builds and developer access](../concepts/reproducible-builds-and-developer-access.md)).
- **Temporary seeds.** Run the device under a throwaway seed — which Coinkite itself says
  "*completely* defeat the design of Coldcard's security model". See
  [[temporary-seeds-and-seed-vault|Temporary seeds and the Seed Vault]]
  ([Temporary seeds and the Seed Vault](../concepts/temporary-seeds-and-seed-vault.md)).

## What the firmware exposes

`docs/menu-tree.txt` is a 724-line indented dump of the whole menu system, annotated with
capability guards — `[IF QR SCANNER]`, `[IF NFC ENABLED]`, `[IF QWERTY KEYBOARD]`,
`[IF SECRET AND NOT TMP SEED]`, `[IF BATTERIES]`. It is the most direct answer to "can the device
do X, and under what conditions", and it distinguishes five top-level device states: no PIN set,
blank wallet, normal operation, factory mode, and SSSP (the hobbled menu under an active
single-signer spending policy). Upstream marks it incomplete and possibly out of date.

Hard ceilings — PSBT sizes, co-signer counts, path depth, slot counts, fee guards — are catalogued
in [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)), which is
Coinkite's own `limitations.md` and the fastest route to an accurate "no".

## Evidence status

Every source in this topic is Coinkite's own documentation, pinned to commit `43b2139` (tip
authored 2026-08-04, subject `rng: discard 12 words after SEIS clear per RM0432 32.3.7`). That
makes it authoritative for **design intent and stated guarantees**, and not independent evidence
that the guarantees hold in silicon. No third-party audit or teardown is attached to any of these
documents. Articles here say "Coinkite states" where the claim rests only on a design doc, and
carry `confidence: medium` for security properties on that footing.

The release histories are the strongest evidence in the collection, because they are dated records
of shipped changes including the project's own bug admissions — the legacy input amount spoofing
fix, the 4.0.1 security fix, the 5.0.6 Virtual Disk hardening, the entropy hotfixes.

Licensing is split and worth stating precisely: firmware and docs are MIT-style, but
`hardware/README.md` states that copyright in the schematics and BOM remains with Coinkite, that
the material is for research and testing only, and that Coinkite "does NOT grant license of this
information for comercial use" [sic].

## Scope of this wiki

In scope: the `coldcard/firmware` docs tree, its architecture READMEs, and the Mk3, Mk4/Mk5 and Q
release histories. Out of scope: the nine other first-party Coldcard repos (`ckcc-protocol`,
`ckbunker`, `psbt_faker`, `push-tx`, `recovery-images`, `wordlist-paper`, `psbt_recovery`,
`modcryptocurrency`, `coldcard-paper-wallet-templator`) and the six vendored forks. Their HEAD SHAs
at discovery are recorded in the collection manifest.

## See Also

- [[security-architecture|Security architecture]] ([Security architecture](security-architecture.md)) — how the MCU, two secure elements and bootloader compose
- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](airgap-signing-workflows.md)) — getting PSBTs in and signatures out
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)) — read before generating any seed
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](../concepts/dual-secure-element-design.md)) — the split-key construction
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](../concepts/pin-entry-and-rate-limiting.md)) — login, delays and the 13-attempt brick
- [[anti-phishing-words|Anti-phishing words]] ([Anti-phishing words](../concepts/anti-phishing-words.md)) — the two-word evil-maid check
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)) — coercion countermeasures
- [[seed-xor|Seed XOR]] ([Seed XOR](../concepts/seed-xor.md)) — deniable N-of-N seed splitting
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — 7z backups, cloning, Key Teleport
- [[temporary-seeds-and-seed-vault|Temporary seeds and the Seed Vault]] ([Temporary seeds and the Seed Vault](../concepts/temporary-seeds-and-seed-vault.md)) — throwaway seeds and their cost
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)) — autonomous signing under limits
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)) — code signing, the genuine light, world checksum
- [[reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](../concepts/reproducible-builds-and-developer-access.md)) — verifying the binary, and building your own
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](../references/model-and-version-matrix.md)) — which model and firmware version for each capability
- [[device-limits|Device limits]] ([Device limits](../references/device-limits.md)) — the catalogue of hard ceilings
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](../references/memory-map-and-key-slots.md)) — flash layout and secure-element slot tables
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](../references/signing-formats.md)) — BIP-137, BIP-322, exports, descriptors
- [[release-timeline|Release timeline]] ([Release timeline](../references/release-timeline.md)) — dated feature and mitigation archaeology
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — the transports that define an air-gapped signer
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](../concepts/seed-generation-and-derivation.md)) — where the master secret comes from

## Sources

- [Collection manifest](../../raw/repos/2026-08-10-collection-coldcard.md) — scope, symlink dedup, org inventory, licensing split
- [Firmware README](../../raw/articles/2026-08-10-coldcard-firmware-readme.md) — security advisory, branches, model support, repro instructions
- [Docs index](../../raw/articles/2026-08-10-coldcard-docs-index.md) — the annotated map of Coinkite's public design record
- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — generation-by-generation architecture summary
- [Hardware details](../../raw/articles/2026-08-10-coldcard-hardware-details.md) — board revisions and the proprietary licence carve-out
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — device states and capability guards
