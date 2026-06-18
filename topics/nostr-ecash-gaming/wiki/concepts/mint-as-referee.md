---
title: Mint-as-referee
type: concept
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [cashu, kirk, manastr, trust-model, escrow, validator]
---

# Mint-as-referee

A design pattern in which a **Cashu mint** plays the dual role of bearer-asset issuer and
**game-rules validator**. The mint:

- Holds escrowed stake (Game tokens locked at challenge time)
- Validates the chain of Nostr game events for protocol compliance
- Verifies that revealed tokens hash back to commitments (anti-double-spend)
- Issues NUT-11 P2PK-locked **reward tokens** to the winner
- Confiscates forfeited tokens from cheaters

It eliminates the need for a separate game server.

## Implementations

- [[raw/repos/2026-06-17-ethntuttle-kirk.md|kirk]] — most direct realization. The mint is in
  the validation loop on every reward distribution.
- [[raw/repos/2026-06-17-ethntuttle-manastr.md|manastr]] — splits the role: a separate
  **Game Engine Bot** validates outcomes; the **CDK mint** only handles token economy
  (`mana` and `loot` custom units). This is closer to "mint-as-bank, separate post-hoc
  validator" than mint-as-referee.

## Trust model

- **Best case**: cryptographic accountability. The mint's actions are publicly visible on
  Nostr; cheating produces signed audit artifacts.
- **Worst case**: trust-shifted, not trust-removed. The mint can selectively refuse
  redemption, can rug the escrow pool ([[raw/articles/2026-06-17-rug-the-mints-fee-bypass-nutshell-lnbits.md|fee-bypass attack]]),
  or can suffer keyset-collision exploits ([[raw/articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md|conduition disclosure]]).
- The author of the trio openly admits ([[raw/articles/2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md|gist]])
  the mint is "just a database, entirely controlled by one entity running a server" — the
  pattern is **explicit-trust with cryptographic accountability**, not trustless.

## Architectural alternative

[[raw/repos/2026-06-17-docnr-nostr-poker-nip101p.md|NIP-101p / nostr-poker]] inverts the
pattern: the dealer is "deck + clock" only; the mint is **out of the loop**; settlement is
P2P Lightning zaps after showdown. The dealer's only authority is shuffle commitment, and
mismatch produces a signed cheating proof. Trust is distributed across player keys + a
reputation marketplace.

## See also

- [[wiki/concepts/c-value-game-piece]]
- [[wiki/concepts/post-hoc-validator-pattern]]
- Hub topic [[../../../fedimint/_index|fedimint]] (federated alternative — guardians instead
  of single mint operator, ROASTr threshold-Nostr-signing as building block)
