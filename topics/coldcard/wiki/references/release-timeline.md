---
title: "Release timeline"
category: reference
sources:
  - raw/articles/2026-08-10-coldcard-release-history-mk3.md
  - raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md
  - raw/articles/2026-08-10-coldcard-release-history-q.md
  - raw/articles/2026-08-10-coldcard-firmware-readme.md
created: 2026-08-10
updated: 2026-08-10
tags: [coldcard, changelog, release-history, versions, dates, feature-archaeology, entropy-advisory, reference]
aliases: ["changelog", "version history", "History-Mk", "History-Q"]
confidence: high
volatility: warm
verified: 2026-08-10
summary: "Every version and date from the three ingested History files — Mk3 (1.0.0r2 through 4.2.0), Mk4/Mk5 (5.0.0 through 5.5.1) and Q (0.0.3Q through 1.4.1Q) — plus a milestone table pinning features to versions. Records the lockstep release pattern between the Mk and Q lines, the missing 5.3.0/1.2.0Q, the duplicated 5.3.3 heading, and the 2065 date typos."
---

# Release timeline

> Feature archaeology for a device whose behaviour is version-gated almost everywhere. Three History
> files were ingested at revision `43b2139`; each ends before the entropy fix for its own line, which
> is the single most important gap in this table. Dates are as printed upstream, **typos included**.

## Milestones

Only features whose version is stated in the ingested sources. Where a Q counterpart shipped the same
day it is given alongside.

| Version | Date | Milestone |
|---------|------|-----------|
| **1.0.0r2** | Aug 2018 | initial public release |
| **2.0.1** | 2019-04-04 | BIP-39 passphrase; **Lock Down Seed** |
| **2.1.0** | 2019-06-26 | XFP display switched to network byte order (`0x0f056943` → `4369050F`) |
| **2.1.1** | 2019-07-03 | **dice-roll entropy** |
| **3.0.2** | 2019-11-01 | `MAX_PATH_DEPTH` set to 12 |
| **3.1.0** | 2020-02-20 | **"NOT COMPATIBLE with Mk1 hardware. It will brick Mk1 Coldcards."** |
| **3.1.4** | 2020-06-12 | **BIP-85** |
| **3.2.1** | 2021-01-08 | duplicate XFP blocked |
| **4.0.0** | 2021-03-17 | **reproducible builds**; **GPL → MIT + CC**; Secure Device Cloning; randomised backup filenames |
| **4.1.0** | 2021-04-29 | **Seed XOR** |
| **4.1.2** | 2021-07-28 | ≤71-byte nonce grinding (thanks @craigraw) |
| **5.0.0** | 2022-03-14 | **Mk4 — new hardware**; 2 MB PSBTs; XFP-of-zero accepted with a warning; `Advanced > Export XPUB`; power-down resets the login countdown |
| **5.0.5** | 2022-07-20 | **BIP-85 passwords** and USB **keyboard emulation** |
| **5.0.6** | 2022-07-29 | Virtual Disk security release |
| **5.0.7** | 2022-10-05 | shipped with **bootrom 3.1.5** — fixes the 7+-Trick-PIN lockout |
| **5.1.0** | 2023-02-27 | **MicroSD 2FA**; dice-roll minimums enforced; **signed exports** and `Verify Sig File`; per-script-type **BIP-137 header byte** |
| **5.2.0** | 2023-10-10 | BIP-39 passphrase reimplemented as a **temporary seed**; passphrase-wallet backup becomes opt-in |
| **5.3.3** / 1.2.3Q | 2024-07-05 | export menus no longer inescapable with NFC **and** VirtDisk disabled |
| **5.4.1** / 1.3.1Q | 2025-02-13 | BIP-32 vs "obsolete" SLIP-132 export toggle |
| **5.4.2** / 1.3.2Q | 2025-04-16 | **CCC**; `Destroy Seed` clears Trick PINs; signing products can leave by a different medium; multisig PushTX finalization |
| **5.4.3** / 1.3.3Q | 2025-05-14 | further export-menu escape fixes |
| **5.4.4** / 1.3.4Q | 2025-09-30 | **single-signer Spending Policy**; CCC renamed **Co-Sign Multisig** |
| **5.5.0** / 1.4.0Q | *2065-03-05* [sic] | **WIF Store**; **Nuke Device** |
| **5.5.1** / 1.4.1Q | 2026-07-01 | WIF watch-only descriptor export; **BIP-322 requires `PSBT_GLOBAL_GENERIC_SIGNED_MESSAGE`**; legacy input-amount spoofing fix (thanks @Damir); NFC tag kept alive for iOS; VirtDisk **and** NFC disabled before HSM; P2PK signing repaired; Delta Mode Trick PIN not restored from backup |
| **1.4.1Q** | 2026-07-01 | major **QR-scanner robustness** work; BIP-21 `amount` decimal-scaling fix |
| **4.2.0** | 2026-07-31 | **entropy hotfix for Mk3** — the only fix release inside these files |

## The entropy advisory sits at the edge of the record

| Line | Last version in the ingested History file | Version that fixes the entropy bug | Documented here? |
|------|------------------------------------------|------------------------------------|------------------|
| Mk4 / Mk5 | 5.5.1 (2026-07-01) | **5.6.0** | **no** |
| Q | 1.4.1Q (2026-07-01) | **1.5.0Q** | **no** |
| Mk3 | 4.2.0 (2026-07-31) | **4.2.0** | **yes** |
| Edge | *no History file in this collection* | **6.6.0** | **no** |

The History files direct readers to `ChangeLog.md` for anything newer, and that file was not part of
this ingest. So for three of four product lines the fix is known only from the README's standing
warning, not from a changelog entry. See
[[entropy-advisory-2026|The 2026 entropy advisory]]
([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)).

## Observations about the record itself

- **Lockstep releases.** From **5.3.1 / 1.2.1Q (2024-05-09)** onward every Mk release has a Q release on
  the *same date*, through 5.5.1 / 1.4.1Q. Reading one line's changelog without the other's is safe from
  that point on; before it, it is not.
- **Missing minors.** The Mk history jumps **5.2.2 → 5.3.1** with no 5.3.0, and the Q history jumps
  **1.1.0Q → 1.2.1Q** with no 1.2.0Q. Both lines skip the same slot.
- **Duplicated heading.** `## 5.3.3 - 2024-07-05` appears **twice** in `History-Mk.md`, and
  `## 1.2.3Q - 2024-07-05` twice in `History-Q.md` — the same upstream duplication in both files.
- **Date typos.** 5.5.0 and 1.4.0Q are both dated **2065-03-05**. From position in the sequence the
  intended date is between 2025-11-03 and 2026-07-01.
- **Symlinks.** `releases/History-Mk4.md` and `releases/History-Mk5.md` are git symlinks to
  `History-Mk.md` — one file, three names, which is why Mk4 and Mk5 share a version stream.

## Full version list — Mk3 line (`History-Mk3.md`)

| Version | Date |
|---------|------|
| 4.2.0 | 2026-07-31 |
| 4.1.9 | 2023-06-26 |
| 4.1.8 | 2023-06-19 |
| 4.1.7 | 2022-11-15 |
| 4.1.6 | 2022-10-05 |
| 4.1.5 | 2022-05-04 |
| 4.1.4 | 2022-04-26 |
| 4.1.3 | 2021-09-02 |
| 4.1.2 | 2021-07-28 |
| 4.1.1 | 2021-04-30 |
| 4.1.0 | 2021-04-29 |
| 4.0.2 | 2021-04-07 |
| 4.0.1 | 2021-03-29 |
| 4.0.0 | 2021-03-17 |
| 3.2.2 | 2021-01-14 |
| 3.2.1 | 2021-01-08 |
| 3.1.9 | 2020-08-06 |
| 3.1.8 | 2020-08-04 |
| 3.1.7 | 2020-07-03 |
| 3.1.6 | 2020-06-14 |
| 3.1.5 | 2020-06-13 |
| 3.1.4 | 2020-06-12 |
| 3.1.3 | 2020-04-30 |
| 3.1.2 | 2020-02-27 |
| 3.1.1 | 2020-02-26 |
| 3.1.0 | 2020-02-20 |
| 3.0.6 | 2019-12-19 |
| 3.0.5 | 2019-11-25 |
| 3.0.4 | 2019-11-13 |
| 3.0.3 | 2019-11-06 |
| 3.0.2 | 2019-11-01 |
| 3.0.1 | 2019-10-10 |
| 2.1.6 | 2019-10-08 |
| 2.1.5 | 2019-09-17 |
| 2.1.4 | 2019-09-11 |
| 2.1.3 | 2019-09-06 |
| 2.1.2 | 2019-08-02 |
| 2.1.1 | 2019-07-03 |
| 2.1.0 | 2019-06-26 |
| 2.0.4 | 2019-05-13 |
| 2.0.3 | 2019-04-25 |
| 2.0.2 | 2019-04-09 |
| 2.0.1 | 2019-04-04 |
| 1.1.1 | Dec 2018 |
| 1.1.0 | Nov 2018 |
| 1.0.2 | Sep 2018 |
| 1.0.1 | Sep 2018 |
| 1.0.0r2 | Aug 2018 |

Note the **five-year gap** between 4.1.9 (June 2023) and 4.2.0 (July 2026): the Mk3 line was
effectively finished, and 4.2.0 exists only because the entropy bug reached back into hardware Coinkite
had stopped developing for.

## Full version list — Mk4 / Mk5 line (`History-Mk.md`)

| Version | Date |
|---------|------|
| 5.5.1 | 2026-07-01 |
| 5.5.0 | *2065-03-05* [sic] |
| 5.4.5 | 2025-11-03 |
| 5.4.4 | 2025-09-30 |
| 5.4.3 | 2025-05-14 |
| 5.4.2 | 2025-04-16 |
| 5.4.1 | 2025-02-13 |
| 5.4.0 | 2024-09-12 |
| 5.3.3 | 2024-07-05 *(heading appears twice)* |
| 5.3.2 | 2024-06-26 |
| 5.3.1 | 2024-05-09 |
| 5.2.2 | 2023-12-21 |
| 5.2.1 | 2023-12-19 |
| 5.2.0 | 2023-10-10 |
| 5.1.4 | 2023-09-08 |
| 5.1.3 | 2023-09-07 |
| 5.1.2 | 2023-04-07 |
| 5.1.1 | 2023-02-27 |
| 5.1.0 | 2023-02-27 |
| 5.0.7 | 2022-10-05 |
| 5.0.6 | 2022-07-29 |
| 5.0.5 | 2022-07-20 |
| 5.0.4 | 2022-05-27 |
| 5.0.3 | 2022-05-04 |
| 5.0.2 | 2022-04-19 |
| 5.0.1 | 2022-03-24 |
| 5.0.0 | 2022-03-14 |

5.1.0 and 5.1.1 share a date (2023-02-27).

## Full version list — Q line (`History-Q.md`)

| Version | Date |
|---------|------|
| 1.4.1Q | 2026-07-01 |
| 1.4.0Q | *2065-03-05* [sic] |
| 1.3.5Q | 2025-11-03 |
| 1.3.4Q | 2025-09-30 |
| 1.3.3Q | 2025-05-14 |
| 1.3.2Q | 2025-04-16 |
| 1.3.1Q | 2025-02-13 |
| 1.3.0Q | 2024-09-12 |
| 1.2.3Q | 2024-07-05 *(heading appears twice)* |
| 1.2.2Q | 2024-06-26 |
| 1.2.1Q | 2024-05-09 |
| 1.1.0Q | 2024-04-02 |
| 1.0.1Q | 2024-03-14 |
| 1.0.0Q | 2024-03-10 |
| 0.0.8Q | 2024-03-02 |
| 0.0.7Q | 2024-02-26 |
| 0.0.6Q | 2024-02-22 |
| 0.0.5Q | 2024-02-16 |
| 0.0.4Q | 2024-02-15 |
| 0.0.3Q | 2024-02-08 — *"first test-only release"* |

The `0.0.x` series is a public beta: six releases in a month, then **1.0.0Q on 2024-03-10**. 0.0.4Q's
entry — *"block firmware upgrade when battery very low"* — is the first Q-specific hazard in the record.

## Evidence status

`confidence: high` for the version numbers and dates: they are verbatim headings from first-party
changelogs at a pinned revision, and the milestone attributions all come from those same entries.
`volatility: warm` because the record is **known incomplete** — `ChangeLog.md` was not ingested, so
anything after 5.5.1 / 1.4.1Q / 4.2.0 is absent, including three of the four entropy fixes. The typo'd
dates and duplicated headings are reproduced rather than corrected, and where a heading gives only a
month (2018 releases) no day is invented.

## See Also

- [[entropy-advisory-2026|The 2026 entropy advisory]] ([The 2026 entropy advisory](../concepts/entropy-advisory-2026.md)) — the fix versions that sit past the end of these files
- [[model-and-version-matrix|Model and version matrix]] ([Model and version matrix](model-and-version-matrix.md)) — which firmware line belongs to which hardware
- [[coldcard-overview|COLDCARD — overview]] ([COLDCARD — overview](../topics/coldcard-overview.md)) — the six generations
- [[device-limits|Device limits]] ([Device limits](device-limits.md)) — limits that changed between releases
- [[signing-formats|Signing formats and standards]] ([Signing formats and standards](signing-formats.md)) — the 5.1.0 header change and signed exports
- [[firmware-authenticity-and-upgrades|Firmware authenticity and upgrades]] ([Firmware authenticity and upgrades](../concepts/firmware-authenticity-and-upgrades.md)) — bootrom versions and the Mk1-bricking release
- [[reproducible-builds-and-developer-access|Reproducible builds and developer access]] ([Reproducible builds and developer access](../concepts/reproducible-builds-and-developer-access.md)) — 4.0.0 repro builds and the licence change
- [[spending-policy-and-two-factor|Spending Policy and two-factor]] ([Spending Policy and two-factor](../concepts/spending-policy-and-two-factor.md)) — 5.1.0, 5.4.2 and 5.4.4
- [[trick-pins-and-duress-wallets|Trick PINs and duress wallets]] ([Trick PINs and duress wallets](../concepts/trick-pins-and-duress-wallets.md)) — bootrom 3.1.5 and the 5.5.1 restore bug
- [[seed-generation-and-derivation|Seed generation and derivation]] ([Seed generation and derivation](../concepts/seed-generation-and-derivation.md)) — 2.1.1, 3.1.4, 5.0.5 and 5.1.0
- [[seed-xor|Seed XOR]] ([Seed XOR](../concepts/seed-xor.md)) — introduced at 4.1.0
- [[temporary-seeds-and-seed-vault|Temporary seeds and Seed Vault]] ([Temporary seeds and Seed Vault](../concepts/temporary-seeds-and-seed-vault.md)) — 5.2.0 passphrase reimplementation
- [[encrypted-backup-and-transfer|Encrypted backup and transfer]] ([Encrypted backup and transfer](../concepts/encrypted-backup-and-transfer.md)) — 4.0.0 cloning, 5.2.0 backup opt-in
- [[connectivity-and-nfc|Connectivity and NFC]] ([Connectivity and NFC](../concepts/connectivity-and-nfc.md)) — the connectivity bugfix history
- [[airgap-signing-workflows|Air-gapped signing workflows]] ([Air-gapped signing workflows](../topics/airgap-signing-workflows.md)) — when each signing transport and integration landed
- [[pin-entry-and-rate-limiting|PIN entry and rate limiting]] ([PIN entry and rate limiting](../concepts/pin-entry-and-rate-limiting.md)) — login-delay and countdown changes by version

## Sources

- [Mk3 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk3.md) — all Mk3-line versions and dates, the standing July 2026 warning, the 4.2.0 hotfix
- [Mk4/Mk5 release history](../../raw/articles/2026-08-10-coldcard-release-history-mk4-mk5.md) — all 5.x versions and dates, milestone entries, the symlink note
- [Q release history](../../raw/articles/2026-08-10-coldcard-release-history-q.md) — all Q-line versions and dates, the 0.0.x beta series, 1.4.1Q parity entries
- [Firmware README](../../raw/articles/2026-08-10-coldcard-firmware-readme.md) — the per-line entropy fix versions, including those absent from the History files
