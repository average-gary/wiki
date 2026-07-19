---
title: "emqx/emqtt-bench — MQTT v5 benchmark, the closest analog harness"
type: raw-source
source_kind: repo
source_url: https://github.com/emqx/emqtt-bench
fetched: 2026-06-24
path: 5
relevance: high
---

# emqtt-bench — million-connection MQTT load tool

- "A lightweight MQTT v5.0 benchmark tool written in Erlang"
- Repo: https://github.com/emqx/emqtt-bench
- Three modes: `conn` (just open + hold connections), `sub` (subscribe to topics), `pub` (publish at configurable rate).

## Architecture & why it's the right analog

MQTT and Stratum V2 share the load-test shape:
- Many small clients (~1 MB RAM each, ideally less).
- Stateful, **persistent** TCP connections (not request/response).
- Binary framing (MQTT CONNECT/PUBLISH packets; SV2 length-prefixed Noise frames).
- Per-connection handshake overhead (MQTT CONNECT; SV2 Noise_NX) that
  CPU-bottlenecks during connection ramp-up.
- Pull pattern: server pushes (MQTT broker → subscribers; SV2 pool →
  `NewMiningJob`). Client occasionally responds (PUBACK; `SubmitSharesStandard`).

emqtt-bench is purpose-built for this exact shape, and is documented to
sustain **millions of connections**.

## Kernel tuning, from README

- `ulimit -n 200000` — file descriptor limit (each connection = 1 fd).
- `net.ipv4.ip_local_port_range='1025 65534'` — expanded ephemeral-port range,
  pushes single-source-IP limit from ~28k to ~64k.

## **The multi-IP trick — directly applicable to SV2**

```
--ifaddr 192.168.200.18,192.168.200.19,192.168.200.20,192.168.200.21
```

This is the **standard pattern** to bypass the 64k-ephemeral-port-per-(srcIP,
dstIP, dstPort) limit. With K source IPs you get K × 64k connections from
one host. Four IPs → ~256k connections; ten IPs → ~640k. The kernel
constraint isn't really the global TCP table; it's the 5-tuple uniqueness.

Adding IPs on Linux is trivial (`ip addr add 10.0.0.X/24 dev eth0` for as
many as you want, plus matching SRC NAT or routing).

## Erlang BEAM as the runtime

Worth noting: emqtt-bench is in Erlang/OTP, which is *purpose-designed* for
millions of lightweight processes — each "client" is one Erlang process
with its own mailbox. The actor model maps 1:1 to "one synthetic miner =
one process". Tokio tasks are a similar abstraction in Rust but with
slightly more per-task overhead than BEAM processes.

## Protocol-specific bits not reusable

- MQTT topic tree, QoS levels, retain flags, MQTT session resumption — not
  in SV2.
- MQTT-5 binary framing differs from SV2 framing (Noise-encrypted SV2 frames
  carry a fixed 6-byte header + payload, all encapsulated in a Noise
  transport message).

## What we'd lift

1. **`--ifaddr` multi-source-IP pattern** — drop straight into a Rust
   tokio harness via `TcpSocket::bind(SocketAddr::from((src_ip, 0)))` per
   connection.
2. **Connection mode separation** (`conn` vs `pub` vs `sub`) — useful
   for SV2: a "just hold the channel open" mode separate from "send shares"
   mode. Different bottlenecks.
3. **Connection-rate parameter (`-i interval`)** — ramp-up controlled by
   inter-connection sleep, not by thread-count, so you can model the
   "subscribe storm" carefully.
4. **Metrics shape** — emqtt-bench emits counter + histogram to stdout, plus
   optional Prometheus pushgateway export. The pattern transfers directly.

## Verdict

Not reusable as-is (MQTT-specific framing), but the **architectural template**
is the right one. If we were going to mimic emqtt-bench in Rust, we'd write
a Tokio app where each "miner" is one task, each task owns one TcpStream +
NoiseInitiator state + a small ring of work, parameterized by
`--connections`, `--rate`, `--ifaddr a,b,c,d`, with a stdout/Prometheus
metrics endpoint. That's ~600-1000 lines of Rust.
