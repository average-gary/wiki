---
title: "BIP-34: Block v2, Height in Coinbase"
source: "https://github.com/bitcoin/bips/blob/master/bip-0034.mediawiki"
type: paper
subtype: bip
retrieved: 2026-07-23
tags: [bitcoin, bip34, coinbase, scriptsig, block-height, consensus]
credibility: high
evidence_strength: spec
direction: "opposes Reading A (reinforcing)"
bears_on: [A]
summary: "BIP-34 mandates the block height as the first item in the coinbase scriptSig. Confirms the coinbase input carries miner-chosen metadata (height + extranonce), not a signature spending a prior output — and is one of the mutable fields that make the coinbase txid unknowable before the block is mined."
---

# BIP-34 — Block height in coinbase

- **"Add height as the first item in the coinbase transaction's scriptSig, and
  increase block version to 2."**
- Format: **"minimally encoded serialized CScript"** — first byte = number of bytes
  in the number (0x03 on mainnet at current heights), following bytes = little-endian
  height. Genesis block = height 0.
- BIP-34 does **not** define the single-input / null-prevout structure — it
  *presupposes* it. That structure lives in Bitcoin Core consensus code
  (see [[../repos/2026-07-23-bitcoin-core-coinbase-consensus-rules|Bitcoin Core consensus rules]]).

## Bearing on the thesis

- The coinbase scriptSig is **reserved for height + arbitrary miner data** (up to
  100 bytes total). It is not a signature satisfying a funding output's script —
  closing off any "the coinbase input could carry the funding-spend witness"
  hand-wave for Reading A.
- The height prefix is one of the mutable coinbase fields (with extranonce, miner
  tags, and the witness merkle root) that make the **coinbase txid unknowable until
  block assembly** — the root of the presigning wall.
