---
title: "Gateway data flow"
category: concept
sources:
  - raw/articles/2026-05-28-datum-gateway-readme.md
  - raw/articles/2026-05-28-ocean-datum-setup-guide.md
created: 2026-05-28
updated: 2026-05-28
tags: [datum, datum-gateway, gbt, blocknotify, sigusr1, stratum, share-validation, mining]
aliases: ["DATUM gateway runtime path", "datum_gateway data path"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "Runtime path of work through DATUM Gateway: Bitcoin node builds template (GBT), gateway distributes Stratum v1 jobs to ASICs, gateway forwards shares to DATUM Prime. New blocks invalidate work via SIGUSR1 (or the HTTP /NOTIFY fallback). Shares are validated twice — once locally, once by the pool — which is why hardware and pool counters disagree."
---

# Gateway data flow

> The path a unit of work takes through the system, the events that invalidate it, and why local-vs-pool share counts diverge in steady state.

## Three boundaries, three protocols

The gateway is a translator at three asymmetric interfaces:

```
ASIC ──Stratum v1 + ASICBoost──▶ DATUM Gateway ──GBT RPC──▶ bitcoind/Knots
                                         │
                                         ▼
                                   DATUM Prime
                                  (DATUM Protocol)
```

The gateway is the **server** for ASICs (Stratum v1) and a **client** to both the local node (GBT) and the pool (DATUM Protocol).

## Steady-state path of a share

1. **Template fetch.** Gateway calls `getblocktemplate` on the local node. Knots is recommended because it gives miners fine-grained policy controls; Core works but the README calls it "severely lacking in template control options" — a centralizing force.
2. **Generation-transaction handshake.** Gateway exchanges DATUM-Protocol messages with the pool to obtain the coinbase output set, primary coinbase tag, and per-miner unique identifier. (See [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)).)
3. **Job distribution.** Gateway packages the template into a Stratum v1 `mining.notify` job (with version-rolling fields for ASICBoost), pushes it to subscribed ASICs.
4. **ASIC submission.** ASIC finds a candidate, sends `mining.submit`.
5. **Local validation (first pass).** Gateway validates the share against its local template — does it meet the share target? Is it a valid block under the local node's view? Accept or reject is sent back to the ASIC immediately.
6. **Pool submission.** Accepted shares (and full block solutions) go up through the DATUM Protocol to DATUM Prime.
7. **Pool validation (second pass).** Pool checks consensus validity, latency, height freshness, presence of pool-required coinbase fields. Result lands in the pool's accounting.

## Why pool and ASIC share counts disagree

This is documented as expected behavior, not a bug. From the README's *Notes/Known Issues/Limitations*:

> "Stratum v1 has no mechanism to report back to the miner that previously accepted work is now rejected, and it doesn't make sense to wait for the pool before responding, either."

So the local pass commits to an answer instantly; the pool pass can later reject for reasons the ASIC will never hear about:

- **Stale work** — between local accept and pool ingest, a new block arrived and the work is now for the wrong height.
- **Latency to network** — pool considers it late even if locally it was fine.
- **Pool-specific guardrails** — extra requirements documented per pool.

The delta varies with gateway configuration and network proximity. Treat ASIC counters as a **lower bound** on what the pool will credit; always reconcile with the pool's own accounting.

## Block-arrival invalidation

Mining stale work is the worst failure mode here, because every share you submit while stale is wasted hashpower. Two mechanisms:

### 1. `SIGUSR1` from local `blocknotify`

The recommended setup runs the gateway as the same user as `bitcoind` and adds to `bitcoin.conf`:

```
blocknotify=killall -USR1 datum_gateway
```

When the node accepts a new block, it shells out to `killall -USR1 datum_gateway`, which signals the gateway to re-fetch the template and push fresh jobs. Requires `psmisc` (provider of `killall`) on most distros.

### 2. HTTP `/NOTIFY` endpoint (fallback)

When the gateway and node are on different hosts (or in different containers), the signal-based path doesn't work. The gateway's dashboard/API exposes a `NOTIFY` endpoint, and `bitcoin.conf` becomes:

```
blocknotify=wget -q -O /dev/null http://datum-gateway:7152/NOTIFY
```

(Default API port is `7152`; default Stratum port is `23334`.) The Docker section explicitly recommends disabling the notify fallback in the gateway config when using HTTP NOTIFY — i.e. don't keep two stale-detection paths racing.

## Pool-disconnect failure mode

When the DATUM Protocol link drops and reconnect fails, the gateway's default is to **disconnect all Stratum clients**. The reason given in the README is to let miners' built-in pool-failover kick over to non-DATUM mining or a backup gateway, rather than silently piling up shares that nobody will credit.

This is operationally important: a long DATUM Prime outage isn't just "shares accumulate locally." It's "miners disconnect and switch pools."

## Memory and capacity

Approximately 1 GB RAM for the gateway baseline, plus 1 GB per 1000 Stratum clients, plus the node's own RAM (per *Requirements*). The recommended `maxmempool=1000` and `blockreconstructionextratxn=1000000` on the node are about giving the local template-builder a richer mempool to draw from — orthogonal to the gateway itself.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — where this data flow sits in the larger stack
- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) — what crosses the gateway↔pool wire
- [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](deployment-and-node-config.md)) — `blocknotify` setup, port numbers, Docker NOTIFY caveats
- [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](stratum-usernames-and-modifiers.md)) — what gets attached to share submissions
- [[tides-payout|TIDES payout]] ([TIDES payout](tides-payout.md)) — coinbase generation transaction is what miners are credited via

## Sources

- [DATUM Gateway — README](../../raw/articles/2026-05-28-datum-gateway-readme.md) — *Node Configuration*, *Notes/Known Issues/Limitations*, *Docker* sections
- [DATUM Setup Guide](../../raw/articles/2026-05-28-ocean-datum-setup-guide.md) — confirms default stratum port `23334` and miner-config flow
