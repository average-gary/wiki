---
title: "Event-kind allocations across Nostr gaming projects"
type: reference
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [reference, nostr, event-kinds, allocation]
---

# Event-kind allocations across Nostr gaming projects

| Range / Kind | Project / Spec | NIP-01 class | Status | Notes |
|---|---|---|---|---|
| **64** | NIP-64 (chess) | Regular | Merged NIP | PGN string in event content; kind = `64` |
| **1650-1660** | NIP-101p (poker) | Regular | DRAFT | DocNR/nostr-poker microstandard; table/sit/hand/action/dispute |
| **9259-9263** | [[../concepts/kirk-event-kinds\|kirk]] | Regular (high band) | Custom | EthnTuttle, Challenge / Accept / Move / Final / Reward |
| **9000-9020** | NIP-29 group moderation | Regular | Merged NIP | Add/remove user, edit metadata, etc. |
| **9021/9022** | NIP-29 join/leave | Regular | Merged NIP | Group lifecycle |
| **30800-30814** | [[../concepts/nutchain-event-kinds\|nutchain]] | Addressable | Spec | EthnTuttle, 14-kind range |
| **31000-31006** | [[../concepts/manastr-event-kinds\|manastr]] | Addressable | Custom (impl) | EthnTuttle, full match lifecycle |
| **33650** | NIP-101p Dealer Profile | Addressable | DRAFT | Dealer reputation marketplace |
| **39000-39004** | NIP-29 group metadata | Addressable | Merged NIP | Group identity, admins, members, roles |

## Bands (per NIP-01)

- 1000-9999 — **regular** events; relays store fully
- 10000-19999 — **replaceable** events; only latest per-pubkey-per-kind is kept
- 20000-29999 — **ephemeral** events; not stored
- 30000-39999 — **parameterized-replaceable / addressable**; latest per (pubkey, kind, `d` tag)

## Observations

- Three EthnTuttle projects, three different bands (regular 9000s + addressable 30800s +
  addressable 31000s).
- No two projects collide.
- Both nutchain and manastr use the addressable band — reasonable because game state is
  long-lived and players want a single addressable handle per match. Kirk uses regular —
  reasonable because every action is a distinct event in a chain.
- NIP-101p (1650+) chose the regular band, presumably to avoid replacement of historical
  hands.

## Recommendation for new gaming protocols

- Reserve a **contiguous range** rather than scattering kinds.
- Pick the band based on event semantics: *match registration* and *player profile* belong
  in addressable; *moves and history* in regular; *real-time UI hints* (read-receipts,
  presence) in ephemeral.
- **Coordinate** with the NIPs repository early — the gaming kind-space is currently
  uncoordinated, but that won't last.
