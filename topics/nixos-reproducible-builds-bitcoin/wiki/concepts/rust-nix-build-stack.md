---
title: "Rust+Nix build stack (buildRustPackage / naersk / crane / Flakebox / fenix)"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [rust, nix, crane, flakebox, fenix, naersk]
sources:
  - "[[../../raw/articles/2026-06-15-rust-nix-tooling-stack.md|Rust+Nix tooling stack]]"
---

# Rust+Nix build stack

The substrate any Bitcoin-adjacent Rust project considering Nix chooses from.

## Layers (bottom to top)

```
Cargo.lock                           ← Rust's own dep pin; necessary, not sufficient
  ↓
buildRustPackage (nixpkgs)           ← legacy, monolithic, weak repro
naersk (nix-community)               ← 2-stage, no IFD, Hydra-compat
crane (ipetkov)                      ← 3-stage, content-addressed deps, composable
  ↓
Flakebox (dpc / rustshop)            ← opinionated wrapper over crane (Fedimint uses this)

fenix (nix-community)                ← Rust toolchain pinning across the whole stack
```

## Why crane wins for Bitcoin-grade projects

- **Per-derivation content-addressing** — clippy, test, audit, build each
  have separately-cached Nix derivations. Lets CI rerun only what changed.
- **No IFD** — sandbox-friendly, Hydra-compatible.
- **Cross-compile matrix** including non-Rust deps (RocksDB, SQLite,
  static-link knobs).
- The b10c Bitcoin Core hash-match work used buildGoModule conventions on
  the Go side and crane-lite patterns on the Rust side
  ([[../../raw/articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md]]).

## Toolchain pinning via fenix

Without a fixed compiler hash, even crane + `Cargo.lock` can't give
bit-identical outputs. fenix uses SHA256-pinned rustup manifests; honors
`rust-toolchain.toml`; Cachix-caches pre-built toolchains.

## Cargo determinism that crane doesn't fix

- Embedded build-IDs and compiler timestamps in binaries (CLN clnrest hit
  this — required `RUSTFLAGS="-C link-arg=-Wl,--build-id=none"` plus rustc
  pin).
- `build.rs` impurity (`git rev-parse HEAD`, env vars) — Fedimint's
  `replaceGitHash` / `bbe` post-build patch is the canonical workaround.
- `OUT_DIR` parallel-build conflicts (rust-lang/cargo#6282).

## See also

- [[go-reproducibility-recipe.md|Go reproducibility recipe]] — sibling stack for LND
- [[../topics/fedimint-reproducible-builds.md|Fedimint reproducible builds]] — case study using this stack
- [[derivation-output-modes.md|Derivation output modes]] — `vendorHash` / FOD mechanics
