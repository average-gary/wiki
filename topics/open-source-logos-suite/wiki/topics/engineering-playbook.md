---
title: Engineering an Open-Source Logos Suite
type: topic
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
confidence: high
tags: [logos, bible-software, architecture, decentralized, oss, playbook]
sources:
  - "[[raw/articles/2026-05-27-logos-feature-surface-synthesis]]"
  - "[[raw/articles/2026-05-27-logos-cascadia-macula-data-availability]]"
  - "[[raw/articles/2026-05-27-oss-sword-project-crosswire]]"
  - "[[raw/articles/2026-05-27-oss-step-bible-tyndale]]"
  - "[[raw/articles/2026-05-27-data-stepbible]]"
  - "[[raw/articles/2026-05-27-data-oshb-wlc]]"
  - "[[raw/articles/2026-05-27-client-stepbible-data]]"
  - "[[raw/articles/2026-05-27-infra-text-iroh-blobs-protocol]]"
  - "[[raw/articles/2026-05-27-infra-sync-atproto-pds]]"
  - "[[raw/articles/2026-05-27-case-file-over-app]]"
---

# Engineering an Open-Source Logos Suite

Synthesized answer to the user's question: *"How could you engineer an open source Logos application suite? Is there decentralized infrastructure that could support something like this?"*

## TL;DR

**Yes, this is buildable in 2026** — and the licensing/data layer is more open than it has been in 30 years. The hard problem is *not* infrastructure; it's the **study-tool UX layer** above the text. The data substrate (SWORD modules + STEPBible-Data + OSHB + MACULA Greek + scrollmapper) covers ~80% of what Logos charges for. Logos's remaining moat is the curated knowledge graph (Factbook), reverse-interlinear alignments per translation, sermon-builder workflow, and library lock-in.

Decentralized infrastructure is **partially useful and oversold elsewhere**. Use it where it actually fits:
- **Text/library distribution** → Iroh blobs (BLAKE3-verified streaming over QUIC, range requests) + plain HTTPS mirrors as fallback. Treat IPFS as opt-in.
- **User notes/highlights/sermons sync** → Yjs/Automerge CRDT with hosted-default + self-host-optional. ATProto's `did:plc` graceful-recovery model is the only one that works for non-technical users.

**Architecture in one sentence**: *Plain markdown/USFM files on disk + a Rust core (Tauri 2 desktop, native shells on mobile via UniFFI) + SQLite FTS5 search + Yjs sync + a sandboxed plugin system + content-addressed library packages distributed via Iroh + HTTPS mirrors.*

## Why this is the moment

Three things changed in 2024-2026 that make an OSS Logos viable:

1. **STEPBible-Data (Tyndale House Cambridge, CC BY 4.0)** dropped a complete tagged Hebrew + Greek corpus with disambiguated Strong's, morphology, lexicons (TFLSJ — free LSJ derivative), proper-noun database, and versification mapping. This is the dataset Logos pays for.
2. **MACULA Greek (Clear Bible)** republishes SBLGNT with full syntactic trees openly — eroding Logos's Cascadia syntactic-search moat.
3. **Local-first software has matured.** Yjs is in production at Linear, JupyterLab, AFFiNE, Evernote. Iroh ships BLAKE3 + QUIC content-addressed blobs as a real protocol. Tauri 2 has the largest set of production cross-platform desktop apps (Spacedrive, GitButler, Cap).

The data is 80% there. The infrastructure is 80% there. What's missing is the integrated UX that makes it actually useful.

## What Logos actually is

Logos.com (Faithlife Corporation, founded 1992 in Bellingham, WA; bought by Cove Hill private equity) is an integrated Bible-study platform with:

| Layer | Logos's offering | OSS state |
|-------|-----------------|-----------|
| **Library** | 120k–250k ebooks; ~500 publishers; .logos proprietary format | Empty; copyright is the wall |
| **Text** | All major translations + originals + LXX + Vulgate + Aramaic | WEB, BSB, KJV, ASV, WLC, MorphGNT solved; ESV/NIV/NASB/NLT walled |
| **Search** | Word/lemma/morphology/syntax across 250k volumes | OSS has lemma; nobody has syntactic |
| **Reverse interlinears** | Per-translation aligned (English ↔ Greek/Hebrew) | Only KJV-aligned (Strong's) is open |
| **Factbook** | Curated entity graph (people/places/topics → verses + library) | Nothing equivalent |
| **Passage Guide** | Auto-aggregates user's library by passage | Nothing equivalent |
| **Sermon Builder** | Slide export, sermon manager, Faithlife Proclaim integration | Bibledit is closest; aimed at translators not preachers |
| **Sync** | Desktop/web/iOS/Android with offline | And Bible (Android) only |
| **Pricing** | $9.99–$19.99/mo OR Bronze/Silver/Gold/.../Portfolio $300–$5000+ perpetual | Free |

See [[../reference/logos-feature-surface|Logos feature surface]] and [[../concepts/study-tool-ux-gap|Study-tool UX gap]].

## The build, in five layers

### Layer 1 — Data (already exists, mostly free)

| Asset | Source | License | Use |
|-------|--------|---------|-----|
| Hebrew OT | OSHB / WLC | CC BY 4.0 | Default Hebrew text + morphology |
| Greek NT (text) | Byzantine MT or STEPBible TAGNT | PD / CC BY 4.0 | Default Greek text |
| Greek NT (morph) | MorphGNT | CC BY-SA | Morphology layer |
| Greek NT (syntax) | MACULA Greek (Clear Bible) | CC BY 4.0 | Cascadia-equivalent syntax trees |
| Lexicons | Strong's, BDB (1906), TFLSJ | PD / CC BY 4.0 | Word study layer |
| Cross-references | OpenBible.info | CC BY | Verse-to-verse links |
| Commentaries | Matthew Henry, JFB, Calvin (CCEL) | PD | Library starter |
| Modern English | WEB, BSB, KJV, ASV | PD | Default translations |
| Versification | STEPBible mapping | CC BY 4.0 | Translation→canonical mapping |
| Proper nouns | STEPBible TIPNR | CC BY 4.0 | Factbook seed |

**Walled** (BYO API key, ship as plugin): ESV (Crossway, free non-commercial API), NIV/NASB/NLT/CSB (royalty-bearing — direct license required).

**Engineering implication**: build text-agnostic. Ship the open stack by default; let users BYO API key for paid translations to shift the license burden onto the user. See [[../concepts/biblical-data-licensing|Biblical data licensing]] and [[../reference/open-data-corpus|Open data corpus]].

### Layer 2 — Storage and search

**Files-on-disk as ground truth.** Plain USFM (translations) + JSON (lexicons, morphology) + markdown (user notes/sermons). This is the Obsidian playbook and it consistently wins — see [[../concepts/file-over-app|File over app]].

**SQLite FTS5 as search index** with `unicode61` tokenizer (handles Hebrew + Greek natively), BM25 ranking, NEAR queries for clause-proximity, custom tokenizers emitting `lemma\0surface` tuples for morphology. Cross-platform; ships embedded; one file. See [[../concepts/search-and-indexing|Search and indexing]].

For Rust-only desktop builds with mass-corpus indexing throughput, Tantivy is a faster upgrade.

### Layer 3 — Client app

**Tauri 2 + Rust core, plus native shells where needed.**

- **Desktop (Win/Mac/Linux)**: Tauri 2. ~600KB binaries vs Electron's 100MB+. Spacedrive, GitButler, Cap as production references.
- **Mobile**: Tauri 2 mobile is rough (per existing [[../../../rust-multi-platform/wiki/concepts/_index|rust-multi-platform]] research). For compliance-grade iOS/Android, ship native SwiftUI/Compose shells over a UniFFI-wrapped Rust core (also borrowed from rust-multi-platform).
- **Web**: optional later — same Rust core compiled to WASM.

**Plugin system** is the moat extender — sermon builders, denominational extensions, language packs all live here. Reject Obsidian's all-in-process model (no sandboxing, no permissions). Use a hybrid:

- **Out-of-process extension host** (Node or worker) for full plugins — VS Code pattern
- **WASM-with-capabilities** for lightweight transforms — Zed/Figma pattern

See [[../concepts/client-architecture|Client architecture]] and [[../decisions/plugin-trust-model|Plugin trust model decision]].

### Layer 4 — Sync (user data)

**Yjs/yrs (Rust port) for CRDT sync of notes, highlights, reading plans, sermon drafts.** Most production-validated CRDT in 2026 (Linear, JupyterLab, AFFiNE, Evernote). Y.XmlElement maps cleanly to Cascadia-style annotations. Pluggable providers: `y-indexeddb` for local-only → `y-websocket` for hosted sync → `Hocuspocus` for self-host.

**Identity/recovery** is the hardest sub-problem. The only model that degrades gracefully for non-technical users is ATProto-style:

- **Default**: hosted account on a free PDS / sync server. Email-based recovery. 99% of users live here.
- **Optional upgrade**: self-custody rotation keys; document portability; self-host PDS for the 1%.
- **Never**: pure seed-phrase. Don't ship that to a pastor.

See [[../concepts/decentralized-sync|Decentralized sync]] and [[../concepts/identity-and-recovery|Identity and recovery]].

### Layer 5 — Library distribution

The library is **mostly static, mostly immutable, occasionally updated** — perfect shape for content addressing. Recommended stack:

- **Canonical packages**: Iroh-blobs HashSeq collections (BLAKE3-verified streaming, range requests). Fetch only Genesis 1 + the LSJ entry for "λόγος" without pulling 2 GB.
- **Trust anchor**: BLAKE3 root hashes published over plain HTTPS (DNSLink, GitHub releases) — gives you a signed manifest without depending on a P2P network's liveness.
- **Boring fallback**: HTTP range-request mirrors (Cloudflare R2, S3, university mirrors) for users behind UDP-blocking firewalls.
- **Opt-in**: IPFS (gateway), BitTorrent v2 (power users) as additional mirrors.

**Out**: ATProto blobs (PDS-bound, ~1MB caps, account-coupled — wrong shape for GB corpora). Hypercore (great fit, but JS/Bare-only ecosystem locks you into Pear runtime).

See [[../concepts/decentralized-text-distribution|Decentralized text distribution]] and [[../decisions/library-distribution|Library distribution decision]].

## Phased build plan

### Phase 0 — Foundation (1-2 months, 1 dev)
- Tauri 2 shell + Rust core scaffold
- SQLite FTS5 schema with multilingual tokenization
- Ingest WEB + WLC + MorphGNT + Strong's + STEPBible-Data
- Basic reading view, lemma search, Strong's lookup
- Yjs sync wired but local-only (`y-indexeddb`)

**Deliverable**: works as well as a basic STEP Bible clone but native, fast, and offline.

### Phase 1 — Study-tool parity (3-4 months, 2 devs)
- Reverse interlinear via STEPBible TAHOT/TAGNT alignments + KJV Strong's tags
- Word study panel (Strong's + BDB + TFLSJ + cross-references)
- Cross-reference panel (OpenBible.info)
- Notebooks + highlights with Yjs CRDT, hosted sync server
- Plugin SDK v0 (sandboxed worker, capability manifest)

**Deliverable**: 60% of Logos's free-tier UX. Real OSS competitor.

### Phase 2 — Logos differentiator parity (4-6 months, 2-3 devs)
- Syntactic search via MACULA Greek + UI for clause queries
- Factbook v0 (entity graph from STEPBible TIPNR + Wikidata + manual curation)
- Passage Guide v0 (aggregates plugins + user library by passage)
- Sermon Builder v0 (slide export, basic preaching workflow — Bibledit's data model is a starting point)
- Iroh-blob library packages with HTTPS-mirror fallback

**Deliverable**: 80% of Logos paid-tier UX for the open data. Defensible.

### Phase 3 — Mobile + ecosystem (ongoing)
- Native iOS (SwiftUI) + Android (Compose) shells over UniFFI-wrapped Rust core
- Plugin marketplace (sermon templates, language packs, denominational extensions)
- BYO-license adapters: ESV API plugin, NIV API plugin (user-supplied keys)
- Self-host docs: PDS, sync server, library mirror

**Deliverable**: cross-device parity with Logos. Self-hostable. Still free.

## What this is NOT trying to be

- **Not a Logos library reader.** Their .logos format is proprietary; users cannot port their books. This is a separate ecosystem.
- **Not a publisher partner network.** That's Logos's commercial moat. Don't fight there; let users BYO licensed translations.
- **Not "fully decentralized."** Per the case-study evidence, "credible exit" beats "actually federated" for adoption. Default to hosted sync; allow self-host. See [[../concepts/credible-exit|Credible exit principle]].
- **Not a translation tool** for Bible translators. That niche is occupied by Bibledit, Paratext, ScriptureForge.

## What kills the project

1. **Trying to clone Logos's library**. The publisher relationships are 30 years deep. Don't.
2. **Going all-in on a single decentralized stack** before product-market fit. Build the boring file+SQLite+HTTPS version first; add Iroh, Yjs hosting, plugins on top.
3. **Theological positioning**. Stay neutral on translation politics, denominational disputes, alignment with any single tradition. Ship the engineering; let users pick their texts.
4. **Premature mobile**. Tauri 2 mobile is still rough; native shells via UniFFI is the proven path but expensive. Land the desktop suite first.

## See Also

- [[../concepts/study-tool-ux-gap|Study-tool UX gap]]
- [[../concepts/biblical-data-licensing|Biblical data licensing]]
- [[../concepts/client-architecture|Client architecture]]
- [[../concepts/decentralized-text-distribution|Decentralized text distribution]]
- [[../concepts/decentralized-sync|Decentralized sync]]
- [[../concepts/file-over-app|File over app]]
- [[../concepts/credible-exit|Credible exit principle]]
- [[../reference/logos-feature-surface|Logos feature surface]]
- [[../reference/oss-bible-software-landscape|OSS Bible software landscape]]
- [[../reference/open-data-corpus|Open data corpus]]
- [[../reference/decentralized-infra-candidates|Decentralized infra candidates]]
- [[../decisions/plugin-trust-model|Plugin trust model]]
- [[../decisions/library-distribution|Library distribution]]
- [[../../output/_index|Outputs]]
