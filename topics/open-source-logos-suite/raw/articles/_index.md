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
- [[2026-05-27-client-tantivy]] — Tantivy as Rust-only upgrade for richer Lucene-style analyzers
- [[2026-05-27-client-stepbible-data]] — STEPBible TAHOT/TAGNT as the OSS-suite tagged-corpus dependency
- [[2026-05-27-client-yjs-crdt]] — Yjs/yrs production track record (Linear, JupyterLab, AFFiNE, Evernote)
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
- [[2026-05-27-infra-sync-local-first-essay]] — Ink & Switch local-first software essay

## Case studies
- [[2026-05-27-case-inkandswitch-local-first]] — Ink & Switch local-first principles
- [[2026-05-27-case-bluesky-not-decentralized]] — 99.9% of Bluesky users on bsky.social; "credible exit" the honest framing
- [[2026-05-27-case-anytype-any-sync]] — Anytype custom any-sync; 4 node types; users mostly on hosted relays
- [[2026-05-27-case-file-over-app]] — Obsidian's "file over app" design principle
- [[2026-05-27-case-nostr-protocol]] — Nostr protocol simplicity beats ATProto adoption per client diversity
