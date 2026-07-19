---
title: sv2-apps JDS — template validation is amortized, NOT per-share
source_type: repos
source_url: https://github.com/marafoundation/sv2-apps/blob/main/pool-apps/jd-server/src/lib/job_declarator/job_validation/bitcoin_core_ipc.rs
fetched: 2026-06-24
path: 4
tags: [stratum-v2, job-declaration, jds, template-validation, share-validation]
---

# JDS template validation cost — amortized once per `DeclareMiningJob`

A common worry about Stratum V2's Job-Declaration path is that the
pool ends up validating a full template per share, making JD mode
much more expensive than Pool-mode validation. The sv2-apps JDS code
shows this is **not** the case.

## Validation lifecycle (jds/job_validation/bitcoin_core_ipc.rs)

The `DeclaredCustomJob` struct (lines ~58–80):

```rust
struct DeclaredCustomJob {
    ...
    validated: bool,  // flipped to true once Bitcoin Core IPC validates
}
```

The handler `handle_declare_mining_job` (line 425) is where the
expensive work happens:

1. Decode the declared `coinbase_tx` bytes into a
   `bitcoin::Transaction` (parsing cost only).
2. Validate it has exactly one coinbase-shaped input, output
   policy-compliant scripts, fee accounting matches.
3. (Eventually) call Bitcoin Core IPC `testblockvalidity`-equivalent
   over the full declared transaction set — `~tens of ms` for a
   ~1 MB / ~3000 tx block.
4. On success: store the validated tx set in the JD-server's state and
   set `validated: true`.

Once validated, every subsequent share that references the same job_id
is served from the cached job. The share path in
`pool-apps/pool/src/lib/channel_manager/mining_message_handler.rs:793`
is **identical** to non-JD mode:

```rust
let res = extended_channel.validate_share(msg.clone());
```

It does NOT re-validate the template.

## When does re-validation happen?

`handle_set_custom_mining_job` (line 664) is invoked by the *miner-side*
JD-client when it asks the pool to commit to a previously declared
template. The pool here:

- Reads `declared_custom_job.validated` (line 699). If false, error
  `ERROR_CODE_SET_CUSTOM_MINING_JOB_JOB_NOT_YET_VALIDATED` (the
  declared job is still being validated).
- Performs **cheap field-equality checks** between the
  `SetCustomMiningJob` message and the stored declared job:
  prev_hash, nbits, version, coinbase tx_version, coinbase prefix,
  input sequence (lines 723–800).
- Does NOT re-validate the tx set.

## Cost contribution to per-share path

Zero, in the steady-state. The only added per-share work in JD mode
vs Pool mode is:

- One field lookup to confirm `validated == true` (already in the
  hot path).
- A coinbase-version + prefix byte-compare (~10 ns).

## Where JD does cost more

- **Connection setup**: every JD-client first sends `DeclareMiningJob`
  + 1 round-trip to Bitcoin Core IPC `testblockvalidity` (≈10–50 ms),
  then `SetCustomMiningJob`. Adds ~tens of ms per re-declaration.
- **Re-declaration on every chain tip**: when prev_hash changes, all
  open JD jobs must be re-declared. So JD has a *throughput* cost
  proportional to (connections × block rate), not (connections ×
  share rate).
- **Memory**: JDS must retain the validated tx set per active job
  until it's superseded (~MB-scale per job, but amortized: typically
  one active per JD-client, sometimes few).

## Implication for the scale-test sim

The user's premise — that share-validation rate is the bottleneck —
applies the **same way** in JD-mode as in Pool-mode. Vardiff still
controls the share rate; template validation is once-per-template, not
once-per-share. The bottleneck shifts to **connection management and
the Bitcoin Core IPC channel for template re-validation on chain-tip
updates**, not to per-share work.

For 100k JD-mode connections, on every block:

- 100k `DeclareMiningJob` → JDS → Bitcoin Core IPC pipeline,
  each ~10–50 ms.
- Aggregate IPC bandwidth: 100k × ~1 MB template = ~100 GB/block.
- This is its own bottleneck, but it's **per-block** (~10/hour), not
  per-share (3,300/s).

## Files

- `/tmp/jds_ipc_validation.rs`
- `/tmp/jds_validation.rs`
