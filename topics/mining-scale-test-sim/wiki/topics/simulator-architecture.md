---
title: "Simulator architecture — recommended design"
type: topic
created: 2026-06-24
confidence: high
tags: [architecture, simulator, design, rust]
---

# Simulator architecture

Design synthesis across [[gimballock vardiff sim|gimballock]], [[connection scale bottlenecks|Path 2's connection ladder]], [[synthetic miner patterns|Path 3's miner patterns]], [[share validation cost model|Path 4's cost ledger]], and [[load harness landscape|Path 5's harness survey]]. Goal: characterize the connection-scale ceiling of a Stratum V2 pool by simulation.

## Top-level shape

```
┌──────────────────────────────────────────────────────────────────┐
│  Load host(s)                                                    │
│  ┌──────────────────────┐  ┌──────────────────────┐              │
│  │ tokio runtime        │  │ Control plane        │              │
│  │   N × SyntheticMiner │  │   NATS / Redis pubsub│              │
│  │   FuturesUnordered   │  │   ramp / fault inject│              │
│  │   K source-IP alias  │  │                      │              │
│  └─────────┬────────────┘  └──────────────────────┘              │
│            │                                                     │
│   noise-sv2/framing-sv2/codec-sv2/parsers-sv2 (SRI crates)       │
│            │                                                     │
│            ▼                                                     │
│   TCP × N (5-tuple uniqueness via K source IPs × 64k ports)      │
└────────────┬─────────────────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────────────────┐
│  Pool under test — real sv2-apps Pool + JD-server                │
│  + real channels_sv2::VardiffState (production Champion)         │
│  + mock-bitcoind (returns fixed gbt, OKs submitblock)            │
│  ├── prometheus exporter                                         │
│  ├── tokio-console / pprof / flamegraph hooks                    │
│  └── per-channel + per-shard locking instrumentation             │
└──────────────────────────────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────────────────┐
│  Aggregator                                                      │
│  prometheus / mimir + tokio-metrics                              │
│  metric registry mirrors gimballock's Metric trait shape         │
└──────────────────────────────────────────────────────────────────┘
```

## Three crate-level pieces

### 1. `scale-sim-harness` crate (new — own Cargo workspace)

Pattern: clone [[gimballock vardiff sim|gimballock's workspace shape]].

```
scale-sim-harness/
├── Cargo.toml
├── Cargo.lock                    # isolated; not in parent workspace
├── src/
│   ├── lib.rs
│   ├── miner.rs                  # SyntheticMiner trait + impls A-E
│   ├── driver.rs                 # FuturesUnordered fleet driver
│   ├── schedule.rs               # ConnectionSchedule (Hold/Ramp/Stall)
│   ├── grid.rs                   # (impl × N_conns × pattern) Cartesian
│   ├── trial.rs                  # one (cell, seed) → CellResult
│   ├── metrics.rs                # Metric trait + handshake_latency,
│   │                             # rss_per_conn, sched_wakeup_ns,
│   │                             # validation_cpu_us, lock_wait_ns
│   ├── rng.rs                    # XorShift64, paired seeding
│   ├── ifaddr.rs                 # K source-IP aliasing
│   └── bin/
│       ├── scale-sweep.rs        # `--connections 1k,10k,...,1M`
│       ├── ramp-storm.rs         # reconnect-storm sub-test
│       ├── trace-conn.rs         # single-connection reproducer
│       └── compare-pools.rs      # SRI vs ckpool vs Datum
├── baseline_SRI-SPM6.toml        # regression baselines per pool variant
├── baseline_SRI-SPM18.toml
├── baseline_ckpool-SPM18.toml
├── docs/
│   ├── DESIGN.md
│   ├── FINDINGS.md
│   └── METRIC_DERIVATION.md
└── .github/workflows/scale-sim.yaml
```

### 2. Pool-under-test instrumentation

Patches to `marafoundation/sv2-apps`:

- Per-channel `validate_share` timing histogram (Prometheus
  `validate_share_duration_seconds`)
- Per-shard lock-wait histogram (`share_lock_wait_seconds{shard=N}`)
- `share_accounting::flush_seen_shares` flush latency
- Active channel count gauge
- Per-channel SPM realized vs targeted

These are PR-able upstream — they're operationally useful, not just
test infra.

### 3. `mock-bitcoind`

Reuse p2poolv2's pattern verbatim — a Node.js (or Rust) stub that:
- Returns a fixed `getblocktemplate` on demand
- Returns `OK` to every `submitblock`
- Optionally introduces a configurable latency to simulate real
  Bitcoin Core IPC (relevant for the JD path's per-template validation
  cost)

Decouples the pool under test from chain state during load tests.

## The SyntheticMiner trait

```rust
#[async_trait]
trait SyntheticMiner: Send + 'static {
    /// Yield the next share to submit, or None to terminate.
    async fn next_share(&mut self) -> Option<SubmitSharesStandard<'static>>;

    /// Called when the pool sets a new vardiff target on us.
    fn on_set_target(&mut self, target: U256);

    /// Called when the pool dispatches a new job.
    fn on_new_job(&mut self, job: &NewMiningJob<'_>);

    /// Self-reported hashrate for SetupConnection / OpenStandardMiningChannel.
    fn hashrate_hps(&self) -> f64;
}
```

Concrete impls, one per [[synthetic miner patterns|pattern]]:

- `MockMiner` (Pattern A) — in-process, no network. For Tier-1 vardiff
  characterization (essentially gimballock's framework integrated here).
- `PoissonMiner` (Pattern B) — Poisson share arrival over real Noise +
  TCP. The default for Tier 1.
- `FixturePoissonMiner` (Pattern C) — PoissonMiner + fixture nonce
  table indexed by vardiff target. Real pool-side validation runs.
- `HybridMockValidationMiner` (Pattern D) — handshake real, pool skips
  validation via a feature flag. For Tier 2 scale.
- `RealCpuMiner` (Pattern E) — wraps `sv2-apps mining_device`. For
  small N control groups.

## Tiered driver plan

| Tier | N | Pattern mix | Hosts | Purpose |
|------|---|-------------|-------|---------|
| **1** | 10k | 100% `FixturePoissonMiner` | 1 | Full pool-side path under load |
| **2** | 100k | 99% `HybridMockValidationMiner` + 1% `FixturePoissonMiner` | 1-2 | Connection-layer scale + validation control group |
| **3** | 1M | Multi-host Tier-2 | 5-10 | Production-scale ceiling characterization |

## Grid shape

Replace [[gimballock vardiff sim|gimballock's]] `(algorithm ×
share_rate × scenario)` Cartesian with:

```
(pool_implementation, connection_count, workload_pattern, vardiff_spm)
```

- `pool_implementation ∈ {sv2-apps, ckpool, datum, ...}` — single-fixture comparison
- `connection_count ∈ {1k, 10k, 30k, 50k, 100k, 280k, 500k, 1M}` — primary axis
- `workload_pattern ∈ {steady, ramp_25, ramp_50, ramp_100, dropout_25, dropout_50, dropout_100}` — connection lifecycle scenarios
- `vardiff_spm ∈ {6, 18, 30}` — secondary policy axis

Per-cell: 1 trial (cells are expensive). Reuse the
`base_seed = 0xDEADBEEFCAFEF00D` paired-seeding pattern for any
per-cell sub-sampling.

## Metric registry

[[gimballock vardiff sim|gimballock's Metric trait]] shape, populated
with scale-test metrics:

| Metric | Category | Source |
|--------|----------|--------|
| `connections_established_per_sec` | Connection | client-side counter / sec |
| `handshake_latency_p50/p95/p99_ms` | Connection | client-side histogram |
| `pool_rss_mb` | Resource | pool's `/proc/self/status` |
| `pool_fd_count` | Resource | pool's `/proc/self/fd` |
| `tokio_sched_wakeup_ns` | Runtime | tokio-metrics |
| `validate_share_duration_us_p50/p99` | Pool | pool histogram |
| `share_lock_wait_us_p50/p99` | Pool | pool histogram |
| `accepted_share_throughput_per_sec` | Pool | pool counter / sec |
| `ramp_to_steady_state_seconds` | Behavioral | derived from SPM stability |
| `recovery_after_dropout_seconds` | Behavioral | derived |
| `bottleneck_stage` | Diagnostic | argmax over CPU% / lock-wait / kernel-buffer |

The `bottleneck_stage` metric is the headline — every cell reports
which stage is the binding constraint.

## Reproducibility (verbatim from [[gimballock vardiff sim|gimballock]])

- `base_seed = 0xDEADBEEFCAFEF00D`, per-trial seed `base_seed +
  (cell_index << 20) + trial_index`
- TOML baseline files committed; markdown for human review
- Slow regression test `#[ignore]`-d, run by CI via `cargo test --release
  --lib -- --ignored`
- Updates to baseline are intentionally manual — PR review gates
  algorithm-change-vs-regression
- `trace-conn` binary reproduces any single-trial failure

## What we don't control

- Real-world TCP RTT jitter from a globally distributed miner fleet —
  the simulator runs everyone over `localhost` or a tightly coupled
  test LAN. Acceptable: bottlenecks of interest are CPU / memory / fd
  / lock, not network distance.
- Real-world miner version diversity (firmware versions, vardiff
  start-diff guesses). Model as a workload-pattern axis if it ever
  matters.

## Out of scope (for v1)

- Multi-pool failover testing
- DDoS / adversarial-miner testing — orthogonal threat model
- Pool-to-pool relay testing (p2pool gossip mesh) — that's a separate
  topic
- Real Bitcoin Core integration — `mock-bitcoind` is sufficient for
  the bottleneck questions

## Next steps

1. **Build greenfield on `noise-sv2 + framing-sv2 + parsers-sv2`.**
   Round 2 closed the IanoNjuguna `PerformanceLoadTestSuite` fork
   decision: rewrite — see [[load harness landscape]]'s closed-lead
   section. Bake in `source_ips: Vec<IpAddr>` + `bind_device:
   Option<String>` on the config struct from day one to break
   through the 64k-port-per-IP wall.
2. **Add Criterion benches for `validate_share`** at
   `marafoundation/stratum :: sv2/channels-sv2/src/server/extended.rs:676`.
   Round 2 path B confirmed no per-share Criterion bench exists in
   either `sv2-apps` or `stratum`. `channels-sv2` has no
   `[dev-dependencies]` section, so adding Criterion is a single
   edit. The 5-20 µs/share number currently underpinning the
   1M-connection = ~2-cores prediction is **unmeasured**; this PR
   replaces a derivation with a measurement. Bench rows: job lookup,
   `merkle_root_from_path`, BIP-320 mask, target compare,
   `ShareAccounting` dup-check.
3. **Pin `tokio = "1.50"` or `>=1.52.2`** in the harness `Cargo.toml`
   — avoid 1.51.x and 1.52.0/1.52.1 (LIFO-slot-stealing regression
   tracked at tokio #8065, +8.5% CPU at microsecond handlers,
   reverted in 1.52.2). [[connection scale bottlenecks|Connection
   scale bottlenecks row 6]] has the detail.
4. Run noise-sv2 / framing-sv2 / parsers-sv2 criterion benches on
   target hardware to ground handshake-CPU and transport-throughput
   numbers (verifying SRI's published 178 µs step_1_responder on
   real hardware).
5. Stand up Tier 1 (10k single-host) with `FixturePoissonMiner` and
   real sv2-apps Pool + mock-bitcoind; baseline lock-wait and
   validate_share latency.
6. **Add `ramp_25 / ramp_50 / ramp_100` workload-pattern cells with
   `first_retarget_latency_ms` as a distinct metric.** Round 2
   path D measured the burst-storm: at burst-connect of N=100k
   S19-class miners, aggregate sps peaks at ~55.4 M for ~130 ms,
   ~385 cores of validation budget. The simulator must capture this
   storm phase as a distinct measurement, not collapse it into
   convergence_time.
7. Add `slow_warmup` and `mid_block_retarget_rejection` workload
   patterns documented in [[operational storm postmortems]].
8. Add per-shard lock-wait histograms to sv2-apps Pool (upstream PR).
9. Extend to Tier 2 (100k) and characterize the public-pool-style
   backpressure curve for SV2 in Rust.

## See also

- [[the bottleneck thesis]] — what this architecture is trying to verify
- [[gimballock vardiff sim]] — primary architectural reference
- [[connection scale bottlenecks]] — the Linux/kernel/network limits
- [[synthetic miner patterns]] — the trait's concrete impls
- [[share validation cost model]] — what pool-side instrumentation measures
- [[load harness landscape]] — alternative toolchains considered
