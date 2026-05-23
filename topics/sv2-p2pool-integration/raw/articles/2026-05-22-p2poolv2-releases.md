---
title: "p2poolv2 release notes — v0.10.10 to v0.10.16"
source_url: https://github.com/p2poolv2/p2poolv2/releases
type: release-notes
ingested: 2026-05-22
quality: 5
confidence: high
tags: [p2poolv2, releases, performance, stratum-v1]
---

# p2poolv2 release notes (May 2026)

Authoritative dated record of project velocity and current SV1 protocol surface.

## Recent (last 2 weeks)
- **v0.10.16** (2026-05-19) — latest
- **v0.10.15** — worker statistics persistence with **6-hour worker / 3-day user grace periods** across reconnects
- **v0.10.13** — performance: ~33% latency reduction, ~51% p99 improvement, ~40% throughput gain via **precomputed merkle branches**
- **v0.10.12** — added `extranonce.subscribe` stratum extension support, max stratum connections limit, `StratumErrorCode` module, per-user share metrics
- **v0.10.11** — height-based DAG walking for share header sync replacing confirmed-chain approach

## Pattern
17 total releases. Active focus is **production-hardening the V1 stratum surface** + share-chain sync optimization. SV2 work is not on this release timeline.
