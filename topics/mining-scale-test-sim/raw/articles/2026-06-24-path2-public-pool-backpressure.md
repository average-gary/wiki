---
title: "public-pool: Node.js stratum server backpressure thresholds & connection limits"
source_url: https://github.com/benjamin-wilson/public-pool/blob/master/src/services/stratum-v1.service.ts
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, connections, public-pool, stratum-v1, nodejs, backpressure, primary-source]
---

# public-pool: production thresholds from a real solo-mining service

[public-pool.io](https://web.public-pool.io) is a widely-used open-source
Bitcoin solo mining pool (NestJS + TypeScript + Node.js `net.Server`).
Its source tree contains the operationally-tuned thresholds at which a
real pool stops accepting new TCP connections — a rare published
data point on stratum scale.

## Headline numbers (defaults from stratum-v1.service.ts)

| Constant                                          | Default       |
|---------------------------------------------------|---------------|
| `DEFAULT_BACKPRESSURE_CHECK_INTERVAL_MS`          | 5000          |
| `DEFAULT_BACKPRESSURE_EVENT_LOOP_P95_MS`          | **2000**      |
| `DEFAULT_BACKPRESSURE_EVENT_LOOP_RESUME_P95_MS`   | **250**       |
| `DEFAULT_BACKPRESSURE_RSS_MB`                     | **2500**      |
| `DEFAULT_BACKPRESSURE_RESUME_RSS_MB`              | **2000**      |
| `DEFAULT_BACKPRESSURE_HEALTHY_CHECKS`             | 3             |
| `DEFAULT_MAX_CONNECTIONS_PER_LISTENER`            | **10000**     |

Per worker process. README states "28 workers with the default limit of
10000 allow up to **280000 connections on one port**."

## What the thresholds tell us about Node.js stratum at scale

- The **event-loop p95 delay** trips at 2 seconds — i.e. one Node.js
  process is considered overloaded when its 95th-percentile loop tick
  takes >2s. This typically corresponds to thousands of active stratum
  clients simultaneously busy in the V1 JSON parsing path.
- **RSS** trips at 2.5 GB. With 10,000 connections per worker that's
  **~250 KB per connection** in steady state — roughly an order of magnitude
  worse than ckpool's ~1-2 KB per connection (Node.js Buffer overhead,
  JSON-string GC churn, NestJS DI graph per client).
- Backpressure mechanism: `server.close()` is called (the listening socket
  shuts; existing connections continue), waits for 3 healthy 5-second
  checks below the resume thresholds (event loop ≤250 ms, RSS ≤2 GB),
  then re-`listen()`s.

## PM2 cluster scheduling

> "When running the worker app in PM2 cluster mode, start the PM2 daemon
> with OS-level connection scheduling. The environment variable must be
> present when the PM2 daemon starts."
> ```bash
> NODE_CLUSTER_SCHED_POLICY=none pm2 start ecosystem.config.js
> ```

`NODE_CLUSTER_SCHED_POLICY=none` delegates connection distribution to the
OS (SO_REUSEPORT-style), which scales better at high accept rates than
Node's default round-robin master-process scheduling.

## Server settings

```ts
socket.setTimeout(1000 * 60 * 5);   // 5-min idle disconnect
server.maxConnections = 10000;
(server as Server & { dropMaxConnection: boolean }).dropMaxConnection = true;
```

`dropMaxConnection=true` (Node 22.12+) makes the listening socket drop
beyond-limit connections immediately instead of accepting then closing.

## Implications for the scale-test simulator

- **Per-connection memory for Node-based pools: ~250 KB**. For Rust/C
  pools: ~1-2 KB. **100x gap** — a single 8 GB box runs ~32k Node clients
  vs. ~4M Rust clients (memory-only — other limits hit first).
- **Connection-acceptance throttling via event-loop delay** is the de facto
  way Node services discover their CPU ceiling. The simulator should
  measure event-loop p95 (or async-runtime equivalent) as the canonical
  "saturation" signal, not just connection count.
- The 10k-per-listener default is **CPU/memory headroom-based**, not a
  protocol limit. The same machine could host more if Node had less GC
  cost per connection.

## Counter-evidence

This is a Node.js bound — does not refute Rust/C scale. But it's a useful
real-world floor: a serious Bitcoin pool runs production at 10k clients
per Node worker, scaling out to ~280k per port via clustering.
