---
title: "Bitcoin Developer Reference — coinbase input & maturity"
source: "https://developer.bitcoin.org/reference/transactions.html"
source_extra:
  - "https://developer.bitcoin.org/devguide/block_chain.html"
type: article
subtype: canonical-docs
retrieved: 2026-07-23
tags: [bitcoin, coinbase, transaction-structure, coinbase-maturity, developer-reference]
credibility: high
evidence_strength: canonical-docs
direction: "opposes Reading A; constrains Reading B"
bears_on: [A, B]
summary: "Canonical developer reference for coinbase structure: exactly one input with a 32-byte null prevout at index 0xffffffff, a 2–100 byte coinbase (scriptSig) field, and the 100-block spendability condition on coinbase outputs."
---

# Bitcoin Developer Reference — coinbase

## Coinbase input structure (verbatim)

- **"The first transaction in a block, called the coinbase transaction, must have
  exactly one input, called a coinbase."**
- Previous-output field: **"A 32-byte null, as a coinbase has no previous
  outpoint"**; index **"0xffffffff, as a coinbase has no previous outpoint."**
- Coinbase (scriptSig) field: **"Arbitrary data not exceeding 100 bytes"** minus
  the 4 height bytes (consensus floor ≥ 2 bytes).
- BIP-34 height: "starts with a data-pushing opcode … followed by the block height
  as a little-endian unsigned integer."

## Coinbase maturity (verbatim)

- **"The UTXO of a coinbase transaction has the special condition that it cannot be
  spent (used as an input) for at least 100 blocks."**
- Rationale: prevents spending rewards from blocks that may become stale after a
  reorg. Practically, a coinbase output needs **≥100 confirmations** before it is
  spendable.

## Bearing on the thesis

- Confirms the single null-prevout input and the ≤100-byte scriptSig — the fixed
  structure that leaves no room for a funding-output spend (Reading A).
- The maturity rule is the load-bearing constraint on Reading B: even if a coinbase
  pays to a 2-of-2 funding script, that funding UTXO cannot be spent — and therefore
  cannot be spliced or closed — until 100 blocks mature.
