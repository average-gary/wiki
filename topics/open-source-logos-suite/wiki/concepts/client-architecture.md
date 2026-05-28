---
title: Client Architecture
type: concept
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [client, tauri, rust, plugins, search, fts5, tantivy, cross-platform]
sources:
  - "[[raw/articles/2026-05-27-client-sqlite-fts5]]"
  - "[[raw/articles/2026-05-27-client-tantivy]]"
  - "[[raw/articles/2026-05-27-client-yjs-crdt]]"
  - "[[raw/articles/2026-05-27-client-obsidian-plugin-arch]]"
  - "[[raw/articles/2026-05-27-client-stepbible-data]]"
---

# Client Architecture

Recommended stack for an open-source Logos suite. Builds on existing [[../../../rust-multi-platform/wiki/_index|rust-multi-platform]] research; cross-references rather than duplicates that work.

## UI framework: Tauri 2 + Rust core

**Why Tauri 2:**
- ~600KB binaries (Spacedrive, GitButler, Cap as production references) vs. Electron's 100MB+
- Reuses native webview engines — Bible-text rendering is HTML/CSS, perfect fit
- Rust core means single performance-critical implementation across platforms
- Mature plugin/capability system (built into Tauri 2)
- Largest production app set among Rust desktop frameworks per [[../../../rust-multi-platform/wiki/concepts/_index|rust-multi-platform/concepts]]

**Why not Electron:**
- 3-5x binary size, 3-5x RAM
- Slower cold start
- No Rust core advantage; each platform reimplements in JS

**Why not Slint or Dioxus:**
- Slint iOS = tech preview as of 2026 ([[../../../rust-multi-platform/wiki/_index|rust-multi-platform]] cite)
- Smaller production app sets
- Less suitable for complex text rendering than webview-based approaches
- Slint is the alternative if native-renderer perf matters more than ecosystem

## Mobile: native shells over UniFFI

Tauri 2 mobile is rough as of 2026. Mobile a11y is weak across all Rust UI frameworks (per existing rust-multi-platform research).

**For compliance-grade iOS/Android**: ship native shells — SwiftUI on iOS, Jetpack Compose on Android — over a UniFFI-wrapped Rust core. The Rust core handles parsing, search, sync, plugin runtime; the native shell renders and handles platform UX.

**Cost**: 2-3x dev time vs. cross-platform. **Benefit**: real platform integration, real a11y, real perf. Logos itself does this (native iOS, native Android, separate desktop).

**Don't ship mobile until Phase 3.** Land desktop suite first; mobile is the hardest part.

## Plugin system

The plugin system is the moat extender — sermon builders, denominational extensions, language packs, AI integrations, BYO-license adapters all live here. The trust model matters at v1 because retrofitting trust later is impossible.

### Reject Obsidian's all-in-process JS model

Obsidian's plugin system is the most successful in the knowledge-app space, but the docs explicitly admit:
- No sandboxing
- No permission system
- Plugins inherit full host privileges (file system, network, secrets)

For a Bible-study app where plugins might handle BYO API keys, sermon drafts, and personal data, this is unacceptable.

### Adopt a hybrid

**Out-of-process extension host** (Node or Worker) for full plugins — VS Code pattern:
- Plugin runs in a separate process
- IPC via JSON-RPC
- Capability manifest declares required permissions
- User grants on install

**WASM with capabilities** for lightweight transforms — Zed/Figma pattern:
- WASM module + capability descriptors
- Pure functions over text → cheap, sandboxed
- Suitable for: text transformations, syntax-tree queries, simple UI panels

### Plugin SDK shape

```
manifest.json:  capabilities, entry points, signed by author key
runtime:        out-of-proc Node (full) or WASM (light)
extension API:  read text, query index, render panel, store user data
```

See [[../decisions/plugin-trust-model|Plugin trust model decision]].

## Search and indexing

**Primary**: SQLite FTS5 with `unicode61` tokenizer + custom morphology tokenizer.

Why FTS5:
- Cross-platform (cross-language; works in Rust, Swift, Kotlin, web via SQL.js)
- Embedded — single file, no server
- BM25 ranking
- NEAR queries enable clause-proximity search
- `unicode61` tokenizer handles Hebrew + Greek natively
- Custom tokenizers (`tokendata=1`) emit `lemma\0surface_form` tuples for morphological lookup

**Upgrade for Rust-only desktop**: Tantivy.
- Faster mass-corpus indexing throughput
- Richer analyzer pipelines (Lucene-style)
- Pure Rust, embeddable
- Use when full-corpus reindex performance dominates

**Avoid Meilisearch** unless a hosted-mode product (web-only) is acceptable.

### Search query types to support

1. **Word search** — surface form lookup
2. **Lemma search** — Strong's number or original-language lemma
3. **Morphology search** — "all imperfective verbs in Genesis"
4. **Syntactic search** — "subject + finite verb + direct-object NP" — needs syntax-graph index, separate from FTS
5. **Phrase / NEAR search** — "love within 5 words of neighbor"
6. **Boolean composition** — AND/OR/NOT across the above

See [[search-and-indexing|Search and indexing]] (TODO concept).

## Sync: Yjs / yrs

**Yjs** for CRDT sync of user notes, highlights, reading plans, sermon drafts. Most production-validated CRDT in 2026.

Production references:
- Linear (issue tracker)
- JupyterLab Real-Time Collaboration
- AFFiNE (knowledge management)
- Evernote (recently)

Why Yjs:
- Pluggable providers: `y-indexeddb` (local), `y-websocket` (hosted), `Hocuspocus` (self-host)
- Y.XmlElement maps cleanly to Cascadia-style annotations on biblical text
- Rust port available (`yrs`) for a single Rust-core implementation
- Active maintenance

Alternative: **Automerge** when richer history-querying matters more than text-merge perf. Also a fine choice; pick one and commit.

See [[decentralized-sync|Decentralized sync]].

## Data layer

**Files-on-disk as ground truth.** This is the Obsidian playbook and consistently wins (see [[file-over-app|File over app]]).

- Translations: USFM files
- Lexicons / morphology: JSON
- User notes / sermons: markdown
- Index: SQLite FTS5 (rebuildable from sources at any time)
- Sync state: Yjs document store (CRDT events)

**Critical**: never store user data only in a database. Always have a markdown/JSON representation that the user can `cd` into and read with `cat`.

## See Also

- [[../topics/engineering-playbook|Engineering playbook]]
- [[file-over-app|File over app]]
- [[decentralized-sync|Decentralized sync]]
- [[../decisions/plugin-trust-model|Plugin trust model]]
- [[../../../rust-multi-platform/wiki/_index|rust-multi-platform topic]]
