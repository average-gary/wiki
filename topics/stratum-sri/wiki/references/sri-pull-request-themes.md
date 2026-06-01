---
title: "SRI Pull Request Themes (HEAD 65c9688c)"
category: reference
sources:
  - raw/repos/2026-05-28-stratum-sri.md
created: 2026-05-28
updated: 2026-05-28
tags: [sri, prs, recent-commits, channels-sv2, share-accounting, validate-share, contributing, reference]
aliases: ["recent SRI PRs", "SRI commit themes"]
confidence: high
volatility: hot
verified: 2026-05-28
summary: "Snapshot of the last ~10 commits on `main` at HEAD 65c9688c, grouped by theme: standard-job error semantics, channels_sv2 share-accounting + validate_share fix, reverted CONTRIBUTING.md versioning exception. Volatility hot — this is a pinned snapshot, not living state."
---

# SRI Pull Request Themes (HEAD 65c9688c)

> A topic-organized view of the last ~10 commits on `main` at the time of ingest. Anchored to the SHAs in the [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md). This article is **`volatility: hot`** — `main` moves fast; treat it as a snapshot.

## Standard-job error semantics

- **PR #2162** / `df4e764d` (merge `d2285629`) — "add `ERROR_CODE_OPEN_MINING_CHANNEL_EXTENDED_CHANNELS_NOT_SUPPORTED_FOR_STANDARD_JOBS`".
  - Distinguishes a standard-job channel-open request against an extended-channels-only server from generic open-channel errors.
  - Touches the [[sv2-mining-subprotocol|SV2 mining subprotocol]] ([SV2 mining subprotocol](../topics/sv2-mining-subprotocol.md)) error surface.
  - Author: plebhash; branch: `2026-05-22-standard-job-error-code`.

## `channels_sv2` correctness

- **PR #2156** / `cc3977e5` (merge `cb033a48`) — "fix `validate_share` panic after `on_set_new_prev_hash` in custom-work mode".
  - Server-side panic when a new prev-hash arrived between custom-work declaration and a share submission.
  - Custom-work mode is the [[sv2-job-declaration-subprotocol|JDP]] ([JDP](../topics/sv2-job-declaration-subprotocol.md))-driven path through [[sv2-channels|`channels_sv2`]] ([channels_sv2](../concepts/sv2-channels.md)).
  - Author: rx18-eng; branch: `fix/validate-share-panic-after-snph`.

- **PR #2149** / `5e1b025f` (merge `9a61b5e9`) — "`channels_sv2::server::share_accounting` keeps track of rejected shares".
  - Adds explicit accounting for rejected shares alongside the existing accepted-shares counter.
  - Server-side change in `channels_sv2`. Author: plebhash; branch: `2026-05-08-refine-server-share-accounting`.

These two together represent the `channels_sv2` server-side becoming more deliberate about share-state tracking. Expect more in this area as JDP-mode deployments stress the same paths.

## CONTRIBUTING.md versioning churn

- **PR #2158** / `c38df383` (merge `58147e68`) — "refine `CONTRIBUTING.md` with versioning exception to `stratum-core`".
- **PR #2160** / `31bc2278` (merge `65c9688c`, HEAD) — "Revert: refine `CONTRIBUTING.md` with versioning exception to `stratum-core`".

Net effect: at HEAD, no `stratum-core` versioning exception is in `CONTRIBUTING.md`. See [[sri-release-process|SRI release process]] ([SRI release process](sri-release-process.md)) for the rule that applies in its absence and why this exception is likely to come back in another form.

## Author / branch overview

The 10 commits at the snapshot involve three authors active on `main` in the window:

- `plebhash` — #2162 (standard-job error code), #2149 (rejected-shares accounting), #2158 (the reverted CONTRIBUTING change).
- `rx18-eng` — #2156 (`validate_share` panic).
- Maintainer merge commits land via PR-style merges (HEAD is itself a merge).

## Heading further back

Tags through `v1.9.0` are present on remotes; commit history before `9a61b5e9` is older work outside the window of this snapshot. For a deeper recent-history view, query `git log --oneline -20` against the local checkout at the same revision rather than re-ingesting.

## See Also

- [[sv2-channels|SV2 Channels]] ([SV2 Channels](../concepts/sv2-channels.md)) — affected by #2149 and #2156
- [[sv2-mining-subprotocol|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](../topics/sv2-mining-subprotocol.md)) — affected by #2162
- [[sv2-job-declaration-subprotocol|SV2 Job Declaration Subprotocol]] ([SV2 Job Declaration Subprotocol](../topics/sv2-job-declaration-subprotocol.md)) — context for the custom-work fix in #2156
- [[sri-release-process|SRI Release Process]] ([SRI Release Process](sri-release-process.md)) — context for the #2158/#2160 churn
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — the crate that #2158 tried to special-case
- [[sri-crate-map|SRI Crate Map]] ([SRI Crate Map](sri-crate-map.md)) — version table for all crates touched by these PRs

## Sources

- [SRI repo metadata snapshot](../../raw/repos/2026-05-28-stratum-sri.md) — last 10 commits on `main` at `65c9688c`, with PR numbers and commit SHAs
