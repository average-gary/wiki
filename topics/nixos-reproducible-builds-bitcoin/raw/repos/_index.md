---
title: Raw Repos — nixos-reproducible-builds-bitcoin
type: index
created: 2026-06-15
updated: 2026-06-15
---

# Repos

Code repositories.

- [bitcoin/bitcoin — contrib/guix/README.md](2026-06-15-bitcoin-core-contrib-guix-readme.md) — Bitcoin Core's actual deterministic-build system
- [fort-nix/nix-bitcoin](2026-06-15-nix-bitcoin-fort-nix.md) — canonical NixOS modules for Bitcoin / Lightning services
- [fedimint/fedimint — flake.nix](2026-06-15-fedimint-flake-nix.md) — best Bitcoin-adjacent Rust flake (cross-compile, wasm, mobile)
- [lightningnetwork/lnd — release.md + scripts/release.sh](2026-06-15-lnd-release-md.md) — Go-based deterministic build, 5-signer manifest
- [Nixpkgs LND derivation — trimpath / ldflags gap](2026-06-15-nixpkgs-lnd-trimpath-gap.md) — why nix-built LND doesn't hash-match upstream
- [Fedimint Nix internals — flake + flakebox.nix + ci-nix.yml + sign.sh](2026-06-15-fedimint-nix-flakebox-internals.md) — full technical layer
- [Fedimint NixOS deployment template](2026-06-15-fedimint-nixos-deployment-template.md) — guardian coordination = `--version` string check

## Round 4 — sv2-apps OCI feasibility (thesis mode)

- [Fedimint `.github/workflows/ci-nix.yml`](2026-06-15-fedimint-ci-nix-workflow.md) — flake-driven OCI release pipeline (decisive falsifier-of-falsifier)
- [sv2-apps current OCI build state](2026-06-15-sv2-apps-current-build-state.md) — Dockerfile + Buildx + QEMU baseline; `stratum-core branch=main` dep
- [rustshop/loglog flake.nix](2026-06-15-rustshop-loglog-minimal-flake.md) — 103-line Rust→OCI minimal flake (dpc, same author as Flakebox)
- [xmtp/libxmtp musl-docker.nix](2026-06-15-xmtp-libxmtp-musl-docker.md) — production multi-arch musl OCI for Rust workspace
