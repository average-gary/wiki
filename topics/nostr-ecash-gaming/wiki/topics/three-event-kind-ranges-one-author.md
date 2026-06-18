---
title: "Three event-kind ranges, one author — what the EthnTuttle trio reveals"
type: topic
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [synthesis, ethntuttle, kirk, manastr, nutchain, nostr-event-kinds, design-evolution]
---

# Three event-kind ranges, one author — what the EthnTuttle trio reveals

The on-ramp question for this wiki was simple: "Read the
[nutchain](https://github.com/EthnTuttle/nutchain) /
[kirk](https://github.com/EthnTuttle/kirk) /
[manastr](https://github.com/EthnTuttle/manastr) trio and tell me about Nostr+ecash gaming."

The surface assumption was a layered stack: nutchain = spec, kirk = library, manastr = the
game on top. **That assumption is wrong.** The three projects use **three non-overlapping
Nostr event-kind ranges**, share an author but not a codebase, and embody **three distinct
designs** for the same problem.

## What was actually shipped

| Project | Event kinds | Status | Trust model | RNG | Bus role for ecash |
|---|---|---|---|---|---|
| [[../concepts/nutchain-event-kinds\|nutchain]] | 30800-30814 | Spec only (last commit Mar 2026) | Threshold-of-players (no external referee) | DASoR — threshold-OPRF over BDHKE | Stake binding (not financial) |
| [[../concepts/kirk-event-kinds\|kirk]] | 9259-9263 | Rust library (last commit Jan 2026) | Mint-as-referee | C-value-as-game-piece | NUT-11 P2PK reward-locked |
| [[../concepts/manastr-event-kinds\|manastr]] | 31000-31006 | Playable game (last commit Aug 2025) | Post-hoc validator (separate from mint) | Deterministic-from-token-secrets via SHA-256 | CDK custom units (`mana`, `loot`) |

## Three different designs

### nutchain (the spec)

- **Most cryptographically ambitious**. ChillDKG + Threshold OPRF over BDHKE = unbiasable
  randomness with no external mint in the RNG loop.
- **Hash-linked event chain** (sequence numbers + `e` tag) bolts ordering onto Nostr at
  the application layer.
- **Explicit caveat**: ChillDKG-OPRF composability is unproven. Author accepts the risk
  because nutchain "has no financial custody at stake" — randomness is bound to game
  state only.
- **Not implemented anywhere yet**.

### kirk (the library)

- **Implements** mint-as-referee architecture in Rust.
- C-values from Cashu blind signatures = game pieces (rank, suit, dice roll).
- Reward tokens are NUT-11 P2PK-locked to winner; cheaters forfeit.
- Trait-based extensibility: any new game implements the `Game` trait.
- Ships with a card-game reference impl, three example binaries.
- Has not been picked up by any other project so far.

### manastr (the playable game)

- **Does NOT use kirk** — implements its own commit-reveal protocol with its own event
  kinds.
- Uses a CDK fork (`manastr-custom-units` branch) instead of Fedimint or upstream CDK.
- Stateless React clients query a strfry relay; a Game Engine Bot validates after the
  fact.
- Most production-ready of the three.
- Architecture pivot mid-2025 — the `ARCHITECTURE_REDESIGN.md` documents the move from a
  shared `global_matches` HashMap to pure event-sourced state.

## Why three different designs?

Plausible read (from commit timelines + the
[[../../raw/articles/2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md|author's own gist]]):

- **manastr (Jul-Aug 2025)** was built first as a working prototype. Used SHA-256 commit-
  reveal because it's simple and the game economy is closed within a custom-units mint.
- **kirk (Sep 2025-Jan 2026)** was an attempt to **generalize** the gameplay primitives
  out of manastr into a reusable library. Different event kinds because the abstraction
  is broader and re-using manastr's kinds would have created false coupling. Not yet
  retrofit into manastr.
- **nutchain (Mar 2026)** was the **next-generation** design — pushing the trust model
  past mint-as-referee toward fully-distributed threshold randomness. Specification
  stage; no implementation yet.

This is consistent with one developer **iterating on the design** rather than building a
unified stack. Each repo represents a snapshot of a research direction, not a coupled
architecture.

## What this means for the wiki's open questions

- **There is no canonical "kirk protocol stack"**. The library exists; nothing else uses it
  yet.
- **There is no canonical NIP** for any of these. All three use private custom kinds.
- **The "trio" framing oversells coupling.** It's better to read each repo on its own as
  three answers to the same question.
- **NIP-101p (poker)** and NostrGameEngine come from different authors and use different
  Lightning-vs-Cashu choices entirely (see [[the-emerging-landscape]]).

## Open question

Will the trio converge on a single protocol, will manastr migrate to kirk + DASoR, or will
the design space remain fragmented? As of 2026-06-17, fragmentation is the answer.

## Sources

- [[../../raw/repos/2026-06-17-ethntuttle-nutchain.md]]
- [[../../raw/repos/2026-06-17-ethntuttle-kirk.md]]
- [[../../raw/repos/2026-06-17-ethntuttle-manastr.md]]
- [[../../raw/articles/2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md]]
