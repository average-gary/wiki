---
title: "Jester / jesterui + NIP-64 — chess over Nostr; canonical board-game-via-PGN-event pattern"
source: https://github.com/jesterui/jesterui
spec: https://github.com/nostr-protocol/nips/blob/master/64.md
demo: https://jesterui.github.io
type: repo
tags: [nostr, chess, nip-64, board-game, pgn, jester, satsangatech]
fetched: 2026-06-17
confidence: high
credibility: medium
quality_score: 4
relevance: direct
direction: nuances
summary: |
  Jester is the earliest / most-starred (61★) Nostr chess PoC, authored a draft NIP-64
  (kind 64 = PGN string in event content), and inspired a second independent implementation
  (satsangatech/nostr-chess in Rust+WASM, with Lichess/Chess.com bridges) that explicitly
  extends NIP-64. Two independent impls = de-facto small standard. NIP-64 is the only
  game-specific NIP currently merged into the Nostr nips repo. No zaps / ecash integration
  — pure protocol layer.
---

# Jester + NIP-64

## Source

- Repo: https://github.com/jesterui/jesterui (61 stars)
- Live demo: https://jesterui.github.io
- NIP-64 spec: https://github.com/nostr-protocol/nips/blob/master/64.md
- Sister impl: https://github.com/satsangatech/nostr-chess
- Quality: 4 (standardized via NIP-64; canonical board-game pattern)

## NIP-64

- **Kind 64** = PGN (Portable Game Notation) chess string in event `content`
- Two modes: strict (export) and lax (import for PGN-from-elsewhere)
- Currently the **only game-specific NIP** in the merged nips repo

## Jesterui

- TypeScript 97.8 % / React / Tailwind
- Integrates `chess.js`, `Stockfish.js`, `Chessground`
- Uses `nostr-rs-relay` for local dev (`npm run regtest:up`)
- Authored the NIP-64 draft (paired repo `jesterui/nip64` exists with pgn-viewer
  dependency)
- Self-described "many bugs and missing features"
- **No zaps / no ecash** — relay-mediated, P2P-style coordination only

## satsangatech/nostr-chess (independent extension)

- Rust + WASM
- `rooky-core` (Nostr + PGN), `chessboard-js` (WASM bindings)
- Chess.com / Lichess adapters via `shakmaty`
- Uses `nostro2` for events
- **Explicitly extends NIP-64** for interop with Lichess/Chess.com APIs

## Why it matters

- Reference protocol for **serializing turn-based games over Nostr** (PGN-in-event pattern)
- Two independent implementations adopting the same NIP makes this the canonical example
  of a board-game NIP outside `kind: 1`/zap territory
- Sets the precedent for the kirk and NIP-101p event-kind ranges to follow
- Demonstrates that **game state can fit entirely in event content** without invoking a
  mint or escrow — a counter-architecture to the "mint-as-referee" Tuttle approach. Suitable
  when the game has no economic stake.
