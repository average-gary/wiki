---
title: "Cross-platform desktop packaging + signing in 2026 — applied to Tauri/Electron"
source: "Synthesis of rust-multi-platform/wiki/concepts/desktop-cross-compile-and-package.md + https://www.electronjs.org/blog (Electron 42 MSIX auto-update)"
type: guide
date_fetched: 2026-05-24
date_published: "2026-05"
tags: [desktop-app, packaging, code-signing, msix, notarization, github-actions]
quality: 5
credibility: high
path: desktop-app-stack
summary: "2026 canonical: 3 GitHub Actions runners (ubuntu-24.04, macos-latest, windows-latest), each native-compiles. macOS notarization via codesign + notarytool ($99/yr Apple Developer). Windows code signing economics changed: Microsoft Trusted Signing (~$120/yr) replaced $300-700/yr OV/EV certs. Electron 42 added MSIX auto-updater; Tauri delegates to cargo-dist (now 'dist' v0.31). For PF2e tool: ship via GitHub Releases with shell+powershell+homebrew+msi installers."
---

# Packaging + signing for the PF2e worldbuilding tool (2026)

## Cross-compile matrix

Use 3 GitHub Actions runners that native-compile their family. Don't try to cross-compile macOS or Windows MSVC from Linux unless you must.

```yaml
matrix:
  - { runs-on: ubuntu-24.04,   target: x86_64-unknown-linux-musl }
  - { runs-on: ubuntu-24.04,   target: aarch64-unknown-linux-musl }
  - { runs-on: windows-latest, target: x86_64-pc-windows-msvc }
  - { runs-on: windows-latest, target: aarch64-pc-windows-msvc }
  - { runs-on: macos-latest,   target: x86_64-apple-darwin }
  - { runs-on: macos-latest,   target: aarch64-apple-darwin }
```

Wrap with `houseabsolute/actions-rust-cross@v1`.

## Packaging tool

**`cargo-dist` / `dist` v0.31.0** (Feb 2026) generates installers for: shell (curl pipe), powershell, npm, homebrew, msi (via cargo-wix). Recommended PF2e install set: `["shell", "powershell", "homebrew", "msi"]`.

For Tauri specifically, `tauri-action` does platform bundling (.app/.dmg, .msi, .deb/.AppImage) — overlap exists; pick one orchestrator.

## macOS code signing + notarization

- **Apple Developer Program**: $99/yr.
- Workflow: `codesign --force --sign "Developer ID Application: <Name> (<TEAMID>)" --options runtime --timestamp <bin>` then `xcrun notarytool submit <archive> --wait` then `xcrun stapler staple`.
- GitHub secrets: `APPLE_DEVELOPER_CERTIFICATE_P12_BASE64`, `APPLE_DEVELOPER_CERTIFICATE_PASSWORD`, `AC_USERNAME`, `AC_PASSWORD` (app-specific, NOT Apple ID password).

## Windows — Trusted Signing changes the indie economics

- **Azure Trusted Signing** ~$10/mo (~$120/yr). Identity-based reputation, accumulates across builds.
- Replaces former indie-killer cost of OV/EV certs ($300-700/yr).
- New apps still SmartScreen-warn until download history accumulates (typically several weeks). Always timestamp.
- **Electron 42** added MSIX auto-updater — cleanest Windows update story in years for Electron apps.

## Linux — usually nothing

- AppImage: no signing required.
- Flatpak: review process via Flathub; recommended for community discoverability.
- Snap: Canonical store registration.

## Recommended PF2e tool pipeline

1. GH Actions matrix → 6 native binaries.
2. Tauri bundler creates .dmg/.msi/.AppImage per platform.
3. macOS notarized via notarytool.
4. Windows signed via Azure Trusted Signing.
5. GitHub Releases hosts artifacts; cargo-dist generates curl/iwr install scripts + Homebrew tap formula.
6. Auto-update: Tauri's built-in updater plugin (signed manifests).
