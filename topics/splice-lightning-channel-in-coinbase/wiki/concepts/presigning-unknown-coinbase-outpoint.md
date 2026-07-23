---
title: "Presigning an unknown coinbase outpoint"
type: concept
created: 2026-07-23
updated: 2026-07-23
confidence: high
tags: [presigning, coinbase-outpoint, bip118, anyprevout, post-block-found, musig2, sighash]
---

# Presigning an unknown coinbase outpoint

The *removable* wall on [[three-readings|Reading B]] (contrast the *non-removable*
[[coinbase-maturity-vs-ln-enforceability|maturity wall]]).

## The wall

A [[coinbase-transaction-structure|coinbase]] txid is unknowable until the block is
mined (it depends on BIP-34 height + extranonce + witness merkle root). Standard
BIP-341 signatures **commit to the exact outpoint**, and BOLT #2 requires a valid
commitment signature over the funding outpoint *before* the funding tx is broadcast.
You therefore **cannot pre-sign** an LN commitment spending a fresh coinbase funding
output — the outpoint it must commit to does not yet exist. This is the same wall
documented in [[../reference/specs-and-prior-art|sighash-anyprevout-bip118]]. *(high)*

## Two ways over it

1. **Post-block-found signing (no soft fork).** Wait until the block is found; the
   winning coinbase bytes freeze, `coinbase_txid:0` becomes known, and an ordinary
   BIP-341 / BIP-327 MuSig2 signature suffices. This is the pivot of the sibling
   [[../reference/specs-and-prior-art|ark-boarding-sv2-mining]] thesis. Precondition
   (BIP-327): the message + aggregate pubkey must be fixed before signing.
2. **SIGHASH_ANYPREVOUT (BIP-118), *not on mainnet*.** APO omits the outpoint from
   the sighash → a signature rebindable to an as-yet-unmined coinbase. Demonstrated
   on Inquisition signet (one APOAS sig spending several differently-valued coinbase
   outputs). Caveat: plain APO still commits to the **amount**, which collides with
   variable coinbase value (subsidy + fees) → needs APOAS or a fixed value. Status:
   Draft / signet-only.

## Why clearing this wall is *not* enough for LN

Both routes let you *sign* a spend of a coinbase output. Neither removes the
**100-block maturity** — that's an *inclusion* constraint, not a *signing* one. So
even a perfectly-signed commitment over a fresh coinbase funding output remains
**non-mineable for 100 blocks**, leaving the channel unenforceable. The presigning
wall is the wall Ark cares about; the maturity wall is the one that specifically
defeats *Lightning*. See [[coinbase-maturity-vs-ln-enforceability]].

## Why this matters for the readings

- **Reading A** doesn't even reach this wall — it's dead on the coinbase input structure.
- **Reading B** must clear *both* walls; it can clear the presigning wall (post-block-found) but not the maturity wall.
- **Reading C** never hits either wall — a matured coinbase output has a known outpoint and is past maturity.

## See also

- [[coinbase-maturity-vs-ln-enforceability]] — the wall this one is often confused with.
- [[three-readings]], [[lightning-splice-mechanics]].
