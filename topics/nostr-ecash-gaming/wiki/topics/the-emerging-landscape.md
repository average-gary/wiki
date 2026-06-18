---
title: "The emerging Nostr+ecash gaming landscape (mid-2026)"
type: topic
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [synthesis, landscape, market-survey, ngengine, nostr-poker, cashu-casino]
---

# The emerging Nostr+ecash gaming landscape (mid-2026)

As of 2026-06-17, the space is **pre-consolidation**. Five concrete factions exist with no
shared protocol.

## Faction map

| Faction | Anchor projects | Coordination | Currency | Trust model |
|---|---|---|---|---|
| **EthnTuttle trio** | nutchain (spec), kirk (lib), manastr (game) | Custom event kinds (3 ranges) | Cashu (CDK + custom units) | Mint-as-referee or threshold-of-players |
| **NostrGameEngine** | ngengine (jME fork), 23-repo org | NostrRTC P2P over Nostr signaling | Lightning v0.5 roadmap; **Cashu not announced** | Traditional client/server with Nostr identity |
| **NIP-101p / nostr-poker** | DocNR/nostr-poker | NIP-101p microstandard (kinds 1650-1660 + 33650) | Lightning via NIP-47 NWC zaps | Replaceable-dealer marketplace + commit-reveal |
| **NIP-64 / chess** | jesterui, satsangatech/nostr-chess | NIP-64 (kind 64, PGN-in-content) | None (no stakes) | Pure protocol, no economic layer |
| **Cashu game shipping kit** | spacenut, Cashu Casino, Monopoly, chessu, OnChainDiscGolf, gandlafbtc tools | Mostly NOT Nostr; classic web | Cashu as **payment rail only** (not NUT-11/14) | Custodial / server-side house |

## What's shared, what's not

**Shared primitives** the ecosystem is converging on:

- **Identity** = NIP-01 Schnorr keys (same secp256k1 as Bitcoin and NUT-11 P2PK)
- **Payments** = NIP-57 zaps; NIP-60/61 Cashu wallet + Nutzaps emerging
- **Encryption for hidden info** = NIP-44
- **Wallet** = NIP-47 NWC

**Non-shared design questions** (where the factions diverge):

- **Whose authority?** Mint (kirk) vs federation (theoretical) vs threshold-of-players
  (nutchain) vs no-authority-just-Lightning (NIP-101p)
- **What is Cashu in the architecture?** Payment rail (Cashu Casino) vs bearer asset for
  game state (kirk) vs custom-unit currency (manastr)
- **How does randomness happen?** Server-side RNG (Cashu Casino) vs C-value (kirk) vs
  threshold-OPRF (nutchain) vs commit-reveal-of-shuffle (NIP-101p)
- **Where does ordering come from?** Hash-linked chain (nutchain, kirk) vs replay-everything
  (manastr) vs relay-as-sequencer (NIP-29 in theory) vs implicit (NIP-64, NIP-101p)

## Conference / funding signal (2025-2026)

- **Bitcoin++ Berlin Oct 2025** — Lightning Edition + dedicated **ecash hackday Oct 1**
  + **Nostr Hackday Oct 5**. Calle (Cashu) confirmed speaker. 100+ hackers, 5M sats prizes.
- **Bitcoin++ Floripa Feb 2025** — explicitly themed "hack+play edition," 10M sats
  prizes. ZBD (gaming-Bitcoin co.), Lightning Labs, Alby present.
- **OpenSats grant waves 15-17 (2026)** — **zero gaming grants**. Routstr (Cashu+Nostr for
  paid AI inference) is the architectural template anyone could fork for gaming. **Funding
  gap.**
- **Calle / Cashu team has not publicly endorsed any gaming reference impl** as of Berlin
  2025 — opportunity for a canonical "Cashu game starter kit."

## NIP gaps (whitespace)

- **No NIP standardizes** ecash-stake-into-match, in-game item ownership, randomness
  oracles, or matchmaking.
- The merged-NIP gaming surface is exactly NIP-64 (chess). NIP-101p (poker) is in feedback.
- 2026 NIP PR activity skews toward AI agents / DVM microstandards. Gaming is a wide-open
  green field.

## Forks in the road

What are the architectural questions not yet resolved?

1. **Cashu vs Fedimint as the trust root.** Fedimint distributes the trust across
   guardians (better) but the multi-currency / module surface is not gaming-friendly yet
   (see hub topic [[../../../fedimint/_index|fedimint]] § multi-currency status). Cashu is
   simpler but the operator IS the trust root.
2. **Lightning vs Cashu as the payment rail.** NIP-101p chose Lightning + NWC zaps;
   manastr chose Cashu custom units. Both are defensible — they trade trustless-but-
   pay-after vs custodial-but-bearer.
3. **Mint-as-referee vs post-hoc-validator.** kirk synchronously involves the mint;
   manastr decouples a separate validator bot. The latter scales better and isolates
   custody risk; the former gives stronger atomicity.
4. **Should a "Nostr Game NIP" be one big NIP or many microstandards?** NIP-90 DVMs is
   officially marked as a cautionary tale ("this got totally out of control, prefer
   use-case-specific microstandards"). The ecosystem signals: many microstandards,
   per-game.

## Recommended posture

If you're building today:

- **Want a shipping engine?** [[../../raw/repos/2026-06-17-nostrgameengine.md|NostrGameEngine]] is
  the only one. Lightning-first. Cashu-bolt-on is your job.
- **Want trustless turn-based gameplay with stakes?** Read kirk; reuse the C-value game-
  piece pattern; consider grafting NUT-11 P2PK from kirk onto NIP-101p's design (the
  obvious cross-pollination no-one has done yet).
- **Want a Cashu-paying small game?** spacenut + the
  [[../../raw/repos/2026-06-17-spacenut-and-gandlafbtc-cashu-toolkit.md|gandlafbtc kit]]
  (`cashu-faucet`, `proxnut`, `headless-cashu`) is the lightest path.
- **Want a Fedimint-backed game federation?** No prior art. Compose
  [[../../raw/repos/2026-06-17-fedimint-modules-roastr-and-prediction-market.md|ROASTr +
  fedimint-prediction-market]] + custom escrow module. Greenfield.

## Sources

- See [[../../raw/_index]] — full source bibliography
