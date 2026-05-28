---
title: "Nostr Protocol Overview"
source_url: "https://github.com/nostr-protocol/nostr"
type: article
path: case
date_ingested: 2026-05-27
date_published: unknown
tags: [case-study, decentralized, nostr, relay, protocol]
quality: 3
confidence: medium
summary: "Nostr's protocol: pubkey identity + simple relays + signed events. Real censorship resistance via cryptographic signatures, but suffers from discovery and de-facto relay centralization."
---

# Nostr Protocol Overview

## Key findings

Protocol shape: users are public keys; events are signed JSON; relays are dumb servers that store and forward. Clients verify signatures, so a relay cannot tamper with content — only refuse to host it.

Censorship-resistance model: "as long as there is any relay willing to host someone, they can still publish." Resilience comes from relay diversity, not from any single relay being trustworthy.

Acknowledged hard problem: "The hardest part is how to find in which relay you will find notes of each person you follow, since they can be anywhere." Discovery is the actual unsolved layer.

## Notable quotes / specifics

- Multiple client implementations (Damus, Primal, Amethyst) — real client diversity exists, unlike most "decentralized" platforms.
- Relays can refuse content but cannot misrepresent it (sigs prevent tampering).
- In practice most users hit a small set of major relays — same de-facto centralization pattern as Bluesky and Anytype, but with much lower switching cost.
- Self-described as "the simplest open protocol" — minimalism is the design choice that lets it actually federate.

## Source notes

Nostr is the closest thing to a working open relay model. Lessons for any logos-suite design: (1) signed events let untrusted relays be useful, (2) discovery across relays is the real UX problem and remains unsolved in 2026, (3) protocol simplicity beats architectural cleverness for adoption — Nostr clients exist in numbers because the protocol fits in a weekend reading. The minimalism that ATProto rejected is what makes Nostr actually federate.
