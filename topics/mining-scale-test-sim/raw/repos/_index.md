---
title: raw/repos
---

# raw/repos

- [2026-06-24-path1-gimballock-vardiff-sim-overview.md](2026-06-24-path1-gimballock-vardiff-sim-overview.md) — overview of gimballock's `vardiff/simulation-framework` branch, ~52-commit narrative arc, branch structure, and how the sim relates to a connection-scale harness
- [2026-06-24-path1-gimballock-sim-crate-layout.md](2026-06-24-path1-gimballock-sim-crate-layout.md) — `vardiff_sim` crate layout: Cargo.toml, lib.rs public API, composed/grid/trial/schedule/metrics/rng modules, ~46 binaries inventoried, reusable patterns for connection-scale
- [2026-06-24-path1-gimballock-sv2apps-deploy.md](2026-06-24-path1-gimballock-sv2apps-deploy.md) — sv2-apps `test/vardiff-simulation-framework` deploy branch: pins stratum-core for hardware validation on an Antminer S21; carries no algorithm logic; documents the sim-to-hardware loop
- [2026-06-24-path5-tag1consulting-goose.md](2026-06-24-path5-tag1consulting-goose.md) — Goose Rust async load framework: reqwest-bound for HTTP but ships `examples/tcp_loadtest.rs` showing raw-TCP via `record_custom_request`; Gaggle distributed mode REMOVED in 0.17.0
- [2026-06-24-path5-p2poolv2-jmeter-stratum.md](2026-06-24-path5-p2poolv2-jmeter-stratum.md) — p2poolv2's `load-tests/jmeter-testing/stratum.jmx`: Stratum **V1** JMeter Groovy harness, 5k threads × 3s submit, mock-bitcoind, no Noise/binary framing — architecture does NOT transfer to SV2
- [2026-06-24-path5-emqx-emqtt-bench.md](2026-06-24-path5-emqx-emqtt-bench.md) — emqtt-bench Erlang MQTT v5 harness; "tuned for millions of connections"; `--ifaddr a,b,c,d` multi-source-IP trick directly applicable to SV2 to bypass 64k ephemeral-port limit
- [2026-06-24-path5-stratum-mining-noise-sv2.md](2026-06-24-path5-stratum-mining-noise-sv2.md) — SRI's `noise_sv2 = 1.4.2` crate: pure-crypto state machine, no I/O, embeddable in any tokio/smol/mio harness; ~1-3 ms handshake CPU cost confirms ramp-up CPU saturates first
- [2026-06-24-path5-locust-custom-protocols.md](2026-06-24-path5-locust-custom-protocols.md) — Locust's documented custom-protocol path (User subclass, gevent monkey-patching constraint, ZMQ master/worker — gold-standard distributed reference, but per-host scale is lowest)
- [2026-06-24-path5-IanoNjuguna-sv2-tools-load-suite.md](2026-06-24-path5-IanoNjuguna-sv2-tools-load-suite.md) — existing Rust `PerformanceLoadTestSuite` for SV2 (max 1,200 concurrent in demos — correctness band, not scale band); useful for `LoadTestConfig` field shape
- [2026-06-24-r2-pathA-stratum-v2-tools-load-suite.md](2026-06-24-r2-pathA-stratum-v2-tools-load-suite.md) — round-2 deep-read of `sv2-test/src/performance_load_tests.rs` (852 lines, commit `f4b9bd90`): 100% MOCK — `establish_mock_connection` is `tokio::sleep`, `translate_sv1_to_sv2` returns a hard-coded literal, no `TcpStream`, no Noise, no source-IP aliasing. Repo is unlicensed, 1-contributor, 8-months idle. **Decision: rewrite (load suite is wrong shape).**

## Path-3 (synthetic-miner methodology) — 2026-06-24

- [2026-06-24-path3-p2poolv2-sim-emitter.md](2026-06-24-path3-p2poolv2-sim-emitter.md) — p2poolv2's `SimEmitter`: closed-loop Poisson share generation with `mean = D · 2^32 / H`, exponential inter-share intervals, Bernoulli block-find, fully-tested math module. Canonical Rust reference for in-process Pattern B.
- [2026-06-24-path3-p2poolv2-run-swarm.md](2026-06-24-path3-p2poolv2-run-swarm.md) — `load-tests/sim/run-swarm.sh`: heterogeneous swarm orchestrator with Zipf hashrate distribution (preserves total network hashrate), log-uniform latency spread, ASERT anchor for steady-state genesis difficulty, reproducible seeding
- [2026-06-24-path3-gimballock-composed-trial.md](2026-06-24-path3-gimballock-composed-trial.md) — gimballock's `Composed<E, B, U>` adapter + `run_trial` per-tick bulk-Poisson driver (10–1000× faster than per-share sampling). Strict in-process algorithm characterization; reuses production `Composed` from `channels-sv2`.
- [2026-06-24-path3-sv2-apps-mining-device.md](2026-06-24-path3-sv2-apps-mining-device.md) — sv2-apps `mining_device` real-CPU SV2 client with `FastSha256d` midstate hasher. `handicap`/`nominal_hashrate_multiplier` knobs, but Pattern E — does not scale past ~10 miners per host.
- [2026-06-24-path3-p2poolv2-jmeter-fixture.md](2026-06-24-path3-p2poolv2-jmeter-fixture.md) — `load-tests/jmeter-testing/` + mock-bitcoind: SV1 fixture-difficulty trick (`bits=0x2100ffff`, target ≈ all-Fs). Published 5k miners at sub-ms submit latency on 16 cores vs CKPool's 27% submit errors at the same scale.
- [2026-06-24-path3-cpuminer-multi-benchmark.md](2026-06-24-path3-cpuminer-multi-benchmark.md) — `cpuminer-multi --benchmark`: pure CPU microbench, no network, no submission, `target=0`. Irrelevant for scale-test; useful only as a per-core hashrate oracle.

## Path-4 (share-validation cost model) — 2026-06-24

- [2026-06-24-path4-ckpool-stratifier-submission-diff.md](2026-06-24-path4-ckpool-stratifier-submission-diff.md) — ckpool's canonical SV1 share-validation path: `submission_diff`, `new_share`, vardiff target ratio (drr=0.3), mindiff=1 / startdiff=42 defaults, share-table aging on workbase roll
- [2026-06-24-path4-sri-sv2-share-validation.md](2026-06-24-path4-sri-sv2-share-validation.md) — SRI `ExtendedChannel::validate_share`, `ShareAccounting::seen_shares` flush-on-tip, classic vardiff thresholds (15–60% deltas tied to elapsed time)
- [2026-06-24-path4-sv2-apps-pool-config-defaults.md](2026-06-24-path4-sv2-apps-pool-config-defaults.md) — Mara sv2-apps Pool defaults (`shares_per_minute = 6.0`, `share_batch_size = 10`)
- [2026-06-24-path4-jds-template-validation-amortized.md](2026-06-24-path4-jds-template-validation-amortized.md) — JDS validates templates ONCE on `DeclareMiningJob`, NOT per-share; per-share path in JD mode is identical to Pool mode

## Round-2 path-B (sv2-apps + stratum bench inventory) — 2026-06-24

- [2026-06-24-r2-pathB-sv2apps-integration-benches.md](2026-06-24-r2-pathB-sv2apps-integration-benches.md) — sv2-apps `integration-tests/benches/` is exactly 3 Criterion benches, all of the miner-side FastSha256d hasher (hasher / microbatch / scaling). **No per-share Criterion bench exists.** Cargo comment marks the benches as deprecation-pending alongside the embedded `mining_device` module.
- [2026-06-24-r2-pathB-stratum-benches-inventory.md](2026-06-24-r2-pathB-stratum-benches-inventory.md) — `marafoundation/stratum` SV2 bench tree: buffer-sv2, codec-sv2, framing-sv2, noise-sv2 are benched; `channels-sv2` (which owns `ExtendedChannel::validate_share`) has NO `benches/` directory. SRI benches cover the wire/framing/handshake layer only.
