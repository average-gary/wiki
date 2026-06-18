---
title: "EthnTuttle — Chaumian ecash design notes (gist) — proponent's own caveats"
source: https://gist.github.com/EthnTuttle/6e69d0915b5b86fab15be95d09f27ae4
type: article
tags: [cashu, ethan-tuttle, design-notes, trust-model, candor, gaming-implications]
fetched: 2026-06-17
confidence: high
credibility: medium
quality_score: 3
relevance: direct
direction: nuances
summary: |
  Design-notes gist from Ethan Tuttle (the author of the kirk / manastr / nutchain trio)
  that openly states the Cashu trust model is "same or better than TTP but much worse than a
  blockchain," that mints are "just a database, entirely controlled by one entity running a
  server," and that Cashu has reverted to an online (not offline) transfer model. The
  cleanest steelman of the contrarian case — sourced from the proponent.
---

# EthnTuttle Chaumian ecash design notes (gist)

## Source

- URL: https://gist.github.com/EthnTuttle/6e69d0915b5b86fab15be95d09f27ae4
- Author: Ethan Tuttle (creator of nutchain / kirk / manastr)
- Quality: 3 (informal but high-signal; proponent's own caveats)

## Quotes

> "Code is still bare bones. Mint is just a database, entirely controlled by one entity running
> a server. Lose the database, kaput."
>
> "Privacy guarantees are kind of not there yet, imo."
>
> "Cashu, at least as currently implemented, reverts back to the 'online' not 'offline' transfer."
>
> "Same or better theft security model than TTP but much worse than a blockchain."

## Why this matters for nostr-ecash gaming

The author of the EthnTuttle gaming work openly states the trust model is *worse than a
blockchain* and that the mint is a single DB. For "P2P gaming via ecash," the "online" caveat
collapses the architecture into a star topology around the mint — every move pings the
referee. The design value of the trio is therefore not "trustless" but **"explicit-trust with
cryptographic accountability"** — useful but distinct.
