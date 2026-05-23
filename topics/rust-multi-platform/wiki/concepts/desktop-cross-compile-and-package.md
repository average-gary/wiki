---
title: "Desktop cross-compile + package — the 2025-2026 toolchain"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: hot
confidence: high
sources:
  - raw/repos/2026-05-21-actions-rust-cross.md
  - raw/repos/2026-05-21-cargo-dist.md
  - raw/repos/2026-05-21-cross-rs.md
  - raw/repos/2026-05-21-cargo-zigbuild.md
  - raw/repos/2026-05-21-cargo-xwin.md
  - raw/articles/2026-05-21-cargo-dist-installer-types.md
  - raw/guides/2026-05-21-macos-codesign-notarize.md
  - raw/articles/2026-05-21-microsoft-msix-trusted-signing.md
---

# Desktop cross-compile + package

## TL;DR

The 2025-2026 canonical pattern: **3 GitHub Actions runners (`ubuntu-24.04`, `macos-latest`, `windows-latest`), each native-compiles its own family**, with `cross` for the Linux x86_64 → Linux aarch64 hop. Wrap with [`actions-rust-cross`](../../raw/repos/2026-05-21-actions-rust-cross.md) for the matrix and [`cargo-dist`](../../raw/repos/2026-05-21-cargo-dist.md) for installer generation.

## Tool decision matrix

| Cross direction | Tool |
|-----------------|------|
| Linux-on-Linux native | `cargo` |
| Linux x86_64 → Linux aarch64/musl/embedded | [cross](../../raw/repos/2026-05-21-cross-rs.md) (Docker-based, 60+ targets) |
| Linux → Apple Darwin | [cargo-zigbuild](../../raw/repos/2026-05-21-cargo-zigbuild.md) (Zig-as-linker, NOT cross) |
| Linux/macOS → Windows MSVC | [cargo-xwin](../../raw/repos/2026-05-21-cargo-xwin.md) (auto-downloads MS SDK) |
| macOS → macOS native | `cargo` |
| Apple-Silicon-native + Intel-mac universal | `cargo zigbuild --target universal2-apple-darwin` |
| Linux glibc-version targeting | `cargo zigbuild --target x86_64-unknown-linux-gnu.2.17` |
| Static binaries | musl targets (`x86_64-unknown-linux-musl`) |

## Why no single host does all 6 well

[`cross` cannot do Apple Darwin or MSVC](../../raw/repos/2026-05-21-cross-rs.md) (licensing). [`cargo-zigbuild`](../../raw/repos/2026-05-21-cargo-zigbuild.md) covers Apple but not Windows MSVC. [`cargo-xwin`](../../raw/repos/2026-05-21-cargo-xwin.md) covers Windows MSVC but not Apple. Closest "one box does everything" is **Linux + zigbuild + xwin** — but it's slower and more brittle than just running 3 GitHub runners.

## Canonical 6-target GitHub Actions matrix

```yaml
strategy:
  matrix:
    platform:
      - { os-name: Linux-x86_64,    runs-on: ubuntu-24.04,   target: x86_64-unknown-linux-musl }
      - { os-name: Linux-aarch64,   runs-on: ubuntu-24.04,   target: aarch64-unknown-linux-musl }
      - { os-name: Windows-x86_64,  runs-on: windows-latest, target: x86_64-pc-windows-msvc }
      - { os-name: Windows-aarch64, runs-on: windows-latest, target: aarch64-pc-windows-msvc }
      - { os-name: macOS-x86_64,    runs-on: macOS-latest,   target: x86_64-apple-darwin }
      - { os-name: macOS-aarch64,   runs-on: macOS-latest,   target: aarch64-apple-darwin }
runs-on: ${{ matrix.platform.runs-on }}
steps:
  - uses: actions/checkout@v6
  - uses: houseabsolute/actions-rust-cross@v1
    with:
      command: build
      target: ${{ matrix.platform.target }}
      args: "--locked --release"
      strip: true
```

Source: [actions-rust-cross README](../../raw/repos/2026-05-21-actions-rust-cross.md). Note `actions/checkout@v6` is current 2025-2026.

## Packaging (cargo-dist orchestration)

[`cargo-dist`](../../raw/repos/2026-05-21-cargo-dist.md) (now branded `dist`, v0.31.0 Feb 2026) auto-generates the Actions workflow + tarballs + 5 installer types:

| Strategy | Type | Cross-platform? |
|----------|------|-----------------|
| **Fetching** (curl/irm pipe) | `shell` | ✓ |
| | `powershell` | ✓ |
| | `npm` | ✓ |
| | `homebrew` | ✓ |
| **Bundling** | `msi` (via cargo-wix internally) | Single-platform |

[Open feature requests](../../raw/articles/2026-05-21-cargo-dist-installer-types.md): Linux Docker, Flatpak, macOS DMG/Cask, PyPI, Winget — none with committed timelines.

### Recommended cargo-dist config for indie tools

```toml
# Cargo.toml
[workspace.metadata.dist]
installers = ["shell", "powershell", "homebrew", "msi"]
hosting = ["github"]
```

Add `npm` if you want `npx <tool>` ergonomics. Add `simple` static-file hosting (v0.31+) for a CDN mirror.

## Code signing

### macOS — Apple Developer Program ($99/yr)

[codesign + notarytool workflow](../../raw/guides/2026-05-21-macos-codesign-notarize.md):

```bash
codesign --force --sign "Developer ID Application: <Name> (<TEAMID>)" \
  --options runtime --timestamp <binary-or-app>

xcrun notarytool submit <archive> \
  --apple-id "$AC_USERNAME" --password "$AC_PASSWORD" --team-id "$TEAM_ID" --wait

xcrun stapler staple <archive>
```

GitHub secrets needed: `APPLE_DEVELOPER_CERTIFICATE_P12_BASE64`, `APPLE_DEVELOPER_CERTIFICATE_PASSWORD`, `AC_USERNAME` (Apple ID), `AC_PASSWORD` (app-specific, NOT regular password).

### Windows — Trusted Signing changes the cost game

[Microsoft now recommends Azure Trusted Signing](../../raw/articles/2026-05-21-microsoft-msix-trusted-signing.md) (~$10/mo) over CA-purchased OV/EV certs ($300-700/yr). Reputation is **identity-based**, accumulates across builds. Indie devs can finally afford "real" code signing — was ~$700/yr EV; now ~$120/yr.

Caveat: new apps still show SmartScreen warnings until download history builds (typically several weeks). Always timestamp.

### Linux — usually nothing

AppImage/Snap/Flatpak don't require certificate signing in the same way. Snap requires Canonical store registration. Flathub has a review process.

## Cross-references

- [[release-pipeline-canonical-2026]]
- [[Microsoft MSIX Trusted Signing]]
- [[macOS codesign + notarytool]]
