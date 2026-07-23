---
title: "BIP34 — Block v2, Height in Coinbase"
source_url: https://github.com/bitcoin/bips/blob/master/bip-0034.mediawiki
type: paper
retrieved: 2026-07-21
credibility: high
corroboration: "coinbase-structure agent"
tags: [bitcoin, bip34, coinbase, scriptSig, block-height, consensus]
summary: "Consensus rule: the block height is the first pushed item in the coinbase scriptSig, minimally-encoded little-endian. Defines the one scriptSig field a daemon can rely on being present and checkable."
---

# BIP34 — Height in Coinbase

- Rule: "Add height as the first item in the coinbase transaction's scriptSig." The
  block height is the **very first pushed item** of the coinbase input script.
- Encoding: "minimally encoded serialized CScript" — first byte = number of bytes in
  the height number; following bytes = **little-endian** representation (including a
  sign bit).
- On mainnet the length prefix "will be 0x03 for the next 150 or so years" (heights
  fit in 3 bytes up to 2^23−1). A typical height push: `03 <h0> <h1> <h2>`
  (e.g. height 840000 → `03 40 D2 0C`).
- Genesis block is height zero.
- This is a **consensus requirement** (invalid block otherwise), so a daemon can
  reliably expect the first scriptSig bytes to be the height push — **but only if it
  can see the raw coinbase bytes** (extended channel or local template).

## Relevance

Check (c′): "scriptSig contains BIP34 height = expected height." The height push
almost always lands in `coinbase_tx_prefix` (before the extranonce region), making it
one of the most reliably-checkable coinbase fields on an extended channel.
