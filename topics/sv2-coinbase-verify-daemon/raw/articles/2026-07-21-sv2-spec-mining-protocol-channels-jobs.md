---
title: "Stratum V2 spec — 05 Mining Protocol (channels, jobs, coinbase split)"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/05-Mining-Protocol.md
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "Cited independently by 3 research agents (client-flow, coinbase-structure, trust-model)"
tags: [stratum-v2, mining-protocol, NewMiningJob, NewExtendedMiningJob, standard-channel, extended-channel, coinbase_tx_prefix, coinbase_tx_suffix, merkle_path]
summary: "Normative SV2 Mining Protocol. Defines the three channel types (standard/extended/group), the job messages, and — critically — which job message exposes the raw coinbase (NewExtendedMiningJob) vs. only the finished merkle root (NewMiningJob)."
---

# SV2 spec — 05 Mining Protocol

Primary normative source. The single most load-bearing document for this topic:
it defines exactly which messages carry coinbase bytes.

## Channel types (§5.1)

- **Standard channels** — created by end mining devices. Header-only mining (HOM):
  > "Standard Jobs are restricted to fixed Merkle Roots, where the only modifiable
  > bits are under the `version`, `nonce`, and `nTime` fields of the block header."
  The upstream computes the merkle root for these devices; they **never see the
  coinbase**. HOM is "the smallest assignable unit of search space."
- **Extended channels** — "intended to be used by Proxies for a more efficient
  distribution of hashing space." Carry `extranonce_prefix` + `extranonce_size`,
  enable **rolling merkle roots**, SV1↔SV2 translation, difficulty aggregation,
  search-space splitting.
- **Group channels** — a set of standard/mining channels on one connection,
  addressable by a common id so one `NewExtendedMiningJob` broadcast reaches all
  members (members must share identical total extranonce size).

## Channel-open messages

- **OpenStandardMiningChannel** (C→S): `request_id` (U32), `user_identity`
  (STR0_255), `nominal_hash_rate` (F32), `max_target` (U256).
  **`.Success`**: `request_id`, `channel_id`, `target` (U256), `extranonce_prefix`
  (B0_32), `group_channel_id` (U32).
- **OpenExtendedMiningChannel** = all standard fields **plus `min_extranonce_size`**
  (U16). **`.Success`**: adds `extranonce_size` (U16) + `extranonce_prefix` (B0_32).

## Job messages — the crux

- **NewMiningJob** (standard channels): `channel_id`, `job_id`, `min_ntime`
  (OPTION[U32] — empty = "future job"), `version` (U32), **`merkle_root`** (U256).
  **No `coinbase_tx_prefix`, no `coinbase_tx_suffix`, no `merkle_path`.** Opaque root only.
- **NewExtendedMiningJob** (extended/group channels): `channel_id`, `job_id`,
  `min_ntime`, `version`, `version_rolling_allowed` (BOOL), **`merkle_path`**
  (SEQ0_255[U256]), **`coinbase_tx_prefix`** (B0_64K), **`coinbase_tx_suffix`**
  (B0_64K). Carries the raw coinbase; no precomputed merkle_root.

## Coinbase reconstruction contract

Full coinbase = `coinbase_tx_prefix ‖ extranonce_prefix ‖ extranonce ‖ coinbase_tx_suffix`.
`extranonce_prefix` is upstream-allocated (fixed per channel); `extranonce` (size
`extranonce_size`) is the miner-rolled space. Compute `coinbase_txid = SHA256d(coinbase)`,
then fold over `merkle_path` (repeated `SHA256d(h ‖ path_element)`, coinbase always
the left/leftmost leaf) → block merkle root.

## Other messages

- **SetNewPrevHash**: `channel_id`, `job_id` (which job to activate), `prev_hash`
  (U256), `min_ntime` (U32), `nbits` (U32). Promotes a future job to active.
- **SubmitSharesStandard**: `channel_id`, `sequence_number`, `job_id`, `nonce`
  (U32), `ntime` (U32), `version` (U32).
- **SubmitSharesExtended** = same + **`extranonce`** (B0_32).
- **SetTarget** (`channel_id`, `maximum_target`) and **SetExtranoncePrefix**
  (`channel_id`, `extranonce_prefix`) may arrive asynchronously.

## Takeaway for the daemon

To check a coinbase, the daemon **must open an extended channel** — only
`NewExtendedMiningJob` delivers the coinbase bytes. A standard channel gives a
finished 32-byte merkle root that discards all coinbase content (one-way hash).
