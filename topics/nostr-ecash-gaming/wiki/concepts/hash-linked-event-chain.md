---
title: Hash-linked Nostr event chain
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [nostr, ordering, application-layer-fix, nutchain, kirk]
---

# Hash-linked Nostr event chain

A pattern that compensates for **Nostr's lack of native event ordering** by chaining each
game-state event to its predecessor via an `e` tag carrying the predecessor's event id +
a sequence number.

## Why this is needed

The peer-reviewed Nostr measurement study
([[raw/papers/2026-06-17-nostr-empirical-decentralization-resilience-conext.md|Wei & Tyson, CoNEXT '25]])
confirms Nostr has **no causality / total-order primitive**. Relays can deliver events
out of order; clients cannot rely on `created_at` for adversarial scenarios.

For game state, this is fatal — turn-ordering, simultaneous-move resolution, and
move-validity-against-prior-state all require a stable order.

## Construction

- Event N references event N-1's id via the `e` tag
- Event N carries `seq = N` (or equivalent monotone counter)
- Validator rejects events whose `previous_event_id` doesn't match the latest known head
- Replays can be detected by competing `e` references

The chain is **tamper-evident**: forging a middle event requires regenerating every
subsequent event.

## Implementations

- [[raw/repos/2026-06-17-ethntuttle-nutchain.md|nutchain]] — explicit; sequence numbers + `e`
  tag chaining is normative in the spec
- [[raw/repos/2026-06-17-ethntuttle-kirk.md|kirk]] — `previous_event_id` field in each Move
  event (kind 9261); GameSequence state machine validates the chain
- [[raw/repos/2026-06-17-ethntuttle-manastr.md|manastr]] — implicit through replay
  semantics; the Game Engine Bot reconstructs the chain by re-execution
- [[raw/repos/2026-06-17-docnr-nostr-poker-nip101p.md|NIP-101p]] — implicit ordering by
  hand sequence; not a hash-linked chain at the protocol level

## See also

- [[wiki/concepts/post-hoc-validator-pattern]]
