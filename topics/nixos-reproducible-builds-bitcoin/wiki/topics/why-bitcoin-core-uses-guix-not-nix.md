---
title: "Why Bitcoin Core uses Guix, not Nix"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bitcoin-core, guix, nix, history, contrarian, decision-rationale]
sources:
  - "[[../../raw/articles/2026-06-15-bitcoin-pr-15277-dong-guix-migration.md|Bitcoin PR #15277 + 2019 Dong announcement]]"
  - "[[../../raw/articles/2026-06-15-guix-full-source-bootstrap-2023.md|Guix Full-Source Bootstrap]]"
  - "[[../../raw/articles/2026-06-15-nixos-discourse-bootstrap-admission.md|NixOS Discourse — bootstrap admission]]"
  - "[[../../raw/repos/2026-06-15-bitcoin-core-contrib-guix-readme.md|Bitcoin Core contrib/guix README]]"
---

# Why Bitcoin Core uses Guix, not Nix

A reader who lands on this wiki expecting "Nix is the reproducible-build
solution for Bitcoin" needs to grok this first: **Bitcoin Core itself does
not use Nix.** It uses Guix.

## The decision

- **2019-04-09**: Carl Dong (dongcarl) posts to help-guix announcing intent
  to migrate Bitcoin Core's release process to Guix.
- **2019-07-12**: PR [#15277](https://github.com/bitcoin/bitcoin/pull/15277)
  merged by Wladimir van der Laan. Concept-ACK reviewers: practicalswift,
  fanquake, laanwj.
- **2021-09-13**: Bitcoin Core 22.0 released — first version with Guix as
  primary deterministic-build path.
- **2022-11-12**: `bitcoin-core/gitian.sigs` archived. Migration arc:
  ~3 years 4 months.

## The reasoning (Dong's stated criteria)

1. **Distribution-independence** — Gitian was Ubuntu-bound.
2. **Supply-chain transparency** — auditable build script in Scheme.
3. **Bootstrap minimization** — path toward
   [[../concepts/bootstrap-chain.md|stage0 / hex0]].

## Why not Nix

Two empirical observations:

1. **Dong's 2019 mailing-list post does not mention Nix.** There is no
   primary source of Nix being evaluated and rejected. Nix simply was not on
   the radar of the Bitcoin Core build-system effort.
2. **The bootstrap-chain gap is real and admitted.** A 2019 NixOS Discourse
   thread captures Nix maintainers conceding the ~120 MB / ~50% trusted-seed
   gap vs Guix and that closing it *"would still be substantial changes to
   Nixpkgs"* — i.e., not on the roadmap. Guix's [[../concepts/bootstrap-chain.md|357-byte hex0 seed]]
   chain (2023) widened the gap further.

The closest answer to "why Guix, not Nix" is therefore:

> Dong picked Guix in 2019 for his own reasons (Guile, bootstrappability
> trajectory). Subsequently Guix has continued to lead on bootstrap
> minimization (full-source bootstrap, 2023) while Nix has not closed the
> gap, so the choice has aged well.

## Could a Nix-based build replace Guix?

**Technically possible, on Linux x86_64, today.** [[../../raw/articles/2026-06-15-b10c-matching-hashes-bitcoind-nix-guix-v31.md|0xB10C's 2026 matching-hashes work]]
demonstrated that a Nix-built `bitcoind` v31.0 can SHA-256-match the official
Guix release binary — but required ~3 years of effort and pragmatic
post-build patching of glibc ELF notes and debug-section CRC32. Linux x86_64
only; no Darwin/Windows cross.

**Practically unlikely to displace Guix** because:

- The bootstrap-chain gap remains.
- Bitcoin Core's `guix.sigs` regime ([[../concepts/multi-builder-attestation.md]])
  has 16-23 attesters per release; switching to Nix would forfeit that
  cohort.
- The [[../../raw/articles/2026-06-15-nixcon-2025-supply-chain-panel.md|2025 Nix supply-chain story]]
  is still converging; signed expressions, channel auth, and rebuilder UX
  are not yet at the stability level Bitcoin Core requires.

## Useful reframing

Nix's role in the Bitcoin ecosystem is **not** "alternative to Guix for
release builds." It's:

1. **Deployment substrate** — [[../../raw/repos/2026-06-15-nix-bitcoin-fort-nix.md|nix-bitcoin]]
   for running nodes.
2. **Reproducible dev environments** — `bix` flake, Fedimint flake.
3. **Cross-compile / multi-target builds** — Fedimint's wasm + native +
   mobile triple-target flake.
4. **A second independent verification path** — like 0xB10C's, providing a
   non-Guix sanity check on the Guix output.
