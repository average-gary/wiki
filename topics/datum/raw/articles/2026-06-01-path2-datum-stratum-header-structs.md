---
title: "DATUM Gateway datum_stratum.h — Per-Miner & Per-Job Structs"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_stratum.h
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 8
tags: [datum, datum-gateway, headers, structs, vardiff-state, miner-state]
related_concepts: [sv2-downstream-replacement, channel-state, vardiff]
---

# datum_stratum.h — the data shape an SV2 variant must reproduce

The header file is a compact map of the gateway's per-miner and per-job state.
Worth reading before any rewrite — it's the *minimum* state that a downstream
mining server needs to track regardless of protocol.

## Per-miner state: `T_DATUM_MINER_DATA`

Vardiff fields (load-bearing for any SV2 variant):

- `uint64_t current_diff` — current target difficulty for this miner
- `uint64_t last_sent_diff` — most recently sent (avoid re-send churn)
- `uint64_t share_count_since_snap` — shares since last vardiff snapshot
- `uint64_t share_diff_since_snap` — diff sum since last snapshot (hashrate proxy)
- `uint64_t share_snap_tsms` — snapshot epoch (ms)
- `bool quickdiff_active` — fast-bump mode flag
- `uint8_t stratum_job_targets[MAX_STRATUM_JOBS][32]` — per-job target snapshot
- `uint64_t stratum_job_diffs[MAX_STRATUM_JOBS]` — per-job diff snapshot

The `stratum_job_targets` / `stratum_job_diffs` per-miner-per-job arrays
(`MAX_STRATUM_JOBS = 256`) exist because **each miner's diff might differ at
the moment a job was sent**. Validating an incoming share requires looking up
the diff that was in force when *that* job was sent to *this* miner. SV2
preserves this implicitly via channel-scoped target state, but the lookup
table is still required.

## Per-job state: `T_DATUM_STRATUM_JOB`

- `char job_id[24]`, `char prevhash[68]`
- `T_DATUM_TEMPLATE_DATA *block_template` — link back to bitcoind GBT
- `unsigned char merklebranch_count` (max 24)
- `T_DATUM_STRATUM_COINBASE coinbase[MAX_COINBASE_TYPES]` — **6 variants**
  (different miner fingerprints get different coinbases — see fingerprint flag)
- `uint64_t coinbase_value, height`
- `int job_state` (states 0-5, see datum_stratum.c findings)
- `bool is_new_block, is_stale_prevblock`

The 6 coinbase variants × per-job storage is a non-trivial memory cost. SV2's
template-distribution layer (TDP) makes the coinbase choice upstream-of-template,
so this multi-coinbase array would simplify or move.

## Per-thread state: `T_DATUM_STRATUM_THREADPOOL_DATA`

- `T_DATUM_STRATUM_JOB *cur_stratum_job` — current job pointer
- `int latest_stratum_job_index` — index into per-thread ring of jobs
- `char submitblock_req[MAX_SUBMITBLOCK_SIZE]` — pre-allocated **8.5 MB**
  buffer for bitcoind submitblock RPC

Note that `submitblock_req` (`MAX_SUBMITBLOCK_SIZE = 8500000`) is allocated
*per thread*. With default 8 threads, that's **68 MB** just for submit buffers.
Consistent with the gateway's "pre-allocate, never fragment" philosophy
(see datum_stratum.c line 405 quote).

## Per-user stats: `T_DATUM_STRATUM_USER_STATS`

- `uint64_t diff_accepted[2]` — running totals (likely [accepted, rejected]
  or [current_window, prior_window])
- `uint64_t last_share_tsms` — for idle detection / hashrate decay

This is what the API/web UI surfaces (see datum_api.c findings —
`/clients` and `/threads` endpoints).

## Constants worth preserving

| Constant | Value | Note |
|---|---|---|
| `MAX_STRATUM_JOBS` | 256 | per-miner job ring size |
| `MAX_COINBASE_TYPES` | 6 | coinbase variants per job |
| `MAX_SUBMITBLOCK_SIZE` | 8500000 | per-thread submit buffer |

## Public API footprint (top of header)

- `send_mining_notify()` / `send_mining_set_difficulty()` — outbound
- `update_stratum_job()` — refresh from new GBT
- `stratum_job_merkle_root_calc()` — share validation helper
- `assembleBlockAndSubmit()` — block-discovery escape hatch
- `generate_coinbase_txns_for_stratum_job()` — coinbase builder

## Replacement notes for SV2-downstream

- **Vardiff fields**: keep, repurpose for SV2 `SetTarget` cadence.
- **Per-miner per-job target/diff arrays**: keep, but key by SV2 channel_id
  and SV2 job_id.
- **Multi-coinbase array**: largely obsolete under SV2 TDP — simplify to
  one coinbase per template.
- **submitblock pre-alloc**: reuse as-is; SV2 doesn't change the bitcoind path.
- **Outbound API (notify/set_difficulty)**: replaced by SV2 `NewMiningJob` +
  `SetTarget` framing.

## Justification

Header captures the per-miner/per-job state shape that any downstream
mining server (SV1 or SV2) must track. Highly compact reference for sizing
the SV2 channel state struct.
