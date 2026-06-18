---
title: "The contrarian case: why Nostr+ecash gaming might fail"
type: topic
created: 2026-06-17
updated: 2026-06-17
confidence: high
tags: [synthesis, contrarian, hard-problems, security, trust-model]
---

# The contrarian case: why Nostr+ecash gaming might fail

The case against this architecture is **strong and largely conceded by the proponents
themselves**. Tabling the sceptical view honestly clarifies what these systems are good
for and what they aren't.

## Mint-as-referee is mint-as-house

A malicious or insolvent mint can:

- **Selectively refuse redemption** (no on-chain accountability layer)
- **Silently overspend its hot wallet** —
  [[../../raw/articles/2026-06-17-rug-the-mints-fee-bypass-nutshell-lnbits.md|Nutshell
  LNbitsWallet ignores `fee_limit_msat`]], drains hot wallet via routing-fee attack,
  marks proofs as spent, returns success-on-overage
- **Be exploited via keyset collision** —
  [[../../raw/articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md|conduition
  disclosure]] shows NUT-13 reduces 64-bit keyset IDs to a 31-bit secret-derivation
  space, enabling poisonous-airdrop coin-fork attacks via `/v1/restore` (NUT-09)
- **The author of the trio admits** ([[../../raw/articles/2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md|gist]]):
  > "Mint is just a database, entirely controlled by one entity running a server. Lose the
  > database, kaput. Same or better theft security model than TTP but **much worse than a
  > blockchain**."

## No global ordering on Nostr

The peer-reviewed measurement
([[../../raw/papers/2026-06-17-nostr-empirical-decentralization-resilience-conext.md|Wei &
Tyson, CoNEXT '25]]) confirms Nostr provides no causality / total-order primitive at the
protocol level. Application-layer
[[../concepts/hash-linked-event-chain|hash-linked event chains]] re-add it, but they're
expensive in a network where:

- **20% of relays are down >40% of the time**
- **132 relays are effectively dead**
- **98.2% of fetches are redundant** (multi-relay duplication)
- **95% of free relays cannot cover their operating cost**

Multi-day tournaments and persistent worlds have no liveness guarantee.

## No native trustless RNG

Cashu has no VRF; Nostr has no consensus. The OWASP SC09:2025 Smart Contract Top 10 lists
**insecure randomness** as a top-10 vuln on EVM — and Cashu+Nostr have *fewer* primitives
than EVM does. Commit-reveal works only when a slashable referee enforces it — circular
dependency on the mint.

[[../concepts/threshold-oprf-dasor|nutchain's threshold-OPRF DASoR]] is a real attempt at
fixing this, but it has unproven composability (ChillDKG-OPRF was not peer-reviewed in
that combination).

## Anti-collusion has no protocol-level answer

Nothing prevents players colluding with the mint operator. Fedimint distributes trust via
threshold (better) — but adds federation-coordination cost and isn't yet wired up for
gaming. NIP-101p's commit-reveal explicitly does NOT catch pre-arrangement.

## Privacy regression for high-stakes play

Larger denominations are linkable; mints see IPs (Cashu FAQ). Whales are deanonymized.
This is a known limitation; OK for low-stakes play, fatal for casino-grade games.

## "Online receiver" + Lightning HTLC limits = star topology

Cashu (per the Cashu FAQ and the Tuttle gist) reverts to **online** transfers in
practice — every move pings the mint. P2P real-time gameplay collapses into a star
topology around the mint, which is exactly what the architecture claimed to escape.

## What the contrarian case **doesn't** kill

- **Low-stakes turn-based games** — chess (NIP-64), small-pot poker (NIP-101p), arcade
  games with trickle payouts (spacenut). The trust model is acceptable when the stake
  per-game is sub-dollar.
- **Closed-economy games** — manastr's `mana` / `loot` custom units mean the only people
  exposed to the mint are this game's players; existential mint risk is bounded to that
  game.
- **Reputation-laundering tournaments** — NIP-101p's replaceable-dealer marketplace lets
  bad dealers be discarded.
- **Identity primitives** — NIP-01 keys for player identity, NIP-58 badges for
  achievements, NIP-87 federation discovery — these don't require trustlessness; they're
  fine.

## Bottom line

Nostr+ecash gaming is **trust-shifted, not trust-removed**. It moves trust from a
centralized game studio to a mint operator (or guardian federation) plus a relay set,
neither of which has consensus, ordering, slashing, or liveness guarantees. **For
low-stakes turn-based games this is fine.** For anything resembling a casino, fast-action
match, or persistent-world MMO, the unsolved problems (RNG, ordering, mint solvency,
collusion, dispute resolution) are not minor — they are **the entire substance of what a
"game engine" needs to provide**.

## Sources

- [[../../raw/articles/2026-06-17-cashu-vulnerabilities-keyset-collision-and-poisonous-airdrop.md]]
- [[../../raw/articles/2026-06-17-rug-the-mints-fee-bypass-nutshell-lnbits.md]]
- [[../../raw/papers/2026-06-17-nostr-empirical-decentralization-resilience-conext.md]]
- [[../../raw/articles/2026-06-17-ethntuttle-chaumian-ecash-design-notes-gist.md]]
