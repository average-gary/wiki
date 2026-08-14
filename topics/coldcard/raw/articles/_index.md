# Articles Index

> Child sources from the coldcard collection ingest — first-party repository documentation and release history.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-08-10-coldcard-docs-index.md](2026-08-10-coldcard-docs-index.md) | Upstream index of Coldcard's internal developer docs, annotating 28 sibling documents. The authoritative map of Coinkite's public design record. | documentation-index, coinkite | 2026-08-10 |
| [2026-08-10-coldcard-security-model.md](2026-08-10-coldcard-security-model.md) | The central threat model: Mk1–Mk3 single SE to Mk4 dual SE, Trick PINs, BIP-85 duress wallets, Delta Mode, Fast Wipe, PSRAM, Flash ECC. | security-model, threat-model, trick-pins, delta-mode, flash-ecc | 2026-08-10 |
| [2026-08-10-coldcard-secure-elements.md](2026-08-10-coldcard-secure-elements.md) | ATECC608 + DS28C36B from different vendors; pairing secrets in PCROP flash, the split seed-encryption key, the full key table, why SE2 cannot validate a PIN. | secure-element, atecc608, ds28c36b, key-hierarchy, rate-limiting | 2026-08-10 |
| [2026-08-10-coldcard-pin-entry.md](2026-08-10-coldcard-pin-entry.md) | Largest doc in the set: prefix/suffix entry, two-word anti-phishing evil-maid check, brick-me PIN, punitive delays, duress wallets, key layouts, retry rate limiting. | pin, anti-phishing, duress-wallet, rate-limiting, evil-maid | 2026-08-10 |
| [2026-08-10-coldcard-limitations.md](2026-08-10-coldcard-limitations.md) | Coinkite's own catalogue of hard limits and policy choices: PSBT and multisig ceilings, SIGHASH policy, fee guards, slot accounting, no RTC. | limitations, multisig, psbt, sighash, fee-limits | 2026-08-10 |
| [2026-08-10-coldcard-memory-map.md](2026-08-10-coldcard-memory-map.md) | STM32L4 address-space layout per model, the hardware firewall protecting bootloader flash, and nonce-based bootloader hash verification. | memory-map, stm32l4, firewall, pcrop, flash-layout | 2026-08-10 |
| [2026-08-10-coldcard-dev-access.md](2026-08-10-coldcard-dev-access.md) | How external developers build custom firmware with non-production key zero, the permanent warning and delay it earns, and the bricking hazard. | development, firmware-signing, dfu, simulator, key-zero | 2026-08-10 |
| [2026-08-10-coldcard-notes-on-repro.md](2026-08-10-coldcard-notes-on-repro.md) | How `make repro` verifies reproducibility: clean-tree preconditions, Docker build, tmpfs checkout of the official release, byte comparison. | reproducible-builds, docker, supply-chain, verification | 2026-08-10 |
| [2026-08-10-coldcard-upgrade-recovery.md](2026-08-10-coldcard-upgrade-recovery.md) | PSRAM-staged firmware upgrade, the world checksum written to SE1 before flashing, and the power-fail recovery cases. | firmware-upgrade, psram, world-checksum, bricking, recovery | 2026-08-10 |
| [2026-08-10-coldcard-backup-files.md](2026-08-10-coldcard-backup-files.md) | The AES-256 7z backup format, its 12-word TRNG passphrase and ~132-bit entropy argument, and a fully worked decrypt example. | backup, 7z, aes-256, trng, entropy | 2026-08-10 |
| [2026-08-10-coldcard-temporary-seeds.md](2026-08-10-coldcard-temporary-seeds.md) | Temporary/ephemeral seeds and the Seed Vault, with Coinkite's own warning that they defeat the secure-element security model. | temporary-seed, seed-vault, bip-85, ephemeral-seed | 2026-08-10 |
| [2026-08-10-coldcard-seed-xor.md](2026-08-10-coldcard-seed-xor.md) | Splitting one BIP-39 seed into N parts that are each valid BIP-39 seeds; deniability properties, XOR lookup table, worked 24- and 12-word examples. | seed-xor, bip-39, plausible-deniability, seed-backup, duress | 2026-08-10 |
| [2026-08-10-coldcard-key-teleport.md](2026-08-10-coldcard-key-teleport.md) | ECDH + AES-256-CTR transfer of seeds, notes, PSBTs and backups between Q devices over NFC/BBQr, with an out-of-band 8-digit code. | key-teleport, ecdh, aes-256-ctr, bbqr, multisig | 2026-08-10 |
| [2026-08-10-coldcard-spending-policy.md](2026-08-10-coldcard-spending-policy.md) | Autonomous signing under limits: bypass PIN, max magnitude, velocity, 25-address whitelist, Web2FA — and what the mode disables. | spending-policy, ccc, bypass-pin, velocity-limit, whitelist | 2026-08-10 |
| [2026-08-10-coldcard-microsd-2fa.md](2026-08-10-coldcard-microsd-2fa.md) | MicroSD as a login second factor: AES key bound to master secret plus card serial, seed wiped if the card is absent or unknown. | 2fa, microsd, serial-number-binding, seed-wipe | 2026-08-10 |
| [2026-08-10-coldcard-web2fa.md](2026-08-10-coldcard-web2fa.md) | RFC 6238 TOTP on a device with no real-time clock, via a stateless webserver holding an ECC keypair known to firmware. | web2fa, totp, rfc-6238, no-rtc, spending-policy | 2026-08-10 |
| [2026-08-10-coldcard-bip85-passwords.md](2026-08-10-coldcard-bip85-passwords.md) | BIP-85 PWD BASE64 deterministic passwords, up to 10,000 by index, typed to the host via USB keyboard emulation. | bip-85, passwords, keyboard-emulation, usb-hid | 2026-08-10 |
| [2026-08-10-coldcard-msg-signing.md](2026-08-10-coldcard-msg-signing.md) | BIP-137 message signing over USB/SD/NFC/QR, the pre-5.1.0 header-byte compatibility break, on-device verification, and signed exports. | message-signing, bip-137, signed-exports, detached-signature | 2026-08-10 |
| [2026-08-10-coldcard-proof-of-reserves-bip-322.md](2026-08-10-coldcard-proof-of-reserves-bip-322.md) | Coldcard as a BIP-322 PSBT signer for proof of reserves, and the strict PSBT field requirements a PoR request must meet. | bip-322, proof-of-reserves, psbt, to-spend, to-sign | 2026-08-10 |
| [2026-08-10-coldcard-generic-wallet-export.md](2026-08-10-coldcard-generic-wallet-export.md) | The general-purpose JSON export: master XPUB and XFP plus BIP-44/49/84 and BIP-48 (and conditionally BIP-45) derivations. | wallet-export, json, xpub, xfp, bip-48 | 2026-08-10 |
| [2026-08-10-coldcard-bip-21-extensions.md](2026-08-10-coldcard-bip-21-extensions.md) | The `wallet=name` BIP-21 URI parameter that narrows multisig address-ownership search to one wallet. | bip-21, uri, multisig, address-verification | 2026-08-10 |
| [2026-08-10-coldcard-nfc-coldcard.md](2026-08-10-coldcard-nfc-coldcard.md) | NFC on Mk4/Mk5/Q: per-model antenna locations, record types, security notes, and a pointed complaint about paywalled ISO/NFC Forum standards. | nfc, iso-15693, ndef, antenna, standards-paywall | 2026-08-10 |
| [2026-08-10-coldcard-nfc-pushtx.md](2026-08-10-coldcard-nfc-pushtx.md) | Single-tap broadcast of a signed transaction via a phone browser; the `t=`/`c=` base64url URL protocol. | pushtx, nfc, broadcast, base64url, airgap | 2026-08-10 |
| [2026-08-10-coldcard-usb-batteries.md](2026-08-10-coldcard-usb-batteries.md) | Four-line community stub listing USB battery packs without auto-shutoff. Little design content; captured for completeness. | usb-battery, power, hardware-compatibility, stub | 2026-08-10 |
| [2026-08-10-coldcard-electrum-usage.md](2026-08-10-coldcard-electrum-usage.md) | Air-gapped Electrum workflow: Save PSBT, sign on device, broadcast the `-final.txn`; plus seed-import tips. | electrum, airgap, psbt, offline-signing | 2026-08-10 |
| [2026-08-10-coldcard-bitcoin-core-usage.md](2026-08-10-coldcard-bitcoin-core-usage.md) | Bitcoin Core setup via `importdescriptors` into a blank descriptor wallet, for native PSBT generation. | bitcoin-core, descriptors, importdescriptors, hwi, psbt | 2026-08-10 |
| [2026-08-10-coldcard-bitcoin-core-2of2-descriptors.md](2026-08-10-coldcard-bitcoin-core-2of2-descriptors.md) | Worked regtest tutorial building an air-gapped 2-of-2 between an Mk4 and a bitcoind software signer. | multisig, bitcoin-core, descriptors, 2of2, regtest | 2026-08-10 |
| [2026-08-10-coldcard-menu-tree.md](2026-08-10-coldcard-menu-tree.md) | 724-line indented dump of the whole menu system with `[IF …]` capability guards. Reference for what the firmware exposes and when. | menu-tree, ux, navigation, conditional-menus, reference | 2026-08-10 |
| [2026-08-10-coldcard-firmware-readme.md](2026-08-10-coldcard-firmware-readme.md) | Repo front page, opening with the live 2021–July 2026 poor-entropy security advisory and the per-line fixed versions; plus repro-build instructions. | readme, security-advisory, entropy-bug, reproducible-builds | 2026-08-10 |
| [2026-08-10-coldcard-hardware-details.md](2026-08-10-coldcard-hardware-details.md) | Schematic and BOM index by board revision — and the proprietary licence carve-out: research/testing only, no commercial use. | hardware, schematics, bill-of-materials, proprietary-license | 2026-08-10 |
| [2026-08-10-coldcard-bootloader-readme.md](2026-08-10-coldcard-bootloader-readme.md) | Bootloader notes: never field-upgradable, PCROP-protected, OpenOCD debugging recipes. Candid that it protects funds only indirectly. | bootloader, pcrop, firewall, openocd, hardware-debug | 2026-08-10 |
| [2026-08-10-coldcard-release-history-mk4-mk5.md](2026-08-10-coldcard-release-history-mk4-mk5.md) | Mk4/Mk5 history through 5.5.1 (2026-07-01), including the legacy input amount spoofing fix and 2MB PSBT support. | changelog, release-history, mk4, mk5, feature-archaeology | 2026-08-10 |
| [2026-08-10-coldcard-release-history-mk3.md](2026-08-10-coldcard-release-history-mk3.md) | Mk3 history from 1.0.0r2 (Aug 2018) to the 4.2.0 entropy hotfix (31 July 2026), with the standing seed-generation warning. | changelog, release-history, mk3, entropy-bug, hotfix | 2026-08-10 |
| [2026-08-10-coldcard-release-history-q.md](2026-08-10-coldcard-release-history-q.md) | Q line history through 1.4.1Q (2026-07-01), mirroring 5.5.1 plus Q-specific CCC and QR fixes. | changelog, release-history, q1, bip-322, ccc | 2026-08-10 |

## Categories

- **security-architecture**: 2026-08-10-coldcard-security-model.md, 2026-08-10-coldcard-secure-elements.md, 2026-08-10-coldcard-pin-entry.md, 2026-08-10-coldcard-memory-map.md, 2026-08-10-coldcard-bootloader-readme.md
- **duress-deniability**: 2026-08-10-coldcard-seed-xor.md, 2026-08-10-coldcard-spending-policy.md (Trick PINs and Delta Mode are covered inside security-model.md and pin-entry.md)
- **backup-transfer**: 2026-08-10-coldcard-backup-files.md, 2026-08-10-coldcard-temporary-seeds.md, 2026-08-10-coldcard-key-teleport.md
- **authentication-2fa**: 2026-08-10-coldcard-microsd-2fa.md, 2026-08-10-coldcard-web2fa.md, 2026-08-10-coldcard-bip85-passwords.md
- **signing-standards**: 2026-08-10-coldcard-msg-signing.md, 2026-08-10-coldcard-proof-of-reserves-bip-322.md, 2026-08-10-coldcard-generic-wallet-export.md, 2026-08-10-coldcard-bip-21-extensions.md
- **connectivity**: 2026-08-10-coldcard-nfc-coldcard.md, 2026-08-10-coldcard-nfc-pushtx.md, 2026-08-10-coldcard-usb-batteries.md
- **wallet-integration**: 2026-08-10-coldcard-electrum-usage.md, 2026-08-10-coldcard-bitcoin-core-usage.md, 2026-08-10-coldcard-bitcoin-core-2of2-descriptors.md
- **platform-supply-chain**: 2026-08-10-coldcard-dev-access.md, 2026-08-10-coldcard-notes-on-repro.md, 2026-08-10-coldcard-upgrade-recovery.md, 2026-08-10-coldcard-hardware-details.md
- **release-history**: 2026-08-10-coldcard-release-history-mk4-mk5.md, 2026-08-10-coldcard-release-history-mk3.md, 2026-08-10-coldcard-release-history-q.md
- **constraints-reference**: 2026-08-10-coldcard-limitations.md, 2026-08-10-coldcard-menu-tree.md
- **overview**: 2026-08-10-coldcard-docs-index.md, 2026-08-10-coldcard-firmware-readme.md

## Recent Changes

- 2026-08-10: Collection ingest wrote 34 child sources from `coldcard/firmware` @ `43b2139`. Three further in-scope paths were git symlinks to blobs already captured and were not duplicated.
