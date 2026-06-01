---
title: "iroh-blobs 0.95 — New features (iroh blog)"
source: https://www.iroh.computer/blog/iroh-blobs-0-95-new-features
type: article
tags: [iroh-blobs, connection-pool, 0.95, stream-traits, irpc]
date: 2026-06-01
publication_date: 2025-10-13
quality: 5
confidence: high
agent: 4
summary: "Post-rewrite stabilization landmark. Adds util::connection_pool::ConnectionPool (multi-endpoint concurrency with idle timeout, connection limits, 'wait for direct connection' hook). Introduces abstract request/response stream traits (Bytes-aware) so compression and other middleware can wrap protocols without forking iroh-blobs. Provider-side events extended via irpc with event masks for permission-based hash filtering."
---

# iroh-blobs 0.95 features

Stabilizes the 0.90 ground-up rewrite. Captures the current shape of iroh-blobs.

## ConnectionPool

`util::connection_pool::ConnectionPool` — manage multiple endpoint connections concurrently:

- Idle timeout
- Connection limits
- "Wait for direct connection" hook (avoid using a relayed connection if a direct one is in progress)

For an AI server fan-out workload (many subscribers pulling model weights concurrently), this is the primitive that prevents per-request connection setup overhead.

## Abstract stream traits

Bytes-aware request/response stream traits — middleware can wrap them without forking iroh-blobs. Use cases:

- Compression (zstd-on-the-wire)
- Custom logging / instrumentation
- Bandwidth shaping

Previously, modifying the wire required a fork. Now it's a wrapper.

## Provider events via irpc

- Event masks for permission-based hash filtering
- Provider can selectively expose events about specific hashes to specific consumers

Enables: "tell me when this hash becomes available, but only if I'm an allowed peer."

## Migration from 0.90 → 0.95 → 0.102

- 0.90 (2025-07-08) — ground-up rewrite. New request types and API shape.
- 0.95 (2025-10-13) — features added in this post
- 0.101 (2026-05-08) — downloader-task reaping, redb 4 upgrade, switched to iroh-util ConnectionPool
- 0.102 (2026-05-27) — breaking: update to iroh@1.0.0-rc.1 (current)

## See also

- [[2026-06-01-iroh-blobs-1-0-rc]]
- [[2026-06-01-iroh-blobs-poisoned-store-issue-233]]
