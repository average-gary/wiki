---
title: "Cashu NUT primitives for gaming (cheat-sheet)"
type: reference
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [reference, cashu, nuts, p2pk, htlc, dleq, gaming-primitives]
---

# Cashu NUT primitives for gaming

Quick reference: which NUT gives you which game-asset semantic.

| NUT | What it provides | Game use |
|---|---|---|
| **NUT-00** | BDHKE basic blind-sign | Token primitive |
| **NUT-04 / NUT-05** | Lightning mint / melt | Buy in / cash out |
| **NUT-09** | Restore (deterministic recovery) | ⚠ also the keyset-collision attack vector — see [[../../raw/articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md]] |
| **NUT-10** | Well-known `secret` JSON `[kind, {nonce, data, tags}]` | Framework for spending conditions |
| **NUT-11** | **P2PK** — Schnorr-locked proofs, n-of-m multisig, locktime + refund, `SIG_INPUTS` / `SIG_ALL` | Reward locking, shared item ownership, atomic state transitions, time-bounded escrow |
| **NUT-12** | **DLEQ** proof of blind-sig authenticity | Verifiable game-asset provenance without trusting the mint |
| **NUT-13** | Deterministic-secret derivation | ⚠ 31-bit keyset-id space — see [[../../raw/articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md]] |
| **NUT-14** | **HTLCs** — hash + timelock conditions | Hash-revealed prize unlock, atomic cross-mint swaps, bet escrow |
| **NUT-15** | Multi-path payments | Sub-bet bundling |

## Pairings used in the wild

| Project | NUTs in active use |
|---|---|
| [[../../raw/repos/2026-06-17-ethntuttle-kirk.md\|kirk]] | NUT-00, NUT-11, NUT-12 |
| [[../../raw/repos/2026-06-17-ethntuttle-manastr.md\|manastr]] | NUT-00, NUT-04/05 (Lightning into custom units), commitment via SHA-256 outside NUTs |
| [[../../raw/repos/2026-06-17-cashu-casino-and-other-cashu-games-survey.md\|Cashu Casino]] | NUT-00, NUT-04/05 only — payment rail |
| [[../../raw/repos/2026-06-17-cashu-casino-and-other-cashu-games-survey.md\|Cashu Monopoly]] | NUT-00 + Lightning BOLT11 — custodial server wallet |

## In-flight (2025-2026)

- **payjoin** (May 2026) — relevant for chip-management without revealing balances
- **custom payment methods** (May 2026) — non-Lightning rails
- **Proof of Liabilities** (Jun 2026) — would partially address the mint-insolvency
  attack, but doesn't catch the Nutshell `LNbitsWallet` fee-bypass (out-of-scope)
- **Deterministic Keypairs** (May 2026)
- **NUT-29 batch minting** (May 2026) — relevant for high-frequency game state

## What's missing for gaming

- **No NUT for randomness oracles** — kirk's C-value approach reuses a primitive that
  exists for issuance, not a primitive designed for RNG
- **No NUT for streaming / state-channel-style ecash** — every state transition is a full
  swap
- **No standardized stake-into-match condition** — the closest is NUT-14 HTLC + NUT-11
  multisig, composed by the application
