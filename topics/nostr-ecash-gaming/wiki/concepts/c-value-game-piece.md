---
title: C-value game piece
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [cashu, kirk, randomness, bdhke, game-piece]
---

# C-value game piece

In Cashu's BDHKE blind-sign flow, the mint's signed value `C = kY` (where `Y =
hash_to_curve(secret)` and `k` is the mint's keyset secret) is **deterministic** (same
secret → same C) but **unpredictable** to the player until they unblind.

[[wiki/concepts/kirk-protocol-stack|Kirk]] uses the first 4 bytes of `C` as a seed to
**deterministically decode a game piece**:

| Game | Decoding |
|---|---|
| 52-card deck | Rank 2..A + Suit ♣♦♥♠ |
| Dice | 1..6 |
| Coin flip | Boolean |
| (custom) | Implementer's `Game` trait |

## Why this works

1. **Unpredictable pre-reveal** — the mint blind-signs without seeing the secret; the player
   knows the secret but cannot predict `k` (and so cannot predict `C`) until unblinding.
2. **Deterministic** — once the secret + keyset are committed (e.g. via SHA-256 hash in a
   Nostr event), the C-derived game piece is fixed.
3. **Publicly verifiable** — anyone holding the proof can re-derive the game piece.

## Constraint: requires a mint

The mint is in the loop. Without a Cashu mint blind-signing, no C value exists. This is the
hard tie between this RNG primitive and the [[wiki/concepts/mint-as-referee|mint-as-referee]]
trust model.

## Contrast with traditional approaches

- **On-chain RNG** (block-derived entropy) — grindable by miners (OWASP SC09:2025).
- **VRF / Chainlink** — needs a programmable settlement layer; Nostr+Cashu has none.
- **Commit-reveal alone** — provides hiding but a single revealed value can still be
  ground; C-values combine commit-reveal with mint-witnessed randomness in one step.

See also [[wiki/concepts/threshold-oprf-dasor|threshold-OPRF DASoR]] for nutchain's
generalization (n-of-m mint roles distributed over the player set).

## Sources

- [[raw/repos/2026-06-17-ethntuttle-kirk.md]]
- [[raw/articles/2026-06-17-cashu-nuts-10-11-12-14-programmable-primitives.md]]
