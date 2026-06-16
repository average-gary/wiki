---
title: "Rust+Nix tooling stack — Flakebox, crane, fenix, naersk"
sources:
  - https://github.com/rustshop/flakebox
  - https://github.com/ipetkov/crane
  - https://crane.dev
  - https://github.com/nix-community/fenix
  - https://github.com/nix-community/naersk
  - https://dpc.pw/posts/embedding-git-version-hash-in-a-binary-in-a-nix-friendly-way/
type: article
year: 2019-2026
ingested: 2026-06-15
tags: [rust, nix, flakebox, crane, fenix, naersk, buildgomodule-equivalent]
confidence: high
quality: 5
---

# Rust+Nix tooling stack

The substrate Fedimint sits on, and the substrate any other Bitcoin-adjacent
Rust project considering Nix flakes will choose from.

## Stack layers (bottom to top)

```
Cargo.lock                           ← Rust's own dependency pin
  ↓
nixpkgs buildRustPackage             ← legacy, monolithic derivation, weak repro
  ↓
naersk      crane                    ← second-gen, two/three-stage builds, pure Nix
              ↓
            Flakebox                 ← Fedimint's choice; opinionated wrapper over crane
fenix                                ← Rust toolchain pinning (replaces rustup, rust-overlay)
```

## crane (ipetkov/crane)

Pure-Nix Cargo build library. Three pillars:

1. **Automatic source vendoring** driven by `Cargo.lock` — dependencies
   become Nix fixed-output derivations, content-addressed.
2. **Incremental** — deps built once, reused across app rebuilds.
3. **Composable** — granular per-step derivations let clippy/test/audit/build
   each have separately-cached Nix derivations.

No IFD by default; sandbox-friendly. Supports alternative cargo registries
and git deps without manual override boilerplate.

The de-facto choice underneath both Flakebox and many Bitcoin-adjacent Rust
projects. Per-derivation content-addressing is the *actual mechanism* that
gives bit-for-bit reproducibility — separate from `Cargo.lock`. Important
distinction from `buildRustPackage` (single monolithic derivation).

## fenix (nix-community/fenix)

Replaces rustup and the older `rust-overlay`. Reproducibility:

- SHA256-pinned rustup manifests (`fromManifest` / `fromManifestFile`) —
  required for pure evaluation.
- `rust-toolchain.toml` honored for version locking.
- Cachix-cached pre-built toolchains for x86_64-linux/x86_64-darwin/
  aarch64-darwin avoid local toolchain rebuilds.
- Profiles: minimal/default/complete mirror rustup.

Without a fixed compiler hash, even crane + `Cargo.lock` can't give
bit-identical outputs.

## Flakebox (rustshop/flakebox; consumed via dpc/flakebox fork)

Higher-level abstraction over crane. Codifies dpc's build practices into a
reusable framework:

- Multi-stage incremental build caching
- Cross-compilation (Linux/Darwin/Android/iOS) including non-Rust deps
- Generated CI workflow templates (Fedimint disables this and uses bespoke
  CI)
- Integrated dev shells
- Nix-modules-style configuration

**Self-described as "very immature."** Single-maintainer (Dawid
Ciężarkiewicz / @dpc). Fedimint pins a fork (`dpc/flakebox`), not the
upstream `rustshop/flakebox` — same person maintains both. Worth flagging
as a supply-chain consideration for any reproducibility argument leaning
on Fedimint's flake.

## naersk (nix-community/naersk)

Predecessor/sibling to crane. Two-stage build (deps first, app second). Pure
Nix-side `Cargo.lock` parsing (no IFD), Hydra-compatible. Cross-compilation
support is more limited than crane's — one reason Flakebox/Fedimint chose
crane.

Useful as the "what crane was chosen over" comparator. Smaller Bitcoin Rust
projects with lighter cross-compile needs may pick naersk.

## The build.rs / git-hash impurity problem

Cargo's `build.rs` can read environment and run arbitrary code at build
time, which breaks Nix purity. Common case: embed `git rev-parse HEAD`
output via `env!("GIT_HASH")`.

Solution (per dpc's blog post):

1. Compile with a 40-char placeholder: `FEDIMINT_BUILD_FORCE_GIT_HASH =
   "01234569abcdef7afa1d2683a099c7af48a523c1"`.
2. Post-process the binary in a separate stdenv derivation using `bbe`
   (binary block editor): `bbe -e 's/${placeholder}/${gitHash}/'`.

Preserves derivation reuse (placeholder content identical across commits)
while still embedding identity. Same pattern criticized in the b10c
Nix↔Guix Bitcoin Core work — but for Fedimint's use case it's
unobjectionable: the patch is internal, deterministic, and not closing a
toolchain gap.

## Cargo non-determinism that even crane doesn't fix

Per `r/reproduciblebuilds` discussion + `rust-lang/cargo#6282`:

- Embedded timestamps in some Rust artifacts persist even with `Cargo.lock`
  + sandboxed build.
- Parallel builds with multiple packages can produce unsafe `OUT_DIR`
  conflicts.

Documents the upstream-Cargo problems that Fedimint's tooling stack works
around but doesn't fully solve. Same flavor as the
[CLN clnrest 368-byte Rust drift](2026-06-15-cln-repro-and-pr-8846.md):
build-IDs, compiler-embedded timestamps, link-arg flags all matter.
