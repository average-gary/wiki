---
title: "Splice-in in shipping wallets: ACINQ/Phoenix + Core Lightning splicein"
source: "https://acinq.co/blog/phoenix-splicing-update"
source_extra:
  - "https://docs.corelightning.org/reference/splicein"
type: article
subtype: implementation-docs
retrieved: 2026-07-23
tags: [lightning, splice-in, phoenix, acinq, core-lightning, splicein, matured-coinbase]
credibility: high
evidence_strength: implementation-docs
direction: "supports Reading C"
bears_on: [C]
summary: "Shipping mainnet wallets splice arbitrary confirmed wallet UTXOs into an existing channel: Phoenix auto-splices on-chain funds received to the wallet; Core Lightning `splicein` takes funds from the internal wallet. Neither distinguishes coinbase-descended UTXOs from any other confirmed UTXO — so splicing a matured (100+ conf) coinbase output into a channel works today with no special handling."
---

# Splice-in in shipping wallets

## Phoenix / ACINQ

- On-chain funds received to the wallet are automatically **spliced into the
  existing channel** ("the funds will be spliced in and the capacity of the channel
  will grow"); uses a swap-in-potentiam-style path for fast availability once
  confirmed.

## Core Lightning `splicein`

- `splicein channel amount` takes funds **"from the internal wallet"** — i.e. any
  confirmed wallet UTXO — and adds them to a channel. A matured coinbase output
  sitting in that wallet is eligible with **no special handling**.
- Neither wallet distinguishes coinbase-descended UTXOs from any other confirmed
  UTXO.

## Bearing on the thesis (Reading C is deployable today)

- This is the narrow, true sense of the claim: a **matured** coinbase UTXO (100+
  confs) is an ordinary confirmed UTXO, accepted as a splice-in input by CLN and
  Phoenix on mainnet today — no covenant, no soft fork.
- Precondition: the coinbase output has matured (≥100 confs). The splice itself is
  an ordinary (non-coinbase) transaction.
