---
title: Manastr stateless client (query-on-render)
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [manastr, nostr, stateless, ui-pattern]
---

# Manastr stateless client (query-on-render)

[[raw/repos/2026-06-17-ethntuttle-manastr.md|Manastr]]'s React "Quantum web client" holds
**no persistent game state** in memory. On every render cycle (~5 s polling), the client:

1. Queries the Nostr relay for events matching `match_id` + relevant event kinds
2. Parses the event stream into temporary view objects (`ChallengeView`, `MatchView`)
3. Renders the UI directly from those views
4. **Discards the view objects after the render frame**

There is no shared in-memory match state, no `global_matches` HashMap, no client-side cache
of resolved combat. State exists only in the Nostr log; the UI is a pure function of
that log.

## Why

The earlier manastr architecture had a `global_matches` HashMap shared between players'
UIs. State changes in that map "didn't propagate through Nostr" — both players saw their
local copy diverge. The redesign (`ARCHITECTURE_REDESIGN.md`) eliminated shared state
entirely.

## Tradeoffs

- ✅ Eliminates synchronization bugs.
- ✅ Scales infinitely — there's no shared object to contend over.
- ✅ All players see the same source of truth (the relay event stream) by construction.
- ❌ Polling latency (~5 s) — unsuitable for real-time games.
- ❌ Re-renders are expensive if the event stream is long; manastr mitigates with shared
  `nostrdb` cache across apps ("very efficient for cross-app caching").

## Generalizable principle

For Nostr-based games, **state-shape your UI as a function of the event stream**, not as
mutable client memory. The pattern composes with the
[[wiki/concepts/post-hoc-validator-pattern|post-hoc-validator]] design — both treat the
event log as the only authoritative state.

## See also

- [[wiki/concepts/post-hoc-validator-pattern]]
- [[wiki/concepts/manastr-event-kinds]]
