---
title: "bitcoin-core/guix.sigs — Bitcoin Core Reproducible-Build Attestations"
source: https://github.com/bitcoin-core/guix.sigs
type: data
maintainer: Bitcoin Core project
year: 2021–2026 (live)
ingested: 2026-06-15
tags: [bitcoin-core, guix, attestation, multi-builder, quantitative]
confidence: high
quality: 5
---

# bitcoin-core/guix.sigs

The single most important quantitative dataset for the Bitcoin reproducibility
question — empirical proof of the multi-builder verification model.

## Key data (snapshot 2026-06)

Unique attesters per release (counted from signer-subdirectories):

| Release | Attesters |
|---------|-----------|
| 26.0    | **23** (highest observed) |
| 27.0    | 19 |
| 28.0    | 20 |
| 28.4    | 16 (recent point-release) |

- 367 stars, 281 forks
- Releases tracked: 26.0/26.1/26.2, 27.0/27.1/27.2, 28.0/28.1/28.2/28.3/28.4
  (plus rcs)
- **Two-stage attestation**: stage 1 `noncodesigned` (build from source),
  stage 2 `all` (attach Apple/Microsoft code signatures distributed back to
  builders).

## Why this matters

This is the headline "N independent builders attest each release" stat for
Bitcoin Core's reproducibility regime. Any Nix-based alternative would need
to match — i.e. show ≥10 independent builders rebuilding from the same flake
inputs and producing identical output hashes per architecture, signed by
distinct keys.

Compare: the Nix-side equivalent ([Lila reproducibility tracker](https://reproducibility.nixos.social/))
counts ~244k attestations across ~147k derivations from many anonymous
rebuilders, but this is system-wide, not per-release-of-a-specific-binary.
The Bitcoin Core pattern is finer-grained and human-attested.
