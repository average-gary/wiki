---
title: "Nostr NIPs relevant to gaming — survey of 01 / 17 / 28 / 29 / 44 / 47 / 51 / 57 / 58 / 60 / 61 / 64 / 87 / 90 / 94 / 101p"
sources:
  - https://github.com/nostr-protocol/nips
  - https://github.com/nostr-protocol/nips/blob/master/01.md
  - https://github.com/nostr-protocol/nips/blob/master/29.md
  - https://github.com/nostr-protocol/nips/blob/master/57.md
  - https://github.com/nostr-protocol/nips/blob/master/60.md
  - https://github.com/nostr-protocol/nips/blob/master/61.md
  - https://github.com/nostr-protocol/nips/blob/master/64.md
  - https://github.com/nostr-protocol/nips/blob/master/87.md
  - https://github.com/nostr-protocol/nips/blob/master/90.md
type: article
tags: [nostr, nips, nip-60, nip-61, nip-64, nip-87, nip-90, nip-29, nip-101p, gaming, ecash-on-nostr]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 4
relevance: direct
direction: supports
summary: |
  Inventory of the Nostr NIPs that any Nostr+ecash gaming system will compose. Identity +
  events: NIP-01. Encrypted DMs: NIP-17 / NIP-44. Lobbies: NIP-28 (chat) / NIP-29 (relay
  groups, with built-in `previous` event-hash causal chain — a relay-as-sequencer primitive).
  Wallets: NIP-47 NWC. Payments: NIP-57 zaps, NIP-60 Cashu wallet, NIP-61 Nutzaps. Federation
  discovery: NIP-87. DVMs: NIP-90 (officially deprecated in favor of microstandards).
  Game-specific: NIP-64 (chess PGN, kind 64). Microstandard draft: NIP-101p (poker, kinds
  1650-1660). Achievements / distribution: NIP-58 / NIP-51 / NIP-94.
---

# Nostr NIPs Relevant to Gaming

## Identity & event log

- **NIP-01** — Schnorr/secp256k1 signed JSON events; replaceable / addressable kinds; filters.
  Foundational. Same Schnorr keys can co-bind to NUT-11 P2PK proofs.

## Encrypted state

- **NIP-44** — versioned encrypted payloads (ChaCha20 + HMAC). Used for hidden-info game
  moves (e.g., poker hole cards in NIP-101p kind 1653).
- **NIP-17** — direct messages (private chat in-game).

## Lobbies / coordination

- **NIP-28** — public chat channels (area chat).
- **NIP-29** — relay-based groups. Relay is authoritative coordinator; relay's keypair signs
  group metadata. Built-in `previous` event-hash causal chain (game-move ordering primitive).
  Membership state reconstructed via event-sourced replay. **Strong fit for game lobbies
  with relay-as-arbiter.**

## Wallets / payments

- **NIP-47 (NWC)** — Nostr Wallet Connect. Used by NIP-101p for pay-after-showdown zaps.
- **NIP-57** — zaps. Settlement primitive used by every nostr-game today.
- **NIP-60** — **Cashu Wallet** — canonical wallet-state-on-Nostr for ecash.
- **NIP-61** — **Nutzaps** — zaps that carry Cashu tokens instead of bolt11 payments.
- **NIP-87** — **Mint announcements** (Cashu/Fedimint). Discovery + web of trust. ROASTr
  (Fedimint module) implements this.

## Marketplaces / oracles

- **NIP-90 (DVMs)** — officially marked **"this got totally out of control, prefer
  use-case-specific microstandards"** in the canonical NIPs README. Implication: gaming
  oracles should be microstandards, not generic DVMs.

## Game-specific

- **NIP-64** — chess. Kind 64 = PGN string in event content. The only merged game-specific
  NIP.
- **NIP-101p** (DRAFT) — poker. Kinds 1650-1660 + addressable Dealer Profile 33650. The
  microstandard pattern in action.

## Achievements / distribution

- **NIP-58** — badges (achievements / gamer profiles).
- **NIP-51** — lists (player rosters, friends, banned users).
- **NIP-94** — file metadata (release distribution).
- **NIP-DC** (Direct Connect, Sept 2025) — could be used for low-latency game P2P.
- **NIP-59** ephemeral gift wrap (May 2026) — useful for hidden-info game moves.

## Custom kinds in the wild

| Range | Project |
|---|---|
| 64 | NIP-64 chess |
| 1650-1660 | NIP-101p poker (draft) |
| 9259-9263 | EthnTuttle/kirk |
| 30800-30814 | EthnTuttle/nutchain |
| 31000-31006 | EthnTuttle/manastr |
| 33650 | NIP-101p Dealer Profile (replaceable) |
| 39000-39004 | NIP-29 group metadata |

Three EthnTuttle ranges in three different blocks of kind-space — note the lack of a single
unified protocol.

## Why this matters

A working Nostr+ecash game composes ~10 NIPs. Most are stable; the gaming-specific layer
(NIP-64, draft NIP-101p, custom kinds) is the active design surface. **No NIP currently
standardizes ecash-stake-into-match, in-game item ownership, randomness oracles, or
matchmaking.** The microstandards approach (per NIP-101p) is the path the ecosystem is
endorsing.

## Cross-reference

- Hub topic `clink-protocol` — Nostr-native Lightning standards (CLINK Offers / Debits /
  Manage), parallel design space to NIP-47/57/60/61.
