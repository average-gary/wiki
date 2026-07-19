---
title: "Load-harness landscape — what tool drives N synthetic SV2 connections"
type: concept
created: 2026-06-24
confidence: high
tags: [load-test, harness, goose, locust, jmeter, emqtt-bench]
---

# Load-harness landscape

## Three buckets

| Bucket | Tools | Verdict for SV2 |
|--------|-------|-----------------|
| **HTTP-only** | wrk, wrk2, oha, drill, vegeta | **Unusable** — no protocol flexibility |
| **HTTP-first + extension paths** | Gatling, JMeter, Locust, Goose, k6 | **Workable but costly** — all extend, none speak SV2 natively |
| **Protocol-specific / generic-async** | emqtt-bench, tcpkali, Tsung | **Closest analogs** — purpose-built for stateful binary persistent connections |

## The HTTP-first bucket assessed

- **JMeter** — Groovy JSR223 + raw `java.net.Socket`. What
  [[synthetic miner patterns|p2poolv2 used for Stratum V1]]. Blocking
  Java thread per miner caps ~5,000 miners per host. No Noise, no
  binary framing helpers.
- **Locust (Python)** — `User` subclass + custom Client. gevent
  constraint means Rust-backed Noise via PyO3 would block greenlets.
  ~1,000–5,000 users per worker. Master/worker model is clean.
- **Goose (Rust)** — reqwest-bound for HTTP, but ships an
  `examples/tcp_loadtest.rs` pattern showing how to drive raw TCP via
  `GooseUser::record_custom_request("TCP", …)`. Tokio runtime.
  **Gaggle (distributed mode) was removed in 0.17.0** (PR #529); pin
  0.16.4 or DIY distributed coordination.
- **k6 (Go)** — `xk6-tcp` extension exists; you'd write SV2 in Go. No
  open-source xk6-sv2.
- **Gatling (Scala)** — theoretically extensible; no published SV2
  plugin.

## The protocol-specific bucket

- **emqtt-bench (Erlang)** — purpose-built for MQTT scale (a stateful
  binary persistent-connection protocol — directly analogous to SV2).
  "Tuned for millions of connections." Multi-source-IP via
  `--ifaddr 10.0.0.10,10.0.0.11,...`. **The closest off-the-shelf
  prior art.** Patterns transfer; the protocol does not.
- **tcpkali (C)** — multi-core TCP/WS load gen with scripted byte
  sequences. ~50k conn/host. No per-connection state machine for
  handshakes. Useful as a sub-component.
- **Tsung (Erlang)** — XMPP / PgSQL / HTTP + XML-plugin custom
  protocols. Controller + slave-nodes. Million-conn scale. Erlang
  toolchain barrier for most teams.

## The pure-Rust async option (recommended)

`noise-sv2 + framing-sv2 + codec-sv2 + parsers-sv2` are standalone
reusable crates in SRI. Each is pure-state-machine, no I/O — wrap any
tokio TcpStream. So the simplest harness is:

```rust
tokio::spawn(synthetic_miner(
    miner_idx, target, source_ip, rng_seed,
    config.clone(),
)).await
```

× N, scheduled by `tokio::runtime::Runtime` with the default
work-stealing scheduler. ~600-1200 lines of Rust gets you:

- CLI shape modeled on emqtt-bench (`--connections N --rate R/s
  --ifaddr a,b,c,d --target host:port --duration 300s`)
- OpenTelemetry / Prometheus metric export
- Per-miner Poisson share submission (see [[synthetic miner patterns]])

### Goose-on-top alternative

Reasonable if you want CLI / scheduler / HTML reports / coordinated-omission-mitigation
for free. But the protocol code you write is identical to the
custom-Rust path, and you lose distributed mode (Gaggle removed). Not
much net win.

## Single-host connection ceiling

- **Linux default** `ip_local_port_range = 32768-60999` → ~28k usable.
- **Tuned**: `net.ipv4.ip_local_port_range='1025 65534'` + `ulimit -n
  200000` → ~64k.
- **Multi-source-IP multiplier**: K source IPs × 64k → K × 64k. 5-tuple
  uniqueness is the actual constraint. emqtt-bench's `--ifaddr` pattern
  is the canonical example.
- **Memory ceiling**: ~16-32 KB kernel buffers × N. 1M conns × 32 KB =
  32 GB just for kernel. Practical 1M-per-host needs 64 GB+ box with
  `net.core.{r,w}mem_default` tuned down.
- **conntrack**: `nf_conntrack_max ≥ 4 × N` if enabled; better to
  disable on a load host.
- **CPU during ramp-up**: noise-sv2 handshake = 1-3 ms/core (secp256k1
  keygen + ECDH + Schnorr verify). A 16-core host = ~5-15k
  handshakes/sec ramp ceiling.

**Realistic per-host ceiling**: **100k-500k persistent SV2 connections
on a tuned 32-core / 64 GB host with 5-10 source IPs.** 1M is
achievable but at that point you're better off going to 4-10 hosts.

## Distributed coordination

| Option | Status |
|--------|--------|
| Locust master + N ZMQ workers | Canonical reference |
| Goose Gaggle (nng + CBOR) | **Removed in 0.17.0**; pin 0.16.4 or DIY |
| k6 Operator on Kubernetes | Modern alternative — N k6 pods, aggregate via Prometheus |
| Custom: NATS or Redis pubsub for control plane | Simplest for a custom Rust harness — ~100 LOC |
| OpenTelemetry OTLP for metrics → Prometheus/Mimir | Cleanest aggregation pattern |

## Metrics

OpenTelemetry OTLP from each load-host process to a single
Prometheus/Mimir is the cleanest. `tokio + tracing + opentelemetry-otlp`
integrates well. Standard counters:

- `connections_established` (counter)
- `handshake_duration_ms` (histogram)
- `channel_open_duration_ms` (histogram)
- `shares_submitted` (counter)
- `shares_accepted` (counter)
- `connection_errors{kind=...}` (counter, labeled)

## p2poolv2 JMeter assessment

**What it is**: 274-line `stratum.jmx` running 5,000 Java threads,
each opening a blocking `java.net.Socket` to port 3333. Three Groovy
JSR223 samplers: Subscribe → Authorize → Submit-loop (3000 ms delay).
Backed by Node.js mock-bitcoind that always returns the same
`getblocktemplate` and OKs every `submitblock`.

**What works for SV2**:
- mock-bitcoind pattern (fixed template, OK-everything submitblock) →
  reusable
- benchmark.sh A/B harness comparing default / native / CKPool variants
  → template applicable for SV2 vs SRI-pool vs Datum
- flamegraph.sh server-side perf companion → orthogonal to protocol, fully
  reusable

**What does NOT transfer**:
- Stratum V1 plaintext JSON — no Noise, no length-prefixed binary
- Blocking Java thread = 1 miner — caps ~5-10k per host
- Hard-coded 3000 ms delay — no Poisson / vardiff
- `run_remote_load.sh` is single-source; no JMeter master/slave wired

**Verdict**: Good SV1 fixture, wrong tool for SV2 scale. Build the Rust
harness; port the mock-bitcoind + flamegraph idea.

## Closed lead — `IanoNjuguna/stratum-v2-tools`

**Verdict: rewrite from scratch** (round 2 path A, commit f4b9bd90 at
`sv2-test/src/performance_load_tests.rs`).

The suite is **100% in-process mock**: `establish_mock_connection` is
`tokio::sleep(10..60ms)`, `submit_share` is `tokio::sleep(80..300µs)`
+ a counter, `translate_sv1_to_sv2` returns a hard-coded
`SubmitSharesStandard` literal regardless of input (lines 717-724).
The `sv2-test` crate has **no `noise-sv2`, `framing-sv2`, or
`codec-sv2` dependency** — it cannot perform an SV2 Noise handshake
at any layer. The memory/CPU "stress" phase allocates `Vec<u8>` and
runs `i.wrapping_add(i*31)` — not SHA-256, not mining-shaped.

Repo status:
- **License: null** — no `LICENSE` file; fork is legally ambiguous
- **0 stars, 0 forks, 1 contributor** (xyephy, 13 commits)
- **Last push: 2025-10-25** (8 months idle as of 2026-06-24)
- **Tested ceiling: 1,500 mock tasks** (CLI entry), no real
  connections, no source-IP aliasing
- No `.github/workflows/`

**Decision**: greenfield. Reusable surface area is ~50 lines (config
struct shape + p95 calc + spawn-with-semaphore pattern) which is
trivially re-derivable. Build directly on `noise-sv2 + framing-sv2 +
parsers-sv2` per the [[simulator architecture]]'s recommendation,
with `source_ips: Vec<IpAddr>` and `bind_device: Option<String>`
designed in from day one.

## See also

- [[synthetic miner patterns]] — what each connection does
- [[connection scale bottlenecks]] — what the host environment supports
- [[simulator architecture]] — how the pieces fit together
