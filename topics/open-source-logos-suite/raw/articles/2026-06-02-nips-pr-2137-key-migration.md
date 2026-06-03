---
title: "PR #2137 — Key migration (open, in flight)"
url: https://github.com/nostr-protocol/nips/pull/2137
retrieved: 2026-06-02
type: pr
---

Open PR opened 2025-11-25 by staab, currently the most active key-rotation proposal in the NIPs repo (33+ comments as of 2026-06-02). Defines three new event kinds:

- kind:360 — "Precommit": user pre-commits to a future migration key, timestamped via OpenTimestamps so attackers cannot retroactively forge a precommit.
- kind:361 — "Migration": signed by the migration key, triggers the actual identity move.
- kind:362 — "Shards": optional encrypted recovery shards distributed via NIP-59 (gift-wrap).

Key design choices: an *intermediate single-use migration key* sits between the old identity key and the new one, so a leaked nsec alone is not enough to forge a migration; immediate validation rather than a holding period; mentions and historical messages are explicitly NOT carried over — only follower-list signaling. Reviewers (notably vitorpamplona, fiatjaf) have flagged that the scheme requires "a central group of trusted relays" to retain the precommit and migration events reliably, and questioned whether regular clients should even implement it (vs. specialized vault apps). Status as of 2026-06-02: open, not merged, no consensus on whether it ships.
