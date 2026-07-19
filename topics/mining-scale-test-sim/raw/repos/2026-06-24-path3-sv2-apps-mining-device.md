---
title: sv2-apps mining_device — real-CPU SV2 mining client (with throttle)
source_url: https://github.com/marafoundation/sv2-apps/blob/mara/integration-tests/lib/mining_device/mod.rs
type: repos
ingested: 2026-06-24
quality: B+
confidence: high
tags: [sv2, mining-device, fastsha256d, real-cpu, integration-test, handicap, noise]
---

# sv2-apps `mining_device` — real-CPU SV2 mining client

Path: `integration-tests/lib/mining_device/mod.rs` on the `mara`
branch of `marafoundation/sv2-apps`. Used by the SV2 integration
tests as a "real" mining-device-side counterparty to the pool.

## What it is

A **real CPU miner** speaking SV2 over Noise. It:
1. Opens a real TCP connection to a pool address
2. Performs the Noise handshake (`HandshakeRole::Initiator`)
3. Sends `SetupConnection`
4. Calls `measure_hashrate(5, handicap)` — runs all worker threads
   for 5 sec to **actually benchmark CPU SHA256d hashrate**
5. Sends `OpenStandardMiningChannel { nominal_hash_rate: measured }`
6. Spawns `worker_count()` mining threads that brute-force SHA256d
   the block header
7. When a share is found, sends `SubmitSharesStandard`

This is **not a synthetic miner** in the simulator sense — it really
hashes. The mining loop:

```rust
pub fn next_share(&mut self) -> NextShareOutcome {
    let hash = if let Some(fast) = &mut self.fast_hasher {
        fast.hash_with_nonce_time(header.nonce, header.time)
    } else {
        header.block_hash().to_raw_hash().to_byte_array()
    };
    // Compare hash to target in big-endian-word order.
    if hash_meets_target_le(&hash, &target.to_little_endian()) {
        NextShareOutcome::ValidShare
    } else {
        NextShareOutcome::InvalidShare
    }
}
```

## FastSha256d — the midstate optimization

```rust
pub struct FastSha256d {
    state0: [u32; 8],                     // midstate after first 64 bytes
    block1: GenericArray<u8, U64>,        // last 16 bytes + padding
    second_block: GenericArray<u8, U64>,  // reusable second SHA256 input
}
```

Precomputes the first SHA256 chunk (the static 64 bytes: version +
prev_blockhash + first 28 bytes of merkle_root). Per nonce attempt,
only `time` (bytes 4..8 of block1) and `nonce` (bytes 12..16) change.
Then a second `compress256` finishes the first SHA256, and a third
`compress256` does the outer SHA256 of the digest. Avoids hashing the
static header bytes on every attempt.

This is a real optimization — but the optimized rate is still
~100 KH/s/core (compared to a real ASIC at ~100 TH/s), so 1 core
mining at handicap=0 is a 9-order-of-magnitude underbid versus
production.

## The `handicap` and `nominal_hashrate_multiplier` knobs

```rust
pub async fn connect(
    address: String, pub_key: ...,
    device_id: Option<String>,
    user_id: Option<String>,
    handicap: u32,                                 // !! sleep between attempts
    nominal_hashrate_multiplier: Option<f32>,      // lie to the pool
    single_submit: bool,
) { ... }
```

- `handicap` — the worker thread sleeps for this many microseconds
  every `nonces_per_call` attempts. **This is how you slow a real
  miner to a target rate.** It's effective but wasteful: you're
  still spinning the CPU.
- `nominal_hashrate_multiplier` — applied to the measured rate
  before `OpenStandardMiningChannel.nominal_hash_rate`, which is
  what vardiff anchors initial difficulty to. **This is the lever
  that lets the pool quote a fake difficulty without the miner
  having to actually deliver it.**
- `single_submit` — exit after one share. Useful for one-shot
  integration tests.

## Connection-scale cost in this design

Each mining_device task holds:
- 1 TcpStream
- 1 Noise codec (decrypt/encrypt buffers, two 32-byte chacha keys)
- 1 `Arc<Mutex<Miner>>` with header, target, fast_hasher
- 1 `Arc<Mutex<Device>>` with channel_id, job tracking
- 1 `Arc<Mutex<SetupConnectionHandler>>`
- Several async channels (incoming, outgoing, share-found, notify)
- `worker_count()` OS threads doing SHA256d (defaults to N-1 cores)

Note: **OS threads per miner**. That's fine for 1–10 simulated
devices, but for 10k+ you'd need to invert: one shared thread pool
that consumes from a queue of "miners to advance", not one pool per
device. The current design pins this to "one or a few miners as test
counterparties".

## Where this is appropriate

- **Correctness tests** that need the pool to see real-PoW shares
  with valid hashes against the channel's target. The synthetic-
  Poisson emitter pattern can't do this: the pool *would* reject the
  share at validate-shares-step if validation is strict.
- **Vardiff integration tests** — set `nominal_hashrate_multiplier`
  to coax the initial difficulty into a range you can actually hit
  with a CPU, then watch the algorithm converge.
- **End-to-end Noise + SV2 framing** correctness.

## Where this is NOT appropriate (the gap)

- **Connection-scale tests**. 10k of these would burn 10k cores. The
  whole topic of `mining-scale-test-sim` exists because this pattern
  doesn't scale.
- For scale-testing, replace `Miner::next_share` (the real hash
  comparison) with a Poisson-sleep + fixture-nonce path, while
  keeping the SV2 framing / Noise / connection state intact.
- This is the "**hybrid pattern**" the prompt called out: keep the
  network surface real, replace the work with simulated emission.

## Reuse model for connection-scale

Take `mining_device::Device` (the SV2 connection state machine) and
swap the work-finding worker thread for a `SimEmitter`-style async
task that:

1. On `SetTarget` / `NewMiningJob`, computes mean share interval
   from `(target_difficulty, nominal_hashrate)`.
2. `tokio::time::sleep` an exponential draw.
3. Optionally picks a precomputed fixture nonce that the pool's
   validate-share will accept (if pool target is set low enough).
4. Sends `SubmitSharesStandard` over the existing Noise+TCP
   connection.

This way you reuse all the connection state, Noise handshake, and
SV2 framing code, but per-miner CPU cost is ~zero between sleeps.
The bottleneck moves to the pool's connection layer (correct: that's
the layer we want to scale-test).
