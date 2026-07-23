---
title: "BIP-141: Segregated Witness — coinbase witness commitment"
source: "https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki"
type: paper
subtype: bip
retrieved: 2026-07-23
tags: [bitcoin, bip141, segwit, coinbase, witness-commitment, block-structure]
credibility: high
evidence_strength: spec
direction: "structural (informs coinbase output layout)"
bears_on: [A, B]
summary: "BIP-141 defines the mandatory witness-commitment output a coinbase carries (OP_RETURN 6a24aa21a9ed + 32-byte commitment) and the coinbase input's single 32-byte witness-reserved-value. Establishes that a coinbase's content — and thus its txid — is finalized only at block assembly, and that coinbase outputs already carry a required commitment output alongside any payout outputs."
---

# BIP-141 — Coinbase witness commitment

- Witness-commitment output scriptPubKey (verbatim hex): **1-byte `OP_RETURN`
  (`0x6a`), 1-byte push of 36 bytes (`0x24`), 4-byte commitment header
  (`0xaa21a9ed`), 32-byte commitment hash** → full magic prefix `6a24aa21a9ed`.
- Commitment hash = `Double-SHA256(witness root hash || witness reserved value)`.
- **"The coinbase's input's witness must consist of a single 32-byte array for the
  witness reserved value."**
- **"The `wtxid` of coinbase transaction is assumed to be 0x0000....0000."**

## Bearing on the thesis

- A coinbase *can* carry arbitrary scriptPubKeys on its payout outputs (including a
  2-of-2 P2WSH/P2TR funding script — Reading B), **alongside** the mandatory
  witness-commitment OP_RETURN output.
- The commitment hash depends on the block's full witness merkle root, so the
  coinbase's own txid is fixed **only at block assembly** — reinforcing the
  unknown-outpoint presigning wall that blocks pre-signing a commitment over a
  fresh coinbase funding output.
