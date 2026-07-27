---
title: Articles — open-source-logos-suite
type: index
created: 2026-05-27
updated: 2026-05-27
---

# Articles

36 ingested articles across 7 research paths.

## Logos feature surface
- [[2026-05-27-logos-wikipedia-overview]] — origin (1992 Bellingham), Faithlife rebrand 2014, Cove Hill PE, C#/WPF stack
- [[2026-05-27-logos-homepage-product-pitch]] — 250k+ resources, AI Research Assistant, ~6M users, $9.99-$19.99/mo
- [[2026-05-27-logos-pricing-tiers-subscription-shift]] — subscription pivot away from Bronze→Portfolio perpetual ($300-$5000+)
- [[2026-05-27-logos-feature-surface-synthesis]] — Passage Guide, Exegetical Guide, Word Study Guide, Factbook, Sermon Builder, reverse interlinear, sync
- [[2026-05-27-logos-cascadia-macula-data-availability]] — MACULA Greek (Clear Bible) republishes SBLGNT + syntactic data openly; Logos's data moat is leaky

## OSS Bible software
- [[2026-05-27-oss-sword-project-crosswire]] — SWORD engine + 100-language modules; powers BibleTime, Xiphos, Pocket Sword, And Bible, Ezra
- [[2026-05-27-oss-step-bible-tyndale]] — STEP Bible web app + STEPBible-Data scholarly assets
- [[2026-05-27-oss-bible-apis-public]] — bible-api.com + wldeh/bible-api free public Bible JSON APIs

## Biblical data licensing
- [[2026-05-27-data-stepbible]] — STEPBible-Data (CC BY 4.0): TAHOT, TAGNT, TBESH/G/TFLSJ, TIPNR, versification map — the strategic dataset
- [[2026-05-27-data-oshb-wlc]] — OSHB / WLC Hebrew OT with morphology
- [[2026-05-27-data-morphgnt-sblgnt]] — MorphGNT (CC BY-SA) + SBLGNT (custom EULA, non-commercial-leaning)
- [[2026-05-27-data-strongs-pd]] — Strong's Concordance public domain; the universal H/G join key
- [[2026-05-27-data-web-ebible]] — World English Bible + Berean Standard Bible (PD modern English)
- [[2026-05-27-data-openbible-xrefs]] — OpenBible.info ~340k cross-references (CC BY)
- [[2026-05-27-data-esv-api-wall]] — ESV Crossway free non-commercial API; 5k req/day; 500-verse cache cap; doctrinal-revocation clause

## Client architecture
- [[2026-05-27-client-sqlite-fts5]] — FTS5 cross-platform with unicode61, BM25, NEAR, custom morphology tokenizers
- [[../repos/2026-05-27-client-tantivy]] — Tantivy as Rust-only upgrade for richer Lucene-style analyzers
- [[../repos/2026-05-27-client-stepbible-data]] — STEPBible TAHOT/TAGNT as the OSS-suite tagged-corpus dependency
- [[../repos/2026-05-27-client-yjs-crdt]] — Yjs/yrs production track record (Linear, JupyterLab, AFFiNE, Evernote)
- [[2026-05-27-client-obsidian-plugin-arch]] — Obsidian's all-in-process JS model lacks sandboxing — explicit limitation

## Decentralized text distribution
- [[2026-05-27-infra-text-iroh-blobs-protocol]] — Iroh blobs BLAKE3 verified streaming + HashSeq collections
- [[2026-05-27-infra-text-ipfs-content-addressing]] — IPFS CID/multihash, IPNS for mutable refs
- [[2026-05-27-infra-text-ipfs-real-world-limits]] — Brave dropped IPFS 2024; production usage is HTTP gateways
- [[2026-05-27-infra-text-bittorrent-v2-merkle]] — BitTorrent v2 Merkle trees + per-file SHA-256 roots; no production WebTorrent v2
- [[2026-05-27-infra-text-atproto-blob-spec]] — ATProto blobs PDS-bound, ~1MB cap; wrong shape for GB corpora
- [[2026-05-27-infra-text-hypercore-pears]] — Hypercore append-only signed log; JS/Bare-only ecosystem

## Decentralized sync / identity
- [[2026-05-27-infra-sync-atproto-pds]] — ATProto did:plc; PDS-to-PDS migration; rotation keys
- [[2026-05-27-infra-sync-atproto-account-migration]] — Documented account migration flow with 72hr window
- [[2026-05-27-infra-sync-nostr-nip51]] — Nostr NIP-51 lists; nsec/npub identity; NIP-46 bunkers
- [[2026-05-27-infra-sync-automerge-repo]] — Automerge-repo; Tonk, Patchwork; CRDT replicated peer-to-peer
- [[../papers/2026-05-27-infra-sync-local-first-essay]] — Ink & Switch local-first software essay

## Case studies
- [[2026-05-27-case-inkandswitch-local-first]] — Ink & Switch local-first principles
- [[2026-05-27-case-bluesky-not-decentralized]] — 99.9% of Bluesky users on bsky.social; "credible exit" the honest framing
- [[2026-05-27-case-anytype-any-sync]] — Anytype custom any-sync; 4 node types; users mostly on hosted relays
- [[2026-05-27-case-file-over-app]] — Obsidian's "file over app" design principle
- [[2026-05-27-case-nostr-protocol]] — Nostr protocol simplicity beats ATProto adoption per client diversity

- [[2026-06-02-andbible-faq-esv-withdrawn.md|AndBible FAQ — ESV no longer in Downloads]]
- [[2026-06-02-andersen-forbes-hebrew.md|Andersen-Forbes Hebrew syntactic database]]
- [[2026-06-02-api-bible-overview.md|API.Bible (American Bible Society)]]
- [[2026-06-02-atproto-account-migration-guide.md|ATProto account migration guide]]
- [[2026-06-02-crossway-statement-of-faith.md|Crossway Statement of Faith]]
- [[2026-06-02-csbible-permissions.md|CSB permissions (Holman Bible Publishers)]]
- [[2026-06-02-cyberhaven-chrome-extension-supply-chain.md|Cyberhaven Chrome extension supply-chain attack (December 2024)]]
- [[2026-06-02-did-plc-spec-rotation-keys.md|did:plc method specification — rotation keys & 72h recovery]]
- [[2026-06-02-esv-api-docs-portal.md|ESV API developer documentation (api.esv.org/docs)]]
- [[2026-06-02-esv-api-overview-terms.md|ESV API overview & terms (Crossway)]]
- [[2026-06-02-fts5-tree-limits.md|SQLite FTS5 tree-query limitations]]
- [[2026-06-02-keyhive-notebook-intro.md|Keyhive notebook — Introduction & threat model]]
- [[2026-06-02-keyhive-notebook-overview.md|Keyhive notebook — design overview (capabilities, BeeKEM, Beelay)]]
- [[2026-06-02-keyhive-notebook-riblt.md|Keyhive notebook — RIBLT for set reconciliation]]
- [[2026-06-02-lockman-nasb-permissions.md|Lockman Foundation NASB permissions & quotation]]
- [[2026-06-02-logos-ai-product-page.md|Logos AI — official product page]]
- [[2026-06-02-lowfat-3john-sample.md|MACULA Greek lowfat sample — 3 John 1:1-2]]
- [[2026-06-02-lowfat-xml-schema.md|Lowfat XML schema (biblicalhumanities Nestle1904 README)]]
- [[2026-06-02-macula-greek-license.md|MACULA Greek LICENSE.md]]
- [[2026-06-02-magisterium-ai-blocked.md|Magisterium AI — homepage (HTTP 429, blocked)]]
- [[2026-06-02-nip-06-mnemonic-key-derivation.md|NIP-06: Basic Key Derivation from Mnemonic Seed Phrase (unrecommended)]]
- [[2026-06-02-nip-26-delegated-event-signing.md|NIP-26: Delegated Event Signing (unrecommended)]]
- [[2026-06-02-nip-46-remote-signing.md|NIP-46: Nostr Connect / Remote Signing]]
- [[2026-06-02-nips-pr-1056-key-revocation.md|PR #1056 — Key Revocation (Draft, open since 2024)]]
- [[2026-06-02-nips-pr-1452-key-migration-revocation.md|PR #1452 — Key Migration and Revocation (open, stalled)]]
- [[2026-06-02-nips-pr-1906-moved-to-tag-closed.md|PR #1906 — NIP-24 'moved_to' tag (closed, half-measure rejected)]]
- [[2026-06-02-nips-pr-2114-d8-key-rotation.md|PR #2114 — NIP D8 Key Rotation (closed in favor of #2137)]]
- [[2026-06-02-nips-pr-2137-key-migration.md|PR #2137 — Key migration (open, in flight)]]
- [[2026-06-02-nlt-api-tyndale.md|NLT API (Tyndale House Publishers)]]
- [[2026-06-02-nostr-how-key-safety-guidance.md|nostr.how — official Nostr getting-started guide on key safety]]
- [[2026-06-02-pulpit-ai-homepage.md|Pulpit AI — homepage]]
- [[2026-06-02-pulpit-ai-pricing.md|Pulpit AI — pricing page]]
- [[2026-06-02-riblt-paper.md|Rateless Invertible Bloom Lookup Tables (Yang, Gilad, Alizadeh — SIGCOMM 2024)]]
- [[2026-06-02-tigersearch-defunct.md|TIGERSearch (Stuttgart) — defunct]]
- [[2026-06-02-treebank-wikipedia.md|Treebank (Wikipedia) — query language landscape]]
- [[2026-06-02-tregex-stanford.md|Tregex / Tsurgeon / Semgrex (Stanford NLP)]]
- [[2026-06-02-youversion-no-ai-disclosure.md|YouVersion / Bible.com — no AI feature disclosure on public pages]]
- [[2026-06-02-youversion-platform-developers.md|YouVersion developer platform]]
