---
title: "Playbook: Nix-built attestation for Bitcoin Core"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: medium
status: synthesis
tags: [playbook, attestation, nix, bitcoin-core, distributed-verification]
sources:
  - "[[../../raw/articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md|b10c matching hashes]]"
  - "[[../../raw/data/2026-06-15-bitcoin-core-guix-sigs.md|guix.sigs data]]"
  - "[[../../raw/articles/2026-06-15-rb-summit-2025-vienna.md|RB Summit 2025]]"
  - "[[../../raw/articles/2026-06-15-nixcon-2025-supply-chain-panel.md|NixCon 2025 panel]]"
---

# Playbook — Nix-built attestation for Bitcoin Core

A practical sketch of what it would take to participate in Bitcoin Core's
release-attestation regime as a *Nix builder*, not a *Guix builder*.

## Goal

Produce a Nix-built `bitcoind` binary whose SHA-256 matches the Guix output
in `bitcoin-core/guix.sigs`, GPG-sign the SHA256SUMS, and PR the signature
back to `guix.sigs` so it counts as a sixteenth-or-more independent attester
for the release.

## Why this matters

The argument is **toolchain diversity**. Today, all 16-23 attesters per
release rebuild via Guix. If a bug or backdoor existed in Guix's bootstrap
chain or in `contrib/guix/`, every attester's hash would agree
*incorrectly*. A Nix attester catches that class of failure.

Per [[../../raw/articles/2026-06-15-rb-summit-2025-vienna.md|RB Summit 2025]],
this is exactly what "distributed verification" should mean: heterogeneous
build paths converging on the same hash.

## Phases

### Phase 1 — Linux x86_64 hash match (precedent: b10c)

**Status**: demonstrated by 0xB10C in 2026 ([[../../raw/articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md|matching-hashes work]]).
~3 years of effort; required post-build patching.

Concrete steps:

1. Fork or upstream into `0xB10C/bitcoind-gunix`.
2. For target release (e.g. v31.0), pin `flake.lock` to the toolchain
   versions in Guix's manifest.
3. Mirror Guix flags: `SOURCE_DATE_EPOCH`, `--remap-path-prefix`,
   `-Wl,--build-id=none`, `-fno-canonical-system-headers`, etc.
4. Run the build; compare with `diffoscope` against the official Guix
   binary.
5. For each divergence: either patch the toolchain or apply a documented
   post-build canonicalization (`bbe` for debug CRC32, ELF-note
   replacements). **Document each patch**.
6. Once SHA-256 matches: GPG-sign and PR to `guix.sigs/<release>/<key-id>/`.

### Phase 2 — Cross-compile (Linux ARM, Windows, macOS)

**Status**: not yet attempted.

Requires `pkgsCross` infrastructure for:

- `aarch64-linux` (relatively well-supported in nixpkgs)
- `riscv64-linux` (nixpkgs cross is improving)
- `x86_64-w64-mingw32` (Windows; nixpkgs has a basic mingw cross but not
  the full Bitcoin-Core toolchain alignment)
- `x86_64-apple-darwin` and `aarch64-apple-darwin` (macOS; the SDK
  licensing makes this fundamentally harder than Guix's
  https://gitlab.com/bitcoin-core/bitcoin-core-osx-sdk distribution)

### Phase 3 — Code-signing stage 2

Bitcoin Core's release flow has a stage 2 where Apple/Microsoft code
signatures are attached and re-distributed. A Nix attester would need to
participate in this round-trip too — straightforward once stage 1 matches.

## Risks / unknowns

- **Bootstrap-tools dependency**: a Nix attester is, transitively, trusting
  the `bootstrap-tools` tarball. The point of multi-attester distributed
  verification is partly defeated if all Nix attesters share that
  pre-built blob ([[../concepts/bootstrap-chain.md]]).
- **Nixpkgs governance turbulence** (Lix fork, Eelco stepping back) means
  the toolchain that hash-matches today may diverge tomorrow.
- **Patching feels wrong**: the b10c patches close real toolchain
  divergences but obscure where the determinism gap actually lives. A
  cleaner long-term fix is upstreaming the determinism knobs into nixpkgs.

## What would change the verdict

Two open developments to track:

1. **CA-derivations stable** in Nix (or Lix) — narrows the gap between
   "input-addressed sandboxed build" and Guix's content-addressed
   semantics.
2. **Nix bootstrap-tools shrinkage** — if a Nix derivation reproducing
   bootstrap-tools from a Mes-style chain were to land, the trusting-trust
   gap closes.

Until then, a Nix attester is *valuable but secondary* — useful for
toolchain-diversity catches, not as a replacement for Guix.

## See also

- [[why-bitcoin-core-uses-guix-not-nix.md]]
- [[nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]]
- [[../concepts/multi-builder-attestation.md|Multi-builder attestation]]
- [[../concepts/bootstrap-chain.md|Bootstrap chain]]
- [[../../theses/nix-can-match-guix-attestation.md|Thesis: Nix can produce a hash-matched Bitcoin Core attestation]]
