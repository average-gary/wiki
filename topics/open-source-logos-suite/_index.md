---
title: Open-Source Logos Suite
type: topic-index
created: 2026-05-27
updated: 2026-05-28
status: active
summary: Engineering an open-source application suite with the feature surface of Logos Bible Software (logos.com) — library, reverse interlinear, syntactic search, lexicons, sermon tools, sync — and the question of whether decentralized infrastructure (IPFS, libp2p, Iroh, ATProto, Nostr, Hypercore) can support text distribution, identity, and user-data sync without a central server.
---

# Open-Source Logos Suite

Topic wiki investigating two coupled questions:

1. **What would an open-source Logos competitor look like?** Logos.com is the dominant commercial Bible-study suite — a desktop+mobile app with a digital library (1000s of priced books), a reverse interlinear, syntactic/lexical/morphological search across original-language texts, lexicons, commentaries, factbook/passage guides, sermon-builder tools, and cross-device sync. What does the open-source landscape already have, and what would it take to ship a viable alternative?

2. **Could decentralized infrastructure support it?** The shape of the data — append-mostly biblical texts, immutable lexicons, user notes/highlights/sermons that need cross-device sync — looks well-suited to content-addressed, peer-to-peer systems. IPFS/libp2p, Iroh, ATProto, Nostr, Hypercore/Dat, Anytype's Any-sync — which (if any) actually solve the problem?

## Anchors
- **Commercial reference**: https://www.logos.com
- **OSS prior art**: SWORD/Diatheke, BibleHub, STEP Bible, Open Scriptures, NET Bible API
- **Open biblical data**: OSHB (Hebrew), MorphGNT, SBLGNT, NETS LXX, Strong's, BDB, LSJ
- **Decentralized infra candidates**: Iroh (already researched in this hub), libp2p, ATProto, Nostr, Hypercore, Anytype any-sync

## Top-level questions
1. **Logos surface** — what is Logos actually, in feature terms, and what is the moat?
2. **Existing OSS** — what does SWORD / STEP Bible / BibleHub / Open Scriptures already do, and where do they fall short?
3. **Open data** — what biblical texts, lexicons, commentaries, and morphology data are openly licensed (and what's locked behind ESV/NIV/NASB-style copyrights)?
4. **Client architecture** — local-first vs server-backed; plugin systems (Obsidian, VS Code patterns); cross-platform stacks (Tauri, Electron, native).
5. **Decentralized text distribution** — IPFS / libp2p / Iroh / ATProto for shipping the digital library and lexicon corpus to clients without a central CDN.
6. **Decentralized identity & sync** — DIDs, Nostr keys, ATProto PDS, Hypercore — for user notes, highlights, reading plans, sermon drafts that travel between devices.
7. **Case studies** — Logseq, Obsidian, Anytype, Bluesky, Nostr clients — what works in practice for similar shape problems?

## Sections
- [[wiki/concepts/_index|Concepts]] — feature surface, data formats, infrastructure primitives
- [[wiki/topics/_index|Topics]] — synthesis playbooks (architecture, decentralized infra, build plan)
- [[wiki/reference/_index|Reference]] — landscape of OSS Bible software, open data sources, infra candidates
- [[wiki/decisions/_index|Decisions]] — architecture decisions
- [[wiki/tools/_index|Tools]] — relevant libraries, frameworks, repos

## Sources
- [[raw/_index|Raw sources]]

## Outputs
- [[output/playbook-engineering-2026-05-27|Engineering Playbook (2026-05-27)]] — 5-layer architecture + phased build plan + decentralized-infra recommendations
- [[output/plan-christ-is-lord-2026-05-28|Plan: christ-is-lord (2026-05-28)]] — roadmap tailoring the playbook to `christ-is-lord` repo (solo full-time, desktop-only v1, Iroh library + boring sync)

## Log
See [[log]].
