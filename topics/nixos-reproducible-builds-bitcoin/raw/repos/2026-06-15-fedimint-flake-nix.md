---
title: "Fedimint flake.nix and Nix developer setup"
source: https://github.com/fedimint/fedimint/blob/master/flake.nix
docs: https://sdk.fedimint.org/core/dev/nix_setup.html
type: repo
maintainer: Fedimint (Eric Sirion et al.)
year: 2022–2026
ingested: 2026-06-15
tags: [fedimint, flake, rust, cross-compile, wasm, mobile, primary-source]
confidence: high
quality: 5
---

# Fedimint flake.nix

Best in-the-wild example of a Bitcoin-adjacent Rust codebase doing serious
cross-compilation under one flake.

## Key claims

- **Toolchain pinning**: Fenix (Rust toolchain manager) at fixed commit
  `6b5325a017a9a9fe7e6252ccac3680cc7181cd63`; deliberately holds LLVM at 20 on
  Linux to dodge a clang 18/19 miscompilation.
- **Custom overlays**: `wasm-bindgen.nix`, `cargo-nextest.nix`,
  `esplora-electrs.nix`, `darwin-compile-fixes.nix`, `cargo-honggfuzz.nix`,
  `trustedcoin.nix`.
- **Outputs**: `fedimintd`, `fedimint-cli`, `gatewayd`, `gateway-cli`,
  `fedimint-load-test-tool`, `devimint`, `wasmBundle`. Three toolchain
  variants: native, `wasm32-unknown-unknown`, "all" (Android + iOS).
- **Reproducibility tactics**: git-hash placeholder substitution (avoids
  dirty-tree impurity), separate clean/dirty handling, `dontStrip =
  !pkgs.stdenv.isDarwin`, deterministic binary patching using `bbe`. Cachix
  binary caching.
- **Docs explicitly state**: Nix is "highly recommended" because it
  guarantees parity with CI — same flake builds locally and in CI, eliminating
  drift.

## Why this matters

Direct template material for any Bitcoin-adjacent Rust workspace (mining
stacks, Lightning libs, custom protocols) considering Nix flakes. Shows the
pattern for: pinning unstable Rust, custom toolchain overlays, multi-target
output (native + wasm + mobile), and reproducible-by-construction CI parity.
