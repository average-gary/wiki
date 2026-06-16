---
title: "Fedimint NixOS deployment template (fedimint/nixos-deployment)"
sources:
  - https://github.com/fedimint/nixos-deployment
  - https://github.com/fedimint/fedimint/blob/master/docs/deploying.md
type: repo
maintainer: Fedimint org
year: 2024-2026
ingested: 2026-06-15
tags: [fedimint, nixos, deployment, guardian, federation, nixos-anywhere]
confidence: high
quality: 5
---

# Fedimint NixOS deployment template

Official deployment template referenced from `docs/deploying.md` for 4-of-N
guardian federations.

## Stack

- `nixos-anywhere` for remote install
- `disko` for declarative disk partitioning
- `nix-bitcoin` (release branch) for `bitcoind`
- `fedimintd` from the Fedimint flake
- `just apply` per-host for upgrades

## Critical reproducibility gaps

1. **Inputs aren't strictly pinned at source level** — `nixpkgs` tracks
   `nixpkgs-unstable`, `nix-bitcoin` tracks the `release` branch. Determinism
   comes from `flake.lock` only.
2. **No Cachix** in template (operator can opt in).
3. **Guardian-coordination is manual**: README says *"Fedimint requires the
   same versions of `fedimintd` on all peers"* and tells operators to run
   `fedimint --version` before DKG.
4. **There is NO tooling to verify all guardians have the same
   content-addressed binary** — only a version-string check. The doc
   explicitly notes this is a *"current limitation that will be relaxed in
   future versions."*
5. **No documented multi-guardian upgrade ceremony** — just `just apply` per
   host independently.

## Why this matters

The federation trust model depends on guardians running identical software.
But:

- Each guardian's `flake.lock` may differ if they don't sync.
- Even with identical `flake.lock`, two guardians could pull from a
  poisoned Cachix cache (the trust assumption is opt-in).
- The **only** programmatic check today is a version *string*, which is
  trivially spoof-able.

This is materially weaker than:

- Bitcoin Core's `guix.sigs` (≥16 attesters cross-checking hashes).
- LND's 5-signer manifest (at least 5 humans vouch).
- A hypothetical `fedimint.sigs` (does not exist).

The federation model assumes guardians are *adversarial-tolerant* in
consensus but *cooperative* in upgrade — and the upgrade-cooperation channel
has no integrity layer.

## Two-distributor reality

- **`fedimint` org** publishes `fedimintd` Docker images and the NixOS
  template.
- **`fedibtc` org** (Fedi the company) publishes the
  `fedibtc/fedimint-ui:0.7.3` Docker image guardians use for setup/DKG.

A guardian deploying via the official path inherits trust from *two distinct
organizations*, neither of which signs each other's releases. The wiki had
not previously distinguished these.

## Mobile gap

Fedi's production iOS/Android wallet is **closed-source**. Even if `fedimintd`
were perfectly reproducible, the user-facing wallet (the surface most users
actually trust with funds) cannot be reproduced by anyone outside Fedi the
company. Phoenix wallet (different project) publishes Android source +
F-Droid-compatible reproducible APKs — strict improvement on Fedi's mobile
posture.

The `fedibtc/fedi-alpha` repo is a signet demo; the production app is not
public.
