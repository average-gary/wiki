---
title: Nutchain event-kind range (30800-30814)
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [nutchain, nostr, event-kinds, addressable]
---

# Nutchain event-kind range (30800-30814)

[[raw/repos/2026-06-17-ethntuttle-nutchain.md|Nutchain]] specifies **14 event kinds** in
the addressable range **30800-30814**, covering setup, gameplay, randomness requests,
DKG contributions, and teardown.

## Notable

- Range is in the **addressable / parameterized-replaceable** band (30000-39999 per
  NIP-01).
- Each event references its predecessor via the `e` tag → **hash-linked chain**.
- Sequence numbers enforce strict event ordering.
- Domain separation across kinds prevents cross-protocol replay.
- Distinct from kirk's 9259-9263 and manastr's 31000-31006.
- Not registered as a NIP.

## Why a hash-linked chain

Nostr provides no native event ordering ([[raw/papers/2026-06-17-nostr-empirical-decentralization-resilience-conext.md|CoNEXT '25 paper]]).
Nutchain explicitly bolts the missing primitive into the application layer: each event
chains to the prior via `e` tag + sequence number, producing a tamper-evident transcript
verifiable by any observer.

## See also

- [[wiki/concepts/threshold-oprf-dasor]]
- [[wiki/concepts/hash-linked-event-chain]]
