---
title: "Coinbase transaction (learnmeabitcoin)"
source: "https://learnmeabitcoin.com/technical/mining/coinbase-transaction/"
type: articles
ingested: 2026-07-16
tags: [coinbase-transaction, coinbase-maturity, txid, bip-34, extranonce, block-subsidy, fees, reference]
summary: "Reference explainer for why a coinbase txid is unknowable before mining and the 100-block maturity rule. The coinbase txid depends on the full coinbase structure (BIP-34 block-height in scriptSig, extranonce, miner tags), all finalized only when the block is mined — so it cannot be computed beforehand. Coinbase outputs can only be spent after the tx is 100 blocks deep (reorg protection). This grounds the whole 'presign against an unknown coinbase outpoint' problem."
---

# Coinbase transaction (learnmeabitcoin)

Supporting reference for the coinbase-presigning problem.

## Why the coinbase txid is unknowable in advance

- The txid depends on the full coinbase structure — **BIP-34 block height in the
  scriptSig, the extranonce, and miner tags** — all finalized only when the block is
  mined. So the txid **cannot be computed beforehand.**
- This is the root reason a normal signature (which commits to the outpoint = txid:vout)
  cannot be made in advance to spend a coinbase output — and why APO's omission of the
  outpoint is the missing piece.

## Coinbase maturity (verbatim)

- "The output(s) of a coinbase transaction can only be spent *after* the transaction is
  **100 blocks deep** in the blockchain," to protect against reorgs.
