---
title: "SV2 ↔ SV1 primitive mapping (for reverse translation)"
type: concept
status: active
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [sv2, sv1, primitives, mapping, reverse-translator]
---

# SV2 ↔ SV1 primitive mapping (for reverse translation)

A reverse translator (SV2 downstream / SV1 upstream) must translate every message in both directions. This article enumerates the mapping. Built from Path 1's protocol-level reading and Path 3's spec-level survival analysis.

## Channel & connection setup

| SV2 (downstream side) | SV1 (upstream side) | Notes |
|---|---|---|
| `SetupConnection` | `mining.configure` | Translator advertises miner-side capabilities to the SV1 pool. Negotiates `version-rolling`, `subscribe-extranonce`, `info` extensions. |
| `SetupConnection.Success` (synthesized) | response to `mining.configure` + `mining.subscribe` + `mining.authorize` | Translator must drive 3 SV1 RPC roundtrips before it can declare downstream setup complete. |
| `OpenStandardMiningChannel` / `OpenExtendedMiningChannel` | (single SV1 connection already open) | Translator allocates a sub-prefix from `ExtranonceAllocator::from_upstream_prefix` and opens an internal channel; no upstream RPC fires. |
| `OpenExtendedMiningChannel.Success` (synthesized) | — | Translator returns `extranonce_prefix` (sub-allocated) + `extranonce_size` (= upstream `extranonce2_size` − local prefix bytes) to downstream miner. |

**See**: [[../../raw/articles/2026-05-28-path1-bitcoin-wiki-stratum-mining-protocol|SV1 spec]], [[../../raw/articles/2026-05-28-path1-sv2-spec-mining-protocol-channels|SV2 spec channels]], [[../../raw/repos/2026-05-28-path4-extranonce-allocator-translator-pattern|extranonce allocator]].

## Job propagation

| SV2 (downstream side) | SV1 (upstream side) | Translation direction |
|---|---|---|
| `NewExtendedMiningJob` | `mining.notify` (clean_jobs=false) | Synthesize SV2 from SV1: build `coinbase_tx_prefix`/`coinbase_tx_suffix` from coinb1/coinb2; `merkle_path` from merkle_branch; `version_rolling_allowed` from negotiated mask. |
| `NewMiningJob` (header-only) | `mining.notify` | Cannot be served directly — translator must precompute merkle root from SV1 coinb1/coinb2 + extranonce + branch. Caches root → extranonce reverse-lookup for share submission. |
| `SetNewPrevHash` | `mining.notify` (clean_jobs=true) | Triggered when the SV1 notify carries clean_jobs=true. Translator broadcasts to every open SV2 channel. |
| `SetExtranoncePrefix` | `mining.set_extranonce` (extension) | If upstream pool re-allocates extranonce1, translator rebuilds the allocator and broadcasts new prefixes to all SV2 channels. **In-flight shares may fail upstream** during this transition. |

The SV2 *future-job* optimization (empty `min_ntime`, prev_hash arrives later) is **lost**: SV1 always sends prev_hash immediately as part of mining.notify. **See**: [[../../raw/articles/2026-05-28-path1-sv2-spec-mining-protocol-channels|SV2 channels spec]].

## Difficulty / target

| SV2 | SV1 | Notes |
|---|---|---|
| `SetTarget { maximum_target: U256 }` | `mining.set_difficulty(float)` | Direction matters. SV1→SV2 conversion is precise (`max_target = pdiff_max / difficulty`). SV2→SV1 conversion (not used in reverse translator) would be lossy. Pool convention: **pdiff** (`0x00000000FFFFFFFF...` as max). |

**See**: [[../../raw/articles/2026-05-28-path1-bitcoin-wiki-difficulty|pdiff vs bdiff]].

## Share submission & responses

| SV2 (downstream side) | SV1 (upstream side) | Translation direction |
|---|---|---|
| `SubmitSharesExtended` | `mining.submit` | Strip the extranonce_prefix bytes from the SV2 share's extranonce → produce SV1 `extra_nonce2`; look up `sv1_job_id_string` from translator's job-ID map; map `channel_id` → `worker_name`. |
| `SubmitShares.Success` (batched: `last_sequence_number`, `new_submits_accepted_count`, `new_shares_sum`) | one boolean per submit | Translator coalesces SV1 acks into SV2 batched success messages, by time window or per N shares. |
| `SubmitShares.Error` (typed: `stale-share`, `difficulty-too-low`, `invalid-job-id`) | JSON-RPC error object | Translator maps SV1 error strings to typed SV2 codes — needs an error-string mapping table per pool implementation (Foundry vs Antpool error wording differs). |

## Version rolling / AsicBoost

| Capability | Behavior in reverse translator |
|---|---|
| Overt (BIP-310 / BIP-320) | **Survives** if the upstream SV1 pool advertises `version-rolling` in `mining.configure`. Translator forwards the negotiated mask to downstream SV2 jobs as `version_rolling_allowed=true`. If the upstream does NOT support BIP-310, translator hard-sets `version_rolling_allowed=false` and rejects submits with non-job version. |
| Covert | **Structurally impossible** — SV1 mining.notify already gives the translator a coinbase that lacks the SegWit witness commitment, so the SV2 downstream never sees anything to grind. Treated as a SegWit safety property. |

**See**: [[../../raw/articles/2026-05-28-path1-bip-310-version-rolling|BIP-310]], [[../../raw/articles/2026-05-28-path1-bip-320-nversion-bits|BIP-320]], [[../../raw/articles/2026-05-28-path1-bitcoinops-asicboost|AsicBoost]].

## Extranonce semantics

SV1 split: `extranonce1` (pool-fixed) + `extranonce2` (miner-rolled).
SV2 Extended split: `extranonce_prefix` (upstream-fixed) + `extranonce` (downstream-rolled, `extranonce_size` bytes).

Direct mapping: `SV2.extranonce_prefix := SV1.extranonce1 || per_channel_local_prefix`, `SV2.extranonce_size := SV1.extranonce2_size − len(local_prefix)`.

The translator owns the `local_prefix` allocation across all SV2 channels via `channels_sv2::extranonce_manager::ExtranonceAllocator::from_upstream_prefix` — its docstring literally calls out the translator use case. **See**: [[../../raw/repos/2026-05-28-path4-extranonce-allocator-translator-pattern|extranonce allocator pattern]].

## Lossy conversions / unavoidable concessions

1. **BIP141 / SegWit witness commitments**: SV1 mining.notify gives the translator a stripped coinbase. SV2 NewExtendedMiningJob expects unstripped. The translator passes the stripped form through unchanged; the SV2 client must accept that and not custom-rebuild the block. **Protocol-fidelity concession.**
2. **U256 → float**: SV2 SetTarget → SV1 set_difficulty would lose precision past ~2^53 — but a reverse translator does not do this direction; SV1→SV2 is precise.
3. **Job-ID type**: SV1 string ↔ SV2 u32 monotonic counter. Translator owns a HashMap, GC'd on `clean_jobs=true`.
4. **Authentication**: SV2 has Noise public-key auth; SV1 is username/password. Translator holds SV1 credentials per channel — credential-management concern.
5. **Future-job optimization**: lost (SV1 always carries prev_hash).
6. **Header-only mining bandwidth gain**: lost upstream (translator still pays full notify bandwidth to SV1 pool); preserved downstream only.

## See also

- [[sv2-features-lost-with-sv1-upstream]] — the survival table
- [[architecture-and-state-machine]] — implementation surface
- [[sv2-spec-issue-102-the-canonical-reference]] — where the SRI spec names this concept
