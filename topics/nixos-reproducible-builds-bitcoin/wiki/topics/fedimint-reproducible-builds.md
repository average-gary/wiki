---
title: "Fedimint reproducible builds"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [fedimint, federation, reproducibility, nix, flakebox, cachix, supply-chain]
sources:
  - "[[../../raw/repos/2026-06-15-fedimint-flake-nix.md|Fedimint flake.nix (round 1)]]"
  - "[[../../raw/repos/2026-06-15-fedimint-nix-flakebox-internals.md|Fedimint Nix internals]]"
  - "[[../../raw/repos/2026-06-15-fedimint-nixos-deployment-template.md|Fedimint NixOS deployment template]]"
  - "[[../../raw/articles/2026-06-15-fedimint-issue-4305-and-pr-4339.md|Issue #4305 + PR #4339 critique]]"
  - "[[../../raw/articles/2026-06-15-rust-nix-tooling-stack.md|Rust+Nix tooling stack]]"
---

# Fedimint reproducible builds

Round-1 ingest treated Fedimint's `flake.nix` as a positive case study:
"best in-the-wild Bitcoin-adjacent Rust flake." This article is the more
honest version. Fedimint has the **strongest build-time tooling** in the
Bitcoin-adjacent Rust ecosystem and the **weakest verification cohort**.

## What Fedimint does well (build-time)

- **Pinned everything**: `flake.lock` content-addresses every input;
  `Cargo.lock` enforced via `--locked` everywhere.
- **Toolchain pinned by hash**: Fenix at `6b5325a017a9a9fe7e6252ccac3680cc7181cd63`,
  Flakebox (dpc fork) at `34701639bceb5b...`. LLVM held at 20 to dodge a
  clang 18/19 miscompilation.
- **Three-stage Crane caching** (`workspaceDeps` → `workspaceBuild` →
  `workspaceTest/Clippy/Doc`).
- **`replaceGitHash` / `bbe` post-build patching** — embeds git identity
  without breaking derivation purity. Documented by dpc at
  [dpc.pw](https://dpc.pw/posts/embedding-git-version-hash-in-a-binary-in-a-nix-friendly-way/).
- **Wide cross-compile matrix**: native (x86_64-linux, x86_64-darwin,
  aarch64-darwin), `wasm32-unknown-unknown`, Android (3 targets), iOS (2
  targets). The breadth no other Bitcoin Rust project ships.
- **Hourly + twice-daily Nix CI** with Cachix push.
- **300 MB closure-size guardrail** on releases.
- **Per-tag `git+file:?rev=` flake URL** in `sign-release` pins the build's
  commit hash inside the Nix store path itself.

This is materially more sophisticated than nix-bitcoin's pass-through
packaging or nixpkgs' `lnd` derivation
([[lightning-node-reproducibility-under-nix.md]]).

## What Fedimint does NOT do (verification-time)

- **No multi-builder cohort** — no `fedimint.sigs` repo, no published
  signer roster. Per maintainer @dpc in issue #4305: *"I checked it
  manually a few times."* That is the entire historical reproducibility
  cohort.
- **Single-system signing** — `just sign-release` produces per-system
  `${tag}-${system}.SHA256SUMS.asc`, signed by one of two humans
  (@elsirion or @dpc). No cross-builder hash comparison.
- **No `SHA256SUMS.asc` in GitHub release assets** — only signed git tags
  + GitHub-managed `digest: sha256:...` per asset. The `SHA256SUMS.asc`
  produced by `sign-release` is not a documented release artifact.
- **Cachix as TOFU** — single key `fedimint.cachix.org-1:Fp...` controlled
  by the project. Issue #2149 (open 11 months, closed without resolution)
  acknowledges the trust gap. Most operators consume Cachix-cached binaries
  without ever rebuilding.
- **Guardian coordination is a `--version` string check**. The
  [NixOS deployment template](../../raw/repos/2026-06-15-fedimint-nixos-deployment-template.md)
  README says *"Fedimint requires the same versions of `fedimintd` on all
  peers"* and tells operators to check `fedimint --version`. No content-hash
  verification across guardians.
- **No `SOURCE_DATE_EPOCH`**, no SLSA, no sigstore, no cosign integration.

## Quantitative spine

| Metric | Fedimint | LND | Bitcoin Core |
|--------|----------|-----|--------------|
| Independent attesters per release | **0** (1 GH-bot + 1 of 2 humans) | 5 maintainers | 16-23 (`guix.sigs`) |
| Cachix / binary-cache trust roots | 1 key | 0 (Docker images) | 0 (Guix from source) |
| Release cadence (minor) | ~2.6 mo | ~2 mo | ~6 mo |
| Cross-system repro check | none | implicit (independent rebuilds) | yes (`guix.sigs` cross-check) |

Fedimint is **two tiers below Bitcoin Core** and **one tier below LND** on
the cohort axis. See [[../concepts/multi-builder-attestation.md]] for the
gold-standard pattern.

## The federation-trust paradox

Fedimint's threshold-trust model assumes guardians are
*adversarial-tolerant* in consensus (e.g. 4-of-7 quorum survives 2
malicious). But the **upgrade channel has no integrity layer**. A
compromised Cachix cache or poisoned `flake.lock` could push different
binaries to different guardians, and:

- Most guardians never rebuild — they consume Cachix.
- The only programmatic check is the `--version` string.
- The federation has no equivalent of "all 4 guardians signed off on
  rebuilding from source".

So Fedimint inherits a *worst-of-both-worlds* property: the consensus layer
is robustly Byzantine-tolerant, but the supply chain delivering the
consensus software is single-builder TOFU.

This isn't unique to Fedimint — LN nodes have the same issue
([[lightning-node-reproducibility-under-nix.md]]) — but Fedimint's
federation model makes the gap *more interesting* because the architectural
threat model already assumes guardians can be adversarial.

## Two-distributor reality

A guardian deploying via the official path inherits trust from *two
distinct organizations*:

- **`fedimint` org** — `fedimintd` Docker images, NixOS template, flake.
- **`fedibtc` org** (Fedi the company) — `fedibtc/fedimint-ui:0.7.3` Docker
  image used for guardian setup/DKG.

Neither org cross-signs the other's releases.

## Mobile-app gap

Fedi's production iOS/Android wallet is **closed-source**. The
`fedibtc/fedi-alpha` repo is a signet demo; the production app is not
public. Even with perfectly reproducible `fedimintd`, the user-facing
wallet (the surface most users actually trust with funds) cannot be
reproduced by anyone outside Fedi the company.

For comparison: Phoenix wallet (different project) ships Android source +
F-Droid-compatible reproducible APKs.

## What would close the gap

In rough effort order:

1. **Publish `SHA256SUMS.asc` in GitHub releases** (immediate; the script
   already exists, it just doesn't run automatically).
2. **Document the signer roster** — close the open follow-up from PR #4339.
3. **Establish a `fedimint.sigs` repo** modeled on `bitcoin-core/guix.sigs`
   — even 3-4 independent rebuilders would put Fedimint at LND parity.
4. **Add a guardian-coordination tool** that hashes the running `fedimintd`
   binary and surfaces it via federation API — replaces the
   `--version`-string check with a content-hash check.
5. **Federation observer dashboard** that tracks per-federation `fedimintd`
   binary hashes (data is on-disk; needs only a probe).
6. **Reproducible mobile builds** — currently impossible without
   open-sourcing the Fedi production app.

(1)-(3) are days-to-weeks of work; (4)-(6) are larger.

## See also

- [[lightning-node-reproducibility-under-nix.md|Lightning node reproducibility under Nix]] — adjacent gap analysis (same shape, different stack)
- [[nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]] — Fedimint pattern is "Pattern 3 (cross-compile / multi-target Rust flake)"
- [[sv2-apps-oci-reproducibility-feasibility.md|sv2-apps OCI reproducibility feasibility]] — applying the Fedimint OCI pattern to SV2 mining stack
- [[../concepts/multi-builder-attestation.md|Multi-builder attestation]] — the gold-standard cohort model
- [[../concepts/derivation-output-modes.md|Derivation output modes]] — how `vendorHash`-style FOD works
- [[../../theses/fedimint-needs-fedimint-sigs.md|Thesis: Fedimint needs a `fedimint.sigs` repo]]
- [[../../theses/sv2-apps-can-easily-adopt-fedimint-style-oci.md|Thesis: sv2-apps can easily adopt Fedimint-style OCI]]
