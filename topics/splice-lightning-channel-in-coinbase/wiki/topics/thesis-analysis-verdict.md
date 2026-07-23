---
title: "Thesis analysis: splicing a Lightning channel in a coinbase"
type: topic
created: 2026-07-23
updated: 2026-07-23
confidence: high
tags: [thesis, verdict, coinbase, splicing, lightning, consensus]
---

# Thesis analysis: "I can splice a lightning channel in a coinbase transaction"

Full reasoning behind the verdict in
[[../../theses/splice-lightning-channel-in-coinbase|the thesis file]]. The claim
resolves into [[../concepts/three-readings|three readings]], each with its own
answer. The one-line result: **taken literally, no; taken charitably, only in a
narrow sense that isn't really "in a coinbase."**

## The collision at the heart of the claim

Two definitions meet head-on:

- A **[[../concepts/lightning-splice-mechanics|splice]]** is *by definition* a
  transaction that **spends the existing channel funding output** and creates a new
  one (BOLT #2: "replacing the funding transaction with a new one").
- A **[[../concepts/coinbase-transaction-structure|coinbase]]** *by definition* has
  exactly one input with a **null prevout** and **spends nothing** (`IsCoinBase()`:
  `vin.size() == 1 && vin[0].prevout.IsNull()`).

A single transaction cannot both spend the funding output and have a null/no-prevout
sole input. That is not a policy choice or a missing feature — it is a **type-level
consensus contradiction**, confirmed independently from the Bitcoin side
(`consensus/tx_check.cpp` rejects a non-coinbase with a null input, `bad-txns-prevout-null`)
and the Lightning side (BOLT #2 requires "exactly one input spending the current
funding transaction").

## Reading A — the splice tx IS the coinbase → **Contradicted**

Dead on arrival. Beyond the input contradiction: a coinbase can't even exist as a
loose transaction (`validation.cpp` rejects it), so it can never be the negotiated,
broadcast splice tx of an interactive session; and a splice can't begin until
`channel_ready`, which for a coinbase funding is 100 blocks out. Every path closes.
No source endorses this reading. **Confidence: high.**

## Reading B — funding output created BY a coinbase → **Spec-legal, not viable**

This is the genuinely interesting reading, and the evidence is a study in "permitted
≠ practical."

**Permitted:** BOLT #2 `channel_ready` contains a rule that only makes sense if the
spec authors anticipated a coinbase-funded channel — "**MUST wait for at least 100
blocks if the funding transaction is the coinbase transaction.**" (Verified verbatim
against master.) A coinbase output's scriptPubKey can be a 2-of-2 P2WSH/P2TR funding
script; BIP-141 allows arbitrary payout scriptPubKeys. The exact question was even
asked publicly (SE #115588) and answered "possible but impractical."

**Not viable**, for two walls (one removable, one not):

- **[[../concepts/presigning-unknown-coinbase-outpoint|Presigning wall]] (removable).**
  You can't pre-sign the commitment over a coinbase outpoint that doesn't exist yet.
  But **post-block-found signing** dissolves this with no soft fork (the sibling Ark
  thesis's central move), and BIP-118 APO would too (not on mainnet). So this wall,
  alone, wouldn't sink Reading B.
- **[[../concepts/coinbase-maturity-vs-ln-enforceability|Maturity wall]] (fatal).**
  `COINBASE_MATURITY = 100` makes the funding output unspendable for ~16.7 h; the
  commitment/force-close tx is *consensus-invalid* during that window, so the channel
  is **unenforceable**. Zero-conf can't help — the output isn't merely unconfirmed,
  it's unspendable. Reorg voids the whole thing. And `splice_init` can't fire until
  `channel_ready`, i.e. not for 100 blocks.

**Why the sibling Ark thesis survives the same maturity wall and LN doesn't:** an
n-of-n Ark batch output simply isn't unilaterally exitable yet, which a cosigned
batch tolerates. Lightning demands unilateral force-closability *from the instant
funds are committed*. The maturity window that Ark shrugs off is exactly what a
Lightning channel cannot accept. The moment you "fix" Reading B the natural way — fund
from a **matured** proxy UTXO — you've left Reading B and landed in Reading C.
**Confidence: high** (the maturity mechanism is consensus-hard; "not viable" is a
strong, well-supported claim rather than a hedge).

## Reading C — splice-in a MATURED coinbase UTXO → **Supported, today**

The narrow sense in which the claim is simply true. A miner's coinbase output, once
100+ confirmations deep, is an ordinary confirmed UTXO. BOLT #2 `tx_add_input` places
no ancestry restriction on splice-in inputs, and a matured coinbase output satisfies
even `require_confirmed_inputs`. Core Lightning `splicein` and Phoenix will splice
arbitrary confirmed wallet UTXOs into a live channel on mainnet **now** — no covenant,
no soft fork. Coinbase-origin funds enter a Lightning channel via an ordinary splice.

The honest caveat: this is "splice **coinbase-descended funds** into a channel," not
"splice a channel **in** a coinbase." The splice transaction is a normal transaction;
the coinbase is merely the ancestor of one of its inputs. **Confidence: high.**

## Revealed preference

Every deployed "mining reward → Lightning" system routes around the naive claim:
OCEAN (BOLT12 offers) and NiceHash pay rewards as **off-chain** LN payments; Braidpool
uses one-way channels settled from **accumulated matured** rewards. Nobody funds or
splices a channel with a fresh coinbase — consistent with the verdict.

## Bottom line

- **Literal (A):** No — consensus-impossible.
- **Charitable (B):** Spec allows a coinbase-*funded* channel, but maturity + reorg
  make it non-viable; fixing it collapses into C.
- **Narrow-true (C):** Yes — splice a *matured* coinbase UTXO into a channel today.

So the sentence "I can splice a lightning channel in a coinbase transaction" is
**false as stated** and **true only when reinterpreted** as "I can splice
matured-coinbase funds into a lightning channel."

## See also

- [[../concepts/three-readings]] — the reading map + summary table.
- [[../concepts/coinbase-transaction-structure]], [[../concepts/lightning-splice-mechanics]] — the colliding definitions.
- [[../concepts/coinbase-maturity-vs-ln-enforceability]], [[../concepts/presigning-unknown-coinbase-outpoint]] — the two walls on B.
- [[../reference/specs-and-prior-art]] — sources.
