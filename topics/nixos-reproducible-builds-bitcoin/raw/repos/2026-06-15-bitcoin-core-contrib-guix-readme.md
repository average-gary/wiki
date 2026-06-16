---
title: "Bitcoin Core contrib/guix — Bootstrappable Bitcoin Core Builds"
source: https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md
attestation_repo: https://github.com/bitcoin-core/guix.sigs
type: repo
maintainer: Bitcoin Core project (bitcoin/bitcoin)
year: 2021–2026
ingested: 2026-06-15
tags: [bitcoin-core, guix, deterministic-build, contrib, primary-source]
confidence: high
quality: 5
---

# Bitcoin Core `contrib/guix/` — Bootstrappable Bitcoin Core Builds

Canonical articulation of why Bitcoin Core uses Guix — and the reference doc
that any Nix-based alternative must benchmark against.

## Key claims

- **Why Guix**: bootstrappable builds let users "audit and reproduce our
  toolchain instead of blindly trusting binary downloads."
- **Mechanism stack**: functional package management, fixed `SOURCES_PATH`,
  `BASE_CACHE`, `SDK_PATH`, `guix shell` containerization, `SOURCE_DATE_EPOCH`
  for timestamp determinism.
- **Default host triples**: Linux (x86_64, arm, aarch64, riscv64, ppc64,
  ppc64le), Windows (x86_64-w64-mingw32), macOS (x86_64 and arm64).
- **Attestation**: `bitcoin-core/guix.sigs` — developers GPG-sign per-arch
  `SHA256SUMS`, mirroring Gitian's flow.
- **No mention of Nix** — the doc doesn't entertain Nix as alternative.

## Why this matters

This is the reference document defining what "reproducible Bitcoin build"
means at the upstream-Core level today. Any Nix-based effort (including
[b10c-matching-hashes-bitcoind-nix-guix-v31](../articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md))
must produce a binary whose SHA-256 matches the Guix output described here.
