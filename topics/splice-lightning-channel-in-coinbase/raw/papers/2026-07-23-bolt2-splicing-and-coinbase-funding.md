---
title: "BOLT #2: Peer Protocol — Splicing & the coinbase-funding rule"
source: "https://github.com/lightning/bolts/blob/master/02-peer-protocol.md"
source_raw: "https://raw.githubusercontent.com/lightning/bolts/master/02-peer-protocol.md"
type: paper
subtype: spec
retrieved: 2026-07-23
tags: [lightning, bolt, splicing, coinbase, funding, interactive-tx, channel-ready, quiescence]
credibility: high
evidence_strength: spec
direction: "opposes Reading A; nuances Reading B; supports Reading C"
bears_on: [A, B, C]
summary: "The normative Lightning splicing spec (merged from PR #1160). Defines a splice as replacing the funding tx by spending the existing 2-of-2 funding output and creating exactly one new funding output. Critically, channel_ready contains an explicit coinbase rule: MUST wait 100 blocks if the funding tx is a coinbase — the spec anticipates coinbase-funded channels but gates them by full maturity."
verified: "channel_ready coinbase rule, splice_init ordering, and tx_add_input shared_input_txid quotes verified verbatim against master 2026-07-23"
---

# BOLT #2 — Splicing & coinbase funding

The authoritative, normative Lightning spec text. Splicing was merged into master
from lightning/bolts **PR #1160**. Every quote below was re-verified verbatim
against the master branch on 2026-07-23.

## What a splice IS (kills Reading A from the LN side)

- Splicing = **"replacing the funding transaction with a new one."**
- The splice initiator **"MUST add the current channel input to the splice
  transaction by sending `tx_add_input` with `shared_input_txid` containing the
  `txid` of the previous funding transaction"** and **"MUST set `prevtx_vout` to
  the previous funding output index."** → the splice tx **spends the existing
  funding UTXO**.
- The shared input carries a valid **`shared_input_signature`** (a 2-of-2 sig over
  the old funding output); invalid → **"MUST send an `error` and fail the channel."**
- `tx_complete` receiver **"MUST fail the negotiation by sending `tx_abort` if:
  There is not exactly one input spending the current funding transaction"** and
  **"...if there is not exactly one channel funding output using the funding public
  keys and contributions."**
- Splice-in adds external UTXOs via `tx_add_input`; splice-out adds a spend output
  via `tx_add_output`. Accepted output scripts: P2WSH, P2WPKH, P2TR.

**Consequence:** A splice tx by construction has (a) ≥1 real input spending a prior
output and (b) exactly one new funding output. A coinbase has neither. A splice tx
can never *be* a coinbase.

## The coinbase-funding rule (the load-bearing quote)

`channel_ready` — **The sender:**

> "if it is not the node opening the channel: SHOULD wait until the funding
> transaction has reached `minimum_depth` before sending this message. **MUST wait
> for at least 100 blocks if the funding transaction is the coinbase transaction.**"

This is decisive for **Reading B**: the spec **explicitly anticipates a channel
whose funding transaction *is* a coinbase**, and handles it by mandating the full
`COINBASE_MATURITY` (100-block) wait before the channel goes live. A coinbase-funded
channel is a *named, spec-legal case* — but it is dead for ~16.7 h.

## Splice cannot begin during the maturity window

- `splice_init` — **"MUST NOT send `splice_init` before sending and receiving
  `channel_ready`."**
- Combined with the coinbase rule: if the funding was a coinbase, `channel_ready`
  cannot be sent for 100 blocks, so **no splice can even begin for 100 blocks.**
- "Splice in a coinbase" therefore collapses: the splice is always a separate,
  later, ordinary (non-coinbase) transaction.

## Commitment-signature ordering (the presigning wall, LN side)

- v2/splice flow orders `commitment_signed` strictly **before** `tx_signatures` and
  broadcast; each side "MUST create a commitment transaction that spends the splice
  funding output" and exchange `commitment_signed` on the **new** funding output
  *before* signing/broadcasting the splice tx.
- v1 funding: funder "MUST NOT broadcast this transaction" until it has received
  `funding_signed`. → **A valid commitment signature over the funding outpoint must
  exist before the funding tx is broadcast.** A coinbase txid is unknowable until
  the block is mined → this ordering cannot be satisfied for a fresh coinbase
  without a rebindable-signature primitive (see [[../papers/2026-07-23-bip118-sighash-anyprevout|BIP-118]]).

## Confirmation / finality

- With `option_zeroconf`: "SHOULD send `splice_locked` immediately after exchanging
  `tx_signatures`." Otherwise `splice_locked` is sent only once a splice tx "reaches
  acceptable depth." Depth follows `accept_channel`'s `minimum_depth` (accepter
  SHOULD pick a depth "reasonable to avoid double-spending").
- Quiescence (`stfu`) precedes `splice_init`/`splice_ack` — the channel must be in a
  clean, HTLC-settled state before restructuring.

## Bearing on the thesis

- **Reading A** (splice tx *is* the coinbase): forbidden — splice must spend the
  prior funding output; a coinbase spends nothing.
- **Reading B** (funding output *created by* a coinbase): explicitly permitted by
  the `channel_ready` rule, but the channel is unusable and no splice can start for
  100 blocks.
- **Reading C** (splice-in a *matured* coinbase UTXO): fully supported — `tx_add_input`
  places no ancestry restriction, and a matured coinbase output satisfies even
  `require_confirmed_inputs`.
