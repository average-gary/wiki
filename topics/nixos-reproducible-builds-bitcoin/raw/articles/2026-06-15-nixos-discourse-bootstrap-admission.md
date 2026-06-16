---
title: "NixOS Discourse: Guix reduces bootstrap seed by 50% (maintainer admission thread)"
source: https://discourse.nixos.org/t/guix-reduces-bootstrap-seed-by-50/4304
type: article
maintainer: NixOS community / discourse.nixos.org maintainers
year: 2019 (long-running)
ingested: 2026-06-15
tags: [nix, bootstrap, contrarian, hostile-witness, mrustc]
confidence: high
quality: 4
---

# NixOS Discourse — bootstrap-seed admission

Self-incriminating primary source: Nix maintainers themselves acknowledging
the bootstrap weakness Bitcoin Core's choice of Guix is meant to dodge.

## Key admissions

- *"Our approach is to download a binary from Mozilla and then use that to
  recompile"* — explicit trusted-third-party for Rust toolchain.
- Acknowledged ~120 MB / ~50% trusted-seed gap vs Guix as factual, not
  contested.
- Maintainer concedes adopting the Guix approach (mrustc bootstrap of Rust)
  *"would still be substantial changes to Nixpkgs"* — i.e. not on the roadmap.

## Why this matters

The strongest contrarian-on-Nix quotes come from Nix's own maintainers. For
the wiki's "why Bitcoin Core picked Guix" article, this thread is the
hostile-witness primary source documenting Nix's known bootstrap gap relative
to Guix. Pair with
[guix-full-source-bootstrap-2023](2026-06-15-guix-full-source-bootstrap-2023.md)
for the positive Guix side of the same comparison.

## Caveats

- Thread is from 2019 — the gap may have narrowed since (CA-derivations were
  merged 2022; Lix is exploring further).
- Nix's bootstrap is still substantially larger than Guix's hex0 seed in 2026.
