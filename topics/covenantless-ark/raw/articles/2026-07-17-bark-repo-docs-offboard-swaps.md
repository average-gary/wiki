---
title: "Offboard Swaps (bark docs/offboard-swaps.md)"
source: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/offboard-swaps.md"
type: articles
ingested: 2026-07-17
tags: [collection, bark-repo, ark, clark, hark, offboard, connector, forfeit, hashlock, swap]
summary: "Why hArk changes offboards: with hArk, forfeits commit only to a single unlock preimage/hash, not the whole funding tx, so in-round offboards lose their automatic commitment and need an extra hash-condition. Proposes connector swaps to enable instant offboards and deprecate round-based offboards."
collection: "bark-repo"
adapter: git
upstream_id: "docs/offboard-swaps.md"
upstream_type: git-file
revision: "4f1b646ae3c4387bd374d835f76719637a48b846"
sha: "a3adbe26d3a94f69841d40e74bb9ed2fadd36aa2"
canonical_url: "https://gitlab.com/ark-bitcoin/bark/-/blob/4f1b646ae3c4387bd374d835f76719637a48b846/docs/offboard-swaps.md"
content_format: markdown
license: "MIT"
fetched: 2026-07-17
---

# Offboard Swaps (bark docs/offboard-swaps.md)

Part of the [[../repos/2026-07-17-collection-bark-repo-manifest.md|bark-repo collection]]. Directly relevant to [[../../wiki/concepts/forfeit-and-connectors.md|forfeits/connectors]] and the hArk transition.

## Motivation — hArk breaks the old offboard trick
- "In traditional Ark or clArk rounds, offboards are very practical: the server simply adds an output to the round's funding tx and because the **connectors commit to the entire funding tx**, users commit to the offboard in their forfeit tx."
- "With hArk, however, **forfeits only commit to a single unlock preimage/hash**. This unlock hash guards the release of the newly issued VTXOs. However, there is no longer an automatic commit to the entire funding tx." → in-round hArk offboards need an **additional hash-based condition** on the offboard output, "making them significantly less attractive because an additional on-chain tx must be made."

## Hash-locked swaps (naive)
- Server sends the on-chain amount to a hash-locked output; user signs a forfeit forcing the server to reveal the preimage so the user can unlock. Problem: user still needs an extra on-chain tx to unlock.

## Connector swaps (preferred)
- Server creates an offboard tx delivering funds to the user **plus a connector output** (the change output could double as the connector).
- Before signing, the user signs a forfeit valid only when spent with that connector output. Once the server holds it, the server signs+broadcasts the offboard tx.
- Result: **instant offboards** without waiting for a round.

## Implementation notes (server-side)
- New gRPC endpoints for offboard requests + forfeit-signature exchange.
- A dedicated offboard wallet (or precautions so unconfirmed offboard tx chains don't grow too old and impede rounds).
- "Round-based offboards can then be entirely deprecated."
