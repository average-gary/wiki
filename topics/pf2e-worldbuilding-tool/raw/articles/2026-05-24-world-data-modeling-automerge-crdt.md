---
title: "Automerge — JSON-like CRDT for Local-First Apps"
source: "https://github.com/automerge/automerge"
type: repo
date_fetched: 2026-05-24
date_published: unknown
tags: [data-model, crdt, sync, local-first, automerge]
quality: 5
credibility: high
path: world-data-modeling
summary: "Automerge is a JSON-CRDT library with Rust core + JS/WASM/C/Swift bindings, automatic merge of concurrent edits, an efficient sync protocol, and rich-text support. Automerge 3 cut memory ~10x. It's the canonical answer for 'local-first multi-device editable world data without a server.'"
---

# Automerge

## Data model
JSON-shaped: objects, arrays, counters, registers, plus a dedicated **Text** CRDT for long-form content with rich-text marks.

## Sync
- Each document is a CRDT with full edit history (compressed).
- Two replicas exchange changes via a **sync protocol** that negotiates which ops the other lacks — bandwidth-efficient even after long offline periods.
- No central server required; pluggable network adapters (WebSocket, BroadcastChannel, IndexedDB, file system).

## Bindings
- Rust (core, low-level) — `automerge` crate.
- JavaScript (`@automerge/automerge`) — most polished, includes React bindings.
- WASM, C FFI, Swift, Deno.

## Performance
- Automerge 3 (2024) reduced memory by ~10x; loading large documents now practical.
- Disk format compresses op history.

## Patterns
- **Repo + DocHandle** abstraction (in `automerge-repo`) — handles persistence, networking, garbage-collected document loading.
- **One doc per entity vs one big doc**: per-entity docs scale better (only sync what's open) but cross-doc references become app-level.

## Relevance to our tool
1. **The sync answer**: if we want multi-device or two-GMs-co-edit support without running a backend, Automerge is the off-the-shelf choice.
2. **Rich text is solved**: notes/journals can use Automerge's Text CRDT and still merge cleanly with concurrent edits.
3. **Doc-per-entity** lines up nicely with our typed-entity model: each Character/Location is its own Automerge doc, references are by ID, and the user only loads the docs they're viewing.
4. **Trade-off vs markdown files**: markdown gives git-style history and external tool access; Automerge gives real-time collab and conflict-free merge but is a binary format. Hybrid: markdown is the **export/portability format**, Automerge is the **live editing format**.
5. **LLM tool-use**: agents read/write through a tool API that operates on the JSON shape — same interface as a JSON document store.
