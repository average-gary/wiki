---
title: "ckpool architecture: multi-process, epoll, passthrough for million-client scale"
source_url: https://github.com/ckolivas/ckpool/blob/master/README
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, connections, ckpool, stratum-v1, passthrough, architecture, primary-source]
---

# ckpool: production-grade stratum-v1 pool — design for scale

Con Kolivas's ckpool is the canonical C/epoll stratum-v1 implementation
used by ckpool.org's solo-mining service and many private pools. Its README
explicitly targets millions of clients via passthrough mode.

## Headline claim (README, verbatim)

> "Passthrough node(s) that combine connections to a single socket which can
> be used to **scale to millions of clients** and allow the main pool to be
> isolated from direct communication with clients."

## Architecture choices that matter for the scale-test sim

- **Multiprocess + multithreaded**: separate processes for connector,
  stratifier, generator — communicate via unix sockets. Each can be pinned
  to a CPU.
- **epoll edge-triggered** in `src/connector.c` (line ~735): one
  `epoll_create1(EPOLL_CLOEXEC)` per receiver thread.
- **Listen backlog hard-coded to 8192** (line 1666 of `connector.c`):
  `listen(sockd, 8192)` "in case the system configuration supports it" — so
  ckpool expects accept-rate to be high enough to keep the queue drained at
  >SOMAXCONN load.
- **maxclients defaults to 90% of RLIMIT_NOFILE** (`ckpool.c` line 1883):
  ```
  if (ckp.maxclients > ret * 9 / 10) {
      LOGWARNING("Cannot set maxclients to %d due to max open file limit of %d, reducing to %d",
                 ckp.maxclients, ret, ret * 9 / 10);
      ckp.maxclients = ret * 9 / 10;
  }
  ```
- **Event-processor thread count = NPROCESSORS_ONLN / 2** (`connector.c`
  line 1748): half the cores handle client-event processing.
- **Reference-counted client_instance_t** with UT_hash on `id` — clients
  pinned to fd, hash lookup is O(1).

## Modes of deployment

- `ckpool` — full pool with bitcoind RPC.
- `ckproxy` (`-p`) — proxy mode, presents miners as single user upstream.
- `ckpassthrough` (`-P`) — collates all incoming connections, streams to
  upstream pool over a single connection. **This is the million-client mode.**
- `cknode` (`-N`) — passthrough + local bitcoind, can submit blocks itself.
- `ckredirector` (`-R`) — front-end that filters non-contributing miners and
  redirects accepted ones to backend.

## Per-connection footprint (struct client_instance, connector.c)

The struct is modest:
- `int64_t id`, `int fd`, `int ref`, `bool invalid`
- two linked-list pointers (dead, recycled)
- `struct sockaddr_storage` (~128 B)
- `char address_name[INET6_ADDRSTRLEN]` (46 B)
- `int server`, `char *buf`, `unsigned long bufofs`
- `sender_send_t *sending`
- shares list head, redirect flags
- ~200-300 bytes per client plus the read buffer (grows by MAX_MSGSIZE=1024).

Read buffer grows in MAX_MSGSIZE=1024-byte chunks. Steady-state usage ≈
**~1-2 KB per connection** in ckpool itself (plus kernel TCP socket
overhead, see other articles).

## vardiff tuning (stratifier.c lines 5790-5860)

ckpool's vardiff targets **drr = 0.3** where `drr = dsps / diff`, i.e.
~0.3 shares per second per connection at equilibrium (≈ 1 share every
3.3s):

```c
optimal = lround(dsps * 3.33);     // sets next diff so drr -> 0.3
if (drr > 0.15 && drr < 0.4) return;  // hysteresis band
```

Vardiff checks **every 72 shares or 240 seconds** (whichever comes first):
```c
if (client->ssdc < 72 && tdiff < 240) return;
```

NOTE: this is much higher than the "1 share per 30-60s" rule of thumb the
user assumed. ckpool's default is closer to **1 share per 3-4s per
connection** at equilibrium for properly-difficulty-targeted ASICs.
(In practice, smaller-hashrate clients get clamped by mindiff and submit
slower.)

## What this means for the scale-test simulator

- At ckpool's default vardiff target (drr=0.3), 100k connections = ~**30k
  shares/sec to validate**. That IS a meaningful share-validation load,
  not a trivial one.
- At 1M connections it would be 300k sps — well beyond what a single
  validator can handle. This is exactly why ckpool's passthrough mode
  collates many miners onto one upstream connection.
- The simulator should NOT assume share-validation is free. Even with
  vardiff floor, ckpool's defaults put validation in the same order of
  magnitude as connection management at 100k+ scale.

## Counter-evidence to the user's hypothesis

User's claim: "vardiff clamps to ~1 share/30-60s." Reality in ckpool:
default target is ~3.3s/share, which is **10x more frequent**. This
significantly raises the share-validation load curve relative to what the
hypothesis predicts. The user should re-derive the validation throughput
target with drr=0.3 (i.e. share rate ≈ 0.3 N for N connections, not
0.02 N).
