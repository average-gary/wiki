---
title: "Local-First Software: You Own Your Data, in spite of the Cloud (Ink & Switch)"
source_url: "https://www.inkandswitch.com/essay/local-first/"
type: paper
path: infra-sync
date_ingested: 2026-05-27
date_published: 2019-04-01
tags: [decentralized, sync, crdt, local-first, ink-and-switch, design-principles]
quality: 5
confidence: high
summary: "Foundational essay defining seven ideals of local-first software (instant, multi-device, offline, collaborative, durable, private, user-controlled) and CRDTs as the merge primitive."
---

# Local-First Software: You Own Your Data, in spite of the Cloud

## Key findings

- **Seven ideals**: (1) No spinners — local-first IO; (2) Multi-device sync; (3) Network is optional; (4) Seamless real-time collaboration; (5) Long-term preservation (works after the company dies); (6) Privacy by default (E2E); (7) User retains ultimate control.
- **CRDTs as foundation**: "General-purpose data structures like hash maps and lists, but multi-user from the ground up." Automatic merge of concurrent edits across devices without a central authority.
- **Identity is intentionally underspecified**: The essay punts on formal identity — prototypes used drawn avatars and "outbox" sharing models. This is BOTH a known gap AND an honest acknowledgment that identity is the hard part.
- **Cloud as backup, not authority**: Servers are demoted to caching/relay role; the device holds the canonical copy.
- **Prototypes**: Trellis (Kanban), Pixelpusher (drawing), PushPin (canvas). The essay explicitly states these are experimental.
- **Established analogues cited**: Git/GitHub (decentralized, conflict-merging), CloudKit, Realm.

## Notable quotes / specifics

- "We use the term 'local-first software' to describe a set of principles for software that enables both collaboration and ownership for users."
- The seven ideals are now widely cited; "ideal 5: long-term preservation" is exactly what a Bible app needs for sermons / decades of notes.

## Source notes

This is the design-rubric, not a protocol. Use it as the scoring matrix when evaluating ATProto / Nostr / Automerge / Hypercore. The Bible-suite product is essentially a local-first app — primary copy on device, sync as enhancement. Score every architectural choice against the seven ideals; reject choices that fail #1, #3, or #5.
