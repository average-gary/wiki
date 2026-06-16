---
title: "Bitcoin Core PR #15277 + 2019 help-guix announcement (Carl Dong's Guix migration)"
sources:
  - https://github.com/bitcoin/bitcoin/pull/15277
  - https://lists.gnu.org/archive/html/help-guix/2019-04/msg00085.html
  - https://bitcoinops.org/en/topics/reproducible-builds/
type: article
authors: Carl Dong (dongcarl)
merger: Wladimir van der Laan (laanwj)
year: 2019
ingested: 2026-06-15
tags: [bitcoin-core, gitian, guix, migration, history, primary-source]
confidence: high
quality: 5
---

# Bitcoin Core PR #15277 — Carl Dong's Guix migration

The "patient zero" introducing Guix to Bitcoin Core, plus the earliest dated
public statement of intent on the help-guix mailing list. Combined here as a
single ingest for the migration story.

## Key dates and claims

- **2019-04-09 15:03 UTC**: Dong posts to help-guix announcing intent to use
  Guix for Bitcoin Core. Stated rationale: *"Guix's focus on bootstrappability,
  and Guile's simplicity and flexibility are very desirable qualities in
  building an auditable, secure, and reliable build process."*
- **2019-07-12**: PR #15277 merged by laanwj. Concept-ACK reviewers:
  practicalswift, fanquake, laanwj.
- **2020-04**: PR #17595 — Guix Windows cross-build.
- **2021-01**: PR #17920 — Guix macOS cross-build.
- **2021-05**: PR #21462 — Guix attestation tooling (replaces gitian.sigs role).
- **2021-08**: PR #22642 — batch-verification of Guix attestations.
- **2021-09-13**: Bitcoin Core 22.0 released — first version with Guix as the
  primary deterministic-build path.
- **2022-11-12**: `bitcoin-core/gitian.sigs` repo archived. Total Gitian-era
  commits: 4,062 (per-release × per-builder × per-platform attestations).

## Migration arc duration

PR #15277 merge (2019-07-12) → 22.0 release (2021-09-13) → gitian.sigs archive
(2022-11-12) = ~3 years 4 months. Counters any narrative of an overnight switch.

## Stated advantages over Gitian

1. Distribution-independence (Gitian was Ubuntu-bound).
2. Supply-chain transparency.
3. Bootstrap minimization (path toward stage0 / hex0 — see
   [guix-full-source-bootstrap-2023](2026-06-15-guix-full-source-bootstrap-2023.md)).

## Stated technical hurdles (from Dong's mailing-list post)

- libstdc++ static-link failure (`.la` files).
- rpath stripping via patchelf.
- `/gnu/store/...-glibc-2.28` interpreter prefix patching.

## Why Nix was not considered

Dong's 2019 mailing-list post chooses Guix without mentioning Nix. The choice
appears to be driven by Guix's bootstrappability story plus Dong's existing
Guile/Lisp affinity, *not* an explicit Nix-vs-Guix evaluation. There is no
known primary source where Nix was evaluated and rejected — it simply was not
on the radar of the Bitcoin Core build-system effort in 2019.
