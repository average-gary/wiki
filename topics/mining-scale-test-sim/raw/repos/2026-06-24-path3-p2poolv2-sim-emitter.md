---
title: p2poolv2 sim emitter — closed-loop Poisson share generation
source_url: https://github.com/p2poolv2/p2poolv2/blob/main/p2poolv2_lib/src/sim/emitter.rs
type: repos
ingested: 2026-06-24
quality: A
confidence: high
tags: [synthetic-miner, poisson, share-emission, p2poolv2, asert, rust, async]
---

# p2poolv2 `SimEmitter` — synthetic miner as closed-loop Poisson process

Module: `p2poolv2_lib::sim::emitter::SimEmitter`. Companion modules:
`sim::timing` (math), `sim::share` (build payload), `sim::blockfind`
(rare block submission), `sim::mod`. All gated behind the `sim` Cargo
feature so it never ships in release builds. Binary entry point:
`p2poolv2_sim` (separate crate, `p2poolv2_sim/src/main.rs`).

## Core idea

One `SimEmitter` task models **one miner of hashrate H (hashes/sec)**.
Instead of brute-force hashing, it sleeps for an
exponentially-distributed interval and then submits a synthetic share
that goes through the pool's full share-organise / ASERT-difficulty
path. When ASERT raises difficulty, the sleep interval grows
mechanically and the emitter slows on its own — so the difficulty
controller itself is genuinely under test, not bypassed.

## Mean inter-share interval (the load formula)

```rust
const HASHES_PER_DIFFICULTY_1: f64 = 4_294_967_296.0; // 2^32

pub fn mean_share_interval_secs(pool_difficulty: f64, hashrate_hps: f64) -> f64 {
    difficulty * HASHES_PER_DIFFICULTY_1 / hashrate_hps
}
```

Confirms the prompt's formula. Equivalently:
`shares/sec = hashrate / (difficulty * 2^32)`.

Sanity numbers from the in-crate tests:
- 1 TH/s, diff 1 → mean interval `2^32 / 1e12` ≈ **4.3 ms**.
- Doubling difficulty doubles the interval.
- Doubling hashrate halves it.

## Exponential draw (inverse-transform)

```rust
pub fn sample_exponential_secs<R: Rng + ?Sized>(mean_secs: f64, rng: &mut R) -> f64 {
    let u: f64 = rng.gen_range(0.0..1.0);  // [0, 1)
    -mean_secs * (1.0 - u).ln()            // (1-u) so ln arg is in (0, 1], never zero
}
```

Test covers convergence of mean over 200k samples to within 3%.

## Block-find as Bernoulli draw (NOT header hash)

```rust
pub fn block_find_probability(block_to_share_ratio: u64) -> f64 { 1.0 / ratio as f64 }
pub fn is_block_find<R: Rng>(probability: f64, rng: &mut R) -> bool { ... }
```

**Critical detail in their design doc**: do NOT use header hashing for
block-find — on regtest the genesis target is so trivial that ~50% of
random nonces would "win" a block, blowing up the chain. Bernoulli
draw is O(1) and decouples block-find rate from a meaningless regtest
target.

When a block-find draws true, the emitter submits a real regtest block
via bitcoind RPC (`submit_sim_block`). The coinbase carries the real
PPLNS payout for accounting correctness; only the nonce-grind is
skipped (regtest accepts any nonce against its trivial target).

## Run loop (cleaned-up shape)

```rust
pub async fn run(mut self) {
    let mut rng = StdRng::seed_from_u64(seed);
    let p_block = block_find_probability(self.config.block_to_share_ratio);
    loop {
        // Get the latest prepared template (same watch channel real
        // stratum connections subscribe to). Wait on `changed()` if none.
        let prepared = match self.template_rx.borrow().clone() {
            Some(p) => p,
            None => { self.template_rx.changed().await?; continue; }
        };

        // Pace: sleep an exponential interval sized by current ASERT difficulty.
        let difficulty = difficulty_from_bits(prepared.bits());
        let mean = mean_share_interval_secs(difficulty, self.config.hashrate);
        let secs = sample_exponential_secs(mean, &mut rng);
        tokio::time::sleep(Duration::from_secs_f64(secs)).await;

        // Re-read latest template (tip may have advanced while sleeping).
        let prepared = self.template_rx.borrow().clone()?;
        // ... build share via build_sim_emission(...) ...
        let is_block = is_block_find(p_block, &mut rng);
        self.emissions_tx.send(built.emission).await?;
        if is_block { submit_sim_block(...).await; }
    }
}
```

## Seed-determinism

Every emitter takes `seed: u64` from config. `run-swarm.sh` passes
`seed = i + 1` so node `i`'s share timeline is reproducible. Combined
with reproducible Zipf weights (also seeded by `DIST_SEED`), the whole
swarm trajectory is replayable from the swarm config.

## Per-emitter cost profile

- **One tokio task** per miner (lightweight green-thread, ~few KB).
- **One watch::Receiver** clone of the prepared-template channel
  (shared underlying storage, ~pointer cost per subscriber).
- **Shared `EmissionSender` / `EmissionReceiver`** channel that all
  emitters fan into — the pool's organise loop reads from there.
- **One StdRng** state (~32 bytes).
- **One JobTracker actor** is started *per emitter* (`start_tracker_actor()`)
  — this is the inefficient part if you wanted to scale to 100k+
  emitters; could be unified.

## What this is good for

- **Vardiff / ASERT under closed-loop load** — emission rate
  automatically slows when ASERT raises difficulty, so the controller
  loop is exercised end-to-end.
- **Multi-miner shape effects** — Zipf hashrate distribution
  (`run-swarm.sh` builds power-law-weighted hashrate splits while
  preserving total network hashrate).
- **Reproducibility** — `(config, schedule, seed)` → byte-identical
  share timeline.
- **End-to-end coverage of validate → organise → store → notify** —
  the share is real bytes built via `build_sim_emission`.

## What this is NOT good for

- **Network / connection layer**: emitter is in-process. It does NOT
  exercise the stratum-server TCP / Noise / framing path. For that
  use a separate harness (gimballock + sv2-apps integration tests, or
  the JMeter load test).
- **TH/s rates over many miners** in tight loops: at 1 TH/s diff-1
  the mean interval is 4.3 ms; tokio can handle that, but in a 100k-
  emitter swarm on a single host you'll burn ~23 M wakeups/sec on the
  scheduler if difficulty stays at 1. Production scale-test pushes
  ASERT to raise difficulty so the steady-state rate stabilizes.
