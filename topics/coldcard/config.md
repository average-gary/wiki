---
title: "coldcard"
description: "COLDCARD — Coinkite's Bitcoin hardware wallet. Dual-secure-element key storage, PIN and anti-phishing design, Trick PINs and duress wallets, backup and transfer schemes, reproducible builds, and the shipped-change record across the Mk3, Mk4/Mk5 and Q product lines."
created: 2026-08-10
freshness_threshold: 70
---

# Wiki Configuration

## Scope

Research on [COLDCARD](https://coldcard.com) ([github.com/coldcard](https://github.com/coldcard)) —
the Bitcoin hardware wallet built by Coinkite Inc. on an STM32L4 MCU with one or two secure
elements. Sourced from the `coldcard/firmware` repository's own design documentation and release
history. Covers:

- **Secure-element architecture**: the Mk1–Mk3 single-element design (Microchip ATECC508A/608B)
  and the Mk4/Mk5/Q dual-element design pairing SE1 (ATECC608) with SE2 (Maxim DS28C36B) from a
  different vendor; the key hierarchy and the split of the seed-encryption key across MCU, SE1 and
  SE2; 32-byte pairing secrets in PCROP/firewalled bootloader flash; why SE2 deliberately cannot
  validate a PIN and what that implies for where rate limiting lives.
- **PIN and login design**: prefix/suffix entry, the two-BIP-39-word anti-phishing response as an
  evil-maid check, attempt counters and punitive delays, secure rate limiting of retries, the
  genuine-vs-caution light and its binding to code signatures and the world checksum.
- **Duress and deniability**: Trick PINs (wipe seed, look blank, brick self, login countdown,
  pretend-wrong-PIN, reboot), BIP-85-derived duress wallets, Delta Mode and its invalid-signature
  behaviour, Fast Wipe's 256 replaceable MCU keys, Fast Brick via pairing-secret rotation, and
  Trick PIN slot accounting.
- **Backup, split and transfer of secrets**: the AES-256 7z backup format and its entropy
  argument, Seed XOR as plausibly deniable N-part BIP-39 splitting, Key Teleport's ECDH +
  AES-256-CTR transfer between Q devices over QR/BBQr/NFC, temporary (ephemeral) seeds and the
  Seed Vault — including the project's own statement that temporary seeds defeat the
  secure-element security model.
- **Signing behaviour and policy**: PSBT limits and multisig constraints, SIGHASH policy, fee
  guards, BIP-322 proof of reserves, BIP-137 message signing and signed exports, and the Spending
  Policy / CCC mode with its bypass PIN, velocity limits, address whitelist and Web2FA.
- **Platform and supply chain**: the memory map and hardware firewall, the bootloader's role and
  limits, developer access with non-production key zero, the PSRAM-staged firmware upgrade and
  world-checksum scheme with its recovery cases, and reproducible builds via Docker.
- **Shipped-change record**: the Mk3, Mk4/Mk5 and Q release histories as dated evidence of when
  features and mitigations landed — including the 2026 entropy bug and its hotfixes.

Out of scope for this topic:

- The nine other first-party Coldcard repos — `ckcc-protocol`, `ckbunker`, `psbt_faker`,
  `push-tx`, `recovery-images`, `wordlist-paper`, `psbt_recovery`, `modcryptocurrency`,
  `coldcard-paper-wallet-templator`. Their HEAD SHAs at discovery are recorded in the collection
  manifest should any be ingested later.
- The six vendored forks in the org (`electrum`, `micropython`, `HWI`, `Bitcoin.org`,
  `bipentropy`, `stm32lib`).
- FROST / threshold-signature self-custody → see hub topic `frostsnap`.
- General Bitcoin wallet-protocol survey work; BIPs are cited here as they bear on Coldcard
  behaviour, not catalogued.

## Conventions

- **Distinguish first-party claims from verified properties.** Every source in this topic is
  Coinkite's own documentation. It is authoritative for *design intent and stated guarantees*, not
  independent evidence that the guarantees hold in hardware. Prefer `confidence: medium` for
  security claims resting only on these docs, and say "Coinkite states" rather than asserting the
  property directly. The release histories are stronger evidence than the design docs, since they
  are dated records of shipped changes.
- **Distinguish product lines.** Mk1/Mk2/Mk3, Mk4, Mk5 and Q differ materially — one secure
  element versus two, SPI serial flash versus PSRAM, no QR scanner versus a scanner and QWERTY
  keyboard. Never state a capability without naming the models it applies to.
- **Pin provenance to commits.** Raw sources carry `revision` (HEAD SHA) and `sha` (blob SHA).
  This is shipping firmware under active development; cite the revision when stating how something
  works, and re-ingest new revisions as new raw sources rather than editing existing ones.
- **Version-gate every behavioural claim.** The docs are dense with "from version 5.1.0…",
  "new in v5.0.7", "requires Mk4, Mk5, or Q". Carry those qualifiers into compiled articles; a
  claim without its version is frequently wrong for some shipping device.
- **Treat the 2026 entropy advisory as live context.** Seeds generated between 2021 and July 2026
  are affected. Any compiled article touching seed generation, backup or recovery must reference
  it and the per-line fixed versions (5.6.0 Mk4/Mk5, 1.5.0Q, 4.2.0 Mk3, 6.6.0 Edge).
- **Respect the licensing split.** Firmware and docs are MIT-style; the `hardware/` design files
  are proprietary, research-and-testing only, with commercial use explicitly not licensed. Do not
  reproduce hardware design material as though it carried the firmware licence.
