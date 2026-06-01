---
title: "iroh-blobs 0.102.0 — content-addressed blobs for iroh 1.0-rc.1"
source: https://github.com/n0-computer/iroh-blobs, https://docs.rs/iroh-blobs/latest/iroh_blobs/
type: repo
tags: [iroh-blobs, blake3, bao, verified-streaming, fs-store, downloader]
date: 2026-06-01
publication_date: 2026-05-27
quality: 5
confidence: high
agent: 2
summary: "iroh-blobs 0.102.0 (2026-05-27). Pinned to iroh = '=1.0.0-rc.1'. Default features: hide-proto-docs, fs-store, rpc. fs-store backed by redb 4 and reflink-copy. bao-tree = '0.16' is the BLAKE3 verified-streaming engine. IROH_BLOCK_SIZE = 16 KiB. Top-level entry: iroh_blobs::api::Store. Submodules: blobs, downloader, remote, tags. 0.101.0 added downloader-task reaping and switched to iroh-util ConnectionPool. README still calls the project pre-production; 'version 0.35 is recommended for production use' is stale advice."
---

# iroh-blobs 0.102.0

## Crate metadata

- **Version**: 0.102.0 (2026-05-27)
- **iroh dep**: pinned `iroh = "=1.0.0-rc.1"`
- **Description**: "content-addressed blobs for iroh"

## Cargo features

```toml
[features]
default = ["hide-proto-docs", "fs-store", "rpc"]
fs-store = ["dep:redb", "dep:reflink-copy", "bao-tree/fs"]
rpc = ["dep:noq", "irpc/rpc", "irpc/noq_endpoint_setup"]
metrics = []
hide-proto-docs = []
```

## Critical dependency

`bao-tree = "0.16"` with features `experimental-mixed`, `tokio_fsm`, `validate`, `serde` — this is the BLAKE3 verified-streaming engine. `blake3` is pulled transitively.

## Module layout

| Module     | Role |
|------------|------|
| `api`      | User-facing store API (`Store`, `Tag`, `TempTag`) |
| `store`    | Storage backends: `mem`, `fs`, `readonly_mem` |
| `protocol` | QUIC request/response wire protocol |
| `provider` | Server-side handler |
| `get`      | Low-level client |
| `ticket`   | Blob tickets |

## Constants

- `IROH_BLOCK_SIZE = 16384` (16 KiB) — chunk size for Bao verification

## Wire protocol summary

> "The requester opens a QUIC stream to the provider and sends the request. The provider answers with the requested data, encoded as BLAKE3 verified streams" — on the same connection.

This is the integrity guarantee on read: every byte is authenticated against the 32-byte root hash before being exposed to the application.

## GC

- `store::GcConfig`, `ProtectOutcome`, `ProtectCb` — protection hooks
- `Tag` (named persistent) vs `TempTag` (ephemeral) for keep-alive

## Recent release history

- **0.95** (2025-10-13) — added `util::connection_pool::ConnectionPool`, abstract request/response stream traits (Bytes-aware) for compression middleware
- **0.101** (2026-05-08) — downloader-task reaping, redb 4 upgrade, switched to iroh-util ConnectionPool
- **0.102** (2026-05-27) — breaking: update to iroh@1.0.0-rc.1

## Stale README warning

README still says "version 0.35 is recommended for production use" — that's pre-rewrite advice. The 0.90 (2025-07-08) ground-up rewrite is the current API; treat 0.35 docs as obsolete.

## See also

- [[2026-06-01-blake3-specs-bao]]
- [[2026-06-01-iroh-blobs-0-95-features-blog]]
- [[2026-06-01-iroh-blobs-poisoned-store-issue-233]]
