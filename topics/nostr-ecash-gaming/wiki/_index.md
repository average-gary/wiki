---
title: Wiki — Nostr + Ecash Gaming
type: index
updated: 2026-06-17
---

# Wiki — Nostr + Ecash Gaming

## Topics (synthesizing reads)

- [[topics/three-event-kind-ranges-one-author.md|Three event-kind ranges, one author]] ⭐ — what the EthnTuttle nutchain / kirk / manastr trio actually is (three designs, not a stack)
- [[topics/the-emerging-landscape.md|The emerging Nostr+ecash gaming landscape (mid-2026)]] ⭐ — five factions, no shared protocol; market map
- [[topics/contrarian-case-and-hard-problems.md|The contrarian case]] — why Nostr+ecash gaming might fail, and what it's actually good for

## Concepts (atomic reference reads)

### EthnTuttle trio mechanics
- [[concepts/c-value-game-piece.md|C-value game piece]] — kirk's clever RNG: Cashu BDHKE C-values as deterministic-yet-unpredictable game pieces
- [[concepts/threshold-oprf-dasor.md|Threshold-OPRF DASoR]] — nutchain's distributed randomness over BDHKE + ChillDKG
- [[concepts/mint-as-referee.md|Mint-as-referee]] — Cashu mint plays validator + escrow + RNG-witness in kirk
- [[concepts/post-hoc-validator-pattern.md|Post-hoc validator pattern]] — manastr's separate-from-mint Game Engine Bot
- [[concepts/manastr-stateless-client.md|Manastr stateless client (query-on-render)]] — UI as pure function of the Nostr event log
- [[concepts/hash-linked-event-chain.md|Hash-linked Nostr event chain]] — application-layer ordering compensating for Nostr's missing primitive
- [[concepts/commit-reveal-token-pattern.md|Commit-reveal token pattern]] — shared anti-cheat across kirk / manastr / NIP-101p

### Cashu primitives for gaming
- [[concepts/nut-11-p2pk-reward-locking.md|NUT-11 P2PK reward-locking]] — Schnorr-locked Cashu proofs, the mechanism for binding a reward to a specific winner

### Event-kind ranges
- [[concepts/kirk-event-kinds.md|Kirk event-kind range (9259-9263)]]
- [[concepts/manastr-event-kinds.md|Manastr event-kind range (31000-31006)]]
- [[concepts/nutchain-event-kinds.md|Nutchain event-kind range (30800-30814)]]

## Reference

- [[reference/event-kind-allocation-table.md|Event-kind allocation table]] — every project's Nostr event kinds in one table, plus NIP-01 band semantics
- [[reference/cashu-nut-primitives-for-gaming.md|Cashu NUT primitives for gaming]] — cheat-sheet of NUT-00/04/05/09/10/11/12/13/14/15 for gaming use cases
