---
title: Wiki — nixos-reproducible-builds-bitcoin
type: index
created: 2026-06-15
updated: 2026-06-15
---

# Wiki

Compiled knowledge layer. Subdirectories:

- `concepts/` — atomic, single-idea articles (one Nix primitive each)
- `topics/` — multi-concept synthesis (e.g., the Bitcoin Core Gitian→Guix
  migration story)
- `reference/` — pointers to upstream specs, repos, talks

Articles use dual-link format (`[[wiki-link|display]]`) and confidence tags.

## Concepts

- [[concepts/derivation-output-modes.md|Derivation output modes]]
- [[concepts/bootstrap-chain.md|Bootstrap chain]]
- [[concepts/multi-builder-attestation.md|Multi-builder attestation]]
- [[concepts/reproducibility-tooling.md|Reproducibility tooling]]
- [[concepts/slsa-and-nix.md|SLSA levels and Nix]]
- [[concepts/go-reproducibility-recipe.md|Go reproducibility recipe]]
- [[concepts/rust-nix-build-stack.md|Rust+Nix build stack]]

## Topics

- [[topics/why-bitcoin-core-uses-guix-not-nix.md|Why Bitcoin Core uses Guix, not Nix]]
- [[topics/nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]]
- [[topics/playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]]
- [[topics/nix-supply-chain-roadmap.md|Nix supply-chain roadmap]]
- [[topics/lightning-node-reproducibility-under-nix.md|Lightning node reproducibility under Nix]]
- [[topics/fedimint-reproducible-builds.md|Fedimint reproducible builds]]

## Reference

- [[reference/upstream-pointers.md|Upstream pointers]]
