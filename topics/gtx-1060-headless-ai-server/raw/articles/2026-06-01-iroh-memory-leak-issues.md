---
title: "iroh memory growth — issues #3565 (idle endpoint) and #3963 (Router span leak)"
source: https://github.com/n0-computer/iroh/issues/3565, https://github.com/n0-computer/iroh/issues/3963
type: article
tags: [iroh, bug, memory-leak, router, accept, instrumentation, contrarian]
date: 2026-06-01
quality: 4
confidence: high
agent: 5
summary: "iroh 0.93.2 endpoint memory grows monotonically (32 MB → 35 MB over 20 min on idle minimal endpoint, no connection churn) — #3565, open with no fix. #3963: instrumentation span attached to Router::accept persists for the lifetime of the user-provided handler. Background connection-maintenance ops emit child spans that accumulate without clearing; a single long-lived idle client connection turns this into unbounded growth around the 1-minute mark. Mitigations are all workarounds: filter the router.accept span, drop instrumentation, or force the accept impl to return quickly. Affects 0.93.0 and main."
---

# iroh long-running-process memory issues

Steelmans the "iroh as long-running daemon on a small box is risky" claim with version-pinned bug numbers.

## Issue #3565 — idle-endpoint memory growth

- iroh **0.93.2** baseline
- Minimal endpoint, no connections, no work
- Memory grows from **32 MB → 35 MB over 20 minutes**
- Monotonic growth — no plateau observed in the test window
- Open, no fix at issue-filing time

## Issue #3963 — Router::accept instrumentation span leak

- Router's `accept` method has a tracing span attached
- The span persists for the **entire lifetime of the user-provided handler**
- Background connection-maintenance ops emit **child spans** during the connection lifetime
- Child spans accumulate without being cleared
- A single long-lived (or malicious idle) client connection turns this into unbounded growth around the 1-minute mark
- Affects **0.93.0 and main**

### Mitigations (all workarounds)

1. Filter the `router.accept` span via tracing-subscriber config
2. Drop tracing instrumentation entirely
3. Force the accept impl to return quickly (don't hold the connection in the handler)

## Implication for an Iroh AI server

The GTX 1060 server has 16 GB RAM — enough headroom that idle leak rate (~3 MB / 20 min ≈ 9 MB/hr ≈ 216 MB/day) wouldn't OOM for weeks. **But** for a long-running daemon hosting many ALPN handlers (Router pattern), #3963 is more concerning:

| Scenario | Bound |
|----------|-------|
| Idle daemon | OOM in ~70 days at observed leak rate |
| Daemon with 10 long-lived peer connections + Router | Hours to days (per #3963) |

### Operator mitigations

- **Schedule restart**: weekly systemd `RestartSec` or cron-driven restart
- **Monitor RSS**: alert if `RSS > N MB`
- **Use Router::accept's quick-return pattern** — push connection work to a tokio task, return from the handler immediately
- **Wait for 1.0** for these to be fixed

## See also

- [[2026-06-01-iroh-blobs-poisoned-store-issue-233]]
- [[2026-06-01-iroh-tickets-security-model]]
