---
title: Kirk event-kind range (9259-9263)
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [kirk, nostr, event-kinds, commit-reveal]
---

# Kirk event-kind range (9259-9263)

[[raw/repos/2026-06-17-ethntuttle-kirk.md|Kirk]] defines five custom Nostr event kinds for
the trustless gaming protocol.

| Kind | Name | Role |
|---|---|---|
| 9259 | Challenge | Initiates the game; carries game-type id, commitment hashes (64-char hex), JSON game params, optional expiry, optional timeout |
| 9260 | ChallengeAccept | Symmetric structure to Challenge; references Challenge id; responder's commitments |
| 9261 | Move | Action; fields: `previous_event_id`, `move_type`, `move_data`, `revealed_tokens` (optional), `deadline` (optional). Move types: `Move`, `Commit` (no tokens), `Reveal` (tokens MUST present) |
| 9262 | Final | Concludes gameplay; both players publish; triggers final validation |
| 9263 | Reward | Distributes outcomes OR records validation failures; carries P2PK-locked reward tokens |

## Notable

- Range is in the **regular event** band (1000-9999 per NIP-01) — events are stored fully on
  relays.
- Distinct from manastr's 31000-31006 ([[wiki/concepts/manastr-event-kinds]]) and nutchain's
  30800-30814 ([[wiki/concepts/nutchain-event-kinds]]).
- Not registered as a NIP. Custom protocol.

## Move-type taxonomy

The `Commit` / `Move` / `Reveal` distinction is the protocol-level commit-reveal mechanism:
players publish the hash first (Commit, no tokens), play through (Move), and finally
reveal tokens (Reveal). Mismatches are rejected by the validator.

## See also

- [[wiki/concepts/c-value-game-piece]]
- [[wiki/concepts/mint-as-referee]]
