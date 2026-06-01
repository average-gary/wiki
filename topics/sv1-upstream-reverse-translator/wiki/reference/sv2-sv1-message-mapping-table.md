---
title: "Reference — SV2 ↔ SV1 message mapping table"
type: reference
status: active
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [reference, message-mapping, sv2, sv1]
---

# Reference — SV2 ↔ SV1 message mapping table

Quick-lookup table for implementers. Full discussion in [[../concepts/sv2-sv1-primitive-mapping]].

## Translator role direction

- Downstream = SV2 (server side, faces SV2 miners)
- Upstream = SV1 (client side, faces SV1 pool)

## Connection lifecycle

| SV2 message (downstream) | SV1 method (upstream) | Translator action |
|---|---|---|
| `SetupConnection` | — | Cache miner-side capabilities. If upstream not yet open, kick off upstream connection. |
| (synthesized) | `mining.configure` | Negotiate `version-rolling`, `subscribe-extranonce`, `info`. Record mask + capabilities. |
| (synthesized) | `mining.subscribe` | Capture `extranonce1`, `extranonce2_size`. Build `ExtranonceAllocator::from_upstream_prefix`. |
| (synthesized) | `mining.authorize` | Pass operator credentials. |
| `SetupConnection.Success` | — | Sent only after all 3 SV1 RPCs succeed. |
| `SetupConnection.Error` | — | Sent if any SV1 RPC fails. |

## Channel lifecycle

| SV2 message | SV1 equivalent | Translator action |
|---|---|---|
| `OpenStandardMiningChannel` | (none) | Allocate sub-prefix. Precompute merkle root from cached SV1 notify. **Note**: header-only requires reverse-lookup root → extranonce. |
| `OpenExtendedMiningChannel` | (none) | Allocate sub-prefix. Build channel state. |
| `OpenExtendedMiningChannel.Success` | (synthesized) | Return `extranonce_prefix` (allocated) + `extranonce_size` (= upstream `extranonce2_size` − local prefix bytes) + last cached `target` and `job`. |
| `OpenMiningChannel.Error` | (none) | Sent if no extranonce slots remain or upstream is down. |
| `CloseChannel` | (none) | Release allocator slot, GC channel state. |

## Job propagation

| SV2 message | SV1 equivalent | Direction | Translator action |
|---|---|---|---|
| `NewExtendedMiningJob` | `mining.notify` (clean_jobs=false) | upstream → downstream | Synthesize from SV1 notify. Map string job_id → u32. |
| `NewMiningJob` (header-only) | `mining.notify` | upstream → downstream | Precompute merkle root per channel. Cache root → extranonce reverse-lookup for share submission. |
| `SetNewPrevHash` | `mining.notify` (clean_jobs=true) | upstream → downstream | Triggered when SV1 notify carries clean_jobs=true. Broadcast to all channels. GC old job_id mappings. |
| `SetExtranoncePrefix` | `mining.set_extranonce` | upstream → downstream | If upstream re-allocates extranonce1, rebuild allocator and broadcast new prefixes. Expect in-flight share failures. |
| `SetTarget` | `mining.set_difficulty` | upstream → downstream | Convert float → U256: `max_target = pdiff_max / difficulty`. |
| `UpdateChannel` | (none) | downstream → translator-only | Local vardiff adjustment; does NOT propagate upstream. |

## Share submission

| SV2 message | SV1 method | Direction | Translator action |
|---|---|---|---|
| `SubmitSharesStandard` | `mining.submit` | downstream → upstream | Strip `extranonce_prefix` bytes from share. Build `mining.submit` params: `[worker_name, sv1_job_id_string, extra_nonce2, ntime, nonce, version_bits?]`. |
| `SubmitSharesExtended` | `mining.submit` | downstream → upstream | Same; for extended-channel submits with rolled extranonce. |
| `SubmitShares.Success` (batched) | (1 boolean per submit) | upstream → downstream | Coalesce by time window (e.g. 100ms) or N shares. Fields: `last_sequence_number`, `new_submits_accepted_count`, `new_shares_sum`. |
| `SubmitShares.Error { code }` | (JSON-RPC error obj) | upstream → downstream | Per-pool error-string mapping table. Codes: `stale-share`, `difficulty-too-low`, `invalid-job-id`. |

## Key field translations

| Field | SV2 type | SV1 type | Conversion |
|---|---|---|---|
| extranonce | `extranonce_prefix \|\| extranonce` (extranonce_size bytes) | `extranonce1 \|\| extranonce2` (extranonce2_size bytes) | `prefix = extranonce1 \|\| local_alloc`; `extranonce_size = extranonce2_size − len(local_alloc)` |
| difficulty | `U256 maximum_target` | float | `target = pdiff_max / difficulty`; pdiff_max = `0x00000000FFFFFFFF...` |
| job_id | `u32` (monotonic, per-channel) | string (arbitrary, pool-defined) | HashMap, GC'd on `clean_jobs=true` |
| version (rolling) | `u32` (full nVersion) | `version_bits` (4 hex chars, masked) | `version_bits = sv2_version & negotiated_mask` |
| coinbase | `coinbase_tx_prefix` + `coinbase_tx_suffix` | coinb1 + coinb2 | Identity (both use the same SegWit-stripped form upstream of merkle root) |
| merkle | `merkle_path: Seq<U256>` | `merkle_branch: array<hex>` | Identity, just byte-order normalization |
| prev_hash | `U256` | hex string | Endian convention: SV1 sends in pool-internal order; SV2 standard is `to_le_bytes()` of the natural Bitcoin block-header bytes. Must verify per-pool. |

## Pool capability propagation

| SV1 `mining.configure` extension | Effect on SV2 downstream |
|---|---|
| `version-rolling` (BIP-310) supported | `version_rolling_allowed=true` on `NewExtendedMiningJob`; advertise mask. |
| `version-rolling` NOT supported | `version_rolling_allowed=false`; reject submits whose `version != job_version`. |
| `subscribe-extranonce` supported | Translator subscribes; relays `mining.set_extranonce` as `SetExtranoncePrefix`. |
| `subscribe-extranonce` NOT supported | Static extranonce; allocator built once at startup. |
| `minimum-difficulty` | Translator clamps `SetTarget` derived from `mining.set_difficulty` to a per-pool floor. |
| `info` | Translator sends `{"hw-version": "reverse-translator-x.y.z", ...}`. |

## See also

- [[../concepts/sv2-sv1-primitive-mapping]] — discussion
- [[../concepts/architecture-and-state-machine]] — runtime task graph
- [[../topics/reverse-translator-playbook]] — full synthesis
