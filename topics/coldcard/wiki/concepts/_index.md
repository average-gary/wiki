---
title: Concepts
type: index
updated: 2026-08-10
---

# Concepts (13)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [entropy-advisory-2026.md](entropy-advisory-2026.md) | **Live advisory.** Seeds generated on-device between 2021 and July 2026 have defective entropy. Fixed at 5.6.0 (Mk4/Mk5), 1.5.0Q, 4.2.0 (Mk3), 6.6.0 (Edge) — three of those versions postdate every ingested changelog. Confidence: high. | coldcard, entropy-bug, security-advisory, seed-generation, trng, hotfix, bip-39 | 2026-08-10 |
| [dual-secure-element-design.md](dual-secure-element-design.md) | SE1 (Microchip ATECC608) plus SE2 (Maxim DS28C36B) from deliberately different vendors; the AES-256-CTR seed key split across MCU/SE1/SE2, Fast Wipe's 256 write-once MCU key slots, and Fast Brick. | coldcard, secure-element, atecc608, ds28c36b, key-hierarchy, aes-256-ctr, hmac-sha256, vendor-diversity | 2026-08-10 |
| [pin-entry-and-rate-limiting.md](pin-entry-and-rate-limiting.md) | Prefix/suffix PIN entry, SE1 key stretching, the 13-attempt counter, login countdown, and why SE2 cannot validate a PIN (no rate limiting, 6 ms per guess). | coldcard, pin, rate-limiting, key-stretching, hmac-sha256, brute-force, login-countdown, atecc608 | 2026-08-10 |
| [anti-phishing-words.md](anti-phishing-words.md) | Two BIP-39 words derived from the PIN prefix via the SE1 `pin stretch` slot — the device-substitution defence, and what it does and does not detect. | coldcard, anti-phishing, evil-maid, bip-39, hmac-sha256, pin, device-substitution | 2026-08-10 |
| [trick-pins-and-duress-wallets.md](trick-pins-and-duress-wallets.md) | Coercion responses stored on SE2: BIP-85 duress wallets at reserved indices, brick-me, wipe variants, Delta Mode's garbage signatures, slot accounting (13 on Mk4, 14 on Q), and the admitted deniability limits. | coldcard, trick-pins, duress-wallet, delta-mode, coercion, bip-85, brick-me, plausible-deniability | 2026-08-10 |
| [seed-generation-and-derivation.md](seed-generation-and-derivation.md) | Where the master secret comes from (TRNG, dice, word/XPRV import, Seed XOR, BIP-85) and everything hanging off it: passphrases, BIP-85 children, Lock Down Seed, the fixed-21-character password path and its QWERTZ trap. | coldcard, seed-generation, trng, dice-rolls, bip-39, bip-32, bip-85, xprv, lock-down-seed, entropy | 2026-08-10 |
| [seed-xor.md](seed-xor.md) | Splitting a BIP-39 seed into N parts that are each themselves valid seed phrases; the open-standard framing, on-device recombination, and why an N−1 subset yields nothing. | coldcard, seed-xor, bip-39, seed-backup, plausible-deniability, xor, seedplate, open-standard | 2026-08-10 |
| [encrypted-backup-and-transfer.md](encrypted-backup-and-transfer.md) | 7z/AES-256 backups keyed by twelve words, Secure Device Cloning, and Q-only Key Teleport (ECDH over BBQr). What a backup carries — and what it silently drops on restore. | coldcard, backup, 7z, aes-256, key-teleport, ecdh, bbqr, cloning, recovery, entropy | 2026-08-10 |
| [temporary-seeds-and-seed-vault.md](temporary-seeds-and-seed-vault.md) | RAM-only ephemeral seeds (5.2.0), the Seed Vault that remembers them, per-wallet settings, and the BIP-39 passphrase reimplemented on this machinery. | coldcard, temporary-seed, ephemeral-seed, seed-vault, bip-39-passphrase, bip-85, tapsigner, ram-only | 2026-08-10 |
| [spending-policy-and-two-factor.md](spending-policy-and-two-factor.md) | CCC / Co-Sign Multisig, single-signer Spending Policy and the SSSP menu state; velocity via `nLockTime` gaps, 25-entry whitelists, MicroSD 2FA and Web2FA (RFC 6238 TOTP with no RTC) — plus Coinkite's own trust admissions. | coldcard, spending-policy, ccc, web2fa, totp, microsd-2fa, bypass-pin, velocity, whitelist, money-manager | 2026-08-10 |
| [firmware-authenticity-and-upgrades.md](firmware-authenticity-and-upgrades.md) | The world checksum written to SE1, the genuine light, code signing and key zero, PCROP and the STM32 firewall, PSRAM-staged upgrades, SD recovery, and STM32 flash ECC (single-bit correct, double-bit NMI). | coldcard, firmware-upgrade, world-checksum, psram, genuine-light, code-signing, pcrop, flash-ecc, recovery | 2026-08-10 |
| [reproducible-builds-and-developer-access.md](reproducible-builds-and-developer-access.md) | Docker `make repro` / `check-repro` / `signit`, the 4.0.0 GPL→MIT+CC relicensing, the simulator and REPL, and the proprietary `hardware/` carve-out (research and testing only). | coldcard, reproducible-builds, docker, supply-chain, signit, key-zero, simulator, repl, licensing | 2026-08-10 |
| [connectivity-and-nfc.md](connectivity-and-nfc.md) | Every I/O path and its per-model availability: MicroSD, USB-C, Virtual Disk, NFC (ISO-15693/NDEF, ≤8000 bytes), QR/BBQr, PushTX — including the "CloudFlare sees all" admission and the empty upstream NFC examples section. | coldcard, nfc, iso-15693, ndef, pushtx, virtual-disk, microsd, bbqr, usb, antenna | 2026-08-10 |

## Recent Changes

- 2026-08-10: 13 concept articles compiled from the coldcard collection at revision `43b2139`.
