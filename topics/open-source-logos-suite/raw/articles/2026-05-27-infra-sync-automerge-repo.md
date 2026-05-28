---
title: "automerge-repo: Pluggable CRDT Sync for Local-First Apps"
source_url: "https://github.com/automerge/automerge-repo"
type: article
path: infra-sync
date_ingested: 2026-05-27
date_published: 2024-09-01
tags: [decentralized, sync, crdt, automerge, local-first, p2p]
quality: 5
confidence: high
summary: "automerge-repo wraps Automerge CRDTs with pluggable storage (IndexedDB, fs) and network adapters (WebSocket, MessageChannel, BroadcastChannel) for many-document local-first apps."
---

# automerge-repo: Pluggable CRDT Sync for Local-First Apps

## Key findings

- **Identity model**: None built-in. Documents are addressed by random `DocumentId`s; whoever has the ID + access to a peer that hosts it can read/write. Auth/identity is application-defined (Keyhive / Beelay project from Ink & Switch is the emerging answer for E2E + capability auth).
- **Storage adapters**: `automerge-repo-storage-indexeddb` (browser), `automerge-repo-storage-nodefs` (server / desktop). Pluggable.
- **Network adapters**: WebSocket (client + server reference impl `automerge-repo-sync-server`), MessageChannel (cross-iframe/worker), BroadcastChannel (cross-tab). Community: y-libp2p analog for Automerge in progress.
- **Sync model**: Per-document sync protocol; peers exchange Bloom-filter-like "have" states, then send minimal change deltas. Eventually consistent, no central authority.
- **Multi-device**: Trivial if both devices know the DocumentId and reach a common peer (sync server or another device). New device onboarding = give it the IDs + a peer.
- **Recovery**: Document survives as long as ANY peer holds it. No built-in encryption-at-rest; if you lose all devices and the sync server is plaintext you have a backup; if you encrypted you need the key.
- **Production apps**: Trellis-like prototypes, Pixelpusher, PushPin (Ink & Switch); growing use in Tonk, Patchwork, MUSE-style apps. No flagship consumer app yet.

## Notable quotes / specifics

- "Provides facilities to support working with many documents at once, as well as pluggable networking and storage."
- Storage and network are explicitly decoupled — same Automerge document can sync over websocket AND tab-to-tab simultaneously.

## Source notes

Best technical fit for rich notes, highlight threads, sermon drafts (CRDT semantics shine). But identity/auth/recovery are explicitly DIY — you must layer it. Pair with Nostr keypair or ATProto DID for identity, run a free hosted sync-server as default, allow self-host. Cheap MVP: IndexedDB + a single sync-server you operate.
