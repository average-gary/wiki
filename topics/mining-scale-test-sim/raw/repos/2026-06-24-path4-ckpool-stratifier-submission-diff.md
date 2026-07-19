---
title: ckpool stratifier — submission_diff and new_share (SV1 share validation)
source_type: repos
source_url: https://github.com/ckolivas/ckpool/blob/master/src/stratifier.c
fetched: 2026-06-24
path: 4
tags: [ckpool, sv1, share-validation, vardiff, dup-detection]
---

# ckpool `submission_diff` and `new_share` — canonical SV1 share validation

`ckolivas/ckpool` is the reference C SV1 pool. The hot path for every
submitted share is `parse_submit` → `submission_diff` → `new_share`. The
file is 8929 lines; the validation core is ~30 LOC.

## Cost ledger per share (lines 5973–6072)

`submission_diff()` runs for **every** share submission, accepted or
rejected:

1. **Coinbase rebuild** (memcpy into `alloca(1024)`):
   `coinb1 || enonce1_const || enonce1_var || nonce2 || coinb2`
2. **One SHA256d** on the variable-length coinbase (txid):
   `gen_hash((uchar *)coinbase, merkle_root, cblen)`
3. **Merkle path reduction** — `wb->merkles` iterations of `gen_hash`
   over 64-byte concatenations. For mainnet at ~2–4k txs/block,
   `merkles ≈ ceil(log2(ntxs)) ≈ 11–12`.
4. **Header assembly** — `memcpy(data, wb->headerbin, 80)` + splice
   merkle root + nonce + ntime + version_mask.
5. **Block-header SHA256d** — `sha256(swap,80,hash1); sha256(hash1,32,hash)`.
6. **`diff_from_target(hash)`** — division-based diff calculation from
   the resulting hash (cheap, microseconds).

Then `new_share()` (lines 6051–6072):

7. **uthash `HASH_FIND` over the per-workbase share table** keyed by the
   32-byte hash (O(1)); insert if not present.

Roughly: **1 SHA256d on the coinbase tx (~250–1000 B) + ~12 SHA256
rounds for the merkle path + 1 SHA256d on the 80-B header + 1 hashtable
lookup**. With modern SHA-NI hardware acceleration (Intel Goldmont+,
AMD Zen+), each SHA256 round is ~0.2–0.5 µs. Total ≈ **5–15 µs per
share on a single x86 core**.

## Duplicate-share memory model (lines 829–858)

```c
static void age_share_hashtable(sdata_t *sdata, const int64_t wb_id)
{
    mutex_lock(&sdata->share_lock);
    ...
        HASH_DEL(sdata->shares, share);
    mutex_unlock(&sdata->share_lock);
}
```

The `shares` hashtable is **aged out when the workbase rolls** (i.e.,
on every new template / blockchange). So dup-detection memory is
bounded by `N_connections × shares_per_workbase_window` and resets
naturally on every getblocktemplate update (typical mainnet pool:
every 5–30 s in ckpool; bound is N × 60 shares/min × workbase
lifetime).

## Vardiff target (lines 5720–5840)

ckpool's vardiff drives `drr = dsps / diff` toward **0.3** (one share
per ~3.3 s of effective hash-rate), with hysteresis band `[0.15, 0.4]`
(roughly 1 share / 7.5–22 s). Floor is `ckp->mindiff` which **defaults
to 1**, with `startdiff = 42`. From `ckpool.c:1784-1787`:

```c
if (!ckp.mindiff)
    ckp.mindiff = 1;
if (!ckp.startdiff)
    ckp.startdiff = 42;
```

`maxdiff` defaults to 0 (unlimited). When users set a personal
`mindiff`, the optimal-share target relaxes to `dsps * 2.4` (≈ 0.4
ratio, fewer shares per second).

## Implications for scale-test sim

- At vardiff floor diff=1, an ASIC pulling ~100 TH/s would submit
  ~14 million shares/sec. The pool would crank diff up immediately;
  the floor is only meaningful for low-hashrate devices (CPU/GPU/old
  ASICs).
- Coinbase rebuild is `alloca(1024)` per call — no heap pressure.
- Single `share_lock` mutex per workbase (one global write lock per
  share insertion) — likely the contention point under high share
  rates, not the SHA work.

## Files referenced

- `/tmp/stratifier.c` (downloaded copy)
- ckpool.c lines 1479–1482, 1784–1787 (default diffs)
