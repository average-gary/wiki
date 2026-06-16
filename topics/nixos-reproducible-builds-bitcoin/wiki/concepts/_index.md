---
title: Concepts — nixos-reproducible-builds-bitcoin
type: index
created: 2026-06-15
updated: 2026-06-15
---

# Concepts

Atomic concept articles.

- [[derivation-output-modes.md|Derivation output modes]] — input-addressed vs FOD vs CA
- [[bootstrap-chain.md|Bootstrap chain]] — Nix bootstrap-tools vs Guix full-source bootstrap
- [[multi-builder-attestation.md|Multi-builder attestation]] — gitian.sigs / guix.sigs pattern
- [[reproducibility-tooling.md|Reproducibility tooling]] — diffoscope, reprotest, strip-nondeterminism
- [[slsa-and-nix.md|SLSA levels and Nix]] — how Nix maps onto Build L1/L2/L3
- [[go-reproducibility-recipe.md|Go reproducibility recipe]] — `CGO_ENABLED=0 go build -trimpath` (relevant to LND)
- [[rust-nix-build-stack.md|Rust+Nix build stack]] — buildRustPackage / naersk / crane / Flakebox / fenix (relevant to Fedimint, LDK)
