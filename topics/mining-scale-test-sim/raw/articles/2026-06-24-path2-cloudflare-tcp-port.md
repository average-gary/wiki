---
title: "Cloudflare: TCP port states, SO_REUSEADDR, ephemeral port pool"
source_url: https://blog.cloudflare.com/the-quantum-state-of-a-tcp-port/
type: article
ingested: 2026-06-24
quality: 4
confidence: high
tags: [scale, connections, tcp, linux, ephemeral-ports, primary-source]
---

# Cloudflare: TCP port semantics relevant to million-connection servers

Three-state "fastreuse" model in the Linux bind bucket: -1 (ephemeral via
connect), 0 (bind w/o SO_REUSEADDR), +1 (bind w/ SO_REUSEADDR).

## Why this matters for stratum at scale

A stratum **server** uses one (or a few) listen ports — port exhaustion
is NOT the server's issue. But:

- **Synthetic miner simulator** running 1M clients FROM one host hits
  the ephemeral port wall HARD. Linux ip_local_port_range is `32768-60999`
  by default = 28,232 ports. For 1M outbound connections to one
  (server-ip, server-port), the client side needs:
  - Multiple source IPs (each gives a fresh 28k-port pool), OR
  - SO_REUSEADDR + SO_REUSEPORT trickery + multiple destinations, OR
  - The simulator must use multiple destination ports on the pool,
    multiplying the (src-ip, src-port, dst-ip, dst-port) 5-tuple space.

## For the scale-test simulator

To exercise 100k+ outbound stratum connections from a single host:

1. Bump `ip_local_port_range` to `1024 65535` (gives ~64k ephemerals).
2. Configure the pool to listen on multiple ports (e.g., 3333-3343 = 10 ports).
3. Use SO_REUSEADDR on the client to allow source-port reuse against
   different dest-ports.
4. For 1M, use multiple loopback aliases (`ip addr add 127.0.0.2/8 dev lo`
   ... `127.0.0.255/8 dev lo`) giving 254 × 28k = ~7M tuple space.

This is one of the **first walls** the simulator hits BEFORE the pool
under test sees any pressure.

## Other Linux limits to bump for million-connection tests

- `fs.file-max` (system-wide fd cap)
- `nofile` ulimit (per-process)
- `net.core.somaxconn` (listen backlog cap; ckpool requests 8192 but
  kernel caps at somaxconn)
- `net.ipv4.tcp_max_syn_backlog`
- `net.netfilter.nf_conntrack_max` if conntrack is enabled (it is on most
  default Linux installs — and conntrack table is the silent killer at
  high connection rate; turn it off on the simulator path or accept the
  hashtable cost)
- `net.ipv4.tcp_tw_reuse=1` if running into TIME_WAIT pressure during
  rapid reconnect tests.
