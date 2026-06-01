---
title: "SRI Release Process"
category: reference
sources:
  - raw/articles/2026-05-28-stratum-sri-release.md
  - raw/articles/2026-05-28-stratum-sri-contributing.md
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [sri, release, versioning, semver, branches, tags, contributing]
aliases: ["RELEASE.md rule", "SRI versioning"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "How SRI cuts releases at HEAD 65c9688c: per-crate SemVer 2.0.0, per-PR public-API discipline from CONTRIBUTING.md, repo X.Y.Z bumps under maintainers' subjective rule, release-branch + tag flow. Latest tag v1.9.0; reverted #2158/#2160 churn around a stratum-core versioning exception."
---

# SRI Release Process

> The release-process surface for `stratum-mining/stratum` lives in two files: `RELEASE.md` (release branches, tags, the X.Y.Z bump rule) and the "Versioning and public dependencies" section of `CONTRIBUTING.md` (per-PR SemVer discipline, especially the public-API rule). This article reconciles them and notes the recent churn around a `stratum-core`-specific exception.

## Per-crate versioning

Per `CONTRIBUTING.md`:

> Whenever submitting a PR that modifies some crate, it's up to the contributor to make sure the versioning of this crate remains sane.

The contributor checks three things on every PR:

1. **What bump does SemVer 2.0.0 prescribe** for the changes in this PR?
2. **Has this crate's version already been bumped** since the last crates.io publish? If yes, does this PR need a larger bump than what's already there?
3. **Does the change affect public API in dependents?** "Public API exposure" is enumerated:
   - re-exports
   - public function/method arguments and return types
   - public trait method signatures
   - public enum variant payloads
   - public struct fields
   - public type aliases and associated types

   If a public-API change in crate `A` is exposed in crate `B`, then `B` also needs an incompatible bump.

CI partially enforces (1) and (2); reviewers are responsible for (3).

For `1.0.0+` crates, an incompatible bump is a MAJOR bump. For `0.x.y` crates, an incompatible bump is normally a MINOR bump (`0.2.3 → 0.3.0`); PATCH bumps within a `0.x.y` line are treated as compatible.

## Repository X.Y.Z bumps

Per `RELEASE.md`:

> The global repository releases follow `X.Y.Z`, which is changed under some subjective criteria:
> - If a release includes only bug fixes, then `Z` is bumped.
> - If a release includes breaking and/or non-breaking changes, then `Y` is bumped.
> - If a release marks a milestone (i.e., crates are reaching a new maturity level), then `X` is bumped.

This is **not** SemVer — it's a maintainer-rule overlay on top of per-crate SemVer. A repo `Y` bump can include both breaking and non-breaking changes; a repo `X` bump signals maturity, not necessarily a coordinated MAJOR across crates.

## Release branches and tags

Per `RELEASE.md`:

1. Create a new release branch `x.y.z` from `main`.
2. Create a new tag for that branch.
3. Publish the release.

The release branch is "a breaking point and future reference" — bug fixes for that release happen on the release branch, not on `main`. New work continues on `main` against the next release. Tags `v1.0.0` through `v1.9.0` are present on remotes at HEAD; `v1.9.0` (`6ab03af2`) is the latest.

## Branch policy

`RELEASE.md` and the local working tree confirm:

- `main` is the default branch and is always active.
- `main` is protected and requires a PR with **at least 2 approvals** to merge.
- Changes to `main` are introduced through merge commits.
- Each release tag points to a release branch kept around for future reference/fixes.

## Crate publication

Per `RELEASE.md`:

> Whenever the repository goes through a global release, all crates are published to crates.io.

`scripts/sv2-publish.sh` is the publish helper alongside `scripts/release-libs.sh`. Crates aren't published continuously — they are published in a batch tied to the repo X.Y.Z release.

## Recent versioning churn (#2158 / #2160)

A short-lived attempt landed in `CONTRIBUTING.md` to add a `stratum-core`-specific versioning exception:

- **PR #2158** / commit `c38df383` — "refine `CONTRIBUTING.md` with versioning exception to `stratum-core`" (merge `58147e68`).
- **PR #2160** / commit `31bc2278` — "Revert: refine `CONTRIBUTING.md` with versioning exception to `stratum-core`" (merged at HEAD `65c9688c`).

Net effect at this snapshot: there is **no** special-case versioning rule for `stratum-core` in `CONTRIBUTING.md`. It follows the same per-PR public-API rule as every other crate. Whatever motivated #2158 will likely come back in another shape; until it does, treat the umbrella crate's versioning as "if you bump a re-exported crate's MAJOR, you almost certainly bump `stratum-core`'s MAJOR" because every re-exported crate sits in `stratum-core`'s public API.

## Changelog

Changelogs are auto-generated on each release page. Maintainers add contextual notes for general release info, breaking changes, and notable changes; there is no hand-maintained `CHANGELOG.md` in the repo.

## See Also

- [[sri-crate-map|SRI Crate Map]] ([SRI Crate Map](sri-crate-map.md)) — current per-crate versions
- [[sri-pull-request-themes|SRI Pull Request Themes]] ([SRI Pull Request Themes](sri-pull-request-themes.md)) — recent commit context including #2158/#2160
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — the crate that triggered the reverted exception

## Sources

- [RELEASE.md](../../raw/articles/2026-05-28-stratum-sri-release.md) — release-branch/tag flow, X.Y.Z subjective rule, branch protection
- [CONTRIBUTING.md](../../raw/articles/2026-05-28-stratum-sri-contributing.md) — per-PR SemVer discipline, public-API rule
- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — #2158 → #2160 revert, latest tag v1.9.0, branch protection observations
