---
title: "Drop-In Q3: Block-Found Data Flow — submitblock + DATUM upstream parallel paths"
source_url: https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_submitblock.c
source_type: source-analysis
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: dropinq3
research_path: dropin-q3-non-stratum-concerns
quality_score: 9
tags: [datum, datum-gateway, submitblock, block-found, parallel-broadcast, escape-hatch, sv2]
related_concepts: [phase2-drop-in-replacement, block-discovery, ocean-independence]
---

# Block-found data flow — the non-negotiable parallel paths

This is the most operationally important property of the gateway, and the
one a Rust drop-in replacement must reproduce exactly.

## The property

When a miner submits a share whose hash meets or beats the **network**
target (i.e., it's a real block, not just a pool share), the gateway
**simultaneously** does two things:

1. Submits the block hex to the local bitcoind via `submitblock` RPC,
   plus to every URL in `extra_block_submissions.urls[]` (orphan-rate
   insurance — operators can run a backup bitcoind and spread the
   broadcast).
2. Ships the share to OCEAN via the upstream DATUM protocol, so
   the operator gets credit for the block in OCEAN's TIDES payout.

These two paths are **independent**. Path 1 does not depend on path 2,
and vice versa. **This is the load-bearing safety property that makes
DATUM Gateway acceptable to bitcoiners who don't want their block-
discovery gated on pool connectivity.**

## C implementation

In `datum_stratum.c::assembleBlockAndSubmit()`:

```c
if (compare_hashes(share_hash, job->block_target) <= 0) {
    // BLOCK
    was_block = true;
    submitblock_req = malloc(8500000);  // worst case
    // ... assemble block hex into submitblock_req ...
    datum_submitblock_trigger(submitblock_req, block_hash_hex);
}
```

`datum_submitblock_trigger()` enqueues the work onto the
`datum_submitblock` thread (created by `datum_submitblock_init()` in
`datum_submitblock.c`), which:

1. Calls `submitblock` RPC on the canonical bitcoind (from `bitcoind.rpcurl`)
2. Iterates `datum_config.extra_block_submissions_urls[]` and calls
   `submitblock` on each
3. Calls `preciousblock` on the canonical node (asks it to treat this
   block as the chain tip even if a competing block arrived first)

**Concurrently and unrelatedly**, the share has already been queued for
the upstream DATUM-protocol leg via `datum_queue.c`, and
`datum_protocol.c` ships it to OCEAN whenever it next runs.

The 8.5 MB `malloc` is a one-shot allocation per block-found event in
the calling thread; since blocks are rare, this is not a significant
memory footprint. The "8 threads × 8.5 MB = 68 MB" sum applies only if
all 8 threads simultaneously assemble a block, which happens roughly
never.

## Rust port flow

```
                                     SV2 miner
                                         │
                            SubmitSharesExtended
                                         │
                                         ▼
                          ┌─ datum-stratum-sv2 ─┐
                          │                     │
                          │  ExtendedChannel    │
                          │  share validation:  │
                          │    1. PoW           │
                          │    2. local target  │
                          │    3. job-ring hit  │
                          │    4. ntime bounds  │
                          │    5. dedup         │
                          │                     │
                          └────────┬────────────┘
                                   │ valid share
                                   │
                  ┌────────────────┼────────────────┐
                  │                │                │
                  ▼                │                ▼
       hash <= block_target?       │         (always — every valid share)
                  │                │                │
                  │ yes            │                ▼
                  │                │      datum-queue::send(QueueItem::Share)
                  │                │                │
                  ▼                │                ▼
       datum-submitblock           │      datum-protocol task (detached)
       (tokio::task::spawn)        │      Noise-encrypted upstream
                                   │      8-job ring buffer
                                   │      ships to OCEAN
                  │                │                │
       ┌──────────┼──────────┐     │                │
       ▼          ▼          ▼     │                ▼
  bitcoind    extra      precious  │           OCEAN credits
  submit-     URLs       block     │           share toward
  block       fanout                │           TIDES payout
  RPC         (parallel)            │
       │          │          │      │
       └──────────┴──────────┴──────┘
                  │
                  ▼
        block propagates to network
```

## Properties to verify in the Rust port

| Property | C behavior | Rust port requirement |
|---|---|---|
| Local submit independent of OCEAN | `datum_submitblock_thread` doesn't touch upstream queue | `datum-submitblock` task spawned independently of upstream task |
| Multi-URL fanout | Sequential loop in `datum_submitblock_doit` | `tokio::join_all` parallel `submitblock` futures |
| `preciousblock` after `submitblock` | Sequential in C | Sequential in Rust (preciousblock requires the block to already be known) |
| Block-not-blocked-by-share-queue | Two separate code paths | Two separate Tokio tasks, no `await` dependency between them |
| Buffer reuse | 8.5 MB per-thread pre-alloc in `datum_stratum.c` | `BytesMut` from a pool, allocated only on block-found event |
| Failure tolerance | Each URL independently logged on failure | `tokio::join_all` returns `Vec<Result<...>>`, log each |

## What can go wrong in a port

**Hazard 1: accidental serialization via shared state.**
If the Rust port shares a `RwLock<BitcoinRpcClient>` between the
share-validation hot path and the submitblock path, and the upstream
DATUM-protocol task uses the same lock, then under contention the
block submission could end up waiting on something else. **Fix:** give
the submitblock path its own RPC client instance; don't share locks
across paths.

**Hazard 2: backpressure on the upstream queue stalling block submission.**
If the upstream queue is bounded (it is, in C: the dual-buffer queue
has `max_entries`) and the consumer is slow, a producer attempting to
enqueue the share could block. In Tokio, `mpsc::Sender::send` is async
and yields. If the share-validation path `await`s this and then
proceeds to submitblock, OCEAN slowness gates block discovery. **Fix:**
fire submitblock first (or in parallel via `tokio::spawn`), then enqueue
the share. Or use `try_send` and drop the share-to-OCEAN if the queue
is full (block submission has higher priority than share crediting).

**Hazard 3: panic in upstream task killing submitblock task.**
Tokio task panics are isolated by default, but if both paths are
spawned from the same `JoinSet` or share an `Arc<Notify>` for shutdown,
a panic in one could cascade. **Fix:** spawn each as a top-level task
with its own supervisor.

**Hazard 4: submitblock RPC timeout shorter than block validation.**
Bitcoind's `submitblock` can take several seconds for a block with
thousands of transactions (deserialize + connect + flush UTXO set
changes). The default reqwest timeout is 30s, which is fine, but the
C client has a 5s libcurl timeout — it would actually time out on a
slow node. **Fix:** explicit long timeout (e.g., 60s) for `submitblock`
specifically, distinct from the GBT poll timeout.

## Why this property matters culturally

OCEAN's pitch (and the entire DATUM thesis) is that the operator
"controls the template." The submitblock escape hatch is what makes
that real:

- The operator generates the template locally (via their own bitcoind)
- The operator constructs the coinbase locally (via the V2 coinbaser blob)
- The operator broadcasts the block locally (via this submitblock path)
- The pool's role is purely accounting: credit the share for payout

If submitblock depended on the pool, OCEAN would hold the block
hostage to its connectivity. The whole story falls apart. Any drop-in
replacement that gets this wrong is not a drop-in replacement.

## Justification

Specifies the most operationally critical property of the gateway in
enough detail to test against during a Rust port. Identifies four
concrete hazards that look benign in code review but break the safety
property at runtime.
