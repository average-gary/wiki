---
title: "Plan: christ-is-lord — a Logos replacement Bible-study app"
type: plan
format: roadmap
sources:
  - "[[../wiki/topics/engineering-playbook]]"
  - "[[../wiki/concepts/study-tool-ux-gap]]"
  - "[[../wiki/concepts/biblical-data-licensing]]"
  - "[[../wiki/concepts/client-architecture]]"
  - "[[../wiki/concepts/search-and-indexing]]"
  - "[[../wiki/concepts/file-over-app]]"
  - "[[../wiki/concepts/decentralized-text-distribution]]"
  - "[[../wiki/concepts/decentralized-sync]]"
  - "[[../wiki/concepts/identity-and-recovery]]"
  - "[[../wiki/concepts/credible-exit]]"
  - "[[../wiki/reference/logos-feature-surface]]"
  - "[[../wiki/reference/oss-bible-software-landscape]]"
  - "[[../wiki/reference/open-data-corpus]]"
  - "[[../wiki/reference/decentralized-infra-candidates]]"
  - "[[../wiki/decisions/plugin-trust-model]]"
  - "[[../wiki/decisions/library-distribution]]"
  - "[[../output/playbook-engineering-2026-05-27]]"
generated: 2026-05-28
repo: /Users/garykrause/repos/christ-is-lord
team: solo, full-time, max velocity
wedge: full Phase 0 (STEP-Bible-clone-but-native-and-fast)
platform: desktop-only for v1
infra-posture: Iroh library distribution + boring (hosted) sync
---

# Plan: christ-is-lord — a Logos replacement Bible-study app

> Generated from [open-source-logos-suite](../_index.md) wiki (17 articles consulted).
> Repo: `/Users/garykrause/repos/christ-is-lord` (currently empty — only `.git`).
> Team: solo, full-time, max velocity.

## Executive Summary

We're building a desktop Bible-study application — repo `christ-is-lord` — that replicates the Logos.com feature surface using only open-licensed biblical data, and ships with Iroh-based content-addressed library distribution from day one. v1 targets the wiki's full Phase 0 deliverable (STEP-Bible-clone-but-native-and-fast: reading, lemma search, Strong's lookup over WEB + WLC + STEPBible TAHOT/TAGNT) plus the integrated Logos study-tool UX (Sermon Builder, Factbook, Passage Guide, syntactic search) introduced in subsequent phases. Stack: **Tauri 2 + Rust core + SQLite FTS5 + Yjs/yrs + Iroh-blobs + HTTPS mirrors**. Mobile is explicitly deferred to a later phase per the wiki's strong recommendation.

## Architecture Decisions

### Decision 1: Tauri 2 + Rust core (not Electron, not Slint, not native-only)

**Context**: [[../wiki/concepts/client-architecture|Client architecture]] documents Tauri 2 as the production winner among Rust desktop frameworks (Spacedrive, GitButler, Cap as references; ~600KB binaries vs. Electron's 100MB+). Bible-text rendering is HTML/CSS — a webview is the right primitive.

**Options considered**:
- **Tauri 2 + Rust core** — small binary, Rust speed, mature plugin/capability system, webview perfect for text
- **Electron** — 3-5x size and RAM, no Rust core advantage, JS-per-platform reimplementation
- **Slint / Dioxus / egui** — smaller production app sets, weaker text-rendering story, mobile a11y gap (per [[../../rust-multi-platform/wiki/_index|rust-multi-platform]] research)

**Decision**: Tauri 2 + Rust core (`logos_core`) compiled as a Rust crate, fronted by a Tauri webview (TypeScript + a UI framework — TBD in Phase 0).

**Consequences**: We commit to Rust as the cross-platform compute language now. Mobile becomes UniFFI-wrapped native shells later. The webview is fine for desktop typography; we accept that ultra-custom layout (Cascadia-style syntax-tree visualizations) may need bespoke canvas/SVG components.

### Decision 2: Files-on-disk as ground truth, SQLite FTS5 as derived index

**Context**: [[../wiki/concepts/file-over-app|File over app]] cites the empirical record: Obsidian/Logseq (files-on-disk) won; Roam/Notion/Anytype (cloud-blob) churned or stalled. Power users will not adopt apps that take `grep` away.

**Options considered**:
- **Files-on-disk + SQLite FTS5 derived index** — ground truth is portable, index is rebuildable
- **SQLite-only** — faster to build, but locks user data into a binary blob
- **CRDT-only (Yjs document store)** — tempting because sync becomes trivial, but breaks the "credible exit" principle

**Decision**: Plain files (USFM, JSON, TSV, markdown) are the source of truth in `~/.christ-is-lord/`. SQLite FTS5 (`index.sqlite`) is rebuildable cache. Yjs document is a secondary sync log, not ground truth.

**Consequences**: Slightly more I/O; per-file write semantics on edits. Pays back as: (a) any text editor works, (b) git/Dropbox/Syncthing sync works without us, (c) plugins can read user data without an API.

### Decision 3: Iroh-blobs for library distribution from day one (boring sync stays hosted)

**Context**: [[../wiki/decisions/library-distribution|Library distribution]] recommends a hybrid: Iroh-blobs HashSeq collections (BLAKE3-verified, range-fetch, P2P when peers exist) + project-signed manifest over HTTPS + HTTP-range-request mirror fallback. [[../wiki/concepts/decentralized-text-distribution|Decentralized text distribution]] explicitly rejects pure IPFS (Brave dropped), ATProto blobs (~1MB cap, wrong shape), and Hypercore (JS-only).

**Options considered**:
- **Iroh-blobs from day one + HTTPS fallback** — content-addressed, BLAKE3-verified, mirror-friendly, demonstrates the decentralization pitch
- **HTTPS only at v1, defer Iroh** — simpler ops, but the "credible exit" story stays vaporware
- **IPFS / BitTorrent v2 / GitHub Releases as primary** — all rejected by the wiki

**Decision**: Iroh-blobs is the canonical distribution path; HTTPS mirrors via Cloudflare R2 (or equivalent) are the always-on fallback. The trust anchor is a project-signed manifest of BLAKE3 roots over HTTPS — clients verify content regardless of how it arrives.

**Consequences**: We adopt the `iroh` and `iroh-blobs` crates in Phase 0. We accept the operational cost of running ≥1 always-on Iroh node + an R2 bucket. Universities, churches, and denominational orgs can run mirror nodes trivially — that's the credible-exit story.

### Decision 4: Hosted Yjs sync (defer ATProto identity to later)

**Context**: User answered "Iroh library + boring sync." [[../wiki/concepts/decentralized-sync|Decentralized sync]] recommends Yjs/yrs for CRDT user-data sync; [[../wiki/concepts/identity-and-recovery|Identity and recovery]] recommends ATProto did:plc (custodial-default with self-custody upgrade) but acknowledges hosted-only is a fine v1 posture.

**Options considered**:
- **Hosted Yjs sync, opaque user IDs at v1** — simplest, fastest to ship, no identity infra to debug
- **Yjs + ATProto did:plc from v1** — adds graceful key recovery story, but doubles the moving parts
- **No sync at v1** — tempting for solo dev, but cross-device sync is one of the wiki's named OSS gaps

**Decision**: Phase 0 wires Yjs but local-only (`y-indexeddb`/`y-leveldb`). Phase 1 adds a Hocuspocus-backed `y-websocket` sync server we run, with simple email/password identity. ATProto did:plc lands in Phase 2.

**Consequences**: We don't need to solve graceful key recovery in v1. We do need to design account schemas now to migrate to ATProto did:plc later without breaking users. Migration plan is captured in Phase 2.

### Decision 5: Hybrid plugin trust model from v1 (out-of-process Node + WASM)

**Context**: [[../wiki/decisions/plugin-trust-model|Plugin trust model]] explicitly rejects Obsidian's all-in-process JS model (no sandboxing, plugins inherit host privileges). The wiki names "Plugin trust gone wrong" as a project-killer.

**Options considered**:
- **Hybrid out-of-proc Node (full plugins) + WASM-with-capabilities (light transforms)** — VS Code + Zed/Figma pattern
- **Obsidian-style in-process JS** — rejected: BYO API keys + sermon drafts must not share host privileges
- **WASM-only** — too constrained for full plugins (sermon-builder UI, AI integrations)
- **No plugins at v1** — but the plugin SDK shape determines the data model; getting this wrong later is unrecoverable

**Decision**: Plugin SDK v0 ships in Phase 1, but the *capability manifest schema and IPC protocol* are designed in Phase 0 alongside the data model. v0 supports the out-of-process Node host with capability manifests. WASM lightweight transforms ship in Phase 2.

**Consequences**: We write the IPC layer (JSON-RPC over stdio or Unix sockets) early. We avoid Obsidian's mistake at v1. The core Rust code stays free of plugin globals — plugins are guests, not first-class.

### Decision 6: Open-data-only at v1 — no walled translations

**Context**: [[../wiki/concepts/biblical-data-licensing|Biblical data licensing]] documents the legal landscape: STEPBible TAHOT/TAGNT + MACULA Greek + WEB/BSB/KJV/ASV + Strong's + BDB + TFLSJ + OpenBible.info xrefs cover ~80% of what Logos charges for. ESV/NIV/NASB/NLT/CSB require either non-commercial-only API (ESV) or per-user royalties (the rest). The wiki's strategy: BYO-API-key plugins shift the license burden to the user.

**Options considered**:
- **Open data only at v1, BYO-API-key plugins for walled translations from Phase 2** — clean legal posture, ships fast
- **Negotiate ESV API integration at v1** — Crossway's doctrinal-revocation clause is a kill-switch we won't accept
- **Negotiate commercial NIV/NASB/NLT/CSB** — premature for a solo OSS project pre-PMF

**Decision**: v1 ships with WEB, BSB, KJV, ASV, WLC, Byzantine MT, STEPBible TAHOT/TAGNT, MACULA Greek, Strong's, BDB, TFLSJ, OpenBible.info, Matthew Henry, JFB. BYO-API-key plugins for walled translations land in Phase 2 (ESV first because it's free for non-commercial; NIV/NASB/NLT/CSB later if there's demand).

**Consequences**: We never ship copyrighted text. License terms travel with plugins. We sidestep Crossway's doctrinal-revocation kill-switch.

### Decision 7: Strong's H/G numbers as the universal join key

**Context**: [[../wiki/concepts/biblical-data-licensing|Biblical data licensing]] §3 — Strong's numbers are PD and the de-facto canonical ID for cross-translation lookup. STEPBible's versification mapping (CC BY 4.0) handles MT/LXX/English numbering differences.

**Decision**: All search, lemma, and lexicon ops normalize through Strong's H/G numbers where possible. Our database schema treats Strong's IDs as foreign keys; surface forms are projections.

**Consequences**: Avoids G/K numbering (Logos-proprietary). Easy interop with any open dataset that uses Strong's. Use STEPBible versification mapping rather than rolling our own.

## Implementation Phases

### Phase 0 — Foundation (target: 6-8 weeks, solo full-time)

**Goal**: Match the wiki's Phase 0 deliverable verbatim — STEP-Bible-clone-but-native-fast-offline — and have Iroh-blobs library distribution working end-to-end so the "credible exit" story is real from day one.

**Week-by-week sequencing** (solo full-time, max velocity):

**Week 1 — Repo skeleton + data ingestion spike**
- [ ] Tauri 2 scaffold (`pnpm create tauri-app`); pick UI framework (recommend SolidJS or Svelte for perf; React if you're faster in it)
- [ ] Rust workspace: `logos_core` (library), `logos_app` (Tauri binary), `logos_ingest` (CLI for data pipeline)
- [ ] CI: macOS + Linux + Windows builds via GitHub Actions on push
- [ ] Spike: download STEPBible TAHOT/TAGNT TSV; parse one book end-to-end into a typed Rust struct
- [ ] Decide directory layout: `~/.christ-is-lord/{library,notes,highlights.jsonl,reading-plans.json,index.sqlite}` per [[../wiki/concepts/file-over-app|File over app]]

**Week 2 — SQLite FTS5 schema + multilingual tokenization**
- [ ] SQLite FTS5 with `unicode61` tokenizer + custom morphology tokenizer emitting `lemma\0surface` tuples (per [[../wiki/concepts/client-architecture|Client architecture]] §search)
- [ ] Verse table: `(book, chapter, verse, translation_id, text)` with FTS5 over `text`
- [ ] Word table: `(verse_id, position, surface, lemma, strongs, morph)` with FTS5 over `lemma`
- [ ] Strong's lexicon table + BDB + TFLSJ
- [ ] Versification mapping table (STEPBible) — pluggable; default English
- [ ] Migration system (`refinery` or `rusqlite_migration`)

**Week 3 — Data pipeline: ingest the open stack**
- [ ] WEB, BSB, KJV, ASV (USFM from eBible.org) → verse table
- [ ] WLC + STEPBible TAHOT (Hebrew + Strong's + morph) → verse + word tables
- [ ] Byzantine MT + STEPBible TAGNT (Greek + Strong's + morph) → verse + word tables
- [ ] Strong's, BDB, TFLSJ → lexicon tables
- [ ] OpenBible.info cross-references → xref table
- [ ] All ingest runs reproducibly via `logos_ingest` CLI; outputs hashed against expected BLAKE3 roots

**Week 4 — Reading view + word study UI**
- [ ] Reader: passage by reference (book/chapter/verse range); WEB default; toggle translations
- [ ] Click word → popover with Strong's + BDB/TFLSJ + morphology
- [ ] Lemma search panel: enter Strong's number → all verses with that lemma, ranked
- [ ] Cross-reference panel for the active verse (OpenBible.info)
- [ ] Keyboard shortcuts (Logos-parity: `g` to go-to, `/` to search)

**Week 5 — Iroh-blobs library distribution**
- [ ] Package the ingested library as Iroh-blobs HashSeq collections per [[../wiki/decisions/library-distribution|Library distribution]]
- [ ] Project-signed manifest (Ed25519) listing every package's BLAKE3 root, served over HTTPS
- [ ] R2 bucket as the always-on HTTP-range mirror
- [ ] Stand up one Iroh node (cheap VM) as the canonical seed
- [ ] In-app "Library" UI: browse available packages, download via Iroh, fall back to HTTPS, verify BLAKE3 against manifest before activating
- [ ] Default install bundles a small "starter" library (WEB + Strong's only); rest are on-demand fetches

**Week 6 — Notes + highlights (Yjs local-only)**
- [ ] Notes are markdown files in `~/.christ-is-lord/notes/` (file-over-app)
- [ ] Highlights are an append-log JSONL (`highlights.jsonl`)
- [ ] Yjs/yrs wired with `y-indexeddb` (or `y-leveldb` via Tauri filesystem) for local-only conflict resolution
- [ ] Notes editor (Markdown with live preview; reuse a TS lib like Milkdown or CodeMirror)
- [ ] "Open in your editor" button that launches `$EDITOR` on the file

**Weeks 7-8 — Polish, packaging, docs, public release**
- [ ] Notarized macOS DMG; signed Windows installer; AppImage + .deb for Linux
- [ ] Auto-update via Tauri's updater plugin (signed manifest)
- [ ] README + install docs + minimal user guide
- [ ] Iroh node + R2 mirror documented for community to replicate
- [ ] **Release: christ-is-lord v0.1.0**

**Dependencies**: None — fresh start.

**Validation**:
- Cold install on macOS/Windows/Linux completes in <90 seconds with starter library downloaded.
- Lemma search for `H430` (Elohim) returns ≥2,500 verses in <500ms.
- User can edit a note in `~/.christ-is-lord/notes/` from any text editor and the app picks up the change on relaunch.
- Library package downloaded via Iroh verifies BLAKE3 against the manifest; HTTPS-mirror fallback works when the Iroh node is down.

**Wiki grounding**: [[../output/playbook-engineering-2026-05-27|Engineering playbook]] §"Phase 0 — Foundation" + [[../wiki/concepts/client-architecture|Client architecture]] (full stack) + [[../wiki/decisions/library-distribution|Library distribution]] (Iroh + HTTPS hybrid).

**Risks**:
- Data-ingestion glue is the longest single task. STEPBible TSV → indexed SQLite is tedious. Mitigation: write `logos_ingest` as a separate crate so it can be iterated independently.
- Iroh ops cost: an always-on node is needed for new users with no peers. Mitigation: cheap VM ($5/mo); R2 fallback always works.

---

### Phase 1 — Study-tool parity (target: 10-14 weeks)

**Goal**: 60% of Logos free-tier UX. Real OSS competitor. Hosted sync goes live.

**Tasks**:
- [ ] Reverse interlinear via STEPBible alignments (WEB/BSB/KJV → Greek/Hebrew); UI renders aligned word pairs above/below the text per [[../wiki/concepts/study-tool-ux-gap|Study-tool UX gap]] §5
- [ ] Word study panel: Strong's + BDB + TFLSJ + cross-references aggregated per click
- [ ] Cross-reference panel powered by OpenBible.info (already in Phase 0; this phase = better UX)
- [ ] **Sync server**: Hocuspocus + `y-websocket`; deploy on Fly.io or Railway. Email/password identity (Argon2). Schema designed to migrate to ATProto did:plc later.
- [ ] In-app sign-in flow; cross-device sync of notes, highlights, reading position
- [ ] **Plugin SDK v0**:
  - Capability manifest schema (per [[../wiki/decisions/plugin-trust-model|Plugin trust model]])
  - Out-of-process Node host with JSON-RPC IPC
  - Plugin lifecycle (install, grant, run, uninstall)
  - Three first-party plugins as proof-of-shape: PD-commentary loader (Matthew Henry, JFB), reading-plan plugin, audio-Bible plugin (PD readings)
- [ ] Reading plans (chronological, M'Cheyne, Bible-in-a-year)
- [ ] In-app preferences (font, line height, original-language script controls)

**Dependencies**: Phase 0 complete.

**Validation**: A user can install on two machines, sign in, and see a note created on machine A appear on machine B within 5 seconds. A third-party developer can ship a plugin using only the public SDK docs.

**Wiki grounding**: [[../output/playbook-engineering-2026-05-27|Engineering playbook]] §"Phase 1" + [[../wiki/concepts/study-tool-ux-gap|Study-tool UX gap]] §1-6 + [[../wiki/decisions/plugin-trust-model|Plugin trust model]].

**Risks**:
- Plugin SDK design is unrecoverable if wrong. Mitigation: write three first-party plugins *during* SDK design, not after — they're the spec.
- Sync server ops (auth, abuse, quotas) is real surface area. Mitigation: rate-limit per account; cap doc size; offer self-host docs from day one.

---

### Phase 2 — Logos differentiator parity (target: 16-24 weeks)

**Goal**: 80% of Logos paid-tier UX over open data. ATProto identity. WASM plugins. BYO-API-key plugins.

**Tasks**:
- [ ] **Syntactic search** over MACULA Greek per [[../wiki/concepts/study-tool-ux-gap|Study-tool UX gap]] §1: clause-query DSL + canned-query library + (basic) tree-pattern UI. Index syntax-tree XML separately from FTS5.
- [ ] **Factbook v0**: entity graph from STEPBible TIPNR + Wikidata + curation. Schema designed to take plugin contributions. UI: entity page = bio + linked verses + linked library articles + map (where applicable) + timeline.
- [ ] **Passage Guide v0**: aggregates plugins + user library by passage. Each plugin can register a "passage-guide-section" capability.
- [ ] **Sermon Builder v0**:
  - Sermon outline editor with auto-resolving Bible references
  - Slide export (PowerPoint via `office-js` plugin or `python-pptx` via plugin); Keynote via OOXML
  - Sermon library (search across past sermons via FTS5)
- [ ] **ATProto did:plc identity**: migrate sync accounts to did:plc; custodial-default with self-custody upgrade per [[../wiki/concepts/identity-and-recovery|Identity and recovery]]
- [ ] **WASM plugin host**: lightweight transforms (text shapers, syntax-tree queries) per [[../wiki/decisions/plugin-trust-model|Plugin trust model]]
- [ ] **BYO-API-key plugins** for walled translations: ESV first (Crossway free non-commercial); NIV/NASB/NLT/CSB if demand justifies

**Dependencies**: Phase 1 complete + plugin SDK proven by ≥10 community plugins.

**Validation**: Syntactic search finds every verbless clause where the subject is a divine name in <2s. A pastor can compose a 20-minute sermon outline, slide-export it, and play it back from a separate device they signed in on.

**Wiki grounding**: [[../output/playbook-engineering-2026-05-27|Engineering playbook]] §"Phase 2" + [[../wiki/concepts/study-tool-ux-gap|Study-tool UX gap]] §1-4 + [[../wiki/concepts/identity-and-recovery|Identity and recovery]].

**Risks**:
- Syntactic-search UX is a research-grade UI problem. Mitigation: ship the textual DSL + canned queries first; tree-pattern editor is Phase 3.
- ATProto migration of existing accounts is non-trivial. Mitigation: design the Phase 1 account schema with migration in mind (don't bind to email forever).

---

### Phase 3 — Mobile + ecosystem (ongoing)

**Goal**: Cross-device parity with Logos. Self-hostable. Plugin marketplace.

**Tasks** (high-level; revisit when Phase 2 ships):
- [ ] Native iOS (SwiftUI) over UniFFI-wrapped Rust core
- [ ] Native Android (Jetpack Compose) over UniFFI-wrapped Rust core
- [ ] Plugin marketplace (sermon templates, language packs, denominational extensions, AI integrations)
- [ ] Self-host docs: PDS, Hocuspocus, library mirror
- [ ] AI Research Assistant plugin (Ollama default, BYO Anthropic/OpenAI key)

**Wiki grounding**: [[../output/playbook-engineering-2026-05-27|Engineering playbook]] §"Phase 3".

---

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| Trying to clone Logos's library | [[../output/playbook-engineering-2026-05-27|playbook]] §"What kills the project" | Don't. We never ship `.logos` format support; library is BYO via plugins or open packages. |
| Going all-in on a decentralized stack pre-PMF | [[../output/playbook-engineering-2026-05-27|playbook]] §"What kills the project" | We chose **Iroh library + boring sync**. Hosted Yjs at v1; ATProto in Phase 2. |
| Theological positioning | [[../output/playbook-engineering-2026-05-27|playbook]] §"What kills the project" | Stay neutral; ship engineering; let users pick texts. Repo name `christ-is-lord` is the founder's confession, not a product positioning — the marketing surface stays neutral per [[../wiki/concepts/credible-exit|Credible exit]]. |
| Premature mobile | [[../output/playbook-engineering-2026-05-27|playbook]] §"What kills the project" | Mobile = Phase 3. Desktop must have PMF first. |
| Plugin trust gone wrong | [[../wiki/decisions/plugin-trust-model|Plugin trust model]] | Capability manifests + out-of-process host designed in Phase 0; SDK ships in Phase 1. We do *not* adopt Obsidian's all-in-process JS model. |
| Marketing as "decentralized" | [[../wiki/concepts/credible-exit|Credible exit]] | Pitch is "your data, your way." Decentralization is mechanism, not message. |
| Crossway doctrinal-revocation kill-switch | [[../wiki/concepts/biblical-data-licensing|Biblical data licensing]] §"Tier 1" | We never embed ESV. BYO API key plugin in Phase 2 only; license burden travels with the user. |
| Solo dev burnout | (not in wiki) | Each phase ends in a shipped release. Cadence over heroics. |
| Iroh always-on node ops | [[../wiki/concepts/decentralized-text-distribution|Decentralized text distribution]] | R2 fallback is always-on regardless. Iroh node failure is degraded mode, not outage. |

## Open Questions

These are not blocking Phase 0 but should be resolved by end of Phase 0:

1. **UI framework choice** (SolidJS / Svelte / React / Vue / vanilla TS). Wiki doesn't take a position — it's an implementation detail. Recommendation: Svelte or SolidJS for perf on long passages; React if you're faster in it.
2. **License of the project itself** (MIT, Apache-2.0, AGPL). The wiki's data sources (CC BY 4.0, PD) are compatible with all three. AGPL hardens against fork-and-host commercial competitors but reduces enterprise/church adoption. Recommendation: Apache-2.0 + CLA, mirroring Bibledit's posture.
3. **Project naming for end users** vs. repo naming. Repo is `christ-is-lord`; product name needs a separate decision. Wiki's credible-exit framing argues for a neutral product name.
4. **Funding model** — donations, GitHub Sponsors, hosted-sync subscription, sermon-builder pro tier? Out of scope for Phase 0 but Phase 1 hosted sync = first decision point.
5. **Versification edge cases** — STEPBible mapping covers the major splits; ad-hoc differences (Catholic deuterocanonical, Orthodox additions) need a position.

## Suggested Follow-ups

- Run `/wiki:research "Tauri 2 production app patterns 2026"` if Phase 0 hits unexpected webview/IPC friction — current research dates to early 2026.
- Run `/wiki:research "Iroh blobs operational lessons 2026"` before Week 5 — wiki has architecture but light ops content.
- Consider `/wiki:plan "christ-is-lord plugin SDK design" --format spec` at the start of Phase 1 to lock the capability manifest schema before code.
- Promote a `.wiki/` to `christ-is-lord` itself for repo-specific decisions that don't belong in the public hub (per the hub's [[../../../_index|conventions]]).

## Sources Consulted

- [[../wiki/topics/engineering-playbook|Engineering playbook]] — base architecture and phase definitions
- [[../output/playbook-engineering-2026-05-27|playbook-engineering-2026-05-27]] — wiki's primary deliverable; this plan tailors it to the repo
- [[../wiki/concepts/study-tool-ux-gap|Study-tool UX gap]] — wedge analysis (Sermon Builder, Factbook, Passage Guide, syntactic search)
- [[../wiki/concepts/biblical-data-licensing|Biblical data licensing]] — open-data-only at v1, BYO API for walled translations
- [[../wiki/concepts/client-architecture|Client architecture]] — Tauri 2 + Rust, FTS5, plugin shape
- [[../wiki/concepts/file-over-app|File over app]] — files-on-disk ground-truth principle
- [[../wiki/concepts/decentralized-text-distribution|Decentralized text distribution]] — Iroh + HTTPS hybrid
- [[../wiki/concepts/decentralized-sync|Decentralized sync]] — Yjs/yrs choice
- [[../wiki/concepts/identity-and-recovery|Identity and recovery]] — ATProto did:plc deferred to Phase 2
- [[../wiki/concepts/credible-exit|Credible exit]] — marketing frame
- [[../wiki/reference/logos-feature-surface|Logos feature surface]] — what we're replacing
- [[../wiki/reference/oss-bible-software-landscape|OSS Bible software landscape]] — what already exists
- [[../wiki/reference/open-data-corpus|Open data corpus]] — every open dataset we ship
- [[../wiki/reference/decentralized-infra-candidates|Decentralized infra candidates]] — Iroh selected
- [[../wiki/decisions/plugin-trust-model|Plugin trust model]] — hybrid out-of-proc + WASM
- [[../wiki/decisions/library-distribution|Library distribution]] — Iroh-blobs + HTTPS mirrors
