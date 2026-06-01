---
title: "datum_sockets.c — TCP transport (no TLS), epoll, PROXY-protocol support"
source: "https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_sockets.c"
type: repos
tags: [datum, sockets, transport, epoll, proxy-protocol, tls-absent, ocean, c-source]
summary: "datum_sockets.c handles the gateway's stratum-side TCP listener (downstream) — NOT the DATUM Protocol upstream socket. It is plain TCP with epoll, no TLS, line-delimited like SV1; PROXY-protocol headers are trusted to a configurable depth. Crucially: this file is the SV1 stratum stack, not the DATUM-Protocol-to-pool stack. The DATUM upstream socket is opened inside datum_protocol.c instead. This separation matters for understanding which encryption applies where."
confidence: high
ingested: 2026-06-01
ingested_by: path1
quality_score: 4
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_sockets.c"
license: MIT
revision_branch: master
---

# datum_sockets.c — the (downstream) stratum-side TCP transport

A finding worth its own ingest: this file does **not** implement the DATUM Protocol transport. It's the **stratum-v1-side server socket** — the listener that miners connect to. The DATUM upstream connection is opened directly inside `datum_protocol.c` using the same standard TCP primitives but with the libsodium framing applied above.

## What's in this file

- An epoll-based TCP listener (`datum_gateway_listener_thread`) that accepts SV1 miner connections and dispatches them to a thread pool.
- Per-connection workers (`datum_threadpool_thread`) that drain `recv()` buffers and dispatch newline-terminated lines.
- PROXY-protocol header parsing: trusts upstream proxy declarations to a configurable depth, useful for behind-haproxy deployments where the real miner IP needs to survive.
- IPv4 and IPv6 dual-bind setup.
- `TCP_NODELAY` and `O_NONBLOCK` flag setting.

What's **not** in this file:

- TLS or any transport encryption. None.
- Binary framing, length prefixes, magic bytes. The protocol on this socket is line-delimited JSON-RPC (Stratum v1).
- The 8-byte DATUM packed header. That lives in `datum_protocol.c` where the upstream socket is read/written.

## Verbatim line-delimited parsing

```c
char *end_line = strchr(start_line, '\n');
while (end_line != NULL) {
    *end_line = 0; // null terminate the line
    ...
}
```

This is bog-standard SV1: each `mining.notify`, `mining.submit`, etc. is a JSON-RPC line ending in `\n`. The DATUM Gateway is a SV1 server downstream and a DATUM client upstream — those are two different sockets handled by two different files.

## PROXY-protocol depth

The gateway can be deployed behind haproxy or any proxy that prepends a PROXY-protocol v1/v2 header. The depth is configurable: trust 1 hop (most common), 2 hops (proxy-to-proxy), etc. This lets the gateway log the real miner IP for the dashboard and for share-attribution. From a security standpoint this is a **configuration footgun** — set it too high and a malicious peer can spoof IPs all the way through.

## Connection lifecycle

```
accept() → assign_to_thread() → worker thread takes over with epoll
```

- `assign_to_thread()` routes to the worker thread with the fewest active connections (load balance).
- Worker threads use `epoll_wait()` with a 7ms timeout; the listener thread uses 100ms.
- On `recv() <= 0` or any send error: `epoll_ctl(EPOLL_CTL_DEL)` + `close(fd)`. **No reconnect logic** — that's the miner's responsibility.

## Function catalog

| Function | Purpose |
|---|---|
| `datum_gateway_listener_thread()` | accept() loop on the SV1 listening port |
| `datum_threadpool_thread()` | per-worker epoll event loop for accepted clients |
| `assign_to_thread()` | least-loaded thread selection |
| `datum_socket_send_string_to_client()` | enqueue a line for outbound write |
| `datum_socket_setoptions()` | TCP_NODELAY + O_NONBLOCK |
| `datum_sockets_setup_listening_sockets()` | bind IPv4/IPv6 |
| `get_remote_ip()` | getpeername() + PROXY-header override |

## Why this matters for the SV2-downstream-proxy

The fact that DATUM Gateway already separates the **downstream listener** (SV1, line-delimited, no TLS, in this file) from the **upstream client** (DATUM Protocol, encrypted, framed, in `datum_protocol.c`) is **exactly the architectural pattern the SV2-downstream proxy must adopt**:

- Replace `datum_sockets.c` with an SV2 listener (binary frames, Noise transport, channel multiplexing).
- Keep `datum_protocol.c` essentially unmodified — it's already the "client to pool" abstraction.
- The translator logic sits between the two, mapping SV2 channels and shares to DATUM's job slots and `0x27` opcodes.

This is conceptually cleaner than the issue #146 proposal (which embeds SV2 alongside SV1 inside the gateway) because SV2 displaces SV1 entirely on the downstream side — no need to maintain both. The downside: existing OCEAN miners running SV1 hardware can't use the proxy. But the topic explicitly is the SV2-downstream-proxy design, so that's by construction.

## What's NOT in scope of datum_sockets.c

If a researcher is looking for:

- The DATUM Protocol on-the-wire framing → `datum_protocol.c`
- The libsodium handshake → `datum_protocol.c`
- The 8-byte packed header → `datum_protocol.h` struct + `datum_protocol.c` parsing
- TLS → not present anywhere; DATUM uses libsodium directly, SV1 listener is plain TCP
- Reconnection → buried in `datum_protocol.c` for upstream, miner-side for downstream

## Sources

- [datum_sockets.c @ master](https://github.com/OCEAN-xyz/datum_gateway/blob/master/src/datum_sockets.c) — 29,311 bytes at HEAD `a3da9e69`.
