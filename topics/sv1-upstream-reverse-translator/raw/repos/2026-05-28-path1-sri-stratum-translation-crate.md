---
title: "SRI stratum-translation crate — bidirectional helpers"
source: https://github.com/stratum-mining/stratum/tree/main/stratum-core/stratum-translation
type: repos
tags: [sri, stratum-translation, sv1-to-sv2, sv2-to-sv1, helpers]
summary: "Major finding: stratum-core/stratum-translation has BOTH sv1_to_sv2 and sv2_to_sv1 modules. These are *transformation* directions, not *role* directions. Both are reusable by a reverse translator. The current forward translator-proxy uses only the SV1→SV2 helpers; reverse translator needs new SV1→SV2 helpers in the *opposite directional intent* and to reuse the existing SV2→SV1 helpers for downstream message synthesis."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# SRI stratum-translation crate (`stratum-core/stratum-translation`)

Runtime-free helper crate (no networking, no async) — pure functions that transform messages between SV1 and SV2. Crate v0.3.0; deps: `binary_sv2 ^5`, `mining_sv2 ^10`, `channels_sv2 ^6`, `sv1_api ^4` (aliased `v1`), `bitcoin`, `tracing`.

## Existing helper functions

- `build_sv1_notify_from_sv2(SetNewPrevHash, NewExtendedMiningJob, clean_jobs) -> Notify` — strips BIP141/SegWit data when needed.
- `build_sv1_set_difficulty_from_sv2_set_target(SetTarget) -> json_rpc::Message`
- `build_sv2_open_extended_mining_channel(request_id, user_identity, nominal_hashrate: f32, max_target, min_extranonce_size)` — used by the existing translator-proxy.
- `build_sv2_submit_shares_extended_from_sv1_submit(...)` — handles version-rolling mask.

## Gaps the reverse translator must author (~150 LOC)

- `build_sv2_new_extended_mining_job_from_sv1_notify(notify, sv2_job_id, version_rolling_allowed)` — inverse of the existing helper.
- `build_sv2_set_target_from_sv1_set_difficulty(set_difficulty)` — uses `Target::from_difficulty(f64)`.
- `build_sv1_submit_from_sv2_submit_shares_extended(share, sv1_job_id_string, user_name, extranonce1_len)` — synthesizes upstream submit.
- mining.notify(clean_jobs) → SetNewPrevHash synthesis.
- mining.subscribe response → OpenExtendedMiningChannel.Success.
- mining.set_extranonce → SetExtranoncePrefix.
- mining.submit JSON-RPC response → SubmitShares.Success/.Error.

## Bidirectionality was designed-in

The presence of both `sv1_to_sv2.rs` and `sv2_to_sv1.rs` modules suggests bidirectional translation was contemplated from the start, even though the reference translator-proxy role uses only the forward direction. This is the strongest existing-code argument that a reverse translator is a natural extension, not a rewrite.

## See also

- [[2026-05-28-path4-stratum-translation-crate]] — path 4's deeper read of the same crate
- [[2026-05-28-path1-sv2-spec-mining-protocol-channels]] — message shapes on the SV2 side
- [[2026-05-28-path2-sri-translator-role]] — the existing forward role
