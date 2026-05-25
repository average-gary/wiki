---
title: "Local-First Software — You Own Your Data, In Spite of the Cloud"
source: "https://www.inkandswitch.com/essay/local-first/"
type: paper
date_fetched: 2026-05-24
date_published: 2019-04-01
tags: [local-first, crdt, sync, philosophy, ink-and-switch]
quality: 5
credibility: high
path: world-data-modeling
summary: "Ink & Switch's foundational essay defines seven ideals for local-first software (no spinners, multi-device, offline-capable, collaborative, long-lived, secure, user-controlled) and frames CRDTs as the technical substrate. The reference text for any 'desktop app where the user owns the data' decision."
---

# Local-First Software

## The seven ideals
1. **No spinners — your work at your fingertips.** Reads/writes are local, instant, no network round-trip.
2. **Your work is not trapped on one device.** Multi-device sync without lock-in.
3. **The network is optional.** Full functionality offline; sync opportunistically.
4. **Seamless collaboration with colleagues.** Real-time multi-user, no merge conflicts thrown at the user.
5. **The Long Now.** Data and the software to read it stored locally — works in 10/50 years.
6. **Security and privacy by default.** End-to-end encryption when sync exists.
7. **You retain ultimate ownership and control.** No remote kill-switch; no rented data.

## Why CRDTs
Centralized servers can offer 1, 2, 4, 6 but never 3, 5, 7. CRDTs (Automerge, Yjs) let every device hold a complete copy that merges automatically — no central coordinator required.

## The Ink & Switch prototypes
Three Electron apps (Trellis kanban, PushPin canvas, Pixelpusher pixel art) demoed the ideals using Automerge. Lessons: schema migration is hard; UX for "your peer is offline" is hard; storage grows with edit history but compaction works.

## Relevance to our tool
1. **Direct alignment**: a PF2e worldbuilding app *should* be local-first — campaigns last years, GMs distrust cloud lock-in, sessions happen offline.
2. **Markdown-on-disk gets us 1, 2 (via Dropbox/git), 3, 5, 7 nearly for free** — but fails 4 (real-time collab) and partially 6.
3. **Hybrid path**: markdown as portable export + an Automerge layer for the live editing/sync experience. The essay explicitly endorses this kind of layered approach.
4. **"The Long Now" is decisive for TTRPGs**: campaigns are 5–10 year artifacts. Plain text + open formats win on this axis vs any proprietary DB.
5. The seven ideals are a great evaluation rubric for any storage proposal we make later.
