---
title: "Lightning splice mechanics"
type: concept
created: 2026-07-23
updated: 2026-07-23
confidence: high
tags: [lightning, splicing, bolt2, interactive-tx, splice-in, splice-out, quiescence, channel-ready]
---

# Lightning splice mechanics

Per [[../reference/specs-and-prior-art|BOLT #2]] (merged from lightning/bolts
**PR #1160**): **"Splicing is the term given for replacing the funding transaction
with a new one."** Verified verbatim against master 2026-07-23.

## A splice spends the existing funding output

The splice transaction, by construction:

1. **Spends the current 2-of-2 funding UTXO.** The initiator "MUST add the current
   channel input … by sending `tx_add_input` with `shared_input_txid` containing the
   `txid` of the previous funding transaction" and a valid **`shared_input_signature`**
   (a 2-of-2 sig over the old funding output).
2. **Creates exactly one new funding output.** `tx_complete` aborts unless there is
   "exactly one input spending the current funding transaction" **and** "exactly one
   channel funding output."
3. Optionally adds **splice-in** inputs (external UTXOs via `tx_add_input`) and/or a
   **splice-out** output. Accepted scripts: P2WSH, P2WPKH, P2TR.
4. Both peers **re-sign new commitment transactions** on the new funding output
   (`commitment_signed`) *before* signing/broadcasting the splice tx (`tx_signatures`).

**This is the definitional fact that kills [[three-readings|Reading A]]:** a splice
tx *must* spend a prior output; a [[coinbase-transaction-structure|coinbase]] spends
nothing.

## A splice presupposes a live channel

- `splice_init` — "MUST NOT send `splice_init` before sending and receiving
  `channel_ready`." A splice is **not** a channel-open primitive; it restructures an
  already-live channel.
- Quiescence (`stfu`) precedes the splice so the channel is HTLC-clean.
- Optech frames splicing as moving funds into/out of a channel "without … a
  confirmation delay to spend the channel's other funds."

## The coinbase-funding rule (why the spec knows about coinbases at all)

`channel_ready` — the sender "**MUST wait for at least 100 blocks if the funding
transaction is the coinbase transaction.**" The LN spec **explicitly anticipates a
coinbase *funding* tx** — but gates the channel behind full coinbase maturity. See
[[coinbase-maturity-vs-ln-enforceability]]. There is **no** analogous rule for a
splice being a coinbase, because that is structurally impossible.

## Splice-in accepts any confirmed UTXO

`tx_add_input` places **no ancestry restriction** on added inputs; the strictest gate
is `require_confirmed_inputs` ("MUST NOT send a `tx_add_input` that contains an
unconfirmed input"). A **matured** (100+ conf) coinbase output satisfies even that —
the basis of [[three-readings|Reading C]]. Shipping wallets (CLN `splicein`,
Phoenix) splice arbitrary confirmed wallet UTXOs today.

## See also

- [[coinbase-transaction-structure]] — the consensus object a splice can never be.
- [[three-readings]] — the reading map.
- [[presigning-unknown-coinbase-outpoint]] — why even *funding* from a fresh coinbase can't be pre-signed today.
