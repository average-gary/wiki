---
title: "Reproducible Builds — Tools (diffoscope, reprotest, strip-nondeterminism, disorderfs)"
source: https://reproducible-builds.org/tools/
type: article
maintainer: Reproducible Builds project
year: 2013–2026
ingested: 2026-06-15
tags: [reproducible-builds, tools, diffoscope, reprotest, vocabulary]
confidence: high
quality: 5
---

# Reproducible Builds — Tools

Canonical tooling vocabulary for the entire reproducibility field. Any
Nix-for-Bitcoin doc that doesn't cite diffoscope/reprotest is missing the
lingua franca.

## Tools

- **diffoscope** — recursively unpacks archives and renders binary formats
  human-readable to answer "what differs?" between two builds. The first tool
  invoked when two independent Bitcoin Core builders' outputs disagree.
- **reprotest** — varies environment axes (timezone, locale, hostname, build
  path, umask, CPU count) on the same source to surface latent
  non-determinism *before* declaring a Nix derivation reproducible.
- **strip-nondeterminism** — post-process canonicalization (gzip / zip / jar)
  for upstreams that can't be patched. Pragmatic stopgap pattern Nix overlays
  can adopt.
- **disorderfs** — FUSE that randomizes `readdir` order to actively *attack*
  one's own build for directory-order bugs. Useful when Nix sandboxing alone
  may mask such issues.
- **Unreproducible Package** — curated catalogue of failure modes. Useful as
  a checklist when auditing a Bitcoin-Nix derivation.

## Why this matters

The terminology Bitcoin Core's `guix.sigs` workflow inherits comes from this
toolchain: when an attester's hash differs, they run diffoscope. A Nix-built
`bitcoind` aiming to match the Guix hash is, mechanically, a diffoscope
session away from a "matching hashes" claim like
[b10c-matching-hashes-bitcoind-nix-guix-v31](2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md).
