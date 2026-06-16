---
title: "Perfectly Reproducible, Verified Go Toolchains"
source: https://go.dev/blog/rebuild
related:
  - https://go.dev/blog/supply-chain
  - https://www.agwa.name/blog/post/verifying_go_reproducible_builds
type: article
authors: Russ Cox (Go team); Filippo Valsorda (Go supply chain)
venue: go.dev official blog
year: 2023 (rebuild) + 2022 (supply-chain)
ingested: 2026-06-15
tags: [go, reproducible-builds, trimpath, sumdb, supply-chain]
confidence: high
quality: 5
---

# Go reproducibility — Cox 2023

Why Go is *structurally easier* to reproduce than C++. Combined ingest of:
- Cox 2023 "Perfectly Reproducible, Verified Go Toolchains" — the toolchain milestone
- Valsorda 2022 "How Go Mitigates Supply Chain Attacks" — the dependency layer
- Ayer 2025 "Verifying Go Reproducible Builds" — practitioner caveats

## The recipe (Cox 2023)

```sh
CGO_ENABLED=0 go build -trimpath
```

Two flags. That's it.

- `-trimpath` — strips local source directory from binary
- `CGO_ENABLED=0` — removes host C toolchain, dynamic linker, system libs

## The toolchain milestone

**Go 1.21.0 (August 2023) is the first toolchain that is itself perfectly
reproducible.** Earlier toolchains were "possible to reproduce, but only with
significant effort, and probably no one did."

Bootstrap chain (Ayer 2025): Go 1.4.3 from C → 1.17.13 → 1.20.14 → modern.

## The dependency layer (Valsorda 2022)

- `go.mod` is the **complete source of truth** — no separate
  constraints/lockfile split like npm/pip.
- **Minimal version selection**: transitive deps pinned to versions in the
  dep's own `go.mod`, not floated to latest.
- **Checksum Database (sumdb)**: append-only transparency log. *"Every module
  using v1.9.2 of a dependency uses identical code, preventing targeted
  backdoors even if Google infrastructure were compromised."*
- **Post-install hooks explicitly prohibited**.

## Practitioner caveats (Ayer 2025)

- macOS toolchains contain Google's cryptographic signatures that **cannot
  be reproduced** — must be stripped before comparison.
- Go 1.21.0 was accidentally released with `GOARM=7` instead of `GOARM=6`
  (env-var drift breaks reproducibility silently).
- Go 1.9.2rc2 was an invalid version baked into the immutable transparency
  log — *"transparency logs can't fix or remove entries added by mistake."*
- Original source tarballs aren't in the Checksum Database — gap for
  targeted backdoors.

## Implication for LND under Nix

LND should be MORE reproducible than Bitcoin Core because Go 1.21+ is
structurally easier than C++. The fact that Nixpkgs `lnd` doesn't hash-match
upstream is a **derivation gap, not a toolchain limitation**:

- Nixpkgs sets `CGO_ENABLED=0` ✓
- Nixpkgs does NOT set `-trimpath` ✗
- Nixpkgs does NOT mirror LND's `-X main.Commit=...` ldflags ✗

Closing this is a 1-2 day nixpkgs PR. See
[nixpkgs-lnd-trimpath-gap](../repos/2026-06-15-nixpkgs-lnd-trimpath-gap.md).
