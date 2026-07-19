---
title: "Rebindable (floating) signatures"
category: concept
sources:
  - raw/articles/2026-07-16-bip-118-anyprevout-spec.md
  - raw/articles/2026-07-16-optech-anyprevout-topic.md
  - raw/articles/2026-07-16-decker-eltoo-blockstream-blog.md
  - raw/articles/2026-07-16-somsen-blind-merged-mining-anyprevout.md
created: 2026-07-16
updated: 2026-07-16
tags: [rebindable-signatures, floating-transactions, anyprevout, noinput, covenant, presigning]
aliases: [rebindable signatures, floating transactions, floating signatures, noinput signatures]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "The core capability APO/NOINPUT create: a signature that does not commit to the specific prevout, so a pre-signed transaction can be 'rebound' to attach to any compatible output rather than one identified UTXO. Signatures bind to a *class* of outputs (matching script/amount, or matching key for APOAS) instead of a single txid:vout."
---

# Rebindable (floating) signatures

> A normal Bitcoin signature commits to the exact prevout (`txid:vout`), so it is valid
> against exactly one UTXO. By excluding the outpoint from the signed message,
> [[anyprevout-sighash-semantics|ANYPREVOUT]] ([ANYPREVOUT](anyprevout-sighash-semantics.md))
> produces a **rebindable** (or "floating") signature: it is valid against *any* output
> whose still-committed properties match. The signature attaches to a **class** of
> outputs, not one identified UTXO.

## The mechanism in one line

Drop the `outpoint` from the sighash → the signature no longer names *which* UTXO it
spends → it can be "rebound" to whichever compatible output actually exists.

The matching criterion depends on the variant:

- **Plain APO**: valid against any output with the **same script + same amount**.
- **APOAS**: valid against any output authorized by the **same BIP-118 key** (script
  and amount uncommitted).

## Why this is powerful — and dangerous

- **Powerful**: you can pre-sign a transaction *before the output it will spend even
  exists*. This is what [[eltoo-ln-symmetry|eltoo / LN-Symmetry]] ([eltoo / LN-Symmetry](eltoo-ln-symmetry.md))
  needs (an update tx that reattaches to whichever prior channel state lands on-chain),
  and it is the crux of [[coinbase-outpoint-presigning|presigning a spend of an unmined coinbase outpoint]] ([presigning a spend of an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)).
- **Dangerous**: the same non-commitment is a replay footgun — a signature meant for one
  output can spend another that happens to match. See
  [[signature-replay-and-chaperone-signatures|signature replay]] ([signature replay](signature-replay-and-chaperone-signatures.md)).

## Floating transactions as covenants

Because a rebindable signature can be *committed to in advance* (even placed inside an
output's script), it can act as a covenant-like constraint. Ruben Somsen's blind
merged mining construction builds "a long string of `sighash_anyprevout` transactions,
each only spendable by the next," with the spending signature placed in the output
script. Using the `s = 1 + e` / known-discrete-log trick, those signatures can be made
**publicly computable**, so "private key security is actually irrelevant" — no party
needs to custody a signing key. This is directly relevant to non-interactive pool /
mining constructions.

## Lineage

The idea originated as **SIGHASH_NOINPUT** (Joseph Poon, 2016), was briefly renamed
**SIGHASH_NOINPUT_UNSAFE** (2018) to flag the replay danger, and was rebased onto
Taproot and renamed **SIGHASH_ANYPREVOUT** in 2021. "Floating transactions" and
"rebindable signatures" name the same capability across these versions.

## See Also

- [[anyprevout-sighash-semantics|ANYPREVOUT sighash semantics]] ([ANYPREVOUT sighash semantics](anyprevout-sighash-semantics.md)) — the exact bytes/fields that make rebinding possible
- [[eltoo-ln-symmetry|eltoo / LN-Symmetry]] ([eltoo / LN-Symmetry](eltoo-ln-symmetry.md)) — the flagship use case
- [[signature-replay-and-chaperone-signatures|Signature replay & chaperone signatures]] ([Signature replay & chaperone signatures](signature-replay-and-chaperone-signatures.md)) — the downside of non-commitment
- [[coinbase-outpoint-presigning|Presigning against an unmined coinbase outpoint]] ([Presigning against an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)) — the anchor application

## Sources

- [BIP-118 normative spec](../../raw/articles/2026-07-16-bip-118-anyprevout-spec.md) — "Removing this commitment allows dynamic rebinding…"
- [Optech — SIGHASH_ANYPREVOUT](../../raw/articles/2026-07-16-optech-anyprevout-topic.md) — rebindable-signatures definition + lineage
- [Decker — eltoo (Blockstream blog)](../../raw/articles/2026-07-16-decker-eltoo-blockstream-blog.md) — "short-circuiting" / floating updates
- [Somsen — Blind Merged Mining with ANYPREVOUT](../../raw/articles/2026-07-16-somsen-blind-merged-mining-anyprevout.md) — floating sigs as covenants + s=1 trick
