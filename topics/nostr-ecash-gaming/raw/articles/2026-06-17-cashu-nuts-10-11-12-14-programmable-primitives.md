---
title: "Cashu NUTs 10/11/12/14 — programmable token primitives for game-asset semantics"
sources:
  - https://github.com/cashubtc/nuts/blob/main/10.md
  - https://github.com/cashubtc/nuts/blob/main/11.md
  - https://github.com/cashubtc/nuts/blob/main/12.md
  - https://github.com/cashubtc/nuts/blob/main/14.md
type: article
tags: [cashu, nut-10, nut-11, nut-12, nut-14, p2pk, htlc, dleq, spending-conditions, gaming-primitives]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: direct
direction: supports
summary: |
  Reference for the Cashu NUTs that turn Cashu from a payment rail into a programmable
  bearer-asset substrate suitable for game-state semantics. NUT-10 defines the well-known
  `secret` JSON `[kind, {nonce, data, tags}]` framework; NUT-11 (P2PK) provides
  Schnorr-locked proofs with n-of-m multisig, locktime + refund pubkeys, SIG_INPUTS vs
  SIG_ALL flags; NUT-12 (DLEQ) proves blind-sig authenticity; NUT-14 (HTLCs) provides
  hash + timelock conditions. Together these are the building blocks for shared in-game
  item ownership, escrow, atomic swaps, and verifiable provenance.
---

# Cashu Programmable-Token NUTs (10 / 11 / 12 / 14)

## Source

- https://github.com/cashubtc/nuts/blob/main/10.md
- https://github.com/cashubtc/nuts/blob/main/11.md
- https://github.com/cashubtc/nuts/blob/main/12.md
- https://github.com/cashubtc/nuts/blob/main/14.md
- Quality: 5 (official spec)

## NUT-10 — well-known secret kinds

- Per-proof spending conditions
- JSON `[kind, {nonce, data, tags}]`
- Framework other NUTs extend

## NUT-11 — P2PK (Pay-to-Public-Key)

- Schnorr-locked proofs (same secp256k1 / Schnorr primitive as Bitcoin and Nostr —
  enabling key reuse across layers)
- **n-of-m multisig** via `pubkeys` + `n_sigs` tags
- **Locktime + refund** via `locktime`, `refund` pubkeys, `n_sigs_refund`
- Signature flags:
  - `SIG_INPUTS` — per-input signatures
  - `SIG_ALL` — single signature covers all inputs + outputs (atomic state transitions)

### Game primitives this enables

- **Shared in-game item ownership** — n-of-m multisig over a guild's loot
- **Escrow** — locktime-delayed refund if a game / match doesn't conclude
- **Atomic swaps** — SIG_ALL bundles two inputs + outputs as one signed transaction
- **Time-bounded match stakes** — refund after expiry

## NUT-12 — DLEQ proofs

- Proves blind-sig authenticity without trusting the mint
- Useful for **verifiable game-asset provenance** — a player can prove a game token came
  from a particular mint without exposing the mint's secrets

## NUT-14 — HTLCs

- Hash + timelock conditions
- Enables trustless escrow, hash-revealed prize unlock, atomic cross-mint swaps

## Why this matters

Kirk uses NUT-11 P2PK to lock reward tokens to the winner's pubkey. nutchain's BDHKE
threshold extension is built on the same blind-sig primitive that NUT-12 DLEQ proofs apply
to. Manastr does NOT lean heavily on NUT-11/14 yet (it uses CDK custom units instead) —
this is a candidate next-step: lift manastr's match-stake escrow into NUT-14 HTLCs.

The shipped Cashu games surveyed (Cashu Casino, Monopoly, spacenut, chessu, OnChainDiscGolf
— see separate raw source) **do not use these primitives**. The gap that the Tuttle trio
is targeting is precisely "use NUT-10/11/14 to encode game state in token spending
conditions, not just operator-side payments."

## Cross-reference

- Hub topic `fedimint` — multi-currency / `AmountUnit` work — Cashu NUT-02 multi-unit pattern
- Hub topic `cdk-ldk-lnurl` — CDK is the reference Cashu impl
- Hub topic `clink-protocol` — Nostr-native payment standards (separate but adjacent
  primitive set)
