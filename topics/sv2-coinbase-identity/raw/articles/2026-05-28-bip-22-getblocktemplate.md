---
title: "BIP-22 (getblocktemplate) — coinbaseaux and append-only conventions"
source_url: https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
source_type: bip
ingested: 2026-05-28
credibility: high
confidence: high
tags: [BIP-22, getblocktemplate, coinbaseaux, scriptSig, append-only, historical]
---

# BIP-22 — historical precedent for who controls coinbase content

## Why this matters
BIP-22 is the historical lineage of SV2-JD: the original mechanism by which a server gives a miner a coinbase template and reserves slots for the miner to fill. Provides the *append-only convention* that frames where per-miner coinbase additions traditionally land.

## Key claims
- Servers can supply "data that SHOULD be included in the coinbase's scriptSig content" via the `coinbaseaux` field.
- Miners get either `coinbasevalue` ("build it yourself") or `coinbasetxn` ("use ours").
- `bad-cb-prefix` rejection: "the server only allows appending to the coinbase, but it was modified beyond that."

## Reading on the thesis
- The append-only / scriptSig-suffix convention is the canonical Bitcoin spot for miner-side coinbase additions.
- In SV2 terms, the SRI Pool implementation places `/pool_tag/miner_tag/` between BIP-34 height and the extranonce — exactly matching the BIP-22 pattern of "server prefix, miner suffix, with delimiters."
- For the thesis (Pool-side tag derived from `user_identity`), the precedent is mechanically clear: the bytes go in scriptSig in the slot that BIP-22-era pools (and SV2's JD path) use.
