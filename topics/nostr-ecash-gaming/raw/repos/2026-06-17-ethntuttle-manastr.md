---
title: "EthnTuttle/manastr — decentralized turn-based strategy game on Nostr + Cashu"
source: https://github.com/EthnTuttle/manastr
type: repo
tags: [nostr, cashu, gaming, mana, decentralized-gaming, rust, wasm, ecash, manastr, react, strfry, cdk-mint, stateless-client]
fetched: 2026-06-17
confidence: high
summary: |
  Manastr is a turn-based two-player strategy game where two armies (deterministically generated
  from Cashu token secrets) duel via Nostr-event-driven moves. Stateless clients reconstruct
  match state on every render by querying a strfry relay; an off-chain "Game Engine Bot"
  validates outcomes after the fact; a CDK mint manages two custom token kinds (`mana`
  in-game currency, `loot` reward). Surprise: **manastr does NOT depend on kirk** — it
  implements its own commitment/reveal anti-cheat with a different event-kind range
  (31000-31006). Active through Aug 2025; integration tests are the canonical spec.
---

# EthnTuttle/manastr

> **Repository purpose**: Reference / playable implementation of a Nostr+Cashu strategy game.
> Two players, deterministic armies from token secrets, 9-phase match lifecycle entirely
> orchestrated through Nostr events, Cashu tokens as escrow + reward.

## Repo Metadata

| Field | Value |
|---|---|
| Owner | EthnTuttle |
| Repo | manastr |
| URL | https://github.com/EthnTuttle/manastr |
| Default branch | `master` |
| Created | 2025-07-28 |
| Last commit | 2025-08-26 (debug logging for Nostr relay) |
| Total commits | 53 |
| Languages | Rust 96.8 % · Just 1.9 % · Shell 1.3 % |
| License | None declared (in-tree) |
| Stars / Forks | 0 / 0 |
| Status | Active development; "production-ready stateless architecture achieved" |

## Game model

- **Type**: turn-based strategy
- **Players**: 2 (head-to-head)
- **Armies**: abstract units **deterministically generated** from Cashu token secrets
  (SHA-256 of token commitment seeds the roster)
- **Combat abilities**: 3-ability system — **Boost / Shield / Heal**
- **Match phases**: 9 (challenge → accept → commit → reveal → moves → resolution → payout)

> "The first truly trustless gaming experience" — players control the entire process; the
> game engine is a *validator*, not a coordinator.

## Nostr integration

Nostr is the **primary coordination layer** and the source of truth for all game state.

- Custom event kinds **31000-31006** (note: distinct namespace from kirk's 9259-9263 and
  nutchain's 30800-30814)
  - **31000** Match challenge (wager + league info)
  - **31001** Challenge acceptance
  - **31002** Token commitment / reveal
  - **31003** Combat moves
  - **31004** Match results
  - 31005 / 31006 — additional state events
- Players are addressed by Nostr keypair (npub)
- Players publish all actions to a `strfry` relay on **port 7777**
- **Stateless client architecture**: each client polls Nostr every ~5 s, **reconstructs match
  state chronologically from events on every render**, and discards view objects after the
  frame
- No persistent shared state — all app state derives from event queries

## Cashu integration

Cashu (via CDK Mint) provides asset escrow and the token economy.

- Pure CDK mint on **port 3333** with **custom units** (the CDK is on a fork branch
  `manastr-custom-units`)
- Two token types:
  - **mana** — in-game currency, purchased via Lightning at **5 mana per sat**
  - **loot** — reward / prize tokens
- Match flow: players lock Cashu tokens as wagers at acceptance → winner receives loot from
  the prize pool
- Revenue split: **95 % to player rewards, 5 % system fee**
- Mint has **no game logic** — purely a bearer-asset layer; validation lives in the Game
  Engine Bot
- Mana balance + commitment secret seeds the army generation deterministically

## Relationship to `kirk`

**Manastr does NOT depend on kirk.** No Kirk imports, dependencies, or references in the
tree. Manastr instead implements its **own** commitment/reveal anti-cheat protocol and its
**own** event-kind range. This is consequential: the trio is more loosely coupled than the
naming implies.

- nutchain — abstract spec (event kinds 30800-30814, threshold OPRF / DASoR randomness)
- kirk — Rust library (event kinds 9259-9263, mint-as-referee, P2PK rewards)
- manastr — standalone game (event kinds 31000-31006, stateless clients, custom-units mint,
  game-engine-bot validator)

These are three **independent designs** sharing themes and an author, not three layers of one
stack.

## Architecture

### Service topology

| Component | Port | Role |
|---|---|---|
| `strfry` Nostr relay | 7777 (WS) | Event coordination, source of truth |
| CDK mint (`manastr-custom-units` branch) | 3333 (HTTP) | Token escrow, mana / loot |
| Game Engine Bot | 4444 (Nostr-only) | Match-outcome validator |
| Shared game logic | — (WASM) | Deterministic combat resolution |
| Quantum web client | 8080 (HTTP) | React UI |

### Stateless client pattern

1. Player publishes signed Nostr event for action
2. Client queries the relay every ~5 s, filtered by match id + relevant event kinds
3. Client parses events into temporary view objects (`ChallengeView`, `MatchView`)
4. UI renders directly from those views
5. View objects are discarded after the render — there is no long-lived match state in the
   client
6. The Game Engine Bot independently re-executes the match from all events to validate the
   outcome
7. Cashu transfer happens only after validation

### Anti-cheat (commitment / reveal)

1. Player 1 publishes SHA-256 hash of their token secret (commitment)
2. Player 2 accepts with a matching commitment of their own secret
3. Both players publish the reveals in a later phase
4. Any mismatch → match auto-invalidates
5. Game Engine re-runs combat from revealed moves to verify consistency

### "Pure validator" pattern

The game engine never coordinates the match — it only **validates after the fact**. This
removes coordination authority from any single party.

## Tech stack

**Backend**

- **Rust** + `tokio` — async runtime
- `nostr` / `nostr-sdk` v0.35 — Nostr client
- **CDK fork** (submodule `daemons/cdk`, branch `manastr-custom-units`) — Cashu mint
- `rusqlite` — event storage (relay)
- **WASM** — shared game logic compiled for client + server identical execution

**Frontend (Quantum web client)**

- React 18 + TypeScript + Vite
- TailwindCSS, sci-fi "quantum" aesthetic
- Nostrify / NDK — Nostr client
- Cashu-TS (submodule) — Cashu wallet ops

**Deployment**

- **Single Rust binary** — orchestrator spawns all services via threads + MPSC channels
- `just build` compiles Rust workspace + CDK mint + Nostr relay + WASM + web client
- Service orchestrator handles health checks + graceful shutdown

## Status & roadmap

| Area | Status |
|---|---|
| Event-driven match lifecycle (9 phases) | ✅ functional |
| Commitment/reveal anti-cheat | ✅ |
| Army generation from token secrets | ✅ |
| Combat (attack/defense/health + abilities) | ✅ |
| Token escrow + reward distribution | ✅ |
| Real Nostr publishing | ✅ |
| Quantum web UI | ✅ |
| Phase 3 (next) | Combat replay + advanced move events |
| Phase 4 (production) | Multi-instance E2E testing, UX polish, real-wallet integration (currently mocked) |

> "Integration tests in `daemons/integration_tests/` are the definitive documentation and
> canonical reference implementation."

## Notable design choices

1. **Stateless clients** — no shared in-memory state; query-on-render reconstructs from
   immutable Nostr events. Eliminates sync bugs.
2. **Commitment/reveal** anti-cheat instead of trusting server validation.
3. **Bearer-asset model** — Cashu tokens stay in player wallets; transfer only via Cashu
   proofs. No central balance ledger.
4. **Pure-validator pattern** — game engine validates *after completion*; never holds
   coordination authority.
5. **Nostr as bulletin board** — reuses Nostr's censorship-resistant relay infra rather than a
   game-specific transport.
6. **Single-binary deployment** — relay + mint + engine + web all in one Rust binary.
7. **WASM for logic reuse** — identical combat resolution client- and server-side.

## Recent commit timeline

- 2025-08-26 — debug logging for Nostr relay
- 2025-08-22 — major refactor: cashume + notedeck as submodules, legacy web removed
- 2025-08-04 → 08-08 — transitioned to Rust thread-based services; quantum web client; single-binary
- 2025-07-28 — initial commit

## Architectural redesign anecdote

Earlier branch had a `global_matches` HashMap shared between players' UIs — meaning state
changes "didn't propagate through Nostr." This was diagnosed as a fundamental design flaw and
the redesign produced the current stateless / query-on-render architecture (`ARCHITECTURE_
REDESIGN.md`).

## Key quotes

> "Players control the entire process."

> "Integration tests are the definitive documentation and canonical reference implementation."

> "All apps use the same nostrdb instance — very efficient for cross-app caching."

> "Render UI directly from reconstructed state, discard view objects after render completes."

## Wiki extraction notes

- Concept articles: **manastr event-kind range (31000-31006)**, **manastr stateless-client
  pattern**, **deterministic army generation from Cashu token secrets**, **mana vs loot token
  economy**, **manastr commitment/reveal anti-cheat**, **CDK custom units (`manastr-custom-units`
  branch)**, **post-hoc validator pattern (Game Engine Bot)**.
- Reference: **strfry-as-game-bus**, **CDK fork branches in the wild**.
- Critical contrast article (topic-level): **kirk vs manastr** — three event-kind ranges,
  three different protocols, one author. Why the divergence?
