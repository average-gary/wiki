---
title: "stratum-mining/stratum (SRI low-level crates)"
source: "https://github.com/stratum-mining/stratum"
type: repos
ingested: 2026-05-28
tags: [sri, stratum-v2, sv2, sv1, rust, mining, bitcoin, stratum-core, codec-sv2, noise-sv2, channels-sv2, framing-sv2, parsers-sv2, handlers-sv2, subprotocols, stratum-translation]
summary: "The upstream Stratum Reference Implementation low-level repo. Contains the SV2 crate suite (`binary-sv2`, `buffer-sv2`, `codec-sv2`, `framing-sv2`, `noise-sv2`, `channels-sv2`, `handlers-sv2`, `parsers-sv2`, `extensions-sv2`, `subprotocols/{common-messages,job-declaration,mining,template-distribution}`), the `stratum-core` workspace umbrella crate, `stratum-translation` (SV1↔SV2), the SV1 crate, plus `protocols/`, `roles/storage`, `benches/`, and `fuzz/`. Application-level wiring lives elsewhere in `sv2-apps`."
canonical_url: "https://github.com/stratum-mining/stratum"
local_checkout: "/Users/garykrause/repos/stratum"
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
branch: "main"
license: "Apache-2.0 OR MIT"
msrv: "1.75.0"
fetched: 2026-05-28
---

# stratum-mining/stratum (SRI low-level crates)

> Repo-level metadata snapshot of the SRI low-level codebase at HEAD `65c9688c` on `main`. Code-level facts in this file should be treated as a pointer to the upstream tree at the recorded commit, not as a copy of it. For per-crate or per-file research, run `/wiki:ingest-collection --adapter git` instead of relying on this single source.

## Identity

- **Upstream**: `github.com/stratum-mining/stratum`
- **Local checkout**: `/Users/garykrause/repos/stratum`
- **Branch**: `main`
- **HEAD commit**: `65c9688ca0e9cdcf213b32a6f51e9309fb75bbab`
- **Latest tag observed**: `v1.9.0` (`6ab03af2`)
- **License**: Apache-2.0 OR MIT
- **MSRV**: Rust 1.75.0 (pinned via `rust-toolchain.toml`, `channel = "1.75.0"`)
- **Website**: stratumprotocol.org
- **Discord**: SV2 Discord
- **Funding**: btrust, HRF, Spiral, OpenSats, Vinteum

## Scope (per upstream README)

> "This repository contains the low-level crates. If you're looking to run Sv2 applications at the most recent changes, check out the `sv2-apps` repository. Those crates are application-level, currently in alpha stage."

So: this repo = SV2 crate library. Applications, daemons, deployment artifacts live in [`sv2-apps`](https://github.com/stratum-mining/sv2-apps), not here.

## Workspace layout

Workspace members declared in root `Cargo.toml`:

```toml
[workspace]
resolver = "2"
members = ["stratum-core"]
exclude = ["integration-test-framework", "fuzz"]
```

Top-level directories observed in the working tree:

```
stratum/
├── Cargo.toml                 # workspace root, member: stratum-core
├── Cargo.lock
├── rust-toolchain.toml        # pinned to 1.75.0
├── README.md
├── CONTRIBUTING.md
├── RELEASE.md
├── SECURITY.md
├── LICENSE.md / LICENSE-APACHE / LICENSE-MIT
├── codecov.yaml
├── benches/                   # microbenchmarks (Criterion / iai)
├── fuzz/                      # cargo-fuzz targets (excluded from workspace)
├── protocols/                 # protocols/fuzz-tests, etc.
├── roles/
│   └── storage/               # storage-trait role-side crate
├── scripts/
│   ├── coverage-protocols.sh
│   ├── release-libs.sh
│   ├── run-integration-tests.sh
│   └── sv2-publish.sh
├── stratum-core/              # workspace umbrella crate (the only `members:` entry)
│   ├── Cargo.toml
│   ├── README.md
│   ├── src/
│   └── stratum-translation/   # SV1↔SV2 translation crate
├── sv1/                       # Stratum V1 protocol crate
│   ├── Cargo.toml
│   ├── README.md
│   ├── examples/
│   └── src/
├── sv2/                       # SV2 crate suite
│   ├── binary-sv2/            # binary encoding/decoding
│   ├── buffer-sv2/            # buffer pooling
│   ├── codec-sv2/             # message codec (Noise-aware)
│   ├── extensions-sv2/        # extension messages
│   ├── framing-sv2/           # message framing
│   ├── handlers-sv2/          # handler traits
│   ├── noise-sv2/             # Noise protocol
│   ├── parsers-sv2/           # message parsing
│   ├── channels-sv2/          # channel management (group/extended/standard)
│   └── subprotocols/
│       ├── common-messages/
│       ├── job-declaration/
│       ├── mining/
│       └── template-distribution/
└── sv2_test_client/           # ad-hoc / integration test client
```

`stratum-core` is the umbrella crate consumers depend on. It re-exports the SV2 crate suite via path/version dependencies and gates SV1 + translation behind features:

- `binary_sv2 ^5.0.0`, `buffer_sv2 ^3.0.0`, `codec_sv2 ^5.0.0` (with `noise_sv2`), `extensions_sv2 ^0.1.0`, `framing_sv2 ^6.0.0`, `noise_sv2 ^1.0.0`, `parsers_sv2 ^0.4.0`, `handlers_sv2 ^0.4.0`, `channels_sv2 ^6.0.0`.
- Subprotocols: `common_messages_sv2 ^7.2.0`, `mining_sv2 ^10.0.0`, `template_distribution_sv2 ^5.1.0`, `job_declaration_sv2 ^7.1.0`.
- Optional: `sv1_api ^4.0.0` behind feature `sv1`; `stratum_translation ^0.3.0` behind feature `translation` (which implies `sv1`).
- Feature `with_buffer_pool` propagates to `binary_sv2`, `framing_sv2`, `codec_sv2`.

## Subprotocols

The SV2 message-level protocols, each as its own crate under `sv2/subprotocols/`:

- **common-messages**: shared connection/setup messages (e.g. `SetupConnection`).
- **mining**: the mining subprotocol (channels, jobs, shares).
- **template-distribution**: TDP (Bitcoin-Core ↔ Job Declarator/Pool template flow).
- **job-declaration**: JDP (Job Declaration Protocol).

`extensions-sv2` is a separate crate from the four standard subprotocols and carries SV2 extension messages (negotiated via `RequestExtensions`).

## Translation

`stratum-core/stratum-translation` is the SV1↔SV2 translation crate. It depends on `sv1` and on the SV2 crates and is gated by the `translation` feature on `stratum-core`. Used by translator-proxy implementations downstream.

## Versioning & releases

Per `RELEASE.md`:

- All crates follow SemVer 2.0.0.
- Repo-level releases use `X.Y.Z` with subjective criteria: `Z` for bug-fix-only, `Y` for breaking and/or non-breaking changes together, `X` for milestone/maturity bumps.
- Release process: branch `x.y.z` from `main`, tag, publish, then any release-only fixes happen on that branch.
- Latest observed tag: `v1.9.0`. Tags `v1.0.0`–`v1.9.0` exist on remotes.

Note: `CONTRIBUTING.md` was at one point amended with a `stratum-core` versioning exception (PR #2158), which was reverted by PR #2160 / commit `31bc2278` shortly before the snapshot.

## Recent activity (HEAD on `main`, newest first)

Last 10 commits at the time of ingest:

```
65c9688c Merge pull request #2160 from stratum-mining/revert-2158-2026-05-18-elaborate-contributing-md
31bc2278 Revert "refine `CONTRIBUTING.md` with versioning exception to `stratum-core`"
d2285629 Merge pull request #2162 from plebhash/2026-05-22-standard-job-error-code
df4e764d add ERROR_CODE_OPEN_MINING_CHANNEL_EXTENDED_CHANNELS_NOT_SUPPORTED_FOR_STANDARD_JOBS
cb033a48 Merge pull request #2156 from rx18-eng/fix/validate-share-panic-after-snph
cc3977e5 fix validate_share panic after on_set_new_prev_hash in custom-work mode
58147e68 Merge pull request #2158 from plebhash/2026-05-18-elaborate-contributing-md
c38df383 refine CONTRIBUTING.md with versioning exception to stratum-core
9a61b5e9 Merge pull request #2149 from plebhash/2026-05-08-refine-server-share-accounting
5e1b025f channels_sv2::server::share_accounting keeps track of rejected shares
```

Themes visible in recent work:

- **Standard-job error semantics** (#2162): a new error code, `ERROR_CODE_OPEN_MINING_CHANNEL_EXTENDED_CHANNELS_NOT_SUPPORTED_FOR_STANDARD_JOBS`, distinguishes the case where a standard-job channel was requested against an extended-channels-only server.
- **`validate_share` panic fix** (#2156, `cc3977e5`): correctness fix in `channels_sv2` for custom-work mode after `on_set_new_prev_hash`.
- **Server share accounting** (#2149, `5e1b025f`): `channels_sv2::server::share_accounting` now tracks rejected shares.
- **Contributing/versioning churn** (#2158 → #2160): an attempted `stratum-core` versioning exception was reverted, leaving `RELEASE.md` as the authoritative release-process doc for now.

## Multi-remote setup (local working tree)

The local clone has many remotes — useful provenance for who is reviewing/forking what:

- `origin` → `stratum-mining/stratum` (canonical)
- `average-gary` → `average-gary/stratum` (the user)
- `plebhash`, `gitgab`, `mis` (MarathonDH), `pioneerhash`, `sjors`, `ethan` (EthnTuttle) → various contributor/fork remotes

Branches with significant local-only or fork state include `iroh`, `feature-flag-subprotocols`, `feature/storage-role`, `ehash-persistence`, `persistence-trait`, `storage-trait`, `validate-share-refactor`, `translator-pool`, `unofficial-docs`, `user_id-accounting`, `new-tproxy`, and assorted `origin-vX.Y.Z` snapshots.

These are not part of upstream `main` and should not be cited as canonical SRI behavior.

## Tooling & policy

- **Toolchain**: pinned to Rust `1.75.0` with `rustfmt`, `clippy`, `rust-analyzer` components.
- **License**: dual Apache-2.0 / MIT, with per-file copyright preservation.
- **Security policy**: `SECURITY.md` exists in the repo root.
- **Codecov**: configured via `codecov.yaml`.
- **Integration tests**: `scripts/run-integration-tests.sh` clones a separate integration-test framework, points it at the local working tree, runs the suite, and restores config.

## Caveats for downstream wiki articles

1. This source is a **single-source repo snapshot**, not a content collection. Compiled articles that need to cite specific SRI files (`channels_sv2::server::share_accounting`, `JobFactory::new`, `OpenMiningChannel.user_identity`, etc.) should pull those file paths via a `git`-adapter collection ingest at the same revision, then cite the per-file raw sources.
2. Application-level behavior (Pool, JD-Server, Translator binaries, deployment) is **not** in this repo. Anything claiming end-to-end SRI behavior must also cite [`sv2-apps`](https://github.com/stratum-mining/sv2-apps).
3. `stratum-core` is the only workspace `members:` entry; `sv1`, the `sv2/*` crates, `protocols/`, `roles/storage`, `benches/`, and `fuzz/` are present in the tree but not in the workspace graph (`fuzz` and the integration-test framework are explicitly `exclude`d). Treat their version numbers as the per-crate `Cargo.toml` source of truth.
4. The local clone has fork-specific branches (`iroh`, etc.) that may carry research patches relevant to other topics (`iroh-transport-stratum-v2`). Code in those branches is **not** representative of upstream SRI.
