---
title: "SRI channels_sv2::client::extended — ExtendedChannel + validate_share (the reusable coinbase-check engine)"
source_url: https://github.com/stratum-mining/stratum/blob/main/sv2/channels-sv2/src/client/extended.rs
source_url_2: https://github.com/stratum-mining/stratum/blob/main/sv2/channels-sv2/src/merkle_root.rs
source_url_3: https://github.com/stratum-mining/stratum/blob/main/sv2/channels-sv2/src/server/jobs/factory.rs
type: repo
retrieved: 2026-07-21
credibility: high
corroboration: "rust-stack agent (primary source, ~1164 lines)"
tags: [stratum-v2, SRI, channels-sv2, ExtendedChannel, validate_share, merkle_root_from_path, JobFactory, bip141, Target, coinbase-reconstruction]
summary: "The single most relevant SRI file for this daemon: ExtendedChannel already reconstructs the coinbase, folds the merkle root, builds the header, hashes, and compares against target. merkle_root_from_path is a standalone free function. JobFactory builds the coinbase server-side (to derive an 'expected' coinbase)."
---

# SRI channels_sv2::client::extended — the coinbase-check engine

## ExtendedChannel

`pub struct ExtendedChannel<'a>` holds `channel_id`, `extranonce_prefix`
(`ExtranoncePrefix`), `rollable_extranonce_size`, `target: Target`,
`nominal_hashrate`, `version_rolling`, `chain_tip`, and active/future/past/stale job
maps. `ExtendedJob<'a> = (NewExtendedMiningJob<'a>, Vec<u8> /*extranonce_prefix*/,
Target)`.

- `on_new_extended_mining_job(NewExtendedMiningJob)`: strips BIP141 witness bytes from
  prefix/suffix (`try_strip_bip141`), files the job as future (empty `min_ntime`) or
  active.
- `on_set_new_prev_hash(SetNewPrevHashMp)`: promotes a future job to active, sets
  `chain_tip`.

## validate_share — the reconstruct-and-check loop

`validate_share(SubmitSharesExtended) -> Result<ShareValidationResult,
ShareValidationError>`:

1. `full_extranonce = extranonce_prefix ++ share.extranonce`.
2. `merkle_root_from_path(coinbase_tx_prefix, coinbase_tx_suffix, full_extranonce,
   merkle_path)`.
3. Build `bitcoin::block::Header{ version, prev_blockhash: u256_to_block_hash(prev_hash),
   merkle_root, time: ntime, bits: nbits, nonce }`.
4. `header.block_hash()` → convert to `Target`.
5. Compare vs `job_target` (share diff) and `network_target = Target::from_compact(nbits)`
   via `network_target.is_met_by(share_hash)` (block-found check).
6. Returns `ShareValidationResult::{Valid, BlockFound, ...}`.

`on_set_custom_mining_job_success(...)` shows full coinbase-from-parts reconstruction
using `bitcoin::{Transaction, TxIn, TxOut, OutPoint, Sequence, Witness}` +
`consensus::serialize` and the byte-offset math to split prefix/suffix around the
extranonce — the inverse operation (build the "expected" coinbase to check against).

The `client` module is **no_std-capable** (feature `no_std` swaps std collections for
`hashbrown`) — relevant for embedded targets. Siblings: `client/standard.rs`,
`client/group.rs`, `client/share_accounting.rs`.

## merkle_root.rs — standalone helper

`merkle_root::merkle_root_from_path(coinbase_tx_prefix, coinbase_tx_suffix, extranonce,
path) -> Option<Vec<u8>>`: concatenates prefix ++ extranonce ++ suffix,
`bitcoin::consensus::deserialize::<Transaction>`, `compute_txid()`, folds the path with
`sha256d`. Also `merkle_root_from_path_(coinbase_id, path)` if you already have the
txid. Depends only on `bitcoin` + `alloc` → liftable for a truly minimal check.

## server/jobs/factory.rs — JobFactory (the "JobCreator")

`JobFactory`: `new_standard_job`, `new_extended_job`,
**`new_coinbase_tx_prefix_and_suffix`**, `new_custom_job`,
`new_extended_job_from_custom_job`, plus `op_pushbytes_pool_miner_tag`. `JobIdFactory`
allocates job ids. Server-side, but exactly the logic to build/derive an "expected"
coinbase to compare against.

Supporting modules: `bip141.rs` (witness strip/reinsert), `target.rs` (`Target`,
`u256_to_block_hash`, `from_compact`, `is_met_by`, `difficulty_float`), `chain_tip.rs`
(`ChainTip`), `extranonce_manager/` (`ExtranoncePrefix`, `ExtranonceAllocator`),
`outputs.rs`, `vardiff/`.

## Reuse-don't-reimplement

For "coinbase check against an expected value," reuse `ExtendedChannel` +
`validate_share` (or the raw `merkle_root_from_path`) + a
`bitcoin::consensus::deserialize::<Transaction>` on the reconstructed coinbase —
rather than reimplementing merkle/header/target math.
