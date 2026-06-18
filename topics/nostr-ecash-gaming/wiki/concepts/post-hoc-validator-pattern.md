---
title: Post-hoc validator pattern
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [manastr, validator, nostr, stateless, anti-coordination]
---

# Post-hoc validator pattern

In [[raw/repos/2026-06-17-ethntuttle-manastr.md|manastr]], the **Game Engine Bot** never
coordinates a match. It runs after the match is over, **re-executes** the game from all
recorded Nostr events, and verifies the winner. This is a deliberate inversion of the
typical client-server game architecture.

## Why

- **Removes coordination authority** from any single party. No service can reject a move,
  censor a player, or unilaterally end a match — the relay just stores events; the engine
  just verifies.
- **Stateless services**. The game engine, the mint, and the relay all operate without
  long-lived game state. State lives only in the immutable Nostr event log.
- **Eliminates a class of bugs**. The earlier manastr design had a `global_matches`
  HashMap shared between players' UIs — state changes that "didn't propagate through Nostr"
  caused desyncs. The redesign collapsed all state into the Nostr event log
  (`ARCHITECTURE_REDESIGN.md`).

## Mechanics

1. Players publish signed Nostr events (kinds 31000-31006) to a `strfry` relay
2. Each client polls the relay every ~5 s, filters by match id + relevant kinds
3. Client reconstructs match state on every render; discards view objects after the frame
4. Game Engine Bot, also subscribed, re-runs combat resolution from the events
5. On verification, the Cashu mint pays out; otherwise, the match auto-invalidates

## Contrast with mint-as-referee

[[wiki/concepts/mint-as-referee|Mint-as-referee]] makes the mint a synchronous validator
on every reward step. The post-hoc-validator pattern decouples them: the mint handles only
custody; the validator runs **after** the events are settled. The result is that the mint
could in principle be replaced (e.g. by a different CDK mint) without changing the game
engine.

## Tradeoffs

- **Latency-tolerant only**. Real-time games can't wait for post-hoc verification.
- **Requires deterministic re-execution**. manastr addresses this by compiling shared
  game logic to **WASM** so client and server execute identically.
- **Dispute resolution is offline**. The pattern produces signed audit artifacts but does
  not arbitrate live moves.

## See also

- [[wiki/concepts/manastr-stateless-client]]
- [[wiki/concepts/mint-as-referee]]
