---
title: "Nix derivation output modes (input-addressed, FOD, content-addressed)"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [nix, derivation, fixed-output, content-addressed, vocabulary]
sources:
  - "[[../../raw/articles/2026-06-15-nix-manual-derivation-outputs.md|Nix Manual — Derivation Outputs]]"
---

# Derivation output modes

Nix derivations produce store paths in one of three modes. The mode chosen
governs both the *purity guarantees* and the *attack surface* of the build.

## 1. Input-addressed (default)

`storePath = hash(derivation inputs)`. No network access. Pure by
construction. The default for almost every package in Nixpkgs.

For a Bitcoin build: this is what you get for compiling `bitcoind` from a
source tree already-in-store.

## 2. Fixed-output derivation (FOD)

`storePath = predeclared via outputHash`. **Network access permitted in the
sandbox** because the output is pinned to a known hash. The only legitimate
mechanism for `fetchurl`, `fetchTarball`, `fetchgit`, etc.

For a Bitcoin build: this is how the Bitcoin Core source tarball enters the
Nix store. If `outputHash` is correct, the FOD is reproducible *as long as
the upstream source content hasn't changed* (or as long as a downstream
verifier can fetch *some* copy whose contents hash to the same value — Nix
doesn't care where the bytes came from).

**The escape hatch through which any source-fetching step enters an
otherwise-sealed sandbox.**

## 3. Content-addressed (CA, experimental)

`storePath = hash(post-build content)`. Currently feature-flagged
(`ca-derivations`). Enables:

- **Early cutoff**: if inputs change but output content doesn't, downstream
  rebuilds skip.
- **Store deduplication**: identical outputs from different input graphs
  collapse to one path.

RFC 62 was merged 2022; rollout in Nix vs Lix is the open implementation
question, not the design question.

## Why this matters for Bitcoin

Every reproducibility question in Nix routes through which mode a derivation
uses. Bitcoin Core reproducibility requires:

- **Source fetch**: FOD with a `git revision`-pinned `fetchgit` (avoid
  mutable tarball + hash, which is "trust on first fetch").
- **Compile**: input-addressed, sandboxed, `SOURCE_DATE_EPOCH` pinned.
- **Optional**: CA-derivations would let downstream verifiers detect
  trivially-identical-output rebuilds without redoing them, but is not yet
  the default.

See also: [[../topics/why-bitcoin-core-uses-guix-not-nix.md|Why Bitcoin Core uses Guix, not Nix]] —
where Nix's bootstrap-tools tarball (a giant FOD trusted on first fetch) is
the exact gap that Guix's full-source bootstrap closes.
