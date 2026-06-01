---
title: "iroh-blobs — resumable, BLAKE3-verified uploads"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-blake3-specs-bao.md
  - raw/papers/2026-06-01-bittorrent-v2-bep-52.md
  - raw/repos/2026-06-01-iroh-blobs-1-0-rc.md
  - raw/articles/2026-06-01-iroh-blobs-0-95-features-blog.md
  - raw/articles/2026-06-01-iroh-blobs-poisoned-store-issue-233.md
  - raw/articles/2026-06-01-blake3-bench-data.md
  - raw/articles/2026-06-01-tus-resumable-upload-protocol.md
tags: [iroh-blobs, blake3, bao, verified-streaming, fs-store, resumable]
---

# iroh-blobs — resumable uploads with BLAKE3 verification

The "send a 5 GB video to my AI server, survive Wi-Fi drops" pattern. Also: model weight distribution, dataset replication, multi-receiver fan-out.

## Why it's the right primitive

| Property | tus.io | **iroh-blobs / Bao** | BitTorrent v2 (BEP 52) |
|----------|--------|---------------------|------------------------|
| Source of truth | Server-side offset | Content hash (BLAKE3, 32B) | Content hash (SHA-256) |
| Resume | "What offset are you at?" | "What hashes do you have?" | Same |
| Whole-file integrity | Optional, end-of-stream | Mandatory, per-chunk against root | Mandatory, per-block |
| Multi-receiver | Re-upload to each | One root → many fetchers | Same |
| Crash mid-upload | Server retains partial; client must remember offset | Receiver retains partial; resumes by hash diff | Same |
| Chunk size | Variable | **16 KiB** (`IROH_BLOCK_SIZE`) | 16 KiB |

→ **For multi-receiver and crash-resilience, iroh-blobs strictly dominates tus.** For single-shot upload from a phone to one server, tus is simpler.

## How verified streaming works

BLAKE3's chunked tree hash is the cryptographic foundation. The Bao construction (per BLAKE3 spec §6.4) interleaves file bytes with hash-tree nodes so any byte range can be verified against a 32-byte root hash without reading the whole file. See [[blake3-specs-bao]].

```
file:    [chunk 0][chunk 1][chunk 2]...[chunk N]
                ↘     ↙       ↘     ↙
                  H₀₁         H₂₃
                       ↘   ↙
                        ROOT (32 bytes)
```

Two encodings:
- **Combined**: pre-order interleaving of file bytes + tree nodes
- **Outboard**: tree nodes in a sidecar file; file bytes untouched

Decoder validates final chunk before exposing length → defeats length-manipulation attacks.

## Crate surface (iroh-blobs 0.102.0, 2026-05-27)

```rust
use iroh_blobs::api::Store;
use iroh_blobs::store::fs::FsStore;
use iroh_blobs::Hash;

// Pin: iroh = "=1.0.0-rc.1", iroh-blobs = "=0.102"
let store = FsStore::load("./blobs").await?;

// Add (with progress)
let tag = store.blobs().add_path("/large/file").await?;
let hash: Hash = tag.hash();   // BLAKE3 root, 32 bytes

// Tag is a TempTag (auto-GC'd) until promoted:
let _persistent = tag.promote("my-model-weights").await?;

// Serve via iroh::Router
let router = Router::builder(endpoint)
    .accept(iroh_blobs::ALPN, store.protocol_handler())
    .spawn();

// Client: download by hash
let conn = endpoint.connect(addr, iroh_blobs::ALPN).await?;
let mut downloader = client.downloader(conn);
downloader.fetch(hash).await?;
// Resumes automatically on reconnect — the receiver knows what it has.
```

## Cargo features (defaults)

```toml
default = ["hide-proto-docs", "fs-store", "rpc"]
fs-store = ["dep:redb", "dep:reflink-copy", "bao-tree/fs"]
rpc = ["dep:noq", "irpc/rpc", "irpc/noq_endpoint_setup"]
```

## What 0.95 added (still relevant in 0.102)

- `util::connection_pool::ConnectionPool` — multi-endpoint concurrency with idle timeout
- Abstract Bytes-aware request/response stream traits — middleware (compression, logging) without forking iroh-blobs
- Provider events via irpc with permission-based hash filtering

See [[iroh-blobs-0-95-features-blog]].

## Performance on the GTX 1060 server (i7-7700HQ, AVX2)

Estimated single-thread BLAKE3: **~3-4 GiB/s** by cycle-per-byte extrapolation. Multi-thread (Rayon over 4 cores): **~12-15 GiB/s** plausible. See [[blake3-bench-data]].

→ Hashing is **not** the bottleneck. Network and SATA SSD are.

(Apple Silicon M1/M2 can be 30%+ slower than hardware-SHA-256 on a single core; not relevant on x86.)

## Production caveats

### Poisoned-store panic — issue #233

iroh-blobs 0.100 (and main as of issue filing) has unresolved data-availability bugs:

- `BaoFileStorage::take()` swaps state to `Poisoned` unconditionally; early-return path leaves the store permanently poisoned
- `HashContext::load()` treats *any* IO error as fatal poisoning

→ **A partial-upload + crash workflow can brick the store** until process restart. PR #214 softens the panic but root causes remain.

### README "production" claim is stale

The repo still says "version 0.35 is recommended for production use" — that's pre-rewrite advice. The 0.90 (2025-07-08) ground-up rewrite is the current API. Treat 0.35 docs as obsolete.

### Operator mitigations

1. Run iroh-blobs in a supervised systemd unit with restart on failure
2. Periodic store integrity check before declaring readiness
3. Use `mem` store for ephemeral things
4. Track issue #233 for actual fix
5. Wait for stable 1.0 before treating as production-grade for write-heavy workloads

## Use cases for the GTX 1060 server

| Use case | Why iroh-blobs fits |
|----------|---------------------|
| Phone uploads videos for transcription | Resumable + content-addressed → no offset bookkeeping |
| Distribute YOLO model weights to friend's homelabs | Multi-receiver, content-addressed, BLAKE3-verified |
| Sync training datasets between two GTX 1060 boxes | Same |
| Archive transcribed audio + diarized output | Persistent tags + BLAKE3 dedup |
| Push pre-built Whisper checkpoints from a CI box | Multi-receiver fan-out |

## See also

- [[blake3-specs-bao]] — the cryptographic primitive
- [[bittorrent-v2-bep-52]] — parallel design with SHA-256
- [[multi-alpn-router-pattern]] — how to expose this on the same Endpoint as moq + ssh
- [[iroh-tickets-and-qr-pairing]] — how clients find the server
- [[iroh-application-patterns-2026-synthesis]]
