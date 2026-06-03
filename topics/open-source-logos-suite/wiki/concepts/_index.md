---
title: Concepts — open-source-logos-suite
type: index
created: 2026-05-27
updated: 2026-06-02
---

# Concepts

## Round 1 (2026-05-27)

- [[study-tool-ux-gap|Study-tool UX gap]] — what OSS Bible software has solved (data + reading) vs what it hasn't (Logos's integrated study UX)
- [[biblical-data-licensing|Biblical data licensing]] — open biblical data inventory; ESV/NIV/NASB walls; BYO-license strategy
- [[client-architecture|Client architecture]] — Tauri 2 + Rust core + UniFFI mobile shells + SQLite FTS5 + Yjs sync
- [[search-and-indexing|Search and indexing]] — query types, FTS5 vs Tantivy, morphology indexes, syntactic search
- [[decentralized-text-distribution|Decentralized text distribution]] — Iroh-blobs HashSeq + BLAKE3 + HTTPS mirrors hybrid
- [[decentralized-sync|Decentralized sync]] — Yjs/yrs CRDT + ATProto identity for user data
- [[identity-and-recovery|Identity and recovery]] — DID method comparison; ATProto did:plc as the only consumer-grade recovery model. **Stale as of 2026-06-02** — see [[nostr-key-rotation]] for corrected position; `/wiki:librarian` rewrite pending.
- [[file-over-app|File over app]] — design principle: plain files on disk = ground truth; app = view
- [[credible-exit|Credible exit principle]] — users want their data not held hostage, not full decentralization

## Round 2 (2026-06-02 — christ-is-lord assess follow-up research)

- [[nostr-key-rotation|Nostr key-rotation: 2026 state of the art]] — No merged NIP for rotation in 2026-06; NIP-26/NIP-06 still flagged unrecommended; PR #2137 most active but not consensus. christ-is-lord must document the gap and ship a kind:0 migration convention.
- [[macula-syntactic-search|MACULA syntactic search: query DSL + indexing]] — Clear-Bible/macula-greek + macula-hebrew lowfat XML under CC BY 4.0 (no SA); recommended schema `(macula_tokens + wordgroups + sentences + frames)` with `parent_id` + materialized path + `(lft,rgt)` interval encoding; Cascadia-flavoured textual DSL compiles to SQL self-joins.
- [[keyhive-small-group-sync|Keyhive: small-group E2EE CRDT sync (Ink & Switch March 2025)]] — pre-alpha, Apache-2.0; bundles convergent capabilities + BeeKEM CGKA (forward secrecy + post-compromise security) + Beelay sync over RIBLT; 3-4× bandwidth savings. Recommended posture: define `GroupSyncTransport` trait, ship feature-gated prototype, defer user exposure until v0.1 + audit.
- [[ai-bible-study-tools-2026|AI Bible-study tools 2026]] — Logos AI / Pulpit AI / Magisterium charge SaaS prices but publish zero architecture; YouVersion has no AI surface; OSS prior art tiny (~9 repos); citation-grounded local-LLM niche is unowned. Recommended plugin shape: capability manifest of `library.read + index.query + network.host:<llm>` (or `local-llm`) with citation-required default.
- [[walled-translation-api-revocation-history|Walled translation API revocation history (2024-2026)]] — ESV API doctrinal-conformity + at-will-revocation clauses still live 2026-06; Crossway pulled ESV from CrossWire SWORD (confirmed by AndBible FAQ); NIV/NASB/CSB have NO self-serve dev APIs; BYO-API-plugin posture (ADR-0000 §6) remains the only sane stance.
