---
title: "Model and version matrix"
category: reference
sources:
  - raw/articles/2026-08-10-coldcard-security-model.md
  - raw/articles/2026-08-10-coldcard-firmware-readme.md
  - raw/articles/2026-08-10-coldcard-secure-elements.md
  - raw/articles/2026-08-10-coldcard-hardware-details.md
  - raw/articles/2026-08-10-coldcard-menu-tree.md
  - raw/articles/2026-08-10-coldcard-limitations.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, models, mk1, mk3, mk4, mk5, q1, firmware-branches, capability-matrix, reference]
aliases: ["which model", "Mk4 vs Q", "model comparison", "hardware revisions"]
confidence: medium
volatility: warm
verified: 2026-08-10
summary: "Which hardware has which secure elements, transports and firmware line; which firmware branch serves which model; and a feature-by-model capability matrix with the version each capability arrived in. Includes the board revisions with published schematics and the minimum firmware for each product line under the 2026 entropy advisory."
---

# Model and version matrix

> The single most common error when writing about this device is stating a capability without naming a
> model. This is the table to check against. Where a version is given it is the version from the
> ingested changelogs; see [[release-timeline|Release timeline]]
> ([Release timeline](release-timeline.md)) for dates.

## Hardware generations

| Line | SE1 | SE2 | Settings / PSBT store | Display & input | Firmware line |
|------|-----|-----|----------------------|-----------------|---------------|
| **Mk1** | ATECC508A | — | external SPI serial flash | touch | ≤ 3.0.6 — **bricked by 3.1.0** |
| **Mk2** | ATECC508A | — | external SPI serial flash | membrane keypad | `v4-legacy` |
| **Mk3** | ATECC608A / 608B | — | external SPI serial flash | keypad, OLED | `v4-legacy`, through **4.2.0** |
| **Mk4** | ATECC608 | **DS28C36B** | MCU flash (AES) + **8 MB PSRAM** | keypad, OLED | **5.x** |
| **Mk5** | ATECC608 | DS28C36B | as Mk4 | as Mk4 | **5.x — same binary as Mk4** |
| **Q (Q1)** | ATECC608 | DS28C36B | as Mk4 | **QWERTY keyboard, larger LCD, QR scanner, 3× AAA, 2 SD slots** | **1.x`Q`** |

Storage inside SE1 across generations: Mk1–Mk3 held **72 bytes** behind a 4–12 digit PIN. SE2
(DS28C36B) adds **fifteen 32-byte slots**, and the two chips have a cryptographic link requiring signed
challenges between them.

### Two facts that cause the most confusion

1. **Mk4 and Mk5 run the same firmware binary.** A build for Mk5 supports Mk4 "with no functional
   differences", and `releases/History-Mk4.md` / `History-Mk5.md` are git **symlinks** to a single
   `History-Mk.md`. One release stream, one changelog.
2. **Q is a parallel version line, not a suffix.** `1.4.1Q` is the sibling of `5.5.1`, released the same
   day. Since 2024-05-09 the two lines ship in lockstep on matching dates.

## Firmware branches

| Branch | Serves |
|--------|--------|
| `master` | Mk4, Mk5 (5.x) |
| Q line | Q1 (1.x`Q`) |
| `v4-legacy` | Mk2, Mk3 (4.x) |
| Edge | pre-release line — **no History file in this collection** |

## Minimum firmware under the entropy advisory

The floor for generating any new seed. This is the most operationally important row in the article.

| Line | Fixed at |
|------|----------|
| Mk4 / Mk5 | **5.6.0** |
| Q | **1.5.0Q** |
| Mk3 | **4.2.0** |
| Edge | **6.6.0** |

See [[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)). Note that three of these four
versions are **newer than the last entry in any ingested changelog**.

## Transports by model

| Transport | Mk1–Mk3 | Mk4 | Mk5 | Q |
|-----------|---------|-----|-----|---|
| MicroSD | ✅ | ✅ | ✅ | ✅ **two slots** (A = top) |
| USB | ✅ | ✅ USB-C | ✅ USB-C | ✅ USB-C |
| Virtual disk | — | ✅ | ✅ | ✅ |
| NFC | — | ✅ trace under the `8` key | ✅ coil `L6`, top-right | ✅ sticker behind the display |
| QR scanner + BBQr | — | — | — | ✅ |
| Batteries | — | — | — | ✅ 3× AAA |
| Virtual debug serial | ✅ (disabled by default) | ❌ **replaced by physical UART** | ❌ | ❌ |
| Hardware UART | — | ✅ requires breaking the case | ✅ | ✅ |

Details in [[connectivity-and-nfc|Connectivity and NFC]]
([Connectivity and NFC](../concepts/connectivity-and-nfc.md)).

## Capability matrix

`—` means not available on that line at all; a version means "from this version".

| Capability | Mk3 | Mk4 / Mk5 | Q |
|------------|-----|-----------|---|
| BIP-39 passphrase | 2.0.1 | ✅ | ✅ |
| Lock Down Seed | 2.0.1 | ✅ | ✅ |
| Dice-roll entropy | 2.1.1 | ✅ (minimums from 5.1.0) | ✅ |
| BIP-85 seeds/XPRVs | 3.1.4 | ✅ | ✅ |
| BIP-85 passwords + keyboard EMU | — | **5.0.5** | ✅ all versions |
| Seed XOR | 4.1.0 | ✅ | 1.3.0Q |
| Reproducible builds | 4.0.0 | ✅ | ✅ |
| Secure Device Cloning | 4.0.0 | ✅ | ✅ |
| Trick PINs | — | ✅ (**13** usable slots) | ✅ (**14** slots) |
| Delta Mode | — | ✅ | ✅ |
| Fast Wipe / Fast Brick | — | ✅ | ✅ |
| Kill Key | — | ✅ a **digit** key | ✅ any **letter** (numbers unsupported), active throughout login |
| Login countdown restart on power cycle | — | ✅ up to 28 days | ✅ |
| MicroSD 2FA | — | **5.1.0** | ✅ (enrolled card must be in **slot A**) |
| Web2FA | — | ✅ 8-digit code entry | ✅ **QR** response (32 bytes) |
| Spending Policy — multisig (CCC) | — | **5.4.2** | **1.3.2Q** |
| Spending Policy — single-signer | — | **5.4.4** | **1.3.4Q** |
| Signed exports / `Verify Sig File` | — | **5.1.0** | ✅ |
| Per-script-type BIP-137 header | ≤5.1.0 used P2PKH header | **5.1.0** | ✅ |
| BIP-322 proof of reserves | — | ✅ (global field required from **5.5.1**) | **1.4.1Q** |
| Temporary seeds / Seed Vault | — | **5.2.0** | ✅ |
| WIF Store | — | **5.5.0** | **1.4.0Q** |
| Nuke Device | — | **5.5.0** | **1.4.0Q** |
| Key Teleport | — | — | ✅ **Q only** |
| Secure Notes | — | — | ✅ **Q only** (lost if a Q backup is restored on Mk4) |
| PushTX | — | ✅ | ✅ (multisig finalization from 5.4.2/1.3.2Q) |
| SD Card Recovery Mode | — | ✅ | ✅ **slot A only** |
| PSRAM-staged upgrades | — | ✅ | ✅ |
| Max PSBT | **384 k** | **2 M** | **2 M** |

## Device states (from the menu tree)

Five top-level states, which is why the same menu path can be absent on an apparently identical device:

| State | Meaning |
|-------|---------|
| No PIN set | fresh from the factory |
| Blank wallet | PIN set, no seed |
| Normal operation | the usual case |
| Factory mode | includes **DFU Upgrade** |
| **SSSP** | the hobbled menu under an active single-signer Spending Policy |

Capability guards seen in the tree: `[IF NFC ENABLED]`, `[IF QR SCANNER]`, `[IF VIRTDISK ENABLED]`,
`[IF QWERTY KEYBOARD]`, `[IF SECRET AND NOT TMP SEED]`, `[IF BATTERIES]`.

## Board revisions with published schematics

From `hardware/` — **proprietary**, research and testing only, no commercial use.

| Model | Revision | Files |
|-------|----------|-------|
| Q | rev D | `schematic-q1d.png`, `bom-q1d.xlsx` |
| Mk5 | rev F | `schematic-mark5f.png`, `bom-mark5f.xlsx` |
| Mk4 | rev D | `schematic-mark4d.png`, `bom-mark4d.xlsx` |
| Mk3 | rev B | `schematic-mark3b.png`, `bom-mark3b.xlsx` |

Excluded from the published set: the custom plastic case, the barcoded secure bag, the pin-recovery
card. Coinkite disclaims that the files are "100% current".

Note the labelling oddity, reproduced as published: `schematic-mark5f.png` is described upstream as
"the **Mark4** rev F schematic" while the BOM for the same revision is labelled Mk5 — consistent with
Mk4 and Mk5 being one design lineage.

## A size discrepancy worth knowing about

Two first-party documents disagree about PSBT capacity:

| Source | Claim |
|--------|-------|
| `security-model.md` | 8 MB PSRAM "permits transaction sizes up to **1 MB**" |
| `limitations.md` and the 5.0.0 changelog | **2 MB** PSBTs supported on Mk4 |

Most likely the security-model figure predates a later increase and was not revised, but nothing in
these sources says so. Both are recorded rather than reconciled.

## Evidence status

`confidence: medium`. Hardware part numbers, transport availability and board revisions are first-party
and specific. The version numbers in the capability matrix come from changelog entries, which is the
strongest evidence in the collection — but the matrix is assembled by cross-referencing several
documents, so an omission here means "not stated in these sources", not "not supported". Q-line version
gates are inferred from same-date sibling releases where the Q changelog entry is terse; those are
marked with the Q version where the Q file states it and with ✅ where only the Mk entry is explicit.
Mk1 and Mk2 are documented only in passing. `volatility: warm` because the matrix gains a row with each
release and the advisory floors will move again.

## See Also

- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — the generations in prose
- [[release-timeline|Release timeline]] ([Release timeline](release-timeline.md)) — dates for every version cited here
- [[device-limits|Device limits]] ([Device limits](device-limits.md)) — the per-model ceilings
- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)) — the minimum-firmware table
- [[security-architecture|Security architecture]] ([Security architecture](../topics/security-architecture.md)) — how the Mk3 → Mk4 change altered the threat model
- [[dual-secure-element-design|Dual secure-element design]] ([Dual secure-element design](../concepts/dual-secure-element-design.md)) — SE1/SE2 part numbers and roles
- [[memory-map-and-key-slots|Memory map and key slots]] ([Memory map and key slots](memory-map-and-key-slots.md)) — the Mk3 and Mk4 flash layouts
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — per-model transports and antennas
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)) — slot counts and Kill Key differences
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)) — the SSSP state and 2FA differences
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](signing-formats.md)) — which models can return signatures by QR
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)) — PSRAM staging and SD recovery, Mk4 and later
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — Key Teleport is Q-only
- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — the transports and workflows each model supports
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](../concepts/temporary-seeds-and-seed-vault.md)) — temporary seeds and Seed Vault arrived at 5.2.0

## Sources

- [Security model](../../raw/articles/2026-08-10-coldcard-security-model.md) — generation progression, SE part numbers and slot counts, Kill Key per model, SPI flash removal, PSRAM, SD Card Recovery Mode slot A
- [Firmware README](../../raw/articles/2026-08-10-coldcard-firmware-readme.md) — branch-to-model mapping, Mk4/Mk5 shared binary, per-line advisory fix versions
- [Dual secure elements](../../raw/articles/2026-08-10-coldcard-secure-elements.md) — Mk4/Q dual-SE scope, SE1 usage differences from Mk3
- [Hardware details](../../raw/articles/2026-08-10-coldcard-hardware-details.md) — board revisions, schematic and BOM filenames, exclusions, licence
- [Menu tree](../../raw/articles/2026-08-10-coldcard-menu-tree.md) — the five device states and capability guards
- [Limitations](../../raw/articles/2026-08-10-coldcard-limitations.md) — per-model PSBT and transaction ceilings, Trick PIN slot counts, Q-backup-on-Mk4 note
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — version gates for the 5.x capabilities
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — version gates for the Q-line capabilities
