---
title: "DATUM Gateway datum_sockets.c — Hand-rolled epoll Thread Pool"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_sockets.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 9
tags: [datum, datum-gateway, threading, epoll, sockets, c-source, async-runtime]
related_concepts: [sv2-downstream-replacement, tokio, async-runtime, threading-model]
---

# datum_sockets.c — the threading model snapshot

**This is the single most important architectural finding for SV2-swap planning.**
The gateway's threading model is **hand-rolled epoll + pthread**, not libevent,
not libuv, not any async runtime. Any SV2 variant in Rust will almost
certainly use Tokio, which means the entire thread/connection-distribution
model gets replaced.

## Event loop: epoll directly

```
epoll_create1(EPOLL_CLOEXEC)
epoll_wait(... timeout=7ms ...)
epoll_ctl(... EPOLL_CTL_ADD/MOD/DEL ...)
flag: EPOLLONESHOT
```

- **Per-thread epoll fd** (`T_DATUM_THREAD_DATA::epollfd`)
- **7 ms wait timeout** — tight loop, balances latency vs CPU
- **EPOLLONESHOT** — connection rearmed after each event, single-fire to
  avoid races between epoll_wait dispatch and read processing
- Linux-only by default; non-Linux uses `epoll-shim` (per CMakeLists.txt)

## Thread distribution model

Function: `assign_to_thread()`:

```
if (datum_active_threads < max_threads) {
    spawn new thread
} else {
    pick thread with min(connected_clients)
}
```

**Lazy thread spawn up to `max_threads`** (default 8), then **least-loaded
distribution**. Defaults: `max_clients_per_thread = 128`,
`max_threads = 8`, `max_clients = 1024`. So 1024 simultaneous miners is the
default ceiling.

**Three-tier rejection**:

1. Per-thread cap: `connected_clients >= max_clients_thread`
2. Global cap: sum across all threads `>= max_clients`
3. OS fd limit (implicit)

## Per-thread context: `T_DATUM_THREAD_DATA`

- `thread_id`, `epollfd`
- `connected_clients`, `next_open_client_index`
- `client_data[]` — fixed array of `T_DATUM_CLIENT_DATA`
- `pthread_mutex_t thread_data_lock`
- `struct epoll_event ev, events[MAX_EVENTS]`
- bool flags: `has_new_clients`, `has_client_kill_request`, `empty_request`
- `T_DATUM_SOCKET_APP *app` — back-pointer

Listener thread is separate; new connections are handed off to a worker
thread via the flags above.

## Per-client buffers: `T_DATUM_CLIENT_DATA`

- `fd`, `cid` — kernel fd + client index within thread
- `buffer[CLIENT_BUFFER]` — read buffer
- `w_buffer[CLIENT_BUFFER]` — write buffer
- `in_buf`, `out_buf` — byte counts (high-water marks)
- `rem_host[DATUM_MAX_IP_LEN+1]` — string IP for logging
- `proxy_line_read` (int) — PROXY protocol state machine
- `new_connection`, `kill_request` (bool)
- `void *datum_thread` — back-pointer to parent thread

## Line-delimited JSON-RPC parsing

```c
strchr(start_line, '\n')  // find delimiter
... parse line ...
memmove(buffer, leftover, leftover_len)  // shift unprocessed
my->app->client_cmd_func(&my->client_data[cidx], start_line)  // dispatch
```

Indirection via `client_cmd_func` is the **clean handoff to the
protocol-specific parser** (datum_stratum.c registers itself as the
command function for the stratum app instance). This is the architectural
seam where an SV2 binary-framed parser would plug in instead — but the
underlying epoll loop assumes line-delimited reads.

## App-level config: `T_DATUM_SOCKET_APP`

- `name`, `listen_port`
- `max_threads`, `max_clients_thread`, `max_clients`
- `datum_threads[]`, `datum_active_threads`
- Function pointers: `client_cmd_func`, `new_client_func`,
  `closed_client_func`, `init_func`, `loop_func`

The function-pointer interface is **already protocol-agnostic** — in
principle one could plug in an SV2 framer. In practice, SV2's binary
framing, Noise handshake, and channel-multiplexing semantics don't
fit naturally into this line-oriented loop.

## Replacement notes for SV2-downstream

**This module gets fully rewritten.** Reasons:

1. **Binary framing vs line-oriented reads** — `strchr('\n')` doesn't apply;
   SV2 has length-prefixed binary frames.
2. **Noise handshake** — needs early-stage transport encryption hooks;
   the current loop has no concept of pre-stratum-bytes negotiation
   (other than optional PROXY protocol).
3. **Async runtime expectation** — Rust SV2 ecosystem (SRI's
   `roles-utils`, `network-helpers-sv2`) is Tokio-native. Reusing the
   epoll+pthread skeleton from C requires either FFI or a complete port.
4. **Channel multiplexing** — SV2 multiplexes channels on a single
   connection; this loop maps one-fd-to-one-miner.

What survives:

- **Three-tier connection-cap discipline** (per-thread / global / fd) —
  reuse semantics, change names.
- **Pre-allocation philosophy** — keep, translate to bounded Tokio tasks
  with fixed-size channel queues.
- **PROXY protocol passthrough** — keep, useful operationally.
- **Listener / worker handoff via flags** — Tokio equivalent is
  `mpsc::channel` for accepted-socket-distribution.

## Threading-model implication for the SV2 swap

The wholesale replacement of datum_sockets.c is the **biggest delta**
between a port and a rewrite. A "minimal SV2 patch" approach is
infeasible — the threading model itself diverges from anything an
async-Rust SV2 server would use. Plan accordingly: this is a
ground-up rewrite of the network layer, not a swap.

## Justification

Highest-leverage finding in the path. The gateway is C+epoll+pthread; the
SV2 ecosystem is Rust+Tokio. Confirms the SV2-downstream variant cannot
be a thin patch — the whole network layer changes, and the docs/concepts
must call this out explicitly.
