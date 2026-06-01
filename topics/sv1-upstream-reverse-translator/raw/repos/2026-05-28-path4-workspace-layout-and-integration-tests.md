# path4 - workspace layout, integration testing, sv2-apps relationship

**Source type**: repos
**Paths**: 
- `/Users/garykrause/repos/stratum/Cargo.toml`
- `/Users/garykrause/repos/stratum/scripts/run-integration-tests.sh`
- `/Users/garykrause/repos/stratum/README.md`
- (referenced) https://github.com/stratum-mining/sv2-apps
**Date observed**: 2026-05-28

## Repo split

Two repositories, deliberately separated:

1. **`stratum-mining/stratum`** (this local checkout): low-level crates — `sv1`, `sv2/*`, `stratum-core` (which embeds `stratum-translation`). README explicitly: "This repository contains the low-level crates."

2. **`stratum-mining/sv2-apps`**: application-level roles (translator-proxy, pool, JDC, JDS, mining-proxy). Currently in **alpha** stage per README. Where `roles_logic_sv2`, `tokio` glue, and binary entrypoints live.

The `Cargo.toml` of the low-level repo is minimal:
```
[workspace]
members = ["stratum-core"]
exclude = ["integration-test-framework", "fuzz"]
```

## Where the reverse translator should live

**Recommendation**: a new role crate in `sv2-apps`, parallel to the existing `translator-proxy`. Path (mirroring sv2-apps convention):

```
sv2-apps/
  roles/
    translator-proxy/                   # SV1 downstream + SV2 upstream (existing)
    reverse-translator/                 # SV2 downstream + SV1 upstream (NEW)
      src/
        main.rs                         # tokio entrypoint
        lib.rs
        config.rs                       # toml config (upstream URL, listen addr, channel limits)
        upstream/                       # SV1 client task
          mod.rs
          sv1_client.rs                 # impl IsClient
          state.rs                      # last_notify, set_difficulty, extranonce1
        downstream/                     # SV2 server task
          mod.rs
          sv2_server.rs                 # SV2 listener, per-connection task
          channel_state.rs              # impl HandleMiningMessagesFromClientAsync
          job_store.rs                  # JobStore<ExtendedJob> impl that ingests SV1 notify
        translation/                    # message translation orchestration
          mod.rs
          mappings.rs                   # job_id, channel_id, user_name maps
          extranonce.rs                 # ExtranonceAllocator wrapper
        share_validation.rs             # gate shares before forwarding to SV1
```

A *secondary* recommendation: the missing reverse-direction translation helpers (described in the `stratum_translation` raw note) should be added to the existing `stratum_translation` crate in this low-level repo as a new module `sv2_to_sv1_reverse.rs` (or expanded into the existing files). The role binary in sv2-apps then depends only on the published `stratum_translation` crate.

## Why NOT inside the low-level repo

- This repo's `Cargo.toml` excludes role-level crates and only contains pure libraries (no `tokio`, no networking).
- The existing translator-proxy lives in sv2-apps already; symmetry argues for the reverse to live there too.
- Integration tests are run from sv2-apps (`scripts/run-integration-tests.sh` clones sv2-apps and patches local `stratum-core`).

## Integration test infrastructure

`scripts/run-integration-tests.sh` reveals the test-flow that the reverse translator must integrate with:

1. Clones `https://github.com/stratum-mining/sv2-apps.git` into `integration-test-framework/sv2-apps/`.
2. Patches its `Cargo.toml` to override `stratum-core` with the local path:
   ```toml
   [patch.crates-io]
   stratum-core = {path = "../../../stratum-core"}
   [patch."https://github.com/stratum-mining/stratum"]
   stratum-core = {path = "../../../stratum-core"}
   ```
3. Runs `cargo nextest run --nocapture --verbose` from `sv2-apps/integration-tests`.
4. Optional `--pr NUMBER` flag pulls a specific sv2-apps PR for cross-repo CI.

This means: the reverse translator's integration tests live in sv2-apps's `integration-tests/`, not in this repo. The low-level repo's PR can include changes to the `stratum_translation` crate; the corresponding sv2-apps PR (referenced by `--pr` or `COMPANION_PR_NUMBER` env var) adds the new role.

## Q8 (testing infrastructure)

- **`sv2_test_client/`**: present in this repo as an empty directory at the moment of inspection (TBD — may be populated in upcoming PRs). Its name strongly suggests an SV2 client harness for testing pool/translator backends.

- **`test/integration-tests/`**: present in this repo, contains only `target/`. Real integration tests are pulled in from sv2-apps.

- **For the reverse translator specifically, mocking SV1 upstream** is a NEW need. Patterns:
  - Build a minimal "fake SV1 pool" using `sv1_api::IsServer` + a tokio TCP listener. The example `sv1/examples/client_and_server.rs` shows ~280 LOC of `IsServer` impl that can be ported. This belongs in sv2-apps's integration-tests under `tests/utils/fake_sv1_pool.rs`.
  - Existing forward translator-proxy tests mock the SV2 upstream side — symmetric mocking on the SV1 side is a clean addition.

## Q7 (async runtime)

The low-level repo has zero tokio dependencies (verified by grep -r tokio across all Cargo.toml files). The sv2-apps repo standardizes on tokio (per common convention in stratum-mining; the translator-proxy uses tokio task-per-connection). The reverse translator MUST follow this convention to interoperate with sv2-apps's existing test harness, logging, and config patterns.

## Key findings

- **Q1 (where does role live)**: `sv2-apps/roles/reverse-translator/`, NOT in stratum-mining/stratum. Translation *helpers* go in `stratum_translation` (this repo); role binary lives in sv2-apps.
- **Q3 (does roles_logic_sv2 need new mode)**: roles_logic_sv2 is in sv2-apps, not here. Not directly inspectable from this checkout. Likely needs a new mode or sibling library — but the low-level abstractions (`channels_sv2`, `handlers_sv2`, `sv1_api`) do NOT need any changes.
- **Q7 (runtime)**: tokio (matches translator-proxy convention; trait_variant async traits in handlers_sv2 are runtime-agnostic).
- **Q8 (testing)**: integration tests are run in sv2-apps with a local-path patch back to stratum-core. Reverse translator tests must add a fake SV1 pool harness to sv2-apps's integration-tests.

## Ingest justification

Documents the cross-repo workspace boundary that determines WHERE the reverse translator role binary lives (sv2-apps), separately from the translation helpers (this low-level repo). Without this split, recommendations for "where the new code goes" would be ambiguous.
