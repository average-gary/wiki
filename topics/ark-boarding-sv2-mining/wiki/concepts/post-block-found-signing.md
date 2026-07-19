---
title: "Post-block-found signing dissolves the coinbase-txid wall"
type: concept
created: 2026-07-17
updated: 2026-07-17
confidence: high
volatility: cold
verified: 2026-07-17
tags: [post-block-found, coinbase-txid, bip-341, bip-118, musig2, rebindable-signatures, timing]
sources:
  - raw/papers/2026-07-17-bip-341-taproot.md
  - raw/papers/2026-07-17-bip-118-anyprevout.md
  - raw/papers/2026-07-17-bip-327-musig2.md
  - raw/articles/2026-07-17-braidpool-covenants-delving.md
summary: "The load-bearing insight of the thesis: because a normal Taproot signature commits to the outpoint (BIP-341), and a coinbase's txid is unknown before the block but frozen at block-found, deferring the n-of-n ceremony to AFTER a block is found makes ordinary MuSig2 signatures sufficient — removing the sole reason APO/CTV are invoked for coinbase presigning."
---

# Post-block-found signing dissolves the coinbase-txid wall

This is the mechanism on which the whole thesis turns. It is **confirmed** by the
evidence.

## The wall

A default Taproot signature commits to the input's **outpoint**. BIP-341's sighash
message includes "`outpoint` (36): the COutPoint of this input (32-byte hash +
4-byte little-endian)", and also `sha_amounts` and `sha_scriptpubkeys`
([[../../raw/papers/2026-07-17-bip-341-taproot.md|BIP-341]]). Consequence: **you
cannot sign a spend until the funding txid exists.** A coinbase's txid depends on
the BIP-34 height, the extranonce, and miner tags — all finalized only when the
block is found — so a coinbase spend cannot normally be *presigned*. This is the
wall documented at [[../../../sighash-anyprevout-bip118/wiki/topics/coinbase-outpoint-presigning|coinbase-outpoint-presigning]].

## What APO/CTV buy — and why the thesis doesn't need it

[[../../raw/papers/2026-07-17-bip-118-anyprevout.md|APO (BIP-118)]] lets a signature
"not commit to the exact UTXO being spent ... enabling dynamic binding." Its whole
purpose is to **presign before the outpoint exists** (eltoo). The Braidpool thread
puts the contrast in one line: APO means "you can pre-sign the next state before
the current one hits the chain," versus "standard Schnorr signing, which would
require **waiting for the actual transaction ID before signing can occur**"
([[../../raw/articles/2026-07-17-braidpool-covenants-delving.md|Delving #1370]]).

The thesis's move: **just wait.** Trigger the ceremony *after* the block is found.

## Why block-found freezes the outpoint

The coinbase txid is `hash(coinbase bytes)`. Rolling the extranonce — which changes
the coinbase and thus its txid and the merkle root — *is part of the mining search
itself*. The moment a header satisfies the target, the winning coinbase bytes are
frozen, so `coinbase_txid:0` is known. From that instant, an ordinary
[[../../raw/papers/2026-07-17-bip-327-musig2.md|MuSig2]] signature over a tx
spending it is fully constructible — and BIP-327 requires exactly this
precondition: "the message and aggregate public key must be determined before
signing begins." The message (the tree tx) commits to the coinbase outpoint, so
the block must already be found.

## The key enabler: the pool controls the coinbase scriptPubKey

The funding transaction here is not some third party's — the pool/miner **writes
the coinbase output**, so it can pay directly to an n-of-n MuSig2 Taproot batch
address. "Fund → then sign the tree that spends it" is tractable because both ends
are under the protocol's control.

## What does NOT go away

- **Presigning *before* the block** would still hit the wall and *would* need
  APO/CTV. The thesis avoids this only by accepting post-block latency.
- **100-block maturity** still locks the funds — a separate constraint, see
  [[coinbase-maturity-and-reorg.md|coinbase maturity & reorg]].

## See Also

- [[covenantless-batch-output-mechanics.md|Covenantless n-of-n batch output mechanics]]
- [[coinbase-maturity-and-reorg.md|Coinbase maturity & reorg]]
- [[../topics/thesis-analysis-viability.md|Viability analysis (verdict)]]
- [[../../../sighash-anyprevout-bip118/wiki/topics/coinbase-outpoint-presigning|coinbase-outpoint-presigning]]
