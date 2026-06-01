---
title: "DATUM Gateway datum_protocol.c — Share Handoff to Upstream"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_protocol.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 8
tags: [datum, datum-gateway, datum-protocol, share-routing, queue, c-source]
related_concepts: [sv2-downstream-replacement, queue-handoff, upstream-leg-unchanged]
---

# datum_protocol.c — the upstream leg the SV2 variant DOES NOT replace

This is the **second-most-important architectural finding**: the
upstream-facing leg (gateway-to-OCEAN) is **encapsulated behind a queue**
and is largely **independent of the downstream protocol**. An SV2-downstream
variant keeps this module almost untouched.

## Producer-consumer handoff

```
[stratum thread]                     [protocol thread]
  client_mining_submit()
    └─ datum_protocol_pow_submit()
        └─ datum_queue_add_item(&pow_queue, &pow)
                                  ──>  datum_protocol_pow_queue_submits()
                                        └─ datum_protocol_pow()
                                            └─ encrypted send to OCEAN
```

The queue (see datum_queue.c findings) is a **dual-buffer pthread_rwlock**
queue, not lockless. Multiple stratum threads produce, single protocol
thread consumes. Hard-fail on overflow (no drop policy).

## Job indexing — the structural decoupling

```c
unsigned char a = datum_protocol_next_job_idx;
datum_jobs[a].sjob = s;       // protocol stores stratum-job pointer
```

When the stratum module gets a fresh job from bitcoind GBT, it calls
`datum_protocol_setup_new_job_idx()`, which assigns a `datum_job_id` (0–7
ring) and stashes a back-pointer to the `T_DATUM_STRATUM_JOB`. Shares
reference this `datum_job_id` when enqueued. The protocol thread reads
job metadata from `datum_jobs[]` (protected by `datum_jobs_rwlock`) when
serializing the upstream submit.

This indirection is **the** seam an SV2 variant exploits: replace the
SV1-job-construction-and-tracking module wholesale, but keep
`datum_protocol_setup_new_job_idx()` intact and feed it
SV2-derived job pointers.

## Threading

- `datum_protocol_client()` runs as a **detached pthread**.
- I/O via **epoll** (own loop, not shared with the stratum threadpool).
- Reader-writer lock `datum_jobs_rwlock` arbitrates concurrent
  job-add (stratum) vs job-read (protocol).

## Trust boundary — no re-validation

> The protocol client **trusts** stratum-layer validation entirely.
> `datum_protocol_pow()` reads job metadata (merkle branches, coinbase
> data) but never re-validates proof-of-work — it assumes the stratum
> module has already validated difficulty and nonce correctness.

This is a load-bearing trust boundary: the share validation pipeline
described in datum_stratum.c (PoW + target + stale + ntime + dupe) is
**the** validation point. **The SV2 variant must do all six checks
before enqueueing**, otherwise it would forward invalid shares
upstream.

## Non-DATUM mode

```c
"*** DATUM pool host is blank. NON-POOLED MINING! ***"
```

**No fallback to a regular SV1 pool exists**. Non-DATUM mode = solo
mining only (block discovery via local bitcoind). An SV2-downstream
variant could theoretically grow an SV2-upstream-fallback option, but
that's out of scope for "SV1-to-ASIC leg replacement."

## Replacement notes for SV2-downstream

**Keep almost everything.** Specifically:

- **Queue-based handoff** — keep. Stratum-thread or SV2-channel-task
  produces, protocol thread consumes. The Rust port would use
  `tokio::sync::mpsc::channel` instead of `pthread_rwlock`-backed
  dual buffers, but the pattern transfers cleanly.
- **Job indexing ring** — keep. `datum_jobs[8]` ring with rwlock works
  for both protocols.
- **Trust boundary** — keep, document explicitly. SV2 share-validation
  pipeline must produce the same guarantees before enqueueing.
- **Detached thread / dedicated loop** — keep, as Tokio task.
- **Encrypted upstream framing** — unchanged.

What changes:

- **Producer side** — instead of `client_mining_submit()` in
  `datum_stratum.c`, the producer becomes the SV2 mining-channel
  share handler.
- **`pow.datum_job_id` lookup** — same field, same ring; just
  populated by SV2 job-builder.

## Architectural takeaway

The gateway's upstream-leg / downstream-leg split is **already clean**
because of the queue. This is what makes "swap SV1 for SV2 on the
downstream side" a meaningful refactor rather than a full rewrite —
the architectural boundary already exists, and it's defensible.

## Justification

Confirms the queue-based architectural seam between downstream
(stratum) and upstream (DATUM) legs. The SV2-downstream variant
preserves this boundary verbatim; only the producer changes.
Critical input for sizing the rewrite scope.
