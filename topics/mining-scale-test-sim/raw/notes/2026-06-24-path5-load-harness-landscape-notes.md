---
title: "Load-harness landscape for SV2 — quick-reference matrix"
type: raw-source
source_kind: notes
fetched: 2026-06-24
path: 5
relevance: high
---

# Load-harness landscape for SV2-style binary protocols

Cross-reference notes consolidating what each tool does and doesn't offer
for "drive N synthetic SV2 connections from M hosts".

## Compatibility matrix

| Tool                  | Lang     | Transport             | Custom protocol | Per-host conns (claimed) | Distributed                          | Stateful  | TLS/Noise          |
|-----------------------|----------|-----------------------|-----------------|--------------------------|--------------------------------------|-----------|--------------------|
| **wrk / wrk2**        | C+Lua    | HTTP only             | No              | ~100k                    | No                                   | No        | TLS                |
| **k6**                | Go+JS    | HTTP, WS, gRPC; xk6   | xk6 extensions  | ~10-50k typical          | k6 Cloud / k6 Operator on K8s        | partial   | TLS                |
| **xk6-tcp**           | Go       | Raw TCP via ext       | yes (write Go)  | unknown                  | via k6 distrib                       | yes       | none built-in      |
| **JMeter**            | Java     | HTTP, JDBC, JMS; JSR223 | yes (Groovy)  | ~5-10k threads           | master/slave (rmi)                   | yes       | TLS; no Noise      |
| **Gatling**           | Scala    | HTTP, WS, MQTT, JMS   | DSL extension   | ~50k                     | Gatling Enterprise                   | yes       | TLS; no Noise      |
| **Locust**            | Python   | HTTP; ext via gevent  | Yes (User class)| ~1-5k per worker         | master/N workers (zmq)               | yes       | TLS; ext for Noise |
| **Goose** (Rust)      | Rust     | reqwest HTTP, ws; tcp via custom | yes (record_custom_request) | 10k+ docs  | **Gaggle removed in 0.17.0** | yes  | reqwest TLS        |
| **drill** (Rust)      | Rust     | HTTP only             | No              | -                        | No                                   | No        | TLS                |
| **oha** (Rust)        | Rust     | HTTP only             | No              | -                        | No                                   | No        | TLS                |
| **tcpkali**           | C        | Raw TCP, WS           | scripted bytes  | ~50k                     | No (one-host)                        | minimal   | TLS;  no Noise     |
| **emqtt-bench**       | Erlang   | MQTT                  | No (MQTT only)  | **millions**             | "fanout via N hosts; no coordinator" | yes       | TLS; no Noise      |
| **mqtt-stresser**     | Go       | MQTT                  | No              | "thousands"              | No                                   | yes       | TLS; no Noise      |
| **ddosify/anteon**    | Go       | HTTP                  | partial         | ~10-50k                  | yes (anteon control plane)           | partial   | TLS                |
| **Tsung**             | Erlang   | HTTP, XMPP, PgSQL, …  | yes (XML plugin)| millions                 | yes (controller + slaves)            | yes       | TLS; no Noise      |
| **swanling**          | Rust     | -                     | -               | -                        | "distributed Goose" — abandoned      | -         | -                  |

(Sources: each tool's README / docs, ingested 2026-06-24.)

## Three viable paths for an SV2 harness

### Path A — Custom thin Rust harness (recommended)

- Built on `tokio` + `noise-sv2 = 1.4.2` + `framing-sv2` + `codec-sv2` +
  `parsers-sv2` (all from SRI workspace, already in scope of this wiki).
- Each "miner" = one `tokio::spawn(synthetic_miner(...))`.
- ~600-1200 lines of Rust for: handshake, channel open, vardiff-paced
  share loop, per-connection metrics.
- **Pros**: smallest stack; only the bottleneck-relevant code is in your
  hands; runs at tokio task density (millions of tasks possible).
- **Cons**: you write the coordinator; you write the metrics export; you
  write the distributed runner.

### Path B — Goose with a TCP-custom transaction

- Use Goose's `examples/tcp_loadtest.rs` pattern; embed `noise-sv2` +
  framing inside the transaction.
- Gets you: CLI, scheduler, ramp-up, throttle, coordinated-omission
  mitigation, HTML report, metrics histograms, controller (telnet/WS).
- Lose: Gaggle distributed mode (removed in 0.17.0; pin 0.16.4 or roll
  your own multi-host).
- **Use this if**: you want the metrics + reporting plumbing free, and
  you're OK with single-host or DIY multi-host.

### Path C — Locust with an `Sv2User` subclass

- Sub-Path: write a `Sv2Client` that calls into a Rust extension
  (PyO3 around `noise-sv2`) — or use a pure-Python Noise_NX impl, but
  none of high quality exist.
- Get: master/worker distribution, web UI, metrics aggregation.
- **Use this if**: you specifically need the master/worker + web UI now
  and are willing to top out at a few thousand miners per worker.

## Single-host connection ceiling

The 64k limit is a 5-tuple uniqueness limit — `(src_ip, src_port,
dst_ip, dst_port, proto)`. The default `net.ipv4.ip_local_port_range`
(32768..60999) gives ~28k usable; expanding to `1025 65534` gives ~64k.

Multipliers:
- **Multi-source IPs** (emqtt-bench `--ifaddr` pattern): K source IPs →
  K × 64k. Add IPs via `ip addr add 10.0.0.X/24 dev eth0`. Linux kernel
  cap on aliases is ~250 by default, more than enough for our needs.
- **Multi-dest ports** (one load host → multiple pool listen ports):
  also multiplies but less useful for "test one pool".
- **TIME-WAIT recycling** (`net.ipv4.tcp_tw_reuse = 1`) plus
  `SO_REUSEADDR` — relevant only if connections are short-lived; SV2
  miners are persistent so TIME-WAIT is rarely an issue.

Other ceilings to tune:
- `ulimit -n` per process (open file descriptors). Set ≥ 1.5 × N.
- `nf_conntrack_max` if conntrack is enabled — set to ≥ 4 × N or disable
  conntrack on the load host.
- `tcp_mem` / `wmem`/`rmem` — per-socket buffer × N can exhaust memory
  fast. Each tokio TcpStream is ~few KB user-space + ~16-32 KB kernel
  buffers. 1M connections × 32 KB = 32 GB just for kernel socket
  buffers.

## Distributed coordination patterns

- **Locust** — master + N workers, ZeroMQ control plane, web UI aggregation. Most polished.
- **JMeter** — RMI master/slave, deprecated, painful at scale.
- **Gatling Enterprise** — paid SaaS; OSS edition is single-host.
- **Goose Gaggle** — was nng + CBOR; removed in 0.17.0. Currently absent.
- **k6 Operator** — Kubernetes-native; spawn N k6 pods, aggregate
  metrics to Prometheus. Good if you already run K8s.
- **Tsung** — Erlang distribution: native controller + slave nodes.
  Battle-tested for million-conn scenarios.
- **Custom NATS / Redis** pubsub — pattern used by ddosify; trivial to
  build for a Rust harness if needed.

## Metrics output formats

- **Locust** — CSV, JSON, live web UI, optional Prometheus exporter.
- **Goose** — stdout summary, request log (CSV/JSON), HTML report, PDF;
  Prometheus via `goose_metrics_prometheus` (third-party).
- **JMeter** — JTL (CSV/XML), Influx Backend Listener for live
  Grafana/InfluxDB.
- **k6** — stdout, JSON, InfluxDB, Prometheus remote write, OpenTelemetry
  (via `k6.io/observability` outputs).
- **Gatling** — local HTML; Gatling Enterprise has live Grafana.
- **emqtt-bench** — stdout counters; Prometheus pushgateway export.

For our SV2 harness: easiest pattern is **emit an OpenTelemetry OTLP
exporter** from each load-host process and aggregate in a single
Prometheus / Grafana. tokio + tracing + opentelemetry-otlp gets us there
in ~100 lines. Same target machine can run a Tempo / Mimir if you want
traces too.
