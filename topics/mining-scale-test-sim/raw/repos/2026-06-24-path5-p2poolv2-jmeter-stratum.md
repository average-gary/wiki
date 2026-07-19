---
title: "p2poolv2/p2poolv2 :: load-tests/jmeter-testing — JMeter Stratum V1 load harness"
type: raw-source
source_kind: repo
source_url: https://github.com/p2poolv2/p2poolv2/tree/main/load-tests/jmeter-testing
fetched: 2026-06-24
path: 5
relevance: high
---

# p2poolv2 JMeter Stratum load test

Tree (recursive listing via `gh api .../git/trees/main?recursive=1`):

```
load-tests/jmeter-testing/.gitignore
load-tests/jmeter-testing/README.adoc
load-tests/jmeter-testing/benchmark.sh
load-tests/jmeter-testing/ckpool-signet-solo.json
load-tests/jmeter-testing/ckpool-testnet4-solo.json
load-tests/jmeter-testing/config-load-test.toml
load-tests/jmeter-testing/flamegraph-README.adoc
load-tests/jmeter-testing/flamegraph.sh
load-tests/jmeter-testing/mock-bitcoind/{server.js, package.json, README.md, .nvmrc}
load-tests/jmeter-testing/run_jmeter.sh
load-tests/jmeter-testing/run_remote_load.sh
load-tests/jmeter-testing/stratum.jmx
load-tests/sim/{run-swarm.sh, stop-swarm.sh, observe.sh, metrics.sh, nightly.sh, plot-metrics.{py,sh}}
load-tests/diagnosis/{p2pool_diagnose.sh, tcp-monitor.sh, .gitignore}
```

## What stratum.jmx actually does

`stratum.jmx` (11 KB) is a 5-step plan, with three Groovy JSR223Samplers
driving a raw `java.net.Socket` to port 3333. Sequence:

1. **Subscribe Sampler** — opens `Socket(host, port)`, writes
   `{"id":1,"method":"mining.subscribe","params":["jmeter/1.0"]}\n`,
   reads response line. Stashes `socket/reader/writer` in JMeter `vars`.
2. **Authorize Sampler** — writes
   `{"id":2,"method":"mining.authorize","params":["tb1q…","x"]}\n`,
   reads until it sees `id=2`. Drains `mining.notify` messages and captures
   `jobId`.
3. **Submit Loop** — `LoopController` with `loops=-1`, `ConstantTimer`
   `delay=3000` ms. Inside the loop, **Submit Sampler** drains notifies, then
   writes a `mining.submit` JSON and times the round-trip.

Default thread group sizing (parametrized via `${__P(...)}`):
- `num_threads = 5000` miners
- `ramp_time = 60` s
- `duration = 300` s
- `delay = 3000` ms between submits per thread

## Protocol

**Stratum V1 (JSON-RPC over plaintext TCP)**, not V2. No Noise, no
length-prefixed binary frames. Each "miner" is a JMeter thread (Java thread,
blocking socket I/O — not a true async harness). 5000 threads on a 16-core /
13 GB Ryzen 7 8745H is what the README benchmarks reach reliably.

## Reported results

```
100 miners,  60 s:     subscribe p50=103ms p99=450ms,  submit p50=1ms   p99=3ms
1,000 miners, 60 s:    subscribe p50=102ms p99=30030ms,  errors ~ 42  (0.2%)
5,000 miners, 300 s:   subscribe p50=101ms p99=112ms,  errors 0/432K   (p2poolv2)
                                                       errors 27% on submit (ckpool — stale job IDs)
```

Subscribe-storm errors at 1,000 miners with a 10 s ramp-up show the
single-threaded-accept bottleneck on CKPool, not on p2poolv2 (async tokio).
At 5,000 miners with a 90 s ramp-up, both behave fine.

## Mock bitcoind

`mock-bitcoind/server.js` (Node) responds to `getblocktemplate` with a fixed
template and `submitblock` with success. This decouples scale-test from
real PoW / regtest plumbing.

## Distributed runner — `run_remote_load.sh`

Standalone single-host JMeter launcher pointing at a remote stratum server
(`--host`, `--port`, `--threads`, `--ramp`, `--duration`, `--delay`). **No
JMeter master/slave coordination** wired up — you'd have to roll that
yourself if you wanted to multi-host.

## What does NOT transfer to SV2

1. **SV1 only.** No Noise handshake; no binary length-prefixed framing.
   The Groovy JSR223 samplers `writer.print(jsonString + "\n")` are not
   reusable for SV2.
2. **Blocking Java threads.** 5,000 threads ≈ 5,000 OS threads with stacks;
   that's fine on a 13 GB host but won't get to 100k without rewriting on
   Netty / virtual threads (Loom).
3. **No share-rate model.** Hard-coded `delay = 3000 ms` per thread. No
   vardiff / Poisson share arrival — every miner submits every 3 s.
4. **No distributed coordination.** `run_remote_load.sh` is single-source.

## What DOES transfer

- The **mock-bitcoind** pattern (fixed `getblocktemplate` + always-OK
  `submitblock`) is directly reusable for SV2 — decouples PoW from scale.
- The **A/B benchmark script** (`benchmark.sh`) running default + native +
  CKPool variants and printing percentile tables is a good template for
  SV2 vs SRI-pool-server vs Datum comparisons.
- The **flamegraph.sh** companion (perf record over the server during the
  load test) is reusable — orthogonal to the protocol.

## Sibling: load-tests/sim/run-swarm.sh

Different harness. This is a **p2pool node swarm** (libp2p p2p traffic, not
miner connections): launches N `p2poolv2_sim` binaries with distinct ports,
distinct payout addresses, zipf-distributed hashrate, latency spread, against
one shared regtest bitcoind. Builds with `--features sim` (must never ship in
release). This is the *Phase 2 swarm harness*, not the *connection-scale
harness* — different bottleneck.
