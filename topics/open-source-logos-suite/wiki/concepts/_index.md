---
title: Concepts — open-source-logos-suite
type: index
created: 2026-05-27
updated: 2026-05-27
---

# Concepts

- [[study-tool-ux-gap|Study-tool UX gap]] — what OSS Bible software has solved (data + reading) vs what it hasn't (Logos's integrated study UX)
- [[biblical-data-licensing|Biblical data licensing]] — open biblical data inventory; ESV/NIV/NASB walls; BYO-license strategy
- [[client-architecture|Client architecture]] — Tauri 2 + Rust core + UniFFI mobile shells + SQLite FTS5 + Yjs sync
- [[search-and-indexing|Search and indexing]] — query types, FTS5 vs Tantivy, morphology indexes, syntactic search
- [[decentralized-text-distribution|Decentralized text distribution]] — Iroh-blobs HashSeq + BLAKE3 + HTTPS mirrors hybrid
- [[decentralized-sync|Decentralized sync]] — Yjs/yrs CRDT + ATProto identity for user data
- [[identity-and-recovery|Identity and recovery]] — DID method comparison; ATProto did:plc as the only consumer-grade recovery model
- [[file-over-app|File over app]] — design principle: plain files on disk = ground truth; app = view
- [[credible-exit|Credible exit principle]] — users want their data not held hostage, not full decentralization
