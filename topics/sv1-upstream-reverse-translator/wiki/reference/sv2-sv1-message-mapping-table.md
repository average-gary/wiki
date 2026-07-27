---
title: "Reference — SV2 ↔ SV1 message mapping table"
category: reference
status: active
created: 2026-05-28
updated: 2026-07-27
verified: 2026-07-27
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-28-path1-bitcoin-wiki-stratum-mining-protocol.md
  - raw/articles/2026-05-28-path1-sv2-spec-mining-protocol-channels.md
  - raw/articles/2026-05-28-path1-bitcoin-wiki-difficulty.md
  - raw/articles/2026-05-28-path1-slush-stratum-extensions.md
  - raw/articles/2026-05-28-path1-bip-310-version-rolling.md
  - raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md
tags: [reference, message-mapping, sv2, sv1, bdiff, pdiff, byte-order]
summary: "Quick-lookup table for implementers. Full discussion in ../concepts/sv2-sv1-primitive-mapping."
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
| `SetExtranoncePrefix` | `mining.set_extranonce` | upstream → downstream | If upstream re-allocates extranonce1, rebuild allocator and broadcast new prefixes. Expect in-flight share failures. On **upstream failover**, this + `SetTarget` is the in-place re-point path; on an **operator-initiated** upstream change, force a reconnect instead ([[../concepts/architecture-and-state-machine|why]]). |
| `SetTarget` | `mining.set_difficulty` | upstream → downstream | Convert float → U256: `max_target = diff1_max / difficulty`. **`diff1_max` convention is unresolved** — this table says pdiff (`0x00000000FFFFFFFF…`); `bitcoin`'s `Target::from_difficulty` and the one shipped implementation use bdiff (`0x00000000FFFF0000…`). ~0.0015% apart, affects difficulty readback only. See [[../concepts/sv2-sv1-primitive-mapping|discussion]]. |
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
| difficulty | `U256 maximum_target` | float | `target = diff1_max / difficulty`. **Unresolved**: pdiff_max = `0x00000000FFFFFFFF…` (pool convention, as originally written here) vs bdiff_max = `0x00000000FFFF0000…` (`rust-bitcoin` `Target::difficulty_float`; chosen by the one shipped implementation). Prefer bdiff. |
| job_id | `u32` (monotonic, per-channel) | string (arbitrary, pool-defined) | HashMap, GC'd on `clean_jobs=true` |
| version (rolling) | `u32` (full nVersion) | `version_bits` (4 hex chars, masked) | `version_bits = sv2_version & negotiated_mask` |
| coinbase | `coinbase_tx_prefix` + `coinbase_tx_suffix` | coinb1 + coinb2 | Identity (both use the same SegWit-stripped form upstream of merkle root) |
| merkle | `merkle_path: Seq<U256>` | `merkle_branch: array<hex>` | Identity, just byte-order normalization |
| prev_hash | `U256` | hex string | SV1 `mining.notify` carries a **per-word (4-byte) swap**, absorbed by `sv1_api`'s `PrevHash` newtype — go through the typed primitive and the SV2 `prev_hash` stays in its natural internal order. Targets are 32-byte little-endian per spec. (Convention taken from a shipped implementation, not interop-tested.) |

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
- [[../concepts/prior-art-blitzpool-rental-proxy]] — a shipped implementation of this table
- [[../topics/reverse-translator-playbook]] — full synthesis
