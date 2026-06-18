---
title: "DocNR/nostr-poker — non-custodial online poker on Nostr + Lightning (NIP-101p draft)"
source: https://github.com/DocNR/nostr-poker
type: repo
tags: [nostr, lightning, poker, nip-101p, commit-reveal, gaming, replaceable-dealer, marketplace, microstandard]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: direct
direction: nuances
summary: |
  Pre-implementation but unusually rigorous draft NIP-101p for non-custodial online poker on
  Nostr with Lightning settlement. Defines event kinds 1650-1660 (table open / sit / hand
  begin / hole cards / action req-resp / community / showdown / dispute) and 33650
  (replaceable Dealer Profiles). Trust model = SHA-256 commit-reveal of dealer shuffle seed
  (mismatch yields a publicly signed cheating proof). Settlement pure-P2P via NIP-47 NWC zaps.
  Reserved trust tiers `tee:` / `frostr:` / `bonded:` show explicit upgrade path. Dealer is
  "deck + clock" only; replaceable-dealer marketplace via 33650 reputation.
---

# DocNR/nostr-poker

## Source

- URL: https://github.com/DocNR/nostr-poker
- Spec: `docs/nip-101p-draft.md`
- Quality: 5

## Architecture (three layers)

1. **Player layer** — PWA; auth via NIP-07 / NIP-46 (Amber/Clave); wallet via NIP-47 NWC;
   client-side hand evaluation (`pokersolver`); settlement via NIP-57 zaps.
2. **Nostr relays** — signed table state, action streams, dealer reputation (kind 33650
   addressable Dealer Profiles).
3. **Dealer layer** — third-party services running deck + clock only. Holds **no funds**.

## NIP-101p event kinds

| Kind | Role |
|---|---|
| 1650 | Table open |
| 1651 | Sit-down |
| 1652 | Hand begin (carries SHA-256 commitment of seed) |
| 1653 | Hole cards (NIP-44 encrypted) |
| 1654 | Action request |
| 1655 | Action response |
| 1656 | Community cards |
| 1657 | Showdown |
| 1658 | Hand end (seed reveal) |
| 1659 | Dispute (audit artifact) |
| 1660 | (further state) |
| 33650 | Replaceable Dealer Profile (reputation) |

## Trust model

- Dealer publishes `sha256(seed || canonical(seats) || hand_n)` in **kind 1652** before
  dealing
- Dealer reveals seed in **kind 1658** at hand end
- Mismatch produces **kind 1659** dispute event — publicly signed cheating proof, audit
  artifact
- **Catches mid-game manipulation; does NOT catch collusion or pre-arrangement** (explicit)
- Reserved tiers for stronger guarantees: `tee:<vendor>` (Nitro / SGX), `frostr:<t-of-n>`,
  `bonded:<sats>`, reproducible builds

## Settlement

- **Pure P2P Lightning**: losers' clients auto-zap winners' `lud16` after showdown via
  NIP-57
- Dealer fee paid the same way
- Dealer holds zero economic authority

## Replaceable-dealer marketplace

The signature design feature: any dealer that implements NIP-101p competes on reputation +
fee. Kind 33650 is the address.

## Stack

- SvelteKit 2, Svelte 5, Tailwind 4
- `nostr-tools`, `@getalby/bitcoin-connect`, `vitest`
- Status: pre-implementation feedback round open

## Three deliverables

1. Harness webapp
2. **NIP-101p specification**
3. Reference dealer implementation

## Why this matters for the topic

Most rigorous Nostr+gaming microspec yet published. Settlement is Lightning today but is the
obvious candidate for swap to **Cashu P2PK escrow** (NUT-11) — exactly the gap manastr/kirk
fill on the Cashu side. The "replaceable-dealer marketplace" pattern (commit/reveal + 33650
reputation) is a transferable primitive to other turn-based stake games.

Cross-reference: the kirk event-kind range (9259-9263) and NIP-101p event-kind range
(1650-1660) are non-overlapping — both could co-exist in Nostr's kind space.
