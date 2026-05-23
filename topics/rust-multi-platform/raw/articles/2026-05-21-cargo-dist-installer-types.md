---
title: "cargo-dist installer types — fetching vs bundling"
source: https://axodotdev.github.io/cargo-dist/book/installers/index.html
type: article
tags: [cargo-dist, installers, packaging, distribution]
date: 2026-05-21
quality: 5
confidence: high
agent: 4
summary: "5 installer types in 2 categories. Fetching (cross-platform): shell (curl|sh), powershell (irm|iex), npm, homebrew. Bundling (single-platform): msi via WiX. Linux Docker, Flatpak, macOS DMG, PyPI, Winget all are open feature requests."
---

# cargo-dist installer types

## Two strategies

### Fetching installers (cross-platform)

User runs the same command regardless of OS/CPU; the installer detects target and fetches the right tarball from GitHub Releases.

| Type | Example invocation |
|------|--------------------|
| `shell` | `curl --proto '=https' --tlsv1.2 -LsSf <url> \| sh` |
| `powershell` | `powershell -c "irm <url> \| iex"` |
| `npm` | `npm install -g <package>` (then `npx ...`) |
| `homebrew` | `brew install <tap>/<formula>` |

> "Fetching installers are also easy to make universal (cross-platform)"

### Bundling installers (single-platform)

> "all bundling installers are currently single-platform"

| Type | Notes |
|------|-------|
| `msi` | Windows installer, bundles binaries directly. User must know their CPU arch. |

## Open feature requests (no committed timeline)

- Linux Docker images
- Flatpak
- macOS Cask / DMG
- PyPI packages
- Windows Winget

## Practical recommendation

For a Rust CLI in 2026:
1. Enable `shell` + `powershell` for the curl/irm pipe-install ergonomics
2. Add `homebrew` (cargo-dist auto-publishes formula to a `homebrew-<name>` tap repo)
3. Add `msi` for Windows users who want a real installer
4. Add `npm` if you want `npx <tool>` ergonomics for JS-adjacent users
5. Skip native macOS DMG / Linux Flatpak / winget for now (manual or wait)

## Cross-references

- [[cargo-dist]]
- [[volks73/cargo-wix]]
