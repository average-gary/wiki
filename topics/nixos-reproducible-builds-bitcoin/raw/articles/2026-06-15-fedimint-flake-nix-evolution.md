---
title: "Fedimint flake.nix — 4-year evolution timeline (2022→2026)"
type: article
source_url: https://github.com/fedimint/fedimint/commits/master/flake.nix
ingested: 2026-06-15
confidence: high
relevance: direct
evidence_strength: primary-source
direction: opposes
tags: [fedimint, flake, history, opposes-thesis, effort-estimation, flakebox]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# Fedimint flake.nix — 4-year evolution timeline

Empirical observation of Fedimint's reproducible-build infrastructure as
an iterated artifact, not a drop-in. The strongest evidence against the
thesis's "easily" qualifier.

## Timeline

| Date | Commit | Event |
|------|--------|-------|
| 2022-06-23 | `fe3e2d8f` | First `flake.nix`: "flakes : adding nix flakes with crane" |
| 2022-08-03 | `08c7db54` | "Nix Flake PoC" — fuller integration attempt |
| 2022-08-09 | PR #322 merged | "Nix flake poc followup" — initial production-ready cut, +196/-16 LOC, Crane-based |
| 2023 | (multiple) | OCI container outputs added (`dockerTools.buildLayeredImage` for `fedimintd`, `gatewayd`, etc.) |
| 2023 | (extracted) | **Flakebox** — `flake.nix` complexity broken out into separate `dpc/flakebox` repo, ~700+ LOC, single-maintainer dependency |
| 2024-03-05 | `8a40d5bd` | "update flakebox (with new, more flexible architecture)" |
| 2024–2025 | (rolling) | LLVM 20 pinning to dodge clang miscompilation; Fenix rev pin to dodge upstream issue; rocksdb 8.11 + `enableLiburing = false` workaround |
| 2026-06 | (current) | `nix/flakebox.nix` is ~41KB; full-fat config including 8 flake inputs, 6 custom overlays, multi-target Android+iOS+wasm |

`flake.nix` has **400+ commits** total across this history.

## What's load-bearing in the current state

From [[../repos/2026-06-15-fedimint-nix-flakebox-internals.md]]:

- `gitHashPlaceholderValue = "01234569abcdef..."` + `replaceGitHash`
  post-build patcher — necessary because Nix builds are sandboxed away
  from `.git`.
- 8 flake inputs: `nixpkgs`, `nixpkgs-unstable`, `flake-utils`, `fenix`
  (rev-pinned), `flakebox` (dpc), `wild` (linker), `cargo-deluxe`,
  `bundlers`, `advisory-db`.
- 6 custom overlays: `wasm-bindgen.nix`, `cargo-nextest.nix`,
  `esplora-electrs.nix`, `darwin-compile-fixes.nix`, `cargo-honggfuzz.nix`,
  `trustedcoin.nix`.
- Cross-compile env block hand-pinning `rocksdb`, `snappy`, `sqlite`,
  `sqlcipher` per-arch static libs.
- Workspace-filter regexes to exclude crates that don't build cleanly
  under Nix.

## Read for the thesis

**Pessimistic read**: "easily adopt" implies hours-to-days of work.
Fedimint's reality is months-to-years of accreted maintenance, much of it
driven by upstream toolchain churn that has nothing to do with Bitcoin or
federated mints.

**Optimistic read (with the load-bearing caveat)**: most of the
4-year-accreted complexity is for capabilities sv2-apps doesn't need —
mobile (Android+iOS) cross-compile, wasm32 target, honggfuzz, multi-org
federation deps. The MVP pattern (Crane → `dockerTools.buildLayeredImage`
→ Cachix) is what loglog ships in 103 lines
([[../repos/2026-06-15-rustshop-loglog-minimal-flake.md]]). The 41KB of
Flakebox is **not** the minimum.

This is the central nuance: "like Fedimint" can mean "Fedimint's MVP
pattern circa 2022 PR #322 — ~200 LOC" or "Fedimint's current 41KB
state." The thesis is *defensible* only against the first reading.

## Maintenance footprint

What a project taking on Flakebox today inherits:

- Flakebox is single-maintainer (dpc). Bus factor: 1.
- Updates are not on a public release cadence; consumers track HEAD.
- LLVM/Fenix workarounds are a moving target as upstream changes.

What a project writing its own minimal flake (loglog-style) inherits:

- Crane (ipetkov), well-maintained, broad community use.
- Fenix (nix-community), well-maintained.
- nixpkgs `dockerTools` (NixOS team), institutional-scale maintenance.

For sv2-apps the cleaner play is to copy the **pattern**, not the
**implementation**. Don't take a flakebox dependency.

## See also

- [[../repos/2026-06-15-fedimint-nix-flakebox-internals.md]]
- [[../repos/2026-06-15-rustshop-loglog-minimal-flake.md]]
- [[2026-06-15-nix-oci-tooling-open-issues.md]]
