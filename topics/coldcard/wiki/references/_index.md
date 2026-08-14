---
title: References
type: index
updated: 2026-08-10
---

# References (5)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [model-and-version-matrix.md](model-and-version-matrix.md) | Which hardware has which secure elements, transports and firmware line; the ~26-row capability matrix with version gates; board revisions; the minimum firmware per line under the entropy advisory. Records the 1 MB vs 2 MB PSBT disagreement between two first-party docs. | coldcard, models, mk1, mk3, mk4, mk5, q1, firmware-branches, capability-matrix, reference | 2026-08-10 |
| [release-timeline.md](release-timeline.md) | Every version and date from the three ingested History files (Mk3 1.0.0r2→4.2.0, Mk4/Mk5 5.0.0→5.5.1, Q 0.0.3Q→1.4.1Q) plus a milestone table. Notes the lockstep releases, the missing 5.3.0/1.2.0Q, the duplicated 5.3.3 heading and the 2065-03-05 typos. | coldcard, changelog, release-history, versions, dates, feature-archaeology, entropy-advisory, reference | 2026-08-10 |
| [device-limits.md](device-limits.md) | Hard numbers and refusals: PIN formats and attempt counts, PSBT ceilings (384 k Mk3 / 2 M Mk4+), 15 multisig co-signers, fee and SIGHASH rejections, transport sizes, the change-output script matrix, and the "answers that are wrong rather than absent" cases. | coldcard, limits, limitations, psbt-size, multisig, sighash, microsd, bbqr, secure-notes, reference | 2026-08-10 |
| [signing-formats.md](signing-formats.md) | Standards implemented (BIP-32/39/44/48/67/85/137/174/322, SLIP-132, RFC 6238), the BIP-137 header-byte change at 5.1.0, detached signed-export construction, BIP-322 `to_spend` reconstruction, the Generic JSON export schema and the BIP-21 `wallet=` extension. | coldcard, bip-137, bip-322, bip-174, psbt, message-signing, signed-exports, bip-21, wallet-export, descriptors, reference | 2026-08-10 |
| [memory-map-and-key-slots.md](memory-map-and-key-slots.md) | STM32L4 address-space tables for Mk3 and Mk4 (bootloader, pairing secrets, the 256 write-once MCU key slots, LFS, SRAM), the fifteen named keys with chip and holder, SE2 page assignments, and the bootloader nonce attestation range. | coldcard, memory-map, stm32l4, flash-layout, sram, pcrop, firewall, key-slots, atecc608, ds28c36b, reference | 2026-08-10 |

## Recent Changes

- 2026-08-10: 5 reference articles compiled from the coldcard collection at revision `43b2139`.
