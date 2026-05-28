---
title: Engineering Playbook — Open-Source Logos Suite
type: playbook
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: warm
status: active
sources: see [[../wiki/_index]]
---

# Engineering Playbook — Open-Source Logos Suite

A practical "how would you actually build this" deliverable answering the user's question:
*"How could you engineer an open source logos.com application suite? Is there decentralized infrastructure that could support something like this?"*

## The short answer

**Yes, this is buildable in 2026.** The licensing layer is more open than ever (STEPBible-Data + MACULA Greek + OpenBible.info under CC BY 4.0 collectively covers ~80% of what Logos charges for). The infrastructure layer is mature where it matters (Tauri 2, SQLite FTS5, Yjs/yrs, ATProto did:plc, Iroh blobs).

The hard problem is **the integrated study UX** — Sermon Builder, Factbook, Passage Guide. That's where the wedge is.

**Decentralized infrastructure is partially useful.** Use it where it actually fits:

- **Library distribution** → Iroh blobs + BLAKE3 manifests over HTTPS + HTTP mirror fallback
- **User identity** → ATProto did:plc (custodial-default with self-custody upgrade)
- **User notes/sermons sync** → Yjs/yrs with hosted-default + self-host-optional

Don't use it where it doesn't:
- **Personal notes storage** → plain markdown files (Obsidian playbook)
- **Plugin distribution** → HTTPS + signatures
- **Search index** → SQLite FTS5

## Architecture in one sentence

> Plain markdown/USFM files on disk + a Rust core (Tauri 2 desktop, native shells on mobile via UniFFI) + SQLite FTS5 search + Yjs sync + a sandboxed plugin system + content-addressed library packages distributed via Iroh + HTTPS mirrors.

## The 5-layer build

### Layer 1 — Data (mostly already exists, free)

Default install ships:

| Asset | License | Source |
|-------|---------|--------|
| WEB, BSB, KJV, ASV English translations | PD | eBible.org |
| WLC + STEPBible TAHOT | CC BY 4.0 | OpenScriptures + STEPBible |
| Byzantine MT + STEPBible TAGNT | PD + CC BY 4.0 | STEPBible |
| MACULA Greek (syntax trees) | CC BY 4.0 | Clear Bible |
| Strong's, BDB, TFLSJ lexicons | PD + CC BY 4.0 | Various |
| OpenBible.info cross-references | CC BY | OpenBible.info |
| Matthew Henry, JFB, Calvin commentaries | PD | CCEL |
| STEPBible versification + TIPNR | CC BY 4.0 | STEPBible |

**Walled translations** (BYO API key plugin): ESV (Crossway free non-commercial), NIV/NASB/NLT/CSB (royalty-bearing).

See [[../wiki/concepts/biblical-data-licensing|Biblical data licensing]] and [[../wiki/reference/open-data-corpus|Open data corpus]].

### Layer 2 — Storage

**Plain files on disk as ground truth.** Per [[../wiki/concepts/file-over-app|File over app]]:

```
~/.bible-suite/
├── library/           # content-addressed, fetched on demand
│   ├── translations/  # USFM
│   ├── lexicons/      # JSON
│   ├── morphology/    # TSV (STEPBible format)
│   ├── syntax/        # XML (MACULA)
│   └── commentaries/  # markdown
├── notes/             # markdown — user content
├── highlights.jsonl   # append log
├── reading-plans.json
└── index.sqlite       # FTS5; rebuildable from sources
```

**Critical rule**: every byte of user data is a plain file the user can read with `cat`. The CRDT and SQLite layers are caches.

### Layer 3 — Client

**Desktop**: Tauri 2 + Rust core. ~600KB binaries. Spacedrive / GitButler / Cap as production references.

**Mobile**: native SwiftUI (iOS) + Jetpack Compose (Android) shells over a UniFFI-wrapped Rust core. Tauri 2 mobile is too rough as of 2026.

**Plugin system**: hybrid — out-of-process Node/Worker (full plugins) + WASM with capabilities (lightweight transforms). Capability manifests; user grants on install.

See [[../wiki/concepts/client-architecture|Client architecture]] and [[../wiki/decisions/plugin-trust-model|Plugin trust model]].

### Layer 4 — Search and sync

**Search**: SQLite FTS5 with `unicode61` tokenizer (Hebrew + Greek native) + custom morphology tokenizer emitting `lemma\0surface` tuples. Tantivy as Rust-only desktop upgrade for mass-corpus indexing.

**Search query types supported**: word, lemma (Strong's), morphology, syntactic (MACULA tree queries), NEAR, boolean.

**Sync**: Yjs/yrs CRDT for user notes/highlights/sermons. Pluggable providers (`y-indexeddb` → `y-websocket` → `Hocuspocus`). ATProto did:plc for identity with hosted-default + self-custody-optional.

See [[../wiki/concepts/search-and-indexing|Search and indexing]] and [[../wiki/concepts/decentralized-sync|Decentralized sync]].

### Layer 5 — Library distribution

**Hybrid stack**:

1. **Trust anchor**: project-signed manifest over HTTPS listing every package's BLAKE3 root
2. **Canonical packages**: Iroh-blobs HashSeq collections (BLAKE3-verified streaming, range requests, P2P when peers available)
3. **Boring fallback**: HTTP range-request mirrors (Cloudflare R2, S3, university hosting)
4. **Opt-in**: IPFS gateway (for users who want it), BitTorrent v2 (power users), GitHub releases (simplest)

Universities, churches, denominational orgs can run mirror nodes trivially. Project shutdown ≠ content unreachable.

See [[../wiki/concepts/decentralized-text-distribution|Decentralized text distribution]] and [[../wiki/decisions/library-distribution|Library distribution]].

## Phased build plan

### Phase 0 — Foundation (1-2 months, 1 dev)

- Tauri 2 shell + Rust core scaffold
- SQLite FTS5 schema with multilingual tokenization
- Ingest WEB + WLC + STEPBible TAHOT/TAGNT + Strong's
- Basic reading view, lemma search, Strong's lookup
- Yjs sync wired but local-only (`y-indexeddb`)

**Deliverable**: works as well as a basic STEP Bible clone but native, fast, and offline.

**Risk**: data ingestion glue is tedious; STEPBible TSV → indexed SQLite is the longest single task.

### Phase 1 — Study-tool parity (3-4 months, 2 devs)

- Reverse interlinear via STEPBible alignments + KJV Strong's tags
- Word study panel (Strong's + BDB + TFLSJ + cross-references)
- Cross-reference panel (OpenBible.info)
- Notebooks + highlights with Yjs CRDT, hosted sync server
- Plugin SDK v0 (sandboxed Worker, capability manifest)

**Deliverable**: 60% of Logos free-tier UX. Real OSS competitor.

**Risk**: plugin SDK design — get it wrong and the ecosystem can't form.

### Phase 2 — Logos differentiator parity (4-6 months, 2-3 devs)

- Syntactic search via MACULA Greek + UI for clause queries
- Factbook v0 (entity graph from STEPBible TIPNR + Wikidata + curation)
- Passage Guide v0 (aggregates plugins + user library by passage)
- Sermon Builder v0 (slide export, basic preaching workflow; Bibledit's data model as starting point)
- Iroh-blob library packages with HTTPS-mirror fallback
- ATProto identity layer

**Deliverable**: 80% of Logos paid-tier UX for the open data. Defensible.

**Risk**: syntactic search UX is a research-grade UI problem. Start with a textual DSL + canned queries; tree-pattern editor in Phase 3.

### Phase 3 — Mobile + ecosystem (ongoing)

- Native iOS (SwiftUI) + Android (Compose) shells over UniFFI-wrapped Rust core
- Plugin marketplace (sermon templates, language packs, denominational extensions)
- BYO-license adapter plugins: ESV API, NIV API, NASB API
- Self-host docs: PDS, Hocuspocus, library mirror

**Deliverable**: cross-device parity with Logos. Self-hostable. Still free.

**Risk**: native mobile is 2-3x dev time; only ship after desktop has product-market fit.

## What this is NOT trying to be

| Don't try to be | Why |
|----------------|-----|
| A Logos library reader | Their .logos format is proprietary; users cannot port their books |
| A publisher partnership network | Logos has 30-year publisher relationships — that's their commercial moat |
| "Fully decentralized" | Per case-study evidence, "credible exit" beats "actually federated" for adoption |
| A translation tool | That niche is occupied by Bibledit, Paratext, ScriptureForge |

See [[../wiki/concepts/credible-exit|Credible exit principle]].

## What kills the project

1. **Trying to clone Logos's library** → don't
2. **Going all-in on a single decentralized stack before product-market fit** → build the boring file+SQLite+HTTPS version first
3. **Theological positioning** → stay neutral; ship engineering; let users pick texts
4. **Premature mobile** → land desktop suite first; mobile is the hardest part
5. **Plugin trust gone wrong** → get capability model right at v1 (cf. Obsidian's regret)
6. **Marketing as "decentralized"** → market as "your data, your way"

## Resource estimate

| Phase | Duration | Team | Outcome |
|-------|----------|------|---------|
| 0 | 1-2 months | 1 dev | STEP Bible clone, native, offline |
| 1 | 3-4 months | 2 devs | 60% Logos free-tier; sync; plugin SDK |
| 2 | 4-6 months | 2-3 devs | 80% Logos paid-tier (open data); ATProto; Iroh distribution |
| 3 | ongoing | 3+ devs | Native mobile; plugin marketplace; self-host stack |

**Total to viable Logos competitor (Phase 2)**: ~9-12 months, ~2-3 devs full-time. ~$300-500k labor cost if commercial; entirely volunteer-feasible if OSS.

## Decentralized infra summary

| Use case | Technology | Why | Status |
|----------|-----------|-----|--------|
| Library distribution | Iroh blobs HashSeq + HTTPS mirrors | Content-addressed; range fetch; tamper detection; community mirror | ✅ Recommended |
| User identity | ATProto did:plc | Only consumer-grade graceful recovery model | ✅ Recommended |
| User data sync | Yjs/yrs CRDT | Production track record; pluggable providers | ✅ Recommended |
| Plugin distribution | HTTPS + signatures | Plugins are tiny; no need for content addressing | ✅ Recommended |
| Public broadcasts (optional) | Nostr | Lightweight signed events | ⚠️ Plugin |
| User notes storage | Plain markdown files | Obsidian playbook; consistent winner | ✅ Required |
| ❌ Pure IPFS | — | Brave dropped; production = HTTP gateway | ❌ Skip |
| ❌ ATProto blobs | — | PDS-bound, ~1MB cap, wrong shape for GB corpora | ❌ Skip |
| ❌ Hypercore | — | JS/Bare-only; locks into Pear runtime | ❌ Skip |
| ❌ Solid PODs | — | 10 years of hype, near-zero adoption | ❌ Skip |

## The frame for users

Not "the decentralized Bible app." Pitch as:

> Your Bible study, your data, your way. Pick our hosted sync or self-host or just keep files on disk. The app is open source; the data is open formats; the texts are open licenses. Walk away whenever — your work comes with you.

That's the message. Decentralization is mechanism, not message.

## Where to read deeper

- [[../wiki/topics/engineering-playbook|Engineering playbook]] (full topic synthesis)
- [[../wiki/concepts/study-tool-ux-gap|Study-tool UX gap]] (the wedge)
- [[../wiki/concepts/biblical-data-licensing|Biblical data licensing]] (build the open stack; BYO walled)
- [[../wiki/concepts/client-architecture|Client architecture]] (Tauri 2 + Rust + UniFFI)
- [[../wiki/concepts/decentralized-text-distribution|Decentralized text distribution]] (Iroh + HTTPS hybrid)
- [[../wiki/concepts/decentralized-sync|Decentralized sync]] (Yjs + ATProto identity)
- [[../wiki/concepts/identity-and-recovery|Identity and recovery]] (custodial-default + self-custody upgrade)
- [[../wiki/concepts/file-over-app|File over app]] (design principle)
- [[../wiki/concepts/credible-exit|Credible exit]] (the marketing frame)
- [[../wiki/reference/logos-feature-surface|Logos feature surface]]
- [[../wiki/reference/oss-bible-software-landscape|OSS Bible software landscape]]
- [[../wiki/reference/open-data-corpus|Open data corpus]]
- [[../wiki/reference/decentralized-infra-candidates|Decentralized infra candidates]]
- [[../wiki/decisions/plugin-trust-model|Plugin trust model]]
- [[../wiki/decisions/library-distribution|Library distribution]]
