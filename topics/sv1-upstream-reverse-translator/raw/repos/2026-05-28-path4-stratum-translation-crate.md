# path4 - stratum_translation crate (low-level repo)

**Source type**: repos (local source code)
**Path**: `/Users/garykrause/repos/stratum/stratum-core/stratum-translation/`
**GitHub**: https://github.com/stratum-mining/stratum/tree/main/stratum-core/stratum-translation
**Crate name**: `stratum_translation` v0.3.0 (cratesio name `stratum_translation`)
**Date observed**: 2026-05-28

## Why this matters for the reverse translator

This is the single most reusable primitive for an SV2-downstream / SV1-upstream reverse translator. The crate already contains pure, runtime-free, network-free helpers in *both* directions; a reverse translator reuses ~50% of the existing helpers and only needs to add the missing inverse helpers (SV1-notify -> SV2-NewExtendedMiningJob and SV1-submit -> SV2-SubmitSharesExtended for the *reverse* direction, plus SV1-set_difficulty -> SV2-SetTarget).

## Public API surface (lib.rs, ~20 LOC)

```
pub mod error;
pub mod sv1_to_sv2;   // forward translator helpers
pub mod sv2_to_sv1;   // forward translator helpers (inbound to SV1 miner)
```

Crate description (Cargo.toml): "Stratum V1 - Stratum V2 translation utilities for reuse across proxies, apps, and firmware".

Explicitly states "What it does not contain: Networking, async runtimes, channels, or long-running tasks." This is a deliberate split: pure conversion code lives here, async networking lives in the role binary (in sv2-apps).

## Existing helpers (~280 LOC total)

`sv1_to_sv2.rs`:
- `build_sv2_open_extended_mining_channel(request_id, user_identity, nominal_hash_rate, max_target, min_extranonce_size) -> Result<OpenExtendedMiningChannel>`
- `build_sv2_submit_shares_extended_from_sv1_submit(submit, channel_id, sequence_number, job_version, version_rolling_mask) -> Result<SubmitSharesExtended>`
  - Crucially handles BIP320 version rolling: `(job_version & !mask) | (version_bits & mask)`

`sv2_to_sv1.rs`:
- `build_sv1_notify_from_sv2(set_new_prev_hash, new_extended_mining_job, clean_jobs) -> Result<server_to_client::Notify>`
  - Auto-strips BIP141 SegWit data via `channels_sv2::bip141::try_strip_bip141`
  - Handles future-job vs active-job ntime selection
- `build_sv1_set_difficulty_from_sv2_set_target(set_target) -> Result<json_rpc::Message>`
- `build_sv1_set_difficulty_from_sv2_target(target) -> Result<json_rpc::Message>` (uses `target.difficulty_float()`)

## Key findings (architectural)

- Q1 (where does new role live): The translation *helpers* clearly belong here. The reverse translator should add a third file `sv1_to_sv2_reverse.rs` (or similar) with helpers that go in the *reverse* semantic direction:
  - `build_sv2_new_extended_mining_job_from_sv1_notify` (build SV2 job from SV1 mining.notify) — needs to **re-add BIP141 padding** (inverse of `try_strip_bip141`), or accept that this is impossible without bitcoin-core context and use coinbase-stripped jobs only.
  - `build_sv2_submit_shares_extended_from_sv1_submit` already exists — but the `channel_id` and `sequence_number` semantics differ in the reverse direction.
  - `build_sv1_submit_from_sv2_submit_shares_extended` (NEW) — needed when a downstream SV2 miner submits a share that we forward upstream to the SV1 pool.
  - `build_sv2_set_target_from_sv1_set_difficulty` (NEW) — inverse of the existing helper.

- Q2 (reuse for SV2 side): Already wires `channels_sv2` for BIP141, target conversion, and uses `mining_sv2`/`v1` (sv1_api) types directly. No abstraction layer is hidden away.

- Q5 (stateful translation): The library is intentionally **stateless**. The role binary owns extranonce mappings, channel-id <-> worker-name maps, job-id translation tables, and share-validation state.

- Q6 (extended channel + single SV1 extranonce1): The `build_sv2_open_extended_mining_channel` helper takes a `min_extranonce_size`; in the reverse direction the translator advertises *exactly* `extranonce2_size` from upstream SV1 minus `extranonce_prefix_len`, then sub-allocates per channel via `channels_sv2::extranonce_manager::ExtranonceAllocator::from_upstream_prefix`.

## Reuse / write-from-scratch breakdown

REUSE AS-IS (forward helpers usable in reverse direction without change):
- `build_sv2_submit_shares_extended_from_sv1_submit` — when a (hypothetical) SV1 client of the reverse translator does mining.submit. (Not the typical reverse case but covers symmetric paths.)

REUSE WITH MINOR CHANGES (inverse direction needed):
- New `build_sv2_new_extended_mining_job_from_sv1_notify` — INVERSE of existing notify helper. BIP141 padding cannot be reconstructed from SV1 data alone (only stripped); strategy is to pass-through the stripped coinbase as-is and set `version_rolling_allowed` from the upstream SV1 mining.configure response.
- New `build_sv2_set_target_from_sv1_set_difficulty` — inverse of the existing one; `Target::from_difficulty(value: f64)` exists in bitcoin crate.

WRITE FROM SCRATCH:
- New `build_sv1_submit_from_sv2_submit_shares_extended(share, job_id_sv1, user_name, extranonce1_len) -> Result<client_to_server::Submit>` — strips the extranonce_prefix bytes from the SV2 share's extranonce to produce SV1 `extra_nonce2` field.
- Job-ID translation table (SV2 jobs are u32, SV1 jobs are arbitrary strings).
- Worker-name <-> channel-id table.

## Ingest justification

The `stratum_translation` crate is the canonical low-level translation library and is *the* place new reverse-direction helpers should be added; documenting its current API surface makes it possible to specify a minimal-diff PR that adds the inverse functions without duplicating logic in the role binary.
