---
title: "Gateway internals — C architecture, threading, and the queue seam"
category: concept
sources:
  - raw/articles/2026-06-01-path2-datum-stratum-server-internals.md
  - raw/articles/2026-06-01-path2-datum-stratum-header-structs.md
  - raw/articles/2026-06-01-path2-datum-sockets-epoll-threadpool.md
  - raw/articles/2026-06-01-path2-datum-config-surface.md
  - raw/articles/2026-06-01-path2-datum-stratum-dupes-share-validation.md
  - raw/articles/2026-06-01-path2-datum-protocol-share-handoff.md
  - raw/articles/2026-06-01-path2-datum-api-operator-observability.md
created: 2026-06-01
updated: 2026-06-01
tags: [datum, gateway, c-internals, threading, epoll, libevent, queue-seam, sv2-replacement]
confidence: high
---

# Gateway internals — C architecture, threading, and the queue seam

A code-level read of `OCEAN-xyz/datum_gateway` aimed at one specific question: **what does the SV1-to-ASIC leg actually do, in code, and what would an SV2-downstream variant have to replace?**

## Module map

| Module | Role | Replacement scope for SV2-downstream |
|---|---|---|
| `datum_sockets.c` | Hand-rolled `epoll_wait(timeout=7ms)` per worker thread | **Full rewrite** (Tokio reactor) |
| `datum_stratum.c` | SV1 mining methods, vardiff, extranonce layout, 6× coinbase variants | **Full rewrite** (SRI mining-channel server) |
| `datum_stratum_dupes.c` | Composite-key share-dedup filter | **Keep, port to Rust, rekey on (channel_id, seq, ntime, ver, xn)** |
| `datum_queue.c` | rwlock dual-buffer producer/consumer queue | **Keep, port to `tokio::sync::mpsc`** |
| `datum_protocol.c` | Detached pthread; encrypted upstream to OCEAN; 8-job ring | **Keep almost unchanged** (same semantics, port to a detached Tokio task) |
| `datum_blocktemplates.c` | Bitcoind GBT pull + parse | **Keep** (bitcoind interface unchanged) |
| `datum_coinbaser.c` | Pool-supplied output blob → coinbase outputs | **Keep, simplify** (SV2 TDP collapses 6 variants) |
| `datum_submitblock.c` | Block-discovery escape hatch | **Keep** |
| `datum_jsonrpc.c` | Bitcoind RPC client | **Keep** |
| `datum_logger.c` | Logging | **Keep, port to `tracing` / `log`** |
| `datum_api.c` | libmicrohttpd dashboard | **Rewrite** (axum); preserve URLs; add Prometheus `/metrics` |
| `datum_conf.c` | JSON config | **Rewrite** (versioned schema; new `sv2_mining_server` section) |

## The queue seam — the architectural finding

The queue-based handoff between the SV1 server (`datum_stratum.c`) and the upstream DATUM-protocol client (`datum_protocol.c`) is **already a clean producer/consumer boundary** (~80 LOC in `datum_queue.c`).

```
SV1 server  ──┐                                          ┌──▶ datum_protocol.c
              │   datum_queue.c (rwlock dual-buffer)     │   detached pthread
              │   ───────────────────────────────────▶   │   8-job ring
              │                                          │   encrypted to OCEAN
SV1 server  ──┘                                          └──▶
              ▲
              │
              The SV2-downstream variant draws its
              line right here. Everything to the left
              gets rewritten; the queue interface and
              everything to the right stays as-is
              (or is ported 1:1 to Tokio).
```

This is the load-bearing finding for sizing an SV2-downstream rewrite: **the proxy doesn't have to reimplement the upstream half** — it just has to produce queue items in the same format that `datum_protocol.c` already consumes (or, in a Rust v0, produce equivalent messages over a `tokio::sync::mpsc::Sender`).

## Threading model — today vs Tokio

| Aspect | Today (C gateway) | SV2-downstream (Rust) |
|---|---|---|
| Network event loop | `epoll_wait(timeout=7ms)` per worker thread | Tokio reactor, mio backend |
| Thread count | Fixed `max_threads=8` pthreads | Tokio worker_threads (CPU-bound default) |
| Conn distribution | Least-loaded across pre-spawned threads, capped at `max_clients_per_thread=128` | One Tokio task per connection, channels per channel |
| Connection ceiling | Hard `max_clients=1024` | Configurable; use `Semaphore` |
| Per-conn buffers | Fixed `CLIENT_BUFFER` read+write, line-delimited via `strchr('\n')` | Length-prefixed binary frames; `tokio_util::codec` |
| Memory philosophy | "Pre-allocate, never fragment" — explicit comment in `datum_stratum.c:405` | Tokio is heap-friendly; bounded channels + `BytesMut` pool where it matters |
| Cross-thread handoff | `pthread_rwlock_t` dual-buffer | `tokio::sync::mpsc::channel` |
| Per-thread state | `T_DATUM_THREAD_DATA` w/ `pthread_mutex_t` | `Arc<RwLock<...>>` or per-task ownership |
| Listener / worker handoff | bool flag + per-thread `client_data[]` slot | `mpsc<TcpStream>` |
| Submitblock buffer | **8.5 MB pre-allocated per thread** (68 MB at 8 threads) | `BytesMut` from a pool, or per-task |

## Extranonce layout (current C gateway)

`extranonce1 = (thread_id << 22) | (client_id ^ 0xB10CF00D)`. 32 bits split. The `0xB10CF00D` xor is a deliberate "blockfood" tag to make collisions visually distinguishable in logs.

For an SV2 variant, this is irrelevant — SRI's hierarchical `ExtranoncePrefix` allocator carves up the 12-byte upstream extranonce differently. See [[../concepts/sv2-extranonce-bridging]].

## Local share validation (six checks)

`datum_stratum.c` runs all six checks on every share **before** queuing it for upstream submission:

1. PoW: SHA-256d output != all zeros (sanity)
2. Hash meets local target (vardiff-derived; not the pool target)
3. Job not stale (prev_block_hash matches latest)
4. ntime within bounds (not too future, not too past)
5. Composite-key dedup: `(connection_id, job_id, ntime, version, extranonce2, nonce)` not seen before
6. Job not aged out of the 8-job ring

These are protocol-agnostic — a Rust SV2-downstream variant can reuse `channels_sv2`'s share validation, which performs equivalent checks against `ExtendedChannel`'s job storage.

## Operator-facing observability

- `datum_api.c` exposes a libmicrohttpd JSON dashboard with operator-relevant counters: shares accepted/rejected, current diff, current job, miner list with per-miner share rate.
- **No Prometheus, no OpenMetrics, no structured logs today.** Flagged as an improvement opportunity for any rewrite, not a parity requirement.

## Sources

- [[../../raw/articles/2026-06-01-path2-datum-stratum-server-internals|datum_stratum.c internals]]
- [[../../raw/articles/2026-06-01-path2-datum-stratum-header-structs|datum_stratum.h structs]]
- [[../../raw/articles/2026-06-01-path2-datum-sockets-epoll-threadpool|sockets epoll + threadpool]]
- [[../../raw/articles/2026-06-01-path2-datum-config-surface|operator config knobs]]
- [[../../raw/articles/2026-06-01-path2-datum-stratum-dupes-share-validation|dupe + validation]]
- [[../../raw/articles/2026-06-01-path2-datum-protocol-share-handoff|queue handoff]]
- [[../../raw/articles/2026-06-01-path2-datum-api-operator-observability|API + observability]]

## See also

- [[gateway-data-flow]] — the runtime path of a template through the system
- [[sv2-downstream-architecture]] — the Rust reimagination of the downstream leg
- [[datum-protocol]] — what `datum_protocol.c` actually speaks
