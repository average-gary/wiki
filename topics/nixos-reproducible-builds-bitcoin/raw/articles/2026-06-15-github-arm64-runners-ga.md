---
title: "GitHub free Linux arm64 hosted runners — public preview Jan 2025, GA Aug 2025"
type: article
source_url: https://github.blog/changelog/2025-01-16-linux-arm64-hosted-runners-now-available-for-free-in-public-repositories-public-preview/
ingested: 2026-06-15
confidence: high
relevance: direct
evidence_strength: primary-source
direction: supports
tags: [github-actions, arm64, ci, runners, supports-thesis, multi-arch]
research_session: 2026-06-15-sv2-apps-easy-oci-reproducibility-thesis
---

# GitHub free Linux arm64 hosted runners (2025)

GitHub announced free `ubuntu-24.04-arm` (and `ubuntu-22.04-arm`) hosted
runners for public repositories in public preview on 2025-01-16; they
went GA in 2025-08. This is the single biggest factor that makes
"sv2-apps replicating Fedimint's CI pattern" cheap.

## Why this matters for the thesis

Before 2025: replicating Fedimint's "native runner per arch" pipeline
required either (a) self-hosted arm64 infrastructure (which Fedimint uses
for production builds — capital cost, ops burden) or (b) Nix
cross-compile from amd64 to arm64, which is an actively unsolved problem
for non-trivial Rust workloads with C-shim deps (see
[[2026-06-15-nix-oci-tooling-open-issues.md]]).

After GA: a public OSS project gets free `ubuntu-24.04-arm` minutes
identical in API surface to `ubuntu-latest`. The Fedimint workflow pattern
ports near-verbatim:

```yaml
strategy:
  matrix:
    arch:
      - { runner: ubuntu-latest,        oci: amd64, system: x86_64-linux }
      - { runner: ubuntu-24.04-arm,     oci: arm64, system: aarch64-linux }
runs-on: ${{ matrix.arch.runner }}
steps:
  - uses: cachix/install-nix-action@v27
  - run: nix build .#container.pool_sv2
  - run: docker load < ./result
  - run: docker tag ... && docker push ...
- # final job: docker manifest create + push
```

## Cost implication

- Total CI minutes ≈ 1.5–2× the current single-runner-with-QEMU pipeline.
- For public repos, those minutes are free.
- For private repos, arm64 minutes are **billed at higher per-minute rates**
  than amd64 (≈ 2× last published price). Not relevant to sv2-apps
  (public repo).

## Reproducibility wins from native arm64 over QEMU

- QEMU emulation is **not bit-identical** across QEMU versions in
  edge cases (e.g. atomic ops, SIMD lowering, syscall translation
  fidelity). Reproducible Builds verification under QEMU requires also
  pinning the QEMU version, which is brittle.
- Native arm64 hardware running the same Nix derivation across rebuilders
  produces identical results without that pin.
- This is the same reason Bitcoin Core's Guix-based deterministic
  release builds use real arm64 hosts for arm64 outputs, not QEMU.

## See also

- [[../repos/2026-06-15-fedimint-ci-nix-workflow.md]] — the pattern this enables for sv2-apps
- [[../repos/2026-06-15-sv2-apps-current-build-state.md]] — current QEMU-based pipeline this replaces
