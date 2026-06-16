---
title: "Fedimint repro-cohort = n=1 (issue #4305) + the half-built sign-release flow (PR #4339)"
sources:
  - https://github.com/fedimint/fedimint/issues/4305
  - https://github.com/fedimint/fedimint/pull/4339
  - https://github.com/fedimint/fedimint/issues/2149
type: article
authors: dpc, justinmoon (Fedimint maintainers)
year: 2024
ingested: 2026-06-15
tags: [fedimint, contrarian, attestation, cachix, hostile-witness, primary-source]
confidence: high
quality: 5
---

# Fedimint reproducibility — primary-source critique

The strongest contrarian evidence on Fedimint's reproducibility posture
comes from the project's own issue tracker.

## Issue #4305 — "0.2.2 release binaries are incomplete" (2024-02)

When asked "Do we test reproducibility at all?", maintainer **dpc answers
verbatim**:

> *"I checked it manually a few times."*

That is the entire historical reproducibility-verification cohort: **n=1,
ad-hoc**.

Other findings from the thread:

- Release v0.2.2 shipped with empty/incomplete `.deb` and `.rpm` packages
  without anyone noticing — direct contradiction of any "release-pipeline
  rigor" claim.
- dpc himself proposes that *"since binaries should be reproducible, we
  should write some `just sign-release` script"* — i.e. PGP-signing was
  bolted on **as a substitute for** independent rebuilds, not as a
  complement.
- Issue closed as *"Old and not relevant anymore. Improvements has been
  made."* — no link to evidence (no CI repro check, no public attestations).

## PR #4339 — "feat: simple release signing system" (2024-02, MERGED)

Introduces `just sign-release` producing per-system `*-SHA256SUMS.asc`
files. Notable gaps from the PR description and review:

- *"We don't need the CI to sign anything, and anyone can verify and sign
  the release independently."* — aspirational; ships **without** a
  public-key roster.
- Open follow-ups left in the PR: *"check-in public keys from maintainers
  that are supposed to sign releases"* and *"add and verify reproducibility
  of macos binaries."* Both still deferred 2026-06.
- Reviewer ask: *"please try to sign and verify that checksums are
  deterministic, you don't have to submit your signatures."* — the inverse
  of the `guix.sigs` model where the whole point is submitting your
  signature.

## Issue #2149 — "Docs explain what trusting Fedimint's Cachix means" (2023-04, closed 2024-03)

Maintainer dpc opens with: *"At least explain what that means since you'll
be asked."* Open 11 months. Closed without a public design doc tying Cachix
usage to a threat model.

Combined with the `flake.nix` Cachix substituter line, this is **TOFU on a
single Cachix key controlled by the project**. In the typical
guardian-onboarding flow (`docker pull fedimint/fedimintd`, or
`nix run github:fedimint/fedimint#fedimintd`), the operator never rebuilds
— defeating the purpose of having a reproducible flake.

## Quantitative spine (from `gh release list` + GitHub API, 2026-06)

| Metric | Fedimint | LND | Bitcoin Core |
|--------|----------|-----|--------------|
| Stable releases since project start | ~40 (since 2023-09) | ~40 | ~5 (annualized) |
| Independent attesters per release | **0** (single GH-Actions bot signs; signed git tag by 1 of 2 humans: @elsirion or @dpc) | 5 maintainer manifests | 16-23 (`guix.sigs`) |
| Release cadence (minor) | ~2.6 months | ~2 months | ~6 months |
| Cachix/binary-cache trust roots | 1 key (`fedimint.cachix.org-1:Fp...`) | 0 (Docker images) | 0 (Guix builds from source) |
| `SHA256SUMS.asc` artifact | per-system, single signer | inline manifest, 5 signers | yes, 16-23 signers |

Fedimint is **two tiers below Bitcoin Core** and **one tier below LND** on
the multi-builder cohort axis.

## What's actually published

GitHub release artifacts (28/release): RPM, DEB, raw binaries, macOS aarch64
tarballs, Start9 `.s9pk` packages, for `fedimintd`, `fedimint-cli`,
`fedimint-dbtool`, `fedimint-recoverytool`, `gatewayd`, `gateway-cli`,
`devimint`, `fedimint-pkgs`, `gateway-pkgs`. Each has a `digest: sha256:...`
field in the API (GitHub-managed).

**No separate `SHA256SUMS` file or `SHA256SUMS.asc` GPG-signed manifest** in
the GitHub release assets — only signed git tags.

## Federation observability gap (2026-06)

Public federation directories:
- `federations.observer` — **DOWN** (ECONNREFUSED) at research time.
- `bitcoinmints.com` — JS-rendered; static fetch yielded one entry (Prism /
  makeprisms.com).
- `fedi.xyz` — no public quantitative federation/user counts.

*No canonical "active Fedimint federations" dataset is reachable from public
sources.* Worth filing as an inventory candidate.
