---
title: p2poolv2 JMeter + mock-bitcoind — fixture-nonce stratum load test
source_url: https://github.com/p2poolv2/p2poolv2/tree/main/load-tests/jmeter-testing
type: repos
ingested: 2026-06-24
quality: A
confidence: high
tags: [jmeter, fixture-nonce, mock-bitcoind, stratum-v1, load-test, p2poolv2, ckpool-comparison]
---

# p2poolv2 JMeter load test + mock-bitcoind — fixture-nonce stratum sim

Path: `load-tests/jmeter-testing/`. README has direct head-to-head
numbers vs CKPool at 100 / 1,000 / 5,000 concurrent miners.

## The architecture (three pieces)

1. **`stratum.jmx`** — JMeter test plan. Each thread is one fake miner.
2. **`mock-bitcoind/server.js`** — Node.js TCP server speaking
   bitcoind JSON-RPC. Returns the same `getblocktemplate` for every
   call. **Always returns success to `submitblock`**. Listens on port
   48332.
3. **`config-load-test.toml`** — points p2poolv2 (or ckpool) at the
   mock bitcoind.

## Mock bitcoind — the difficulty-1 fixture trick

```js
// Override difficulty to be extremely easy so every submit triggers
// submitblock, regardless of the enonce1 assigned by the stratum server.
gbt.bits = "2100ffff";
gbt.target = "ffff000000000000000000000000000000000000000000000000000000000000";
```

`bits = 0x2100ffff` ⇒ target ≈ 0xffff0000…0000. **Every nonce
satisfies it.** So:

- The stratum server can hand any miner any extranonce.
- The miner submits any fixed nonce.
- The pool's `validate_share` path executes fully on real bytes (so
  parsing, serialization, signature aren't skipped).
- The pool then calls `submitblock` on the mock bitcoind, which
  always returns success.

This is the **fixture-difficulty pattern**: don't precompute special
nonces, just lower the bar so any value is a winning share. End-to-
end real bytes, zero CPU per miner.

## The JMeter sampler — what each fake miner does

Per-thread Groovy script (extracted from `stratum.jmx`):

```groovy
// Subscribe
def socket = new Socket(host, port)
socket.setSoTimeout(30000)
writer.print('{"id":1,"method":"mining.subscribe","params":["jmeter/1.0"]}\n')
// drain notify, capture job_id

// Authorize
writer.print('{"id":2,"method":"mining.authorize","params":["tb1q...","x"]}\n')

// Loop forever (LoopController -1) with 3-second Timer
{
  // drain pending mining.notify to keep job_id fresh
  def submit = [
    id: 3, method: "mining.submit",
    params: ["tb1q...", jobId, "0000000000000000", "67b6f938", "f15f1590"]
  ]
  writer.print(submit.toString() + "\n")
  def response = reader.readLine()
}
```

Hardcoded fixed values:
- `extranonce2 = "0000000000000000"`
- `ntime       = "67b6f938"`
- `nonce       = "f15f1590"`

These work because the mock bitcoind's fixture target accepts
*everything*. **No real PoW**. The submit-loop just hammers the pool
once every 3 seconds.

## Published benchmark numbers

Test machine: AMD Ryzen 7 8745H (16 cores), 13 GB RAM, Arch Linux.

| Miners | Duration | Ramp | Server | Samples | Errors | Submit avg |
|-------:|---------:|-----:|--------|--------:|-------:|-----------:|
|    100 |     60 s |  10s | P2Poolv2 default | 1,977 |    0 | 1.3 ms |
|    100 |     60 s |  10s | CKPool           | 1,977 |    0 | 1.3 ms |
|  1,000 |     60 s |  10s | P2Poolv2 default | 19,452 |  42 (0.2%) | 0.4 ms |
|  1,000 |     60 s |  10s | CKPool           | 18,523 | 158 (0.9%) | 0.4 ms |
|  5,000 |    300 s |  90s | P2Poolv2 default | 432,710 |  0 | 0.3 ms |
|  5,000 |    300 s |  90s | CKPool           | 432,694 | 112,865 (27% on submit, stale-jobid races) | 0.4 ms |

**Submit latency is ~sub-millisecond at 5k miners** with zero errors
in P2Poolv2. CKPool's single-threaded accept loop is slower under
concurrent connection storms; the 27% submit errors at 5k are
stale-jobid races (some submits race with new `mining.notify` between
the drain and the send).

## Headline observation for scale-test sim

At a 3-second-per-share submit rate, **5,000 connections is a
solved problem at sub-millisecond latency on a 16-core box**. The
interesting work begins at 50k–500k connections, where the JMeter
JVM thread model starts to dominate the cost and you'd want to move
to a Rust/Go async client (see k6, vegeta, or a custom tokio-based
SyntheticMiner).

## Limitations of this approach

- **JMeter threads = OS threads (Java)**: scaling to 100k miners on
  a single host hits the JVM thread limit. The 5k mark is roughly
  where this design tops out per machine.
- **No vardiff convergence test**: the mock returns the same
  template forever, never increments difficulty. So this isn't a
  closed-loop ASERT/vardiff test — it's a pure stratum-server
  throughput / concurrency stress test.
- **No real share-rate control**: the 3-second timer is constant
  across all threads. Per-miner Poisson rate variance and per-miner
  hashrate are not modeled.
- **SV1 only**: doesn't exercise the Noise handshake, frame
  encryption, or the SV2 binary frame parser — which are the
  expensive parts of an SV2 pool's per-connection cost.

## What this benchmark *does* prove

- P2Poolv2's async tokio runtime handles connection storms
  qualitatively better than CKPool's single-threaded accept loop.
- The fixture-target pattern is sufficient to exercise the
  submitblock → bitcoind path without a real chain.
- 5k concurrent connections is a baseline minimum any production
  pool implementation should clear.
