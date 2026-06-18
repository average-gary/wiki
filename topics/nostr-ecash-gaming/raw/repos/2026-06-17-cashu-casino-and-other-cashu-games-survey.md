---
title: "Cashu Casino + other shipped Cashu games — survey of awesome-cashu gaming entries"
source: https://github.com/cashubtc/awesome-cashu
type: repo
tags: [cashu, gaming, casino, monopoly, chess, awesome-cashu, payment-rail-only]
fetched: 2026-06-17
confidence: high
credibility: medium
quality_score: 3
relevance: direct
direction: nuances
summary: |
  Catalog of all Cashu-based games linked from awesome-cashu. Cashu Casino (Next.js),
  spacenut (arcade), Cashu Monopoly (Flask), chessu.cash (chess puzzles), OnChainDiscGolf
  (scorecard) — five live projects total. Pattern: every one uses Cashu purely as a
  payment rail. NONE use NUT-11 P2PK or NUT-14 HTLCs for game-asset semantics. Confirms the
  whitespace that kirk / nutchain / manastr try to fill.
---

# Survey: Cashu-Based Games (from awesome-cashu)

## Cashu Casino

- Repo: https://github.com/babdbtc/cashucasino
- Stack: Next.js
- Auth: **NIP-07** (extension) + **NIP-98** (HTTP auth) + **NIP-04** (encrypted DM for
  withdrawal delivery)
- Cashu lib: `@cashu/cashu-ts` v3.0.2
- Mint quotes: NUT-04 / NUT-05
- Games: Slots, Plinko, Crash, Mines, Blackjack
- **RNG: server-side** (centralized; the server is the house)

## spacenut

(See dedicated raw source `2026-06-17-spacenut-and-gandlafbtc-cashu-toolkit.md`.)

## Cashu Monopoly

- Repo: `bTCpy/monopoly`
- Python Flask + JS
- **Custodial server wallet**
- Lightning buy-in via BOLT11
- Winner gets pot as Cashu token
- Auto-scaling economics
- **No Nostr**
- Beta with explicit fund-loss warnings

## chessu.cash

- Chess-puzzle-to-Cashu rewards (rewards puzzle solvers)

## OnChainDiscGolf

- Disc golf scorecard with Cashu payments

## Pattern

Every one of these uses Cashu **as a payment rail**. None use:

- **NUT-11 P2PK** for game-asset semantics (i.e., game items as P2PK-locked Proofs)
- **NUT-14 HTLCs** for trustless escrow / atomic swaps
- **NUT-12 DLEQ** proofs for verifiable provenance
- **C-value-as-game-piece** (kirk's signature trick)
- **Commit-reveal token patterns** (nutchain / manastr)

The whitespace that the EthnTuttle trio targets is clear: **Cashu as bearer-asset substrate
for game state**, not just payment.

## Trust model contrast

- Cashu Casino: server-side RNG → server is the house. Standard online-casino model.
- Cashu Monopoly: custodial server wallet → server holds the prize pool. Same.
- Chessu / OnChainDiscGolf: Cashu = reward tip for completing skill activity. No game-state
  consequences.
- spacenut: arcade with sats payout, also custodial.

None move the trust model meaningfully beyond "trust the operator." That is precisely why
manastr / kirk / nutchain are interesting research even if they're not yet shipping.
