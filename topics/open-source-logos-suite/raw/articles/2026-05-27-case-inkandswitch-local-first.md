---
title: "Local-First Software: You Own Your Data, in spite of the Cloud"
source_url: "https://www.inkandswitch.com/essay/local-first/"
type: article
path: case
date_ingested: 2026-05-27
date_published: 2019-04-01
tags: [case-study, local-first, decentralized, crdt, ink-and-switch]
quality: 5
confidence: high
summary: "Foundational Ink & Switch essay defining the seven ideals of local-first software with concrete lessons from three CRDT-based production prototypes (Trellis, Pixelpusher, PushPin)."
---

# Local-First Software: You Own Your Data, in spite of the Cloud

## Key findings

The seven ideals: (1) No spinners — instant local response, (2) data not trapped on one device, (3) network is optional, (4) seamless real-time collaboration, (5) The Long Now (data survives vendor death), (6) E2E encryption / security by default, (7) ultimate user ownership and control.

What worked in their prototypes:
- Automatic conflict resolution succeeded more often than expected because users actually rarely encounter conflicts in practice.
- Offline-first creates a tangible sense of ownership that cloud apps lack.
- React's functional reactive model integrates cleanly with CRDT data structures.

What broke:
- "CRDTs accumulate a large change history, which creates performance problems" — storage and memory bloat over real-world use.
- "Network communication remains an unsolved problem" — the algorithms work, getting bytes between peers does not.
- NAT traversal and P2P connectivity unreliable across heterogeneous networks.

## Notable quotes / specifics

- No existing solution satisfies all seven ideals: cloud apps win at collaboration but lose ownership; old desktop apps own data but cannot multi-device sync.
- CRDTs are positioned as foundational but explicitly NOT yet production-ready replacements for Firebase.
- The essay's pragmatic conclusion is that local-first is a goalpost, not a shipped product category.

## Source notes

This is the canonical reference for the local-first movement. Most subsequent design discussion (Obsidian, Logseq, Anytype) cites this essay as motivation. Important that the AUTHORS themselves flag CRDT history bloat and NAT traversal as unsolved — those problems remain in 2026.
