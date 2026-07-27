---
title: "Multi-builder attestation (gitian.sigs / guix.sigs pattern)"
category: concept
created: 2026-06-15
updated: 2026-06-15
volatility: warm
confidence: high
tags: [attestation, multi-builder, guix-sigs, gitian-sigs, distributed-verification]
summary: "Bitcoin Core's release-integrity model: N independent builders rebuild each release from source on their own machines and GPG-sign per-arch SHA256SUMS, publishing the signatures into a public repo."
sources:
  - "[[../../raw/data/2026-06-15-bitcoin-core-guix-sigs.md|bitcoin-core/guix.sigs data]]"
  - "[[../../raw/articles/2026-06-15-rb-summit-2025-vienna.md|RB Summit 2025 — distributed verification]]"
  - "[[../../raw/articles/2026-06-15-bitcoin-pr-15277-dong-guix-migration.md|Bitcoin PR #15277 + 2019 announcement]]"
---

# Multi-builder attestation

Bitcoin Core's release-integrity model: **N independent builders** rebuild
each release from source on their own machines and **GPG-sign per-arch
SHA256SUMS**, publishing the signatures into a public repo.

## The pattern

1. Release tag is published in `bitcoin/bitcoin`.
2. Each builder runs `contrib/guix/guix-build` (replaces Gitian since 22.0).
3. Builder produces per-arch `SHA256SUMS` for noncodesigned binaries.
4. Builder GPG-signs the file and PRs it to `bitcoin-core/guix.sigs`.
5. Verifiers compare hashes across signers; mismatches = investigation.
6. Stage 2: Apple/Microsoft code-signing attached, distributed back, and
   re-attested.

## Quantitative profile (per-release attesters, 2026-06)

| Bitcoin Core release | Independent attesters |
|---|---|
| 26.0 | **23** |
| 27.0 | 19 |
| 28.0 | 20 |
| 28.4 | 16 (point-release) |

`gitian.sigs` (1010-archived 2022-11-12) accumulated 4,062 commits across
its lifetime — each commit is a single builder × platform × release
attestation.

## How this generalizes (RB Summit 2025)

The Reproducible Builds community is moving toward this same model
ecosystem-wide as **distributed verification** — Holger Levsen's
formulation: *"if the russians, the chinese and the US agree, the build
output is probably fine."* Bitcoin Core has run this model in production for
~6 years (2019 PR #15277 → 2026); the broader community is generalizing it.

## Implication for Nix-on-Bitcoin

A Nix-based reproducible Bitcoin build is *only* meaningful if it
participates in this attestation regime — i.e. produces output hashes
verifiable against `guix.sigs` entries, not a parallel
`nix-bitcoin.sigs` universe.

[[../topics/playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]] sketches what this would look like in practice.

## See also

- [[bootstrap-chain.md|Bootstrap chain]]
- [[../topics/why-bitcoin-core-uses-guix-not-nix.md|Why Bitcoin Core uses Guix, not Nix]]
- [[reproducibility-tooling.md|Reproducibility tooling]]
- [[../../theses/fedimint-needs-fedimint-sigs.md|Thesis: Fedimint should establish a fedimint.sigs multi-builder attestation repo]]
- [[../topics/fedimint-reproducible-builds.md|Fedimint reproducible builds]]
- [[../topics/lightning-node-reproducibility-under-nix.md|Lightning node reproducibility under Nix]]
- [[../../theses/nix-can-match-guix-attestation.md|Thesis: A Nix-built attestation can join bitcoin-core/guix.sigs as toolchain-diversity insurance]]
- [[../topics/nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]]
- [[../topics/playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]]
- [[../../theses/sv2-apps-can-easily-adopt-fedimint-style-oci.md|Thesis: sv2-apps could easily adopt reproducible builds for OCI containers like Fedimint]]
- [[../topics/sv2-apps-oci-reproducibility-feasibility.md|sv2-apps OCI reproducibility — feasibility assessment vs Fedimint pattern]]
