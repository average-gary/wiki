---
title: "tag1consulting/goose — Rust async load testing framework (Locust-inspired)"
type: raw-source
source_kind: repo
source_url: https://github.com/tag1consulting/goose
fetched: 2026-06-24
path: 5
relevance: high
---

# Goose — Rust async load test framework

- Repo: https://github.com/tag1consulting/goose
- Stars: ~981, language: Rust, last update 2026-06-22
- Description: "Load testing framework, inspired by Locust"
- Topics: `load-testing`, `http-client`, `metrics`, `rust`

## Key facts (from `Cargo.toml` and src)

- **Transport hard dependency on `reqwest = 0.13`** (HTTP only) and `tokio-tungstenite = 0.28` (WebSocket). No raw-TCP transport built in.
- Tokio multi-thread runtime; `async-trait`, `futures`.
- Metrics: built-in throughput, request count, response-time histograms, requests/sec, errors. Output via stdout, HTML report, optional `pdf-reports` feature (requires headless_chrome).
- Coordinated-omission mitigation is a first-class concept (book chapter).

## **TCP support — built-in escape hatch**

Goose ships an `examples/tcp_loadtest.rs` that demonstrates load-testing a raw
TCP echo server via `GooseUser::record_custom_request("TCP", ...)`. The pattern:

```rust
use goose::prelude::*;
use tokio::net::TcpStream;

async fn tcp_echo(user: &mut GooseUser) -> TransactionResult {
    let host = user.base_url.host_str().unwrap_or("127.0.0.1");
    let port = user.base_url.port().unwrap();
    let started = Instant::now();
    let mut stream = TcpStream::connect(format!("{host}:{port}")).await?;
    stream.write_all(payload).await?;
    let mut buf = vec![0u8; payload.len()];
    stream.read_exact(&mut buf).await?;
    let rt = started.elapsed().as_millis() as u64;
    user.record_custom_request("TCP", "tcp_echo", rt, true, None, None).await?;
    Ok(())
}
```

The `--host` flag accepts any URL scheme (`tcp://`, `grpc://`, `ws://`); Goose
just extracts host and port. The metrics system happily tracks anything —
Goose's HTTP-only marketing is misleading. For persistent connections across
transactions, wrap `TcpStream` in `Arc<tokio::sync::Mutex<TcpStream>>` and
stash in `user.set_session_data()` (per the example's docstring).

**Implication for SV2**: a Goose-based harness would do its own Noise
handshake + `framing-sv2` parsing inside each transaction, with Goose
providing the user scheduler, metrics, throttling, CLI, and report generation.

## **Gaggle (distributed mode) — REMOVED in 0.17.0**

The book documents Gaggle (manager + N workers, nng + CBOR transport for
messages), but the **technical.md** chapter explicitly notes:

> NOTE: Gaggle support was temporarily removed as of Goose 0.17.0 (see
> https://github.com/tag1consulting/goose/pull/529). Use Goose 0.16.4 if you
> need the functionality described in this section.

The current version (0.19.0-dev) has no distributed coordination. You'd have
to either pin 0.16.4, ship one binary per host yourself + aggregate JTL-like
output, or use the Goose controller (telnet/WebSocket) for external orchestration.

Reported scale (from Tag1 AWS blog, linked in `gaggle/overview.md`):
"12,000 active users generating over 41,000 requests per second and
saturating 16 Gbps" across two hosts. Linear scaling claim.

## Connection scaling per host

Book and README don't quote a per-host max-connections number for raw TCP
transport. With reqwest HTTP, a small AWS instance hit "2,000 users generating
6,500 rps and saturating 2.6 Gbps". For SV2-style persistent TCP, the limit
is going to be ephemeral-port range (64k by default) and FD ulimit.

## Verdict

- **Best Rust-async load framework if you can live with writing the protocol
  yourself.** Tokio runtime, scheduler, metrics, report all free.
- **Custom protocols are first-class** via `record_custom_request`.
- **No distributed mode in current main** — must pin 0.16.4 or roll your own.
