# Articles Index

> First-party repository documentation from the frostsnap collection ingest, plus thesis-directed
> sources gathered for `theses/frostsnap-firmware-on-coldcard-mk4`.

Last updated: 2026-08-10

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [2026-08-10-frostsnap-readme.md](2026-08-10-frostsnap-readme.md) | Project overview: distributed FROST multisig custody, daisy-chained devices, user-chosen quorum, Taproot single-key on-chain footprint. | frost, threshold-signatures, taproot, bitcoin-self-custody | 2026-08-10 |
| [2026-08-10-frostsnap-security-policy.md](2026-08-10-frostsnap-security-policy.md) | The three-clause security model, coordinated disclosure, 1M-sat bounty, and the malicious-backup/ransom carve-out. | threat-model, security-policy, bug-bounty, coordinator-trust | 2026-08-10 |
| [2026-08-10-frostsnap-key-derivation-design.md](2026-08-10-frostsnap-key-derivation-design.md) | How devices authenticate a coordinator via share images and the reconstructed root polynomial; the rootkey/appkey derivation tree. | key-derivation, coordinator-authentication, root-polynomial, xpub-privacy | 2026-08-10 |
| [2026-08-10-frostsnap-frost-backup-scheme.md](2026-08-10-frostsnap-frost-backup-scheme.md) | 25-BIP39-word share format: 256-bit scalar, 8-bit polynomial checksum, 11-bit words checksum; fingerprint grinding; PK-substitution defense. | frost-backup, shamir-secret-sharing, bip39, polynomial-checksum | 2026-08-10 |
| [2026-08-10-frostsnap-device-provisioning.md](2026-08-10-frostsnap-device-provisioning.md) | Factory provisioning, ESP32 Secure Boot v2 key binding and eFuse burning, dev-vs-prod posture, batch flashing. | secure-boot-v2, device-provisioning, efuse, genuine-certificate | 2026-08-10 |
| [2026-08-10-frostsnap-thaw-recovery-tool.md](2026-08-10-frostsnap-thaw-recovery-tool.md) | Emergency Python tool reconstructing xpriv + Taproot descriptor from shares; Core v28.0/BIP-389 and rescan requirements. | emergency-recovery, xpriv, taproot-descriptor, bip389 | 2026-08-10 |
| [2026-08-10-frostsnap-device-firmware-readme.md](2026-08-10-frostsnap-device-firmware-readme.md) | ESP32-C3 Rust firmware build: riscv32imc target, RISC-V GCC, deterministic builds. | esp32c3, riscv32imc, embedded-rust, deterministic-builds | 2026-08-10 |
| [2026-08-10-frostsnap-flutter-app-readme.md](2026-08-10-frostsnap-flutter-app-readme.md) | Flutter coordinator app build via flutter_rust_bridge; Linux/APK targets. Retains template boilerplate. | flutter, flutter-rust-bridge, coordinator-app | 2026-08-10 |
| [2026-08-10-frostsnap-cst816s-touch-driver.md](2026-08-10-frostsnap-cst816s-touch-driver.md) | no_std CST816S touchpad driver with ESP32-C3 interrupt support; BSD-3-Clause, derived from upstream crates. | cst816s, touchscreen-driver, no-std, hardware-interrupts | 2026-08-10 |
| [2026-08-10-frostsnap-font-generator.md](2026-08-10-frostsnap-font-generator.md) | Python tooling generating Gray4 4-bit anti-aliased fonts as Rust source for embedded-graphics. | embedded-fonts, gray4, embedded-graphics | 2026-08-10 |
| [2026-08-10-frostsnap-desktop-camera.md](2026-08-10-frostsnap-desktop-camera.md) | QR camera capture: V4L2 on Linux, Media Foundation on Windows, mobile_scanner on macOS. | qr-scanning, camera-capture, v4l2, cross-platform | 2026-08-10 |
| [2026-08-10-frostsnap-devicehal-pr-513.md](2026-08-10-frostsnap-devicehal-pr-513.md) | PR #513 `frostsnap-embedded-lift` (open, not merged): six-associated-type `DeviceHal` trait; portable run loop never sees `esp_hal`. | devicehal, portability-seam, pull-request, trait-abstraction | 2026-08-10 |
| [2026-08-10-frostsnap-device-crate-platform-bindings.md](2026-08-10-frostsnap-device-crate-platform-bindings.md) | Measured ESP coupling: 110 `esp_*` occurrences, 86 `esp_hal::` paths, pinned RISC-V target and `linkall.x`; honest estimate 15–20k lines touched. | esp-hal, platform-coupling, riscv32imc, line-counts, rgb565 | 2026-08-10 |
| [2026-08-10-coldcard-musig2-and-frost-paths.md](2026-08-10-coldcard-musig2-and-frost-paths.md) | Coldcard EDGE already ships MuSig2 on Mk4 (BIP-373/390/328) with a documented t-of-n taptree policy; `ngu.secp256k1` MuSig2 API, missing scalar ops, BIP-445 path. | coldcard, musig2, frost, bip-445, libngu, threshold-signing | 2026-08-10 |
| [2026-08-10-embedded-rust-portability-limits.md](2026-08-10-embedded-rust-portability-limits.md) | What `no_std` does and does not buy: `embedded-hal` 1.0 portability, exact `stm32l4s5vi` embassy feature, zero `thumbv*-none-*` CI for the crypto crates, FROST needs `alloc`. | embedded-rust, portability, embedded-hal, embassy, stm32l4s5, ci-targets | 2026-08-10 |

## Categories

- **security-model**: 2026-08-10-frostsnap-security-policy.md, 2026-08-10-frostsnap-key-derivation-design.md
- **backup-recovery**: 2026-08-10-frostsnap-frost-backup-scheme.md, 2026-08-10-frostsnap-thaw-recovery-tool.md
- **device-hardware**: 2026-08-10-frostsnap-device-provisioning.md, 2026-08-10-frostsnap-device-firmware-readme.md, 2026-08-10-frostsnap-cst816s-touch-driver.md
- **app-tooling**: 2026-08-10-frostsnap-flutter-app-readme.md, 2026-08-10-frostsnap-font-generator.md, 2026-08-10-frostsnap-desktop-camera.md
- **overview**: 2026-08-10-frostsnap-readme.md
- **portability-and-porting** (thesis): 2026-08-10-frostsnap-devicehal-pr-513.md, 2026-08-10-frostsnap-device-crate-platform-bindings.md, 2026-08-10-embedded-rust-portability-limits.md
- **coldcard-interop** (thesis): 2026-08-10-coldcard-musig2-and-frost-paths.md

## Recent Changes

- 2026-08-10: Thesis research added 4 sources for `frostsnap-firmware-on-coldcard-mk4` — the `DeviceHal` lift (PR #513), measured ESP coupling in `device/`, Coldcard's shipped MuSig2 + the BIP-445 path, and the limits of embedded-Rust portability.
- 2026-08-10: Collection ingest wrote 11 child sources from `frostsnap/frostsnap` @ `c319850` and `frostsnap/frostsnap-thaw` @ `ad3b637`.
