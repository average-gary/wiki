---
title: "Collection: frostsnap (GitHub org)"
source: "https://github.com/frostsnap"
type: repos
ingested: 2026-08-10
tags: [collection, collection-manifest, git, frostsnap, frost, threshold-signatures, bitcoin-custody, esp32]
summary: "Manifest for a git collection ingest of the frostsnap GitHub organization: 11 child sources captured from frostsnap/frostsnap at c319850 and frostsnap/frostsnap-thaw at ad3b637. Covers the FROST threshold-signature Bitcoin custody system — ESP32-C3 device firmware, Flutter coordinator app, key-derivation/recovery design, the 25-word share backup scheme, secure-boot provisioning, and the emergency Python recovery tool."
collection: "frostsnap"
adapter: git
revision: "c319850a77cf077febbd9bccd9dffdf7b666b009"
canonical_url: "https://github.com/frostsnap/frostsnap"
license: "MIT"
---

# Collection: frostsnap (GitHub org)

Org-level git collection ingest of [github.com/frostsnap](https://github.com/frostsnap) —
"Ultimate Bitcoin Security", [frostsnap.com](https://frostsnap.com),
[@FrostsnapTech](https://x.com/FrostsnapTech).

Frostsnap is a distributed multisignature Bitcoin self-custody system built on
FROST threshold Schnorr signatures. Keys live as Shamir shares across multiple
daisy-chainable ESP32-C3 devices; a configurable `t`-of-`n` quorum (e.g. 2-of-3)
must cooperate to sign. Because Taproot enables Schnorr threshold signatures,
the wallet presents a single public key on-chain: single-sig fee profile, hidden
multisig for privacy.

## Repositories in scope

| Repo | Role | HEAD at ingest | Language | License | Ingested |
|------|------|----------------|----------|---------|----------|
| [frostsnap/frostsnap](https://github.com/frostsnap/frostsnap) | Firmware + software monorepo (primary) | `c319850a77cf077febbd9bccd9dffdf7b666b009` | Rust, Dart | MIT | 10 children |
| [frostsnap/frostsnap-thaw](https://github.com/frostsnap/frostsnap-thaw) | Emergency Python recovery tool | `ad3b6373fa72b42f75b3d456f2b7444547fe030b` | Python | (unstated in repo) | 1 child |

### Excluded from this collection

Four repos in the org are **forks of upstream Espressif/embedded projects**, not
first-party Frostsnap work. They are dependencies-by-vendoring, not sources
about Frostsnap, so no child sources were written for them:

| Fork | Upstream purpose | License |
|------|------------------|---------|
| `esp-hal` | `no_std` HALs for ESP32 microcontrollers | Apache-2.0 |
| `esp-pacs` | Peripheral Access Crates for Espressif SoCs | Apache-2.0 |
| `esp-display-interface-spi-dma` | Rust SPI display interface with DMA for ESP32 | Apache-2.0 |
| `esp-idf` | Espressif IoT Development Framework | Apache-2.0 |

## Child source selection

The primary repo is a **code monorepo, not a docs repo** — 26 text-like files
matched, but most are Flutter/CMake scaffolding. Included: the 10 substantive
prose documents. Excluded as build scaffolding, vendored, generated, or
boilerplate: `frostsnapp/{linux,windows}/**/CMakeLists.txt`,
`frostsnapp/rust_builder/**`, `frostsnap_factory/bootloader/**/CMakeLists.txt`,
`frostsnapp/assets/google_fonts/OFL.txt` (font license),
`frostsnap_fonts/font_tools/requirements.txt` (empty),
`frostsnap_fonts/font_tools/generated/README.md`, and
`frostsnapp/ios/Runner/Assets.xcassets/.../README.md`.

| # | Child source | Upstream path | Blob SHA |
|---|--------------|---------------|----------|
| 1 | [Frostsnap README](../articles/2026-08-10-frostsnap-readme.md) | `README.md` | `66ff7b5` |
| 2 | [Security Policy & Threat Model](../articles/2026-08-10-frostsnap-security-policy.md) | `SECURITY.md` | `99130a1` |
| 3 | [Key Derivation and Recovery Design](../articles/2026-08-10-frostsnap-key-derivation-design.md) | `docs/key-derivation-design.md` | `09e04ab` |
| 4 | [FROST Backup Scheme](../articles/2026-08-10-frostsnap-frost-backup-scheme.md) | `frost_backup/README.md` | `0d3f050` |
| 5 | [Device Provisioning & Secure Boot](../articles/2026-08-10-frostsnap-device-provisioning.md) | `frostsnap_factory/PROVISIONING.md` | `6f51c87` |
| 6 | [Device Firmware Build](../articles/2026-08-10-frostsnap-device-firmware-readme.md) | `device/README.md` | `63c7f92` |
| 7 | [Flutter App Build](../articles/2026-08-10-frostsnap-flutter-app-readme.md) | `frostsnapp/README.md` | `3d9df3b` |
| 8 | [CST816S Touch Driver](../articles/2026-08-10-frostsnap-cst816s-touch-driver.md) | `cst816s/README.md` | `a7ca6e3` |
| 9 | [Gray4 Font Generator](../articles/2026-08-10-frostsnap-font-generator.md) | `frostsnap_fonts/font_tools/README.md` | `7d1a500` |
| 10 | [Desktop Camera Capture](../articles/2026-08-10-frostsnap-desktop-camera.md) | `frostsnapp/desktop_camera/README.md` | `b3fb7e7` |
| 11 | [frostsnap-thaw Recovery Tool](../articles/2026-08-10-frostsnap-thaw-recovery-tool.md) | `README.md` (thaw repo) | `08ff6a2` |

## Cargo workspace structure

From `Cargo.toml` at `c319850`. Rust toolchain pinned to **1.88.0** with target
`riscv32imc-unknown-none-elf`; `flake.nix` describes "Frostsnap ESP32-C3
firmware with deterministic builds" on `nixos-25.05`.

| Crate | Purpose |
|-------|---------|
| `frostsnap_core` | Coordinator and signer state management |
| `frostsnap_comms` | Communication protocol and message serialization |
| `frostsnap_coordinator` | Coordinator-side logic |
| `device` | ESP32-C3 firmware (`frostsnap_device`; bins `frontier`, `legacy`) |
| `frostsnap_embedded` | Embedded support layer |
| `frostsnap_factory` | Factory provisioning / batch flashing |
| `frostsnap_secure_boot` | ESP32 Secure Boot v2 signing |
| `frost_backup` | Shamir share ↔ 25-word BIP39 mnemonic encoding |
| `frostsnap_fonts` | Gray4 embedded fonts |
| `frostsnap_widgets` | Embedded UI widgets |
| `frostsnapp/rust` | Rust core behind the Flutter app (`flutter_rust_bridge`) |
| `frostsnapp/desktop_camera` | Linux/Windows camera capture for QR scanning |
| `cst816s` | `no_std` CST816S touchpad driver (BSD-3-Clause) |
| `macros` | `frostsnap_macros` proc macros |
| `tools/widget_simulator`, `tools/stack_check` | Dev tooling (SDL2; stack analysis) |

`device` and `cst816s` require riscv32 and `widget_simulator` needs SDL2, so
they are excluded from `default-members` to keep a root `cargo check` working.

## Cryptography

FROST is implemented via the team's own [secp256kfun](https://docs.rs/schnorr_fun/latest/schnorr_fun/frost/index.html)
(`schnorr_fun::frost`), tracking [the FROST paper](https://eprint.iacr.org/2020/852.pdf).

## Provenance and confidence notes

- Repository content is **first-party project documentation** — authoritative
  for what Frostsnap's design and build process *claims to be*, not independent
  verification that the security model holds. The 1,000,000-sat bounty in
  `SECURITY.md` is the project's own framing of its threat model.
- All crate versions are `0.1.0` (`frostsnap_macros` at `0.0.1`) and the repo
  ships an "AS IS, WITHOUT WARRANTY" disclaimer — treat as pre-1.0 software.
- Copyright: `LICENSE` reads "Copyright (c) 2023 Nick Farrow, Adam Mashrique,
  Lloyd Fournier" (MIT). Original authorship credited to @musdom, @LLFOURN,
  @nickfarrow, @evanlinjin; current org members listed as evanlinjin and
  nickfarrow.
- Repo stats at ingest: 154 stars, 17 forks, 1,251 commits, 40 open issues, 13
  open PRs.
- `frostsnap-thaw` declares no license file; treat licensing as unknown.
