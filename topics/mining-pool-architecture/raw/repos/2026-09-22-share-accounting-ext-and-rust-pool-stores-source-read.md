---
title: "share-accounting-ext, PPLNS-JD, hydrapool and p2poolv2 — what a share accounting layer records"
source: "https://github.com/demand-open-source/share-accounting-ext"
related_sources:
  - "https://github.com/demand-open-source/pplns-with-job-declaration"
  - "https://github.com/256Foundation/hydrapool"
  - "https://github.com/p2poolv2/p2poolv2"
type: repos
ingested: 2026-09-22
tags: [share-accounting, sv2-extension, slice, miner-verifiable-accounting, probabilistic-verification, pplns-jd, fee-attribution, template-provenance, rocksdb, column-families, delete-range, retention, coinbase-payout, source-read]
summary: "Four implementations read at source, and together they answer what a share accounting layer must record. share-accounting-ext (EXTENSION_TYPE = 32) introduces the SLICE as the unit of accounting: a 60-byte record of number_of_shares, summed difficulty, the reference job's fees, a MERKLE ROOT OVER THE SHARES IN THE SLICE, and the reference job_id. A slice covers shares mined while mempool extractable fees are roughly constant, and is kept shorter than a round to deny pool-hopping. Each Share carries TWO job ids — its own and the slice's reference_job_id — plus share_index and a merkle_path to the slice root. The messages (ShareOk, NewBlockFound, GetWindow, GetWindowSuccess, GetShares) exist so the MINER CAN AUDIT THE POOL: fetch the window, sample slices, sample shares, verify PoW, verify merkle path to the slice root, verify summed difficulty and fees within a delta. That is SmartPool's probabilistic verification arriving in Bitcoin without a smart contract. The PPLNS-JD paper supplies the payout: payout = r x score_d + F_S x score_f, splitting subsidy by hashpower and fees by difficulty x fees-chosen — and CONFIRMS round 1's hypothesis that fee attribution requires template provenance per share. p2poolv2 gives the only real production store: RocksDB, 16 column families, a 24-byte big-endian composite share key (n_time, user_id, seq) giving natural temporal sort, btcaddress/workername normalised out via serde(skip) into a User CF, delete_range_cf for O(1) pruning, 7-day default TTL. hydrapool delegates all storage to p2poolv2_lib and embeds PPLNS payouts directly in the coinbase, so the pool never holds funds."
commits_read:
  - "share-accounting-ext: c661e93 (2025-07-14)"
  - "pplns-with-job-declaration: 88219bd (published 2024-08-28)"
  - "hydrapool: 9553363 (Release 2.4.0, 2026-03-05)"
  - "p2poolv2: 635084b (2026-03-05)"
credibility: high
credibility_score: 5
credibility_rationale: "Direct source read at named commits with path:line citations and transcribed structs/schemas. Maturity differs sharply across the four and is recorded per repo — share-accounting-ext is experimental (20 commits, no tests, activation mechanism marked TODO), p2poolv2 is the only one with production evidence."
confidence: high
research_round: 2
research_agent: "B2 (source read)"
confirms: "Round 1 hypothesis in wiki/concepts/share-accounting-and-durability.md that SLICE-style fee attribution forces template provenance into the share pipeline — confirmed by the PPLNS-JD score_f formula, and the gap is real: neither hydrapool nor p2poolv2 actually stores the per-share transaction list."
scope_note: "Payout-schema design belongs to bitcoin-mining-payout-schemas; p2pool share-chain internals to sv2-p2pool-integration. Recorded here for the persistence/accounting architecture only."
extraction_note: "Subagent source read. Structs and the share key layout are transcribed. The PPLNS-JD payout formula is from the PDF and should be re-read before implementation."
---

# What a share accounting layer records

## share-accounting-ext — the slice, and a miner who can audit

**`EXTENSION_TYPE: u16 = 32`** (`src/const.rs:1`). Stated purpose (`extension.md:3-12`): enable payout
schemes accounting for **both hashpower and transaction fees** when miners use Job Declaration — the
centralisation problem being that pools pick transactions while miners supply the work.

### The Slice is the unit of accounting

`src/data_types/slice.rs:20-32`, **fixed 60 bytes** (line 60):

```rust
pub struct Slice {
    pub number_of_shares: u32,  // how many shares in this slice
    pub difficulty: u64,        // sum of all share difficulties
    pub fees: u64,              // fees of the ref job for this slice
    pub root: Hash256,          // merkle root of all shares in the slice
    pub job_id: u64,            // ID of the reference job
}
```

A slice groups shares mined while mempool max-extractable-fees is approximately constant
(`extension.md:40-41`), and is deliberately **shorter than a full mining round to remove pool-hopping
incentive** (`extension.md:55-60`). A new slice starts when a share arrives whose fees ≥ f + δ, or whose
prev-hash differs from the current slice's reference job.

Note what the `root` field does: it commits to the set of shares in the slice, so the pool cannot later
revise the slice's membership. **The accounting record is made tamper-evident, not merely published.**

### Each share carries two job ids

`src/data_types/share.rs:19-30`:

```rust
pub struct Share<'decoder> {
    pub nonce: u32,
    pub ntime: u32,
    pub version: u32,
    pub extranonce: B032<'decoder>,
    pub job_id: u64,            // what the miner actually worked on
    pub reference_job_id: u64,  // the slice's reference template, for fee scoring
    pub share_index: u32,       // index within the slice
    pub merkle_path: B064K<'decoder>,  // path to the slice root
}
```

Plus `PHash { phash: Hash256, index_start: u32 }` (`phash.rs:20-23`) mapping which slices belong to which
prev-hash, so a miner can verify share PoW (`extension.md:67-71`).

### The messages exist so the miner can check the pool's arithmetic

- **`ShareOk`** — per `SubmitShare`, returns `ref_job_id` and `share_index` so the miner knows *where its
  share landed in the accounting structure*.
- **`NewBlockFound`** — sent only when **this pool** finds a block, carrying `block_hash`.
- **`GetWindow` / `GetWindowSuccess`** — the miner requests the PPLNS window for that block; the pool
  returns `slices: SEQ0_64K[SLICE]` and `phashes: SEQ0_64K[PHASH]`. The window runs from `slice[start]`
  to `slice[end]` where cumulative difficulty meets `N × window_size`; **the final slice contains the
  block-finding share and is excluded from payout** (`extension.md:153-159`).
- **`GetShares`** — request specific shares by window-global index for spot checks.

**The verification protocol** (`extension.md:24-33`): ask for the window → randomly select slices →
randomly select shares within them → fetch missing transactions via `GetTransactionsInJob` → verify
share PoW → verify `share_hash + merkle_path == slice.root` → verify
`sum(verified_share_diffs) ≤ slice.difficulty` → verify `share_fees ≤ slice.fees + delta`.

**This is SmartPool's probabilistic verification, on Bitcoin, without a smart contract.** Round 1
recorded the principle — sampled verification of a high-volume accounting stream works if the penalty
makes cheating expectation-neutral — and dismissed SmartPool's substrate as non-transferable. This
extension transfers the *verification* half by making the pool commit to merkle roots the miner can
sample against. What it lacks is SmartPool's penalty function: a miner who detects a discrepancy can only
leave, not slash. Detection without enforcement, which is still a large improvement over nothing.

**What it deliberately does not define**: the payout formula, `N`, the fee tolerance `delta`, or any
database schema. **Not in the sv2-spec repo.** Extension activation is marked **TODO**
(`extension.md:83-84`).

**Maturity: experimental.** 20 commits, last July 2025, no tests found, depends on a demand-open-source
fork of `stratum`.

## PPLNS-with-Job-Declaration — the payout, and the provenance requirement

8-page paper, published 2024-08-28, 3 commits. No implementation in the repo.

**Payout** (§3.3): `payout(s_i) = r × score_d(s_i) + F_S × score_f(s_i)` — subsidy `r` distributed by
hashpower, the slice's fee pot `F_S` distributed by a composite score.

**Fee score** (§3.2): `score_f(s_i) = (d_i × f_i) / Σ_{j∈slice}(d_j × f_j)`, where `f_i` is *"the fee in
the block header of that share (which depends on the transactions chosen in the template)"*.

**So template provenance per share is required, confirmed.** You cannot compute `f_i` without knowing
which transactions were in the miner's declared job. Round 1 inferred this from DMND's SLICE description;
the formula confirms it.

The consequence is a two-component incentive: a miner that selects *better transactions* earns more of
the fee pot than an equal-hashrate peer that does not. That is the mechanism intended to pay for the cost
of running a node and declaring jobs.

**Accountability section** (§5) requires the pool to publish per slice: share count, summed difficulty,
reference-job fees, merkle root of the shares, reference job id — **exactly the `Slice` struct above.**
Spec and implementation line up.

`N` is not fixed; Appendix A works an example at N = 100 shares/min × 8 × 10 min = 8,000 shares, noting N
should span multiple blocks to smooth variance. Ocean's TIDES is cited as prior art with N = 8 × difficulty.

## p2poolv2 — the only production store

**RocksDB** (`p2poolv2_lib/Cargo.toml:32`). Sixteen column families
(`store/column_families.rs:19-36`): `Block`, `BlockTxids`, `TxidsBlocks`, `Uncles`, `BitcoinTxids`,
`Inputs`, `Outputs`, `Tx`, `BlockIndex`, `BlockHeight`, **`Share`**, **`Job`**, **`User`**, `UserIndex`,
`Metadata`, `SpendsIndex`.

**Share key — 24 bytes, big-endian composite** (`accounting/simple_pplns/mod.rs:74-80`):

```rust
pub fn make_key(n_time: u64, user_id: u64, seq: u64) -> Vec<u8> {
    let mut key = Vec::<u8>::with_capacity(24);
    key.extend_from_slice(&n_time.to_be_bytes());    // 8
    key.extend_from_slice(&user_id.to_be_bytes());   // 8
    key.extend_from_slice(&seq.to_be_bytes());       // 8
    key
}
```

Big-endian is the whole trick: it gives **natural temporal sort order in RocksDB**, so a PPLNS window is a
range scan rather than an index lookup. Time is stored in **microseconds** (`n_time * 1_000_000` at
`store/pplns_shares.rs:37`) with a Snowflake-ish `get_next_id()` sequence for uniqueness.

**Share value** (`mod.rs:26-46`, encoded at `95-127`):

```rust
pub struct SimplePplnsShare {
    pub user_id: u64,
    pub difficulty: u64,
    #[serde(skip)] pub btcaddress: Option<String>,   // NOT stored
    #[serde(skip)] pub workername: Option<String>,   // NOT stored
    pub n_time: u64,
    pub job_id: String,
    pub extranonce2: String,
    pub nonce: String,
}
```

**Normalisation is explicit**: `btcaddress` and `workername` are `#[serde(skip)]` to keep variable-length
strings out of every share row, reconstructed on read from the `User` CF via a batched `multi_get_cf` in
`populate_btcaddresses()` (`store/pplns_shares.rs:99-121`). Serialised payload is
`user_id, difficulty, n_time, job_id, extranonce2, nonce` — the last three retained for **block
reconstruction**, not for payout.

**Read path** (`store/pplns_shares.rs:50-95`): reverse iteration from `end_time` using
`IteratorMode::From(&end_key, Reverse)` with `set_iterate_lower_bound()`, default limit 100,000.

**Retention** (`store/background_tasks.rs:31-88`): a task every 24 h deleting shares older than a
`pplns_ttl` (default **7 days**) via **`delete_range_cf`** over `make_key(0,0,0)` →
`make_key(cutoff+1,0,0)`. `delete_range_cf` is an O(1) metadata operation, with real removal deferred to
compaction — the correct primitive for this, and only possible because the key is time-prefixed.

TTL must be ≥ the maximum PPLNS window span. **No SQL-style indexes; ordering is the index.**

Tests exist (`p2poolv2_tests/`, plus unit tests at `pplns_shares.rs:124-270`). v0.7.0, 1,125 commits.

## hydrapool — storage delegated, payouts in the coinbase

Depends on `p2poolv2_lib` at tag v0.7.0 (`Cargo.toml:34`); **no database dependency of its own.** Share
ingest: `mining.submit` → validate PoW and duplicates → if it meets Bitcoin difficulty, `submit_block()`
→ build `SimplePplnsShare` weighted by session difficulty → wrap in an `Emission` → tokio mpsc channel →
`EmissionWorker` → `add_pplns_share()`. **Batching is implicit in the async channel** rather than being a
DB-level batch.

**Window is difficulty-based, not count-based**:
`total_difficulty = bitcoin_target.difficulty_float() × config.difficulty_multiplier` (default 1.0),
traversed in reverse in **1-day batches** until accumulated difficulty meets the target.

**Payout recalculated on every new block template** — not only on block discovery — and
`proportion = miner_accumulated_difficulty / total_accumulated_difficulty`, with the last miner absorbing
rounding remainder. Donation and fee deducted sequentially in basis points.

**PPLNS outputs are embedded directly in the coinbase transaction; the pool never holds miner funds.**
That removes the custody surface entirely and, architecturally, means the payout computation is on the
*template* path — recomputed per template — rather than being a periodic batch job. A notable coupling:
accounting latency now affects job production.

## Synthesis — the union of the four

**Minimal share record** (intersection of all): `user_id` (u64, normalised to an address elsewhere),
`difficulty` (u64 — the weight), `timestamp` (u64 — window boundaries *and* retention), `job_id`.

**For block reconstruction**: `nonce`, `extranonce2`, `ntime`.

**For Job-Declaration fee accounting**: `reference_job_id`, the share's `fee`, `merkle_path` to the slice
root, `share_index`.

**Per slice, aggregated**: share count, summed difficulty, reference-job fees, merkle root, reference
job id.

**Separately**: `user_id → btcaddress` plus `created_at`.

## The open hole, and it is the interesting one

**Nobody stores template provenance per share.** PPLNS-JD's `score_f` needs `f_i`, the fees implied by
the transactions in *that share's* declared job. Neither hydrapool nor p2poolv2 stores a per-share
transaction list, and no code path recalculates fees from a stored `job_id`. A `Job` column family exists
in p2poolv2, so the join is *possible* — store the `DeclareMiningJob` with its wtxid list and join on
`job_id` — but it is not implemented.

So the accounting layer required by the fee-attribution payout schemes now being deployed **does not yet
exist in any open implementation**. That is the concrete version of round 1's observation that paying for
template contribution changes what accounting must remember.

Also unresolved: what `delta` (fee tolerance) should be; maximum slice duration; how slice boundaries are
re-scored after a reorg (no reorg handling found); and how a miner working across pools would compare
accounting between them.

## Maturity

| Repo | Commits | Last activity | Tests | Status |
|---|---|---|---|---|
| share-accounting-ext | 20 | Jul 2025 | none found | experimental spec, activation TODO |
| pplns-with-job-declaration | 3 | Aug 2024 | n/a (paper) | academic reference |
| hydrapool | 181 since 2025 | Mar 2026 | unknown | production-intended, debian packaging |
| p2poolv2 | 1,125 since 2025 | Mar 2026 | extensive | production-ready |
