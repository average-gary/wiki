---
title: "SV2 Spec — Mining Protocol (channels, jobs, shares)"
source: https://github.com/stratum-mining/sv2-spec/blob/main/05-Mining-Protocol.md
type: articles
tags: [sv2, mining-protocol, channels, extranonce, submit-shares]
summary: "Authoritative SV2 spec section 5 — channel taxonomy (Standard / Extended / Group), extranonce_prefix vs extranonce, NewMiningJob (header-only) vs NewExtendedMiningJob, SetTarget U256, batched SubmitShares.Success, typed SubmitShares.Error codes."
confidence: high
ingested: 2026-05-28
ingested_by: path1
quality_score: 5
---

# SV2 Spec — Mining Protocol

## Channel taxonomy

- **Standard**: header-only mining. `NewMiningJob` carries only `merkle_root: U256`. Fixed `extranonce_prefix`. Cannot be served from an SV1 upstream without local merkle-root precomputation in the translator (because SV1 pools send coinb1/coinb2/merkle_branch, not roots).
- **Extended**: rolling extranonce. `NewExtendedMiningJob` includes `coinbase_tx_prefix`/`coinbase_tx_suffix` + `merkle_path`. **Canonical channel type for a reverse translator** because it maps cleanly to SV1's extranonce1/extranonce2 model.
- **Group**: broadcast aggregate; all members share total extranonce. Lost when upstream is SV1 (no broadcast primitive).

## Extranonce mapping

- SV1: `extranonce1` (pool-fixed) + `extranonce2` (miner-rolled, fixed bytes).
- SV2 Extended: `extranonce_prefix` (upstream-fixed) + `extranonce` (downstream-rolled, `extranonce_size` bytes).
- Direct translation: `SV2.extranonce_prefix := SV1.extranonce1`, `SV2.extranonce_size := SV1.extranonce2_size`.

## SetTarget vs set_difficulty

- SV2 `SetTarget { maximum_target: U256 }` is exact.
- SV1 `mining.set_difficulty(float64)` is lossy (~2^53 precision).
- SV1 → SV2 conversion: choose pdiff convention `target = max_pdiff / difficulty`; precise enough for mining purposes.

## Submit shares

- SV2 `SubmitSharesStandard` / `SubmitSharesExtended` carry `channel_id, sequence_number, job_id (u32), nonce, ntime, version`.
- SV2 `SubmitShares.Success` is **batched**: `last_sequence_number, new_submits_accepted_count, new_shares_sum`.
- SV2 `SubmitShares.Error` has typed codes: `stale-share`, `difficulty-too-low`, `invalid-job-id`.
- SV1 returns one boolean per submit. Translator must serialize SV1 acks into per-share SV2 success messages or coalesce in time windows.

## Future-job optimization (LOST when upstream is SV1)

SV2 lets a downstream pre-compute on a job before its prev_hash is finalized: `NewExtendedMiningJob` with empty `min_ntime`, followed later by `SetNewPrevHash`. SV1 `mining.notify` always carries prev_hash. Reverse translator cannot synthesize SV2 future jobs without pre-block-template hints from upstream — typically not available.

## See also

- [[2026-05-28-path1-sri-stratum-translation-crate]] — existing SRI helpers
- [[2026-05-28-path3-sv2-spec-discussion-deployment-scenarios]] — spec section 10.4.5 (V2→V1) is literally `...`
