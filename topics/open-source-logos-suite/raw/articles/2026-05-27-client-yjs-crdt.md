---
title: "Yjs — High-Performance CRDT Framework for Local-First Sync"
source_url: "https://github.com/yjs/yjs"
type: repo
path: client
date_ingested: 2026-05-27
date_published: 2025-01-01
tags: [client, architecture, local-first, sync, crdt]
quality: 4
confidence: high
summary: "Yjs is the most production-validated CRDT toolkit: Y.Doc with Array/Map/Text/XmlElement types, sync via websocket/webrtc/indexeddb providers, Rust port (yrs), and shipping in AFFiNE, Linear, JupyterLab, Evernote, Gitbook."
---

# Yjs — High-Performance CRDT Framework for Local-First Sync

## Key findings

- **Four core CRDT types**: `Y.Array` (sequence with efficient mid-position insert/delete), `Y.Map` (key-value), `Y.Text` (rich text with formatting deltas), `Y.XmlElement`/`Y.XmlFragment` (hierarchical, XML-compatible — relevant for Bible markup or notes structured like Cascadia syntax graphs). All types nest; all observable.
- **Sync providers (pluggable, swappable)**:
  - `y-websocket` — client-server sync
  - `y-webrtc` — peer-to-peer with signaling servers (no central server data path)
  - `Hocuspocus` — extensible standalone server with persistence + webhooks (the productized backend)
- **Persistence providers**:
  - `y-indexeddb` — browser offline storage
  - `y-mongodb`, `y-postgresql` — server backends
- **Performance**: struct-merging, tombstone deletion, garbage collection. Strong on sequential-edit patterns (typical document editing). Generally outperforms Automerge in benchmarks for typing-heavy workloads.
- **Polyglot ports**: **Rust = `yrs` / `y-crdt`** (relevant to Tauri/UniFFI core), Python (`pycrdt`), WASM (`ywasm`), .NET (`ydotnet`). yrs makes Yjs viable as the sync layer in a Rust-core Logos suite.
- **Production-validated apps**: AFFiNE, Cargo, Gitbook, Evernote, Lessonspace, Huly, JupyterLab, **Linear**, AWS SageMaker. This is *the* CRDT in production.
- **Offline-first pattern**: combine network provider (state propagation when online) + persistence provider (survives restart) — app functions disconnected, eventual consistency on reconnect.

## Notable quotes / specifics

- yrs (Rust port) is what a Tauri app would embed; FFI via UniFFI per [[rust-multi-platform/mobile-ffi-decision-tree]] makes the same sync state available on iOS/Android.
- `Y.XmlElement` is interesting for biblical apps: Cascadia's syntax graph is XML-based, and Y.XmlElement could host collaborative annotation of syntax trees.

## Source notes

For the Logos-style suite's sync layer, **Yjs (or yrs in Rust) is the default recommendation** over Automerge for three reasons:
1. More production deployments at scale (Linear, JupyterLab proves serious workloads).
2. Better merge performance on text-heavy workloads (sermon notes, study commentaries).
3. Pluggable providers — start with `y-indexeddb` / local SQLite + sidecar sync server, swap to P2P or self-hosted Hocuspocus later without app rewrite.

**Trade-off**: Yjs's binary update format is opaque (good for merge perf, bad for "diff this" debugging). Automerge has more academic clarity and richer history-querying. For a Bible study app where users want "who edited this annotation when?", Automerge's history model is friendlier. **Recommendation**: Yjs/yrs for live document state + sermon notes; plain Git for raw markdown notes if user wants Git-style history; SQLite for the verse/lexicon corpus (read-mostly, doesn't need CRDT).
