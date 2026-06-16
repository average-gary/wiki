---
title: "sv2-apps OCI reproducibility — feasibility assessment vs Fedimint pattern"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [sv2-apps, stratum-v2, fedimint, oci, dockerTools, crane, feasibility, cross-domain]
sources:
  - "[[../../raw/repos/2026-06-15-fedimint-ci-nix-workflow.md|Fedimint ci-nix.yml]]"
  - "[[../../raw/repos/2026-06-15-fedimint-nix-flakebox-internals.md|Fedimint Flakebox internals]]"
  - "[[../../raw/repos/2026-06-15-sv2-apps-current-build-state.md|sv2-apps current build state]]"
  - "[[../../raw/repos/2026-06-15-rustshop-loglog-minimal-flake.md|loglog minimal flake]]"
  - "[[../../raw/repos/2026-06-15-xmtp-libxmtp-musl-docker.md|libxmtp multi-arch musl-docker.nix]]"
  - "[[../../raw/articles/2026-06-15-github-arm64-runners-ga.md|GitHub free arm64 runners]]"
  - "[[../../raw/articles/2026-06-15-fedimint-flake-nix-evolution.md|Fedimint flake.nix 4-year timeline]]"
  - "[[../../raw/articles/2026-06-15-nix-oci-tooling-open-issues.md|Nix OCI tooling open issues]]"
  - "[[../../raw/articles/2026-06-15-mitchellh-nix-with-dockerfiles.md|Hashimoto: Nix with Dockerfiles]]"
---

# sv2-apps OCI reproducibility — feasibility assessment

Whether `stratum-mining/sv2-apps` could adopt reproducible OCI image
builds modeled on the Fedimint pattern, and at what cost. The thesis
under test is *"sv2-apps could easily adopt reproducible builds for OCI
containers like Fedimint."* The verdict is in
[[../../theses/sv2-apps-can-easily-adopt-fedimint-style-oci.md]]; this
article is the underlying engineering assessment.

## What "like Fedimint" actually means (the load-bearing fact)

Before this research session, a plausible falsifier was that Fedimint's
*Rust binaries* are reproducible but its *Docker Hub images* are baked by
Buildx — leaving the OCI half of the supply chain non-deterministic.

[[../../raw/repos/2026-06-15-fedimint-ci-nix-workflow.md|Fedimint's `ci-nix.yml`]]
falsifies that. The Docker Hub images come from the flake:

```bash
nix build -L .#container.<name>
docker load < ./result
docker tag ... && docker push ...
```

Each per-arch image is a `dockerTools.buildLayeredImage` output. After
both arches push, a final job stitches with `docker manifest create`. The
multi-arch story uses **native runners per arch** (one `ubuntu-latest`
amd64 + one self-hosted arm64), not Nix cross-compile and not QEMU.

So "like Fedimint" = **Crane-built Rust binaries fed into
`dockerTools.buildLayeredImage` outputs, pushed via a per-arch native-runner
matrix, manifest-stitched on registry**. That is a coherent, well-scoped
target.

## sv2-apps starting point

From [[../../raw/repos/2026-06-15-sv2-apps-current-build-state.md]]:

- **Workspace shape**: 3 release binaries (`pool_sv2`, `jd_client_sv2`,
  `translator_sv2`). Smaller than Fedimint's 7+.
- **Build today**: `docker/Dockerfile` (multi-stage,
  `rust:1.85-slim-bookworm` → `debian:bookworm-slim`), GitHub Actions with
  `setup-qemu-action` + `setup-buildx-action`, single-runner amd64+arm64
  via QEMU emulation, push to `stratumv2/<app>:<tag>` on Docker Hub.
- **C-shim surface**: capnpc (calls `capnproto` in build.rs) and pure-Rust
  crypto via `secp256k1`/`miniscript`. **No openssl-sys, no ring,
  no libssh2.** Materially cleaner than LND or Bitcoin Core.
- **Reproducibility today**: zero. Mutable base-image tags, unpinned
  `apt-get update`, no `--locked` on cargo, no `SOURCE_DATE_EPOCH`.
- **`rust-toolchain.toml`** is pinned (good).

## The favorable factors

1. **Build surface is small and clean** — 3 binaries, no openssl/ring,
   pure-Rust crypto. Mechanically simpler than the Fedimint comparator.
2. **Public repo → free GH-hosted arm64 runners** since 2025-08
   ([[../../raw/articles/2026-06-15-github-arm64-runners-ga.md]]).
   This is the single biggest enabler — Fedimint pays for self-hosted
   arm64; sv2-apps gets it free.
3. **Crane is mature for Rust workspaces**. The
   [[../../raw/repos/2026-06-15-rustshop-loglog-minimal-flake.md|loglog 103-line flake]]
   demonstrates the binary→OCI happy path; the
   [[../../raw/repos/2026-06-15-xmtp-libxmtp-musl-docker.md|libxmtp musl-docker.nix]]
   demonstrates per-arch images for production Rust.
4. **No mobile / wasm / Android / iOS** — sv2-apps doesn't need any of
   the targets that drove most of Flakebox's complexity (see
   [[../../raw/articles/2026-06-15-fedimint-flake-nix-evolution.md|Flake evolution timeline]]).

## The unfavorable factors

1. **`stratum-core { git = "...", branch = "main" }`** — moving git branch
   dep auto-bumped by an upstream `repository_dispatch` workflow. Each
   bump invalidates `cargoHash`/`vendorHash`/`cargoLock.outputHashes`. Any
   Nix-side adoption needs the existing `stratum-core-sync` workflow
   extended to recompute Nix dep hashes on each bump, OR sv2-apps has to
   pin to upstream tags (out-of-scope upstream contract change).
   The maintainers already see this as a ship-blocker — there's an
   inline comment in the workspace: *"MUST be changed before stratum-apps
   is published to crates.io."*
2. **No prior art in the mining-pool space** — no flake in
   `stratum-mining/stratum`, none in `pool2win/p2poolv2`, none in
   `lightningdevkit/rust-lightning`, none in OCEAN's `datum_gateway`. So
   sv2-apps would be a first-mover in mining-pool Nix adoption. Pro: low
   coordination cost. Con: every sharp edge is discovered in-house.
3. **Tooling open issues bite the unhappy path**
   ([[../../raw/articles/2026-06-15-nix-oci-tooling-open-issues.md]]):
   nixpkgs `dockerTools` `runAsRoot` is broken on `ubuntu-24.04-arm`
   (#416467); nix2container cross-compile only landed in 2025; docs are
   incomplete (#374290). Mitigation: don't use `runAsRoot`; don't use
   nix2container; use `dockerTools.buildLayeredImage` only — exactly the
   Fedimint pattern.
4. **Multi-builder cohort takes years to bootstrap**. Even Fedimint, with
   the build tooling done, has 0 independent rebuilders per release
   ([[fedimint-reproducible-builds.md]]). Reproducibility-without-verification
   is a marketing claim. sv2-apps adopting the build infrastructure is
   step 1 of N; building a `sv2-apps.sigs`-style cohort is step N.

## Effort budget

Rough decomposition assuming the Fedimint MVP pattern (not the full Flakebox):

| Component | Source pattern | LOC budget | Effort |
|---|---|---|---|
| Initial `flake.nix` (3 binaries, devShell, OCI outputs) | loglog × 3 + libxmtp matrix | ~150-200 LOC | 1-2 weeks |
| `ci-nix.yml` GitHub Actions workflow | Fedimint copy | ~50 LOC | 1-2 days |
| `stratum-core-sync` extension to recompute cargo hashes | new | ~30 LOC | 2-3 days |
| Cachix or `attic` binary cache setup | Fedimint copy | infrastructure | 1 day |
| Documentation (point users at Nix vs Dockerfile path) | new | ~ 1 page | 1 day |
| **Build-side total** | | **~250 LOC + infra** | **~3 weeks of focused work** |

What's *not* in this budget:

- SLSA L3 cosign attestations (additional ~1 week, off-the-shelf via
  the SLSA GitHub generator).
- Multi-builder cohort / `sv2-apps.sigs` (months-to-years of social
  infrastructure, not engineering).
- NixOS deployment module for `sv2-apps` (out of scope for this thesis).
- Full Flakebox adoption (not recommended; bus-factor-1 dependency).

## Recommended approach (if this thesis becomes a project)

1. **Stay on the dockerTools path** — the Fedimint-loglog-libxmtp pattern.
   Don't take a Flakebox dependency; copy the *pattern* not the
   *implementation*.
2. **Native runners per arch** — `ubuntu-latest` for amd64,
   `ubuntu-24.04-arm` for arm64, manifest-stitch with `docker manifest
   create`. Skip QEMU and skip Nix cross-compile.
3. **No `runAsRoot`** in OCI image config — sidesteps nixpkgs #416467.
   Replace `gettext-base`-via-apt with `pkgs.gettext` in `contents`.
4. **Pin `stratum-core` to a tagged release** (or extend the auto-sync
   workflow to recompute `cargoHash`). The current `branch = "main"` is
   a known maintenance liability independent of Nix.
5. **Ship `devShells.default` alongside the OCI outputs** — same flake,
   covers the dev-onboarding wins from
   [[../../raw/articles/2026-06-15-mitchellh-nix-with-dockerfiles.md|Hashimoto's
   post]] without committing to NixOS-everywhere.
6. **Defer SLSA / cosign / `sv2-apps.sigs` to a follow-up phase** — get
   the build deterministic first; layer attestation transport on top.

## Where this lands sv2-apps in the wiki's existing comparison

From [[lightning-node-reproducibility-under-nix.md]] and
[[fedimint-reproducible-builds.md]]:

| Project | Build tooling | Multi-builder cohort |
|---------|---------------|----------------------|
| Bitcoin Core | Guix (deterministic) | 16-23 (`guix.sigs`) |
| Fedimint | Nix flake + Flakebox | 0 (Cachix TOFU) |
| LND | Docker (non-reproducible by spec) | 5 maintainers (binary parity) |
| CLN | Cargo + best-effort | varies |
| LDK | Cargo (no flake) | varies |
| **sv2-apps (today)** | Dockerfile + Buildx + QEMU | 1 (Docker Hub TOFU) |
| **sv2-apps (post-thesis)** | Nix flake + dockerTools | 1 → grows with adoption |

Adopting the Fedimint pattern moves sv2-apps from "below LND" to
"Fedimint-tier" on the build axis without changing the cohort axis. The
cohort axis is a separate, longer initiative.

## See also

- [[fedimint-reproducible-builds.md|Fedimint reproducible builds]] — the comparator
- [[nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]] — the catalog this would extend
- [[lightning-node-reproducibility-under-nix.md|Lightning node reproducibility under Nix]] — adjacent gap analysis
- [[../concepts/multi-builder-attestation.md|Multi-builder attestation]] — the cohort-axis ceiling
- [[playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]] — the SLSA/cosign layer this defers
- [[../../theses/sv2-apps-can-easily-adopt-fedimint-style-oci.md|Thesis: sv2-apps can easily adopt Fedimint-style OCI]] — the verdict
