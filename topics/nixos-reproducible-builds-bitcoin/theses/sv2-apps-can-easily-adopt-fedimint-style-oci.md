---
title: "Thesis: sv2-apps could easily adopt reproducible builds for OCI containers like Fedimint"
type: thesis
status: completed
created: 2026-06-15
updated: 2026-06-15
verdict: partially-supported
confidence: high
core_claim: "sv2-apps could easily adopt reproducible builds for OCI containers, modeled on Fedimint's Nix flake + dockerTools.buildLayeredImage pattern."
key_variables:
  - sv2-apps build (Rust workspace, 3 binaries, Dockerfile + Buildx + QEMU today)
  - Fedimint Nix flake / Flakebox / dockerTools / ci-nix.yml pattern
  - "easily" = bounded engineering effort, weeks not quarters
  - reproducibility = bit-identical OCI image hash across rebuilders
falsification: "Either (a) Fedimint's OCI images are not actually reproducible (only binaries are), (b) the path requires exotic upstream changes, or (c) effort exceeds a quarter of skilled engineering work."
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# Thesis: sv2-apps could easily adopt reproducible builds for OCI containers like Fedimint

## Core Claim

sv2-apps (`stratum-mining/sv2-apps` — the Stratum V2 reference applications:
`pool_sv2`, `jd_client_sv2`, `translator_sv2`) could replace its current
Dockerfile + Buildx + QEMU pipeline with a Nix flake driving
`dockerTools.buildLayeredImage` outputs, modeled on Fedimint's
`ci-nix.yml`, achieving bit-identical OCI image hashes across
rebuilders. Effort scoped to a few weeks of focused work.

## Key Variables

- **sv2-apps build** — 3 Rust binaries, Dockerfile-driven multi-arch via
  QEMU. No `--locked`, no `SOURCE_DATE_EPOCH`, mutable base tags. C-shim
  surface limited to capnproto.
- **Fedimint pattern** — Crane-built Rust binaries fed into
  `pkgs.dockerTools.buildLayeredImage`; per-arch native runners; manifest
  stitching on registry. Confirmed by
  [[../raw/repos/2026-06-15-fedimint-ci-nix-workflow.md]].
- **"Easily"** — defined here as <1 calendar quarter of effort by
  someone who has built a Nix flake before; no upstream Bitcoin or
  Stratum-spec changes; no exotic toolchain gymnastics.
- **Reproducibility** — bit-identical OCI image tarball hash (and
  manifest digest) when independent rebuilders run `nix build` on the
  same flake-locked source.

## Testable Prediction

A `nix build .#container.pool_sv2` (and `.#container.jd_client_sv2`,
`.#container.translator_sv2`) on the same flake.lock and source will
produce identical OCI tarball hashes across two rebuilders running on:

- amd64 host with NixOS or Nix-on-Linux
- arm64 host with NixOS or Nix-on-Linux

…with the same flake commit. CI verifies by running the build twice and
comparing `sha256sum result`.

## Falsification Criteria

The thesis is falsified if **any** of:

1. Fedimint's OCI images on Docker Hub are NOT produced by the flake
   (i.e. by a separate Buildx pipeline) — checking the repo's actual CI
   workflow.
2. Multi-arch reproducible OCI from a single Nix host has unsolved
   blocking gaps for capnproto + Rust workloads.
3. The dep graph (specifically `stratum-core { git, branch = "main" }`)
   forces non-bounded vendor-hash maintenance.
4. Fedimint's "drop-in" tooling is so accreted with single-maintainer
   workarounds that adopting it imports unsustainable maintenance.
5. Effort exceeds a calendar quarter even for the MVP.

## Evidence For

Sorted by evidence strength.

### Strong

- **[[../raw/repos/2026-06-15-fedimint-ci-nix-workflow.md|Fedimint
  ci-nix.yml]]** (primary source) — Fedimint's Docker Hub images ARE
  produced by the flake (`nix build .#container.<name>` →
  `docker load` → `docker push`). Falsifier #1 is dissolved. Multi-arch
  via native runners per arch + `docker manifest create` stitching.
- **[[../raw/repos/2026-06-15-rustshop-loglog-minimal-flake.md|loglog
  minimal flake]]** (primary source / case study) — same author as
  Fedimint's Flakebox demonstrates the pattern in 103 LOC. Linear
  extrapolation to sv2-apps' 3 binaries: ~150-200 LOC.
- **[[../raw/repos/2026-06-15-xmtp-libxmtp-musl-docker.md|libxmtp
  musl-docker.nix]]** (primary source / case study) — production Rust
  workspace shipping per-arch reproducible OCI images for amd64 + arm64
  musl. Most direct precedent for sv2-apps' multi-arch requirement.
- **[[../raw/articles/2026-06-15-github-arm64-runners-ga.md|GitHub free
  arm64 runners]]** (primary source / changelog) — `ubuntu-24.04-arm`
  runners free for public repos since GA 2025-08. Removes the cost
  objection to "native runner per arch." sv2-apps is a public repo.
- **[[../raw/repos/2026-06-15-sv2-apps-current-build-state.md|sv2-apps
  build state]]** (primary observation) — no openssl-sys, no ring, no
  libssh2 in `pool-apps/Cargo.lock`. Cleaner C-shim surface than LND or
  Bitcoin Core. Already has `rust-toolchain.toml` pinned.

### Moderate

- **[[../raw/repos/2026-06-15-fedimint-nix-flakebox-internals.md|Fedimint
  Flakebox internals]]** (primary source) — proves the comparator is
  doing real reproducibility work (replaceGitHash patcher, LLVM 20 pin,
  Crane three-stage cache, 300 MB closure-size guardrail). The MVP
  pattern is a proper subset.

## Evidence Against

### Strong

- **[[../raw/articles/2026-06-15-fedimint-flake-nix-evolution.md|Fedimint
  flake.nix 4-year timeline]]** (primary source) — Fedimint's current
  41KB `nix/flakebox.nix` is 4 years of accreted complexity (8 flake
  inputs, 6 custom overlays, mobile + wasm + cross-compile, Flakebox
  extracted as a separate single-maintainer project). "Easily adopt
  Fedimint's flake" is misleading if read literally; "adopt the
  Fedimint MVP pattern circa 2022 PR #322" is correct.
- **[[../raw/repos/2026-06-15-sv2-apps-current-build-state.md]]
  re: dep model** — `stratum-core { git, branch = "main" }` auto-bumped
  by upstream `repository_dispatch`. Each bump invalidates Nix-side
  dep hashes. Adopting Nix means extending `stratum-core-sync.yaml` to
  recompute hashes per bump, OR pinning to upstream tags. The
  maintainers already flag this as a pre-publish blocker (inline comment:
  *"MUST be changed before stratum-apps is published to crates.io"*).

### Moderate

- **[[../raw/articles/2026-06-15-nix-oci-tooling-open-issues.md|Nix OCI
  tooling open issues]]** (primary source / issue tracker) — nixpkgs
  `dockerTools` has open issues (`runAsRoot` broken on
  `ubuntu-24.04-arm`, doc gaps, format-version inconsistency).
  nix2container cross-compile only landed in 2025. Adopters who hit
  these eat a 1-2 week debug tax on top of the happy-path estimate.
  Mitigation: stay on `dockerTools.buildLayeredImage`, avoid `runAsRoot`,
  don't use nix2container — exactly the Fedimint pattern.

### Weak / nuance

- **[[../raw/articles/2026-06-15-mitchellh-nix-with-dockerfiles.md|Hashimoto:
  Nix with Dockerfiles]]** (expert opinion) — popular blog post pushes
  a Dockerfile-wrapping-Nix pattern that does NOT yield reproducible
  OCI images. Documentation cost: sv2-apps' adopted Nix path needs to
  explicitly steer readers away from this pattern.
- **No prior art in mining-pool space** — no flake in
  `stratum-mining/stratum` (the upstream SRI repo), none in p2pool,
  p2poolv2, datum_gateway. sv2-apps would be the first; sharp edges
  discovered in-house, no community pattern to lean on. Cuts both ways.

## Nuances & Caveats

- **"Easily" splits between two readings**:
  - "Build *like Fedimint MVP*" (Crane + dockerTools, the loglog/libxmtp
    pattern, ~150-250 LOC of flake + 50 LOC of CI) — **3 weeks**.
  - "Build *like Fedimint current state*" (full Flakebox, 6 overlays,
    cross-compile env, replaceGitHash, 41KB) — **months**, and imports
    a single-maintainer-bus-factor-1 dependency. Not recommended.

- **Reproducibility ≠ verified reproducibility**: even with the build
  bit-deterministic, sv2-apps still has a 1-rebuilder cohort (Docker Hub
  push from the GitHub-hosted runner). Building a `sv2-apps.sigs`-style
  cohort is a separate, longer initiative — the same gap Fedimint has
  ([[../wiki/topics/fedimint-reproducible-builds.md]]).

- **The `stratum-core branch=main` problem** is the largest moderating
  variable. It's already on the maintainers' to-fix list independent of
  Nix; the ROI of fixing it goes up if Nix adoption is on the roadmap.

- **SLSA / cosign / sigstore** are NOT in the MVP scope. They're
  off-the-shelf via the GitHub SLSA generator and a subsequent ~1 week
  of work, but they layer on top of bit-deterministic builds, not before.
  Don't conflate.

- **Cachix-as-TOFU**: Fedimint's binary cache is a single-key trust
  root. A sv2-apps Cachix would inherit the same property. The cohort
  axis is what fixes this, not Cachix itself. See
  [[../wiki/topics/fedimint-reproducible-builds.md]] § federation-trust
  paradox.

## Verdict

**Status**: Partially Supported

**Confidence**: High

**Summary**: The thesis holds for the **build axis** at the **MVP-pattern
reading**. sv2-apps could realistically ship a Nix flake driving
reproducible OCI images via `dockerTools.buildLayeredImage`, with native
arm64 runners now free on GitHub, in approximately 3 weeks of focused
engineering. The `stratum-core branch=main` dep model is the single
largest moderating cost and is solvable (and already on the maintainers'
fix list). The thesis is **falsified at the literal "adopt Fedimint's
flake" reading** — the current Flakebox is 4 years of accreted
complexity, much of it for capabilities sv2-apps doesn't need; copy the
*pattern*, not the *implementation*.

**Strongest supporting evidence**:

1. Fedimint's `ci-nix.yml` confirms the OCI half *is* flake-driven —
   the central thesis-opposing argument is empirically wrong.
2. The loglog (103 LOC) + libxmtp (multi-arch musl) precedents collapse
   the engineering budget into a tractable LOC count.
3. Free GH-hosted arm64 runners since 2025-08 remove the
   self-hosted-infra cost objection that Fedimint pays.
4. sv2-apps' build surface is materially cleaner than the comparator
   (no openssl/ring, only 3 binaries, no mobile/wasm).

**Strongest opposing evidence**:

1. Fedimint's flake is 4 years of accreted maintenance — adopting it
   literally is not easy. (Mitigation: adopt the MVP pattern, not the
   current state.)
2. `stratum-core { git, branch = "main" }` is structurally hostile to
   Nix's hash-pinning model; needs a fix that's already on the
   maintainers' radar.

**Key caveats**:

- "Reproducible build" ≠ "verified reproducibility." Cohort
  (rebuilders + signed manifests) is a separate, longer initiative.
- Tooling open issues (nixpkgs `dockerTools` #416467, etc.) bite the
  unhappy path. Stay on the documented happy path.
- SLSA / cosign attestation transport is a ~1 week follow-up, not a
  prerequisite.

**What would change this verdict**:

- A real attempt at the work that takes >1 quarter would shift the
  verdict from "Partially Supported" to "Insufficient Evidence" or
  "Mixed."
- A breaking change in Fedimint's flake that drops `dockerTools` for
  `nix2container` would invalidate the "copy the pattern" path; the
  newer pattern would need re-evaluation.
- Discovery of a build.rs / runtime dep in `stratum-core` that requires
  network access during build (e.g. fetching Bitcoin Core test
  vectors) would break Nix sandboxing and substantially raise the cost.

**Suggested follow-up theses**:

- *"sv2-apps reproducibility delivers operator-meaningful supply-chain
  improvement only if a 3+ rebuilder cohort exists."* (cohort-axis
  thesis, parallel to
  [[../theses/fedimint-needs-fedimint-sigs.md]])
- *"Pinning `stratum-core` to a tagged release would reduce CI churn
  net-negative for the upstream SRI velocity model."* (dep-model thesis,
  Nix-orthogonal but unblocks Nix adoption)
- *"A shared `stratum.nix` flake-fragment in `stratum-mining/stratum`
  upstream would lower adoption cost for sv2-apps and any future
  downstream Stratum implementation."* (upstream-flake thesis)

## Implementation pointer

If this thesis becomes a project, the engineering plan is in
[[../wiki/topics/sv2-apps-oci-reproducibility-feasibility.md]] §
"Recommended approach."

## See also

- [[../wiki/topics/sv2-apps-oci-reproducibility-feasibility.md]] — the
  underlying engineering assessment
- [[../wiki/topics/fedimint-reproducible-builds.md]] — the comparator
- [[../wiki/topics/nix-flake-patterns-for-bitcoin-projects.md]] — the
  catalog this thesis would extend (Pattern 5: SV2 mining stack)
- [[fedimint-needs-fedimint-sigs.md]] — parallel cohort-axis thesis
- [[../wiki/concepts/multi-builder-attestation.md]] — the cohort-axis
  ceiling
