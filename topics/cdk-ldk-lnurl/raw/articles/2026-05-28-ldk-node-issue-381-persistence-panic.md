---
title: "LDK Node #381 — panic-on-persistence-failure (open tracking issue)"
type: article
source: https://github.com/lightningdevkit/ldk-node/issues/381
fetched: 2026-05-28
published: 2024-09
confidence: high
tags: [ldk-node, footgun, persistence, panic, open-issue]
summary: Tracking issue for unaddressed panic-on-persistence-failure paths in LDK Node. Confirmed by maintainer (tnull) — fix blocked on rust-lightning, planned for v0.8. Direct relevance to Cashu mint reliability.
---

# LDK Node #381 — persistence-failure panics

Last comment: 2025-11-17. Status: **open**, blocked on upstream `rust-lightning`. Maintainer `tnull` confirms.

## What the issue says

LDK Node still has unaddressed panic-on-persistence-failure paths as of late 2025:

- A transient persistence failure (disk full, VSS network blip, KV store error) can cause LDK Node to **panic the process** rather than gracefully error
- Many of the panics live in upstream `rust-lightning` (the LDK protocol layer)
- Fix requires fully switching to `KVStore` for `ChannelMonitor` persistence, planned for v0.8

## Why this matters for a Cashu mint

The Cashu mint's reserve **is** the LN backend's wallet. Process panic mid-state-update has cascading consequences:

1. Process dies → operator restarts
2. On restart, `ChannelMonitor`s may have been persisted at an inconsistent point
3. Worst case: a force-close on recovery to "be safe", which destroys liquidity and could expose stale commitment txs

For a mint with thousands of users' ecash backed by LN channels, this is a high-severity class of bug — not theoretical, currently tracked, multi-quarter timeline to fix.

## Mitigation for operators

- Run LDK persistence on **reliable storage** (PostgreSQL via custom DynStore, or VSS with high uptime — not a flaky NVMe in a container)
- Set up process health monitoring + auto-restart, but accept that auto-restart can't fix corrupted state
- Have on-call procedure for "LDK panicked, what now?"
- For high-value deployments, consider running CDK with **CLN or LND backend** instead of LDK Node — both have multi-year operational track records

## Related issues

- [#857 — VSS panic during splicing](https://github.com/lightningdevkit/ldk-node/issues/857) (closed; same class of bug, demonstrated in CI)
- [#834 — TorConfig HTTP bypass](https://github.com/lightningdevkit/ldk-node/issues/834) (open; privacy footgun)
- [#913 — LSPS2 first HTLC fails on small channels](https://github.com/lightningdevkit/ldk-node/issues/913) (open; liquidity bootstrap footgun)
