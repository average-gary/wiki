---
title: "OCEAN DATUM Gateway — pool tag + per-miner coinbase tag (precedent)"
source_url: https://github.com/OCEAN-xyz/datum_gateway
source_type: code-readme
ingested: 2026-05-28
credibility: medium
confidence: medium
tags: [OCEAN, DATUM, BIP-22, coinbase-tag, primary-tag, secondary-tag, decentralized-mining]
---

# OCEAN DATUM — the closest production precedent for per-miner coinbase tagging

## Why this matters
OCEAN's DATUM Gateway is the only mainnet pool (as of 2026) that has shipped *per-miner* coinbase tagging. Useful for understanding what the thesis-style feature looks like in production and what trade-offs it makes.

## Key claims
- "Be sure to also set your coinbase tags. The primary tag setting is unused in pooled mining, however the secondary tag is intended to show on things like block explorers when you mine a block."
- Miners running DATUM must "include the primary coinbase tag as provided by the pool" and "include the unique identifier provided by the pool."
- Templates are built locally by the miner via GBT (BIP-22); the pool validates and finalizes.

## Reading on the thesis
**Nuances**:
- DATUM proves per-miner coinbase tagging is viable in practice — but does so via miner-side template construction (a JD-equivalent), not via Pool-side `user_identity` lookup.
- DATUM's design choice was deliberate: by having the *miner* assemble its own coinbase, the per-miner tag is non-custodial — the miner can verify the tag is what it expects.
- The thesis (Pool-side, non-JD) gets a similar wire-format result but loses the verifiability property: the miner has to trust that the Pool actually inserted the right `user_identity`-derived bytes.

This is feasibility precedent + a design caution: per-miner coinbase tags exist; the *trust* properties depend on who builds the bytes.
