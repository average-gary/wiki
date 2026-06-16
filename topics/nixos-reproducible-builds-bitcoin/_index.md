---
title: NixOS Reproducible Builds for Bitcoin Projects — Wiki
type: wiki-root
created: 2026-06-15
updated: 2026-06-15
scope: hub-topic
sensitivity: public-shareable
---

# NixOS Reproducible Builds for Bitcoin Projects

How Nix and NixOS are used to produce bit-for-bit reproducible binaries for
Bitcoin Core and adjacent projects (Lightning, Stratum V2 / mining, signing
devices, etc.). Covers the historical Gitian-on-Ubuntu workflow, the migration
to Guix-based deterministic builds, and the parallel Nix-flake / `nix build`
ecosystem maintained by Bitcoin OSS projects (BTCPay Server, NixBitcoin, Fedimint,
LDK, sv2-apps, p2pool, signing devices like ColdCard / Krux).

## Layout

- `wiki/concepts/` — atomic concept articles (Nix store hashing, fixed-output
  derivations, content-addressed derivations, IFD, bootstrap chain, cross-compile)
- `wiki/topics/` — synthesizing topic articles (Bitcoin Core build migration,
  flake patterns for Bitcoin projects, comparison vs Guix)
- `wiki/reference/` — pointers to upstream specs, CVEs, talks, repos
- `raw/` — ingested source material with provenance
- `output/` — generated artifacts (playbooks, decision matrices)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: 34 (3 papers, 19 articles, 11 repos, 1 data)
- Articles compiled: 15 (7 concepts, 7 topics, 1 reference)
- Outputs: 0
- Theses: 3 (2 open candidates + 1 with verdict)
- Last research session: 2026-06-15 (round 4 — `--mode thesis` sv2-apps OCI feasibility)

## Start here

- [[wiki/topics/why-bitcoin-core-uses-guix-not-nix.md|Why Bitcoin Core uses Guix, not Nix]] — start here; the load-bearing reframe
- [[wiki/topics/nix-flake-patterns-for-bitcoin-projects.md|Nix flake patterns for Bitcoin projects]] — what's actually shipped today
- [[wiki/topics/lightning-node-reproducibility-under-nix.md|Lightning node reproducibility under Nix]] — LND/CLN/Eclair/LDK gap analysis
- [[wiki/topics/fedimint-reproducible-builds.md|Fedimint reproducible builds]] — strongest tooling, weakest cohort
- [[wiki/topics/sv2-apps-oci-reproducibility-feasibility.md|sv2-apps OCI reproducibility feasibility]] — applying the Fedimint pattern to SV2 mining stack (3-week MVP)
- [[wiki/topics/playbook-nix-attestation-for-bitcoin.md|Playbook: Nix-built attestation for Bitcoin Core]] — what it would take to participate in `guix.sigs`
- [[wiki/topics/nix-supply-chain-roadmap.md|Nix supply-chain roadmap]] — 2024–2026 state and Bitcoin implications

## Scope

- **In scope**: Nix language + flakes; Nix as a tool for building Bitcoin Core,
  LN node binaries, mining-stack binaries, hardware-wallet firmware, infra-deploy
  artifacts (NixOS modules for `bitcoind`, `lnd`, `clightning`, mempool,
  electrs, btcpayserver). Reproducibility verification (r-b.org, build-env
  dumping, SBOM-via-Nix).
- **Adjacent (referenced)**: Guix (Bitcoin Core's primary deterministic build
  toolchain post-Gitian), Gitian (legacy), Reproducible Builds project, SLSA,
  in-toto, supply-chain provenance.
- **Out of scope**: Generic NixOS server admin, non-Bitcoin reproducibility
  (Linux kernel, Debian, Arch).
