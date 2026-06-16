---
title: "Core Lightning reproducibility (Docker pipeline + PR #8846 Rust toolchain blockers)"
sources:
  - https://docs.corelightning.org/docs/repro
  - https://github.com/ElementsProject/lightning/blob/master/flake.nix
  - https://github.com/ElementsProject/lightning/pull/8638
  - https://github.com/ElementsProject/lightning/pull/8846
  - https://github.com/ElementsProject/lightning/issues/8547
type: article
maintainer: ElementsProject / Core Lightning
year: 2025-2026
ingested: 2026-06-15
tags: [cln, core-lightning, reproducible-builds, docker, rust, build-id]
confidence: high
quality: 5
---

# Core Lightning reproducibility

CLN has the most documented reproducible-build story among LN nodes — and
also a public record of how often it breaks.

## The Docker-based pipeline

Per `docs.corelightning.org/docs/repro`:

- Per-Ubuntu-release base images: `cl-repro-jammy` (22.04),
  `cl-repro-noble` (24.04), `cl-repro-resolute` (26.04).
- Build invocation: `docker run --rm -v $(pwd):/repo -ti cl-repro-jammy`.
- Five-stage process: known build env → strip variance → package → manifest
  with hashes → "release captain" plus "co-maintainers and contributors"
  sign.
- `gpg -sb --armor SHA256SUMS` produces `SHA256SUMS.asc`.
- **No Guix, no Nix.** Docker only.

## CLN's own flake.nix

Repo root has a `flake.nix` with companion `flake.lock`:

- Modular: `nix/apps.nix`, `nix/checks/flake-module.nix`, `nix/pkgs/flake-module.nix`, `nix/shells.nix`.
- Pinned to `github:NixOS/nixpkgs/nixos-unstable` — channel branch, not a
  hash. Determinism comes from `flake.lock` only.
- Derivation uses `src = ../../.;` — path-based on the active checkout.
  **Useful for devs, NOT a hermetic source pin to a tag.**
- Open PR #9203: "nix: fix `nix build` and simplify NixOS install docs"
  (flake currently has known broken paths).

## PR #8638 — nightly reprobuild test (DRAFT)

`cdecker` opened a CI job to validate reproducibility on every commit. **Still
draft as of research date.** WIP commits ("REMOVEME", "fixup!") show the
effort isn't polished.

Approach: Docker-based, single-builder CI. Not a multi-attester cohort
comparable to `guix.sigs`.

## PR #8846 — clnrest Rust 368-byte drift (MERGED)

The concrete failure case: `clnrest` produced binaries differing by **368
bytes** despite identical source. Root cause: build-IDs and compiler-embedded
timestamps live INSIDE binaries; `tar --mtime` alone is insufficient.

Required fix:
1. `SOURCE_DATE_EPOCH=1672531200` (set in build env)
2. `RUSTFLAGS="-C link-arg=-Wl,--build-id=none"`
3. Docker `no-cache` (cache-poisoning hazard)
4. Pin Rust to **`1.92.0`** specifically (not "stable" — moving target)

Issue #8547 is the bug report; PR #8846 is the fix.

## Implication for Nix

Nixpkgs `clightning` is built from the *release zip* (FOD), not from CLN's
own flake. So:

- Nixpkgs CLN doesn't include `cln-grpc` or `clnrest` Rust plugins (the
  upstream flake assembles those separately).
- Nixpkgs CLN binary won't byte-match the Docker-built `cl-repro-jammy`
  output unless coincidentally.
- Three different "reproducible" CLN builds exist:
  1. Upstream `cl-repro-*` Docker (canonical).
  2. Upstream `flake.nix` (hacking convenience, drift-prone).
  3. Nixpkgs derivation (release-zip + autotools).

None bit-match each other.

## Why this matters

CLN demonstrates the "Docker as escape hatch" pattern that all major LN
projects rely on. Bitcoin Core moved past Docker-based deterministic builds
in 2019-2021 specifically because of kernel/util-linux drift. CLN hasn't
made that move yet.
