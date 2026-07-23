---
title: "The three readings of the claim"
type: concept
created: 2026-07-23
updated: 2026-07-23
confidence: high
tags: [thesis, readings, coinbase, splicing, disambiguation]
---

# The three readings of the claim

"I can splice a lightning channel in a coinbase transaction" is ambiguous. The
research resolves it into three distinct readings with three distinct verdicts.

## Reading A — literal: the splice tx *is* the coinbase

The on-chain splice transaction is itself the block's generation transaction:
position 0, spending the old funding UTXO, creating a new one.

**Verdict: impossible (contradicted).** A
[[lightning-splice-mechanics|splice]] MUST spend the existing funding output; a
[[coinbase-transaction-structure|coinbase]] has exactly one input with a *null*
prevout and spends nothing. `IsCoinBase()` and "spends a real UTXO" are mutually
exclusive in consensus code. Adding the funding input as a *second* input makes
`vin.size() != 1` → not a coinbase; keeping the one null input → can't spend funding
→ not a splice. No mechanism resolves it. *(high — consensus code + BOLT #2)*

## Reading B — charitable: an LN funding output *created by* a coinbase

A coinbase output's scriptPubKey is a 2-of-2 P2WSH/P2TR channel funding output; the
"splice" happens later against it.

**Verdict: spec-legal but not usefully viable.** BOLT #2 `channel_ready` **names
this case** ("MUST wait for at least 100 blocks if the funding transaction is the
coinbase transaction"), so it is explicitly permitted. But three walls make a
*fresh*-coinbase-funded channel non-viable:
1. **Unknown outpoint at construction** — the commitment tx can't be pre-signed
   before the coinbase txid exists ([[presigning-unknown-coinbase-outpoint]]).
   *Removable* via post-block-found signing or APO, but APO isn't on mainnet.
2. **100-block maturity** — the funding output is unspendable, so the channel is
   **unenforceable** for ~16.7 h ([[coinbase-maturity-vs-ln-enforceability]]).
   *Not* removable.
3. **Reorg** — an orphaned block voids the coinbase and every commitment over it.
No splice can even *begin* for 100 blocks (`splice_init` requires `channel_ready`).
*(high — BOLT #2 + consensus code + Optech zero-conf)*

## Reading C — narrow-true: splice-in a *matured* coinbase UTXO

A miner's coinbase output, once matured (100+ confs), is an ordinary confirmed UTXO.
Spending it as a **splice-in input** into an existing channel adds coinbase-origin
funds to that channel.

**Verdict: true and deployable today.** `tx_add_input` places no ancestry
restriction; a matured coinbase output satisfies even `require_confirmed_inputs`;
CLN `splicein` and Phoenix will splice arbitrary confirmed wallet UTXOs on mainnet
now — no covenant, no soft fork. This is the only sense in which the claim holds
cleanly. The splice tx itself is an ordinary (non-coinbase) transaction. *(high —
BOLT #2 + implementation docs)*

## Summary table

| Reading | Claim | Verdict | Blocker / basis |
|--------|-------|---------|-----------------|
| A | splice tx *is* the coinbase | **Contradicted** | coinbase spends nothing; splice must spend funding |
| B | funding output *created by* coinbase | **Spec-legal, not viable** | 100-block maturity → unenforceable; reorg; presigning wall |
| C | splice-in a *matured* coinbase UTXO | **Supported (today)** | matured coinbase = ordinary confirmed UTXO |

## See also

- [[coinbase-transaction-structure]], [[lightning-splice-mechanics]] — the two colliding definitions.
- [[coinbase-maturity-vs-ln-enforceability]], [[presigning-unknown-coinbase-outpoint]] — the walls on B.
- [[../topics/thesis-analysis-verdict]] — full verdict synthesis.
