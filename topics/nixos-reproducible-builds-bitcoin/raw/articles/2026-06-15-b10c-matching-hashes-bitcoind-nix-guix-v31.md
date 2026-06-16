---
title: "Matching Hashes: Reproducing the Guix-built Bitcoin Core release binary with Nix"
source: https://b10c.me/projects/027-bitcoind-gunix-match/
companion_repo: https://github.com/0xB10C/bitcoind-gunix
type: article
author: 0xB10C (independent Bitcoin developer; OpenSats LTS grantee)
year: 2026
ingested: 2026-06-15
tags: [nix, guix, bitcoin-core, reproducible-builds, case-study, primary-source]
confidence: high
quality: 5
---

# Matching Hashes: Reproducing the Guix-built Bitcoin Core release binary with Nix

The single strongest practitioner artifact in the entire Nix-for-Bitcoin
space — a public, dated, hash-verified demonstration that a Nix-built
`bitcoind` v31.0 (x86_64-pc-linux-gnu) can match the official Guix release
binary at the SHA-256 level.

## Key claims

- **First independent Nix build to match Guix at the hash level** for Bitcoin
  Core (v31.0, Linux x86_64 only).
- ~3 years of effort; final ~80 commits driven by Claude Sonnet/Opus on a
  heavy VM for ~1.5 weeks.
- Required pragmatic post-build patching: hardcoded glibc ELF note replacements
  and a final-binary debug-section CRC32 fixup. *Matching was not achieved by
  toolchain alignment alone.*
- Companion repo `github.com/0xB10C/bitcoind-gunix` (tag `v31.0-match`)
  contains the patching logic.
- Verifier model: anyone running the same flake.nix can rebuild and compare to
  Guix release artifacts — a second independent path beyond the Guix builder
  cohort.

## Limitations

- Linux x86_64 only — no Darwin/Windows cross-compile.
- Resulting binary is not directly runnable on NixOS without compat shims.
- Community pushback (NixOS Discourse): the post-build patching is debated as
  "matching by patching" rather than true toolchain reproducibility.

## Why this matters

Real-world demonstration of the gap between Nix and Guix on Bitcoin Core. The
patches required to close the gap reveal *exactly* what the two toolchains
disagree about (linker metadata, debug-section CRC32) — a useful map for any
future Nix-on-Bitcoin reproducibility effort.
