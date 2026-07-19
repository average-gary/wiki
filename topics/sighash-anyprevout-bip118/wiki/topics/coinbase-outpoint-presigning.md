---
title: "Presigning a spend of an as-yet-unmined coinbase outpoint"
category: topic
sources:
  - raw/articles/2026-07-16-bip-118-anyprevout-spec.md
  - raw/articles/2026-07-16-delving-bitcoin-braidpool-covenants-apo-ctv.md
  - raw/articles/2026-07-16-delving-bitcoin-ctv-apo-cat-signet-activity.md
  - raw/articles/2026-07-16-delving-bitcoin-jamesob-ctv-noncustodial-mining-payouts.md
  - raw/articles/2026-07-16-somsen-blind-merged-mining-anyprevout.md
  - raw/articles/2026-07-16-cointelegraph-covenants-part3-anyprevout.md
  - raw/articles/2026-07-16-learnmeabitcoin-coinbase-transaction.md
created: 2026-07-16
updated: 2026-07-16
tags: [coinbase-presigning, anyprevout, apoas, ctv, mining-payout, share-accounting, coinbase-maturity, rebindable-signatures, braidpool]
aliases: [coinbase presigning, presign coinbase spend, unmined coinbase outpoint, APO coinbase payout]
confidence: high
volatility: warm
verified: 2026-07-16
compiled-from: mixed
summary: "The anchor question of this wiki: can SIGHASH_ANYPREVOUT let you presign a transaction that spends an as-yet-unmined coinbase output (unknown txid)? Answer: YES in principle and demonstrated on-chain — APO omits the outpoint, so a signature made in advance can bind to the coinbase output once it exists. BUT plain APO still commits to the amount, and coinbase value (subsidy+fees) is variable, so in practice you need APOAS (drop the amount commitment) or must fix the value structurally. CTV (output-side commitment) is the cleaner alternative for pure payout fanout. The 100-block maturity rule is a separate inclusion-timing constraint."
---

# Presigning a spend of an as-yet-unmined coinbase outpoint

> **The question**: a coinbase transaction's txid is unknowable until the block is
> mined, so a normal signature (which commits to the `outpoint`) cannot be produced in
> advance to spend it. Mining pools / share-accounting schemes that want to **pre-sign
> payout or fan-out transactions** before a block is found hit exactly this wall. Does
> [[anyprevout-sighash-semantics|SIGHASH_ANYPREVOUT]] ([SIGHASH_ANYPREVOUT](../concepts/anyprevout-sighash-semantics.md))
> solve it?
>
> **Short answer**: Yes, in principle, and it has been demonstrated on-chain — but with
> a decisive caveat about the *amount* commitment that pushes real designs toward APOAS
> or toward CTV.

## Why the problem exists

Three properties of a coinbase output (detailed in
[[coinbase-maturity-and-unknown-txid|coinbase outpoint: unknown txid & maturity]] ([coinbase outpoint: unknown txid & maturity](../concepts/coinbase-maturity-and-unknown-txid.md))):

1. **Unknown txid** — the txid depends on BIP-34 block height, extranonce, and miner
   tags, all finalized only at mining time. So it can't be computed in advance.
2. **Variable value** — the output pays `subsidy + fees`, which isn't known when a
   payout would be pre-signed.
3. **100-block maturity** — the output can't be spent until 100 confirmations.

A normal signature commits to the `outpoint`, so property (1) alone blocks presigning.

## (a) Prevout omission → yes, presigning works (directly sourced + demonstrated)

APO computes its digest "as if `SIGHASH_ANYONECANPAY` was set, except `outpoint` is not
included." Because the signature never commits to `txid:vout`, it can bind to a coinbase
output that **does not yet exist** at signing time — this is precisely
[[rebindable-signatures|rebindable signatures]] ([rebindable signatures](../concepts/rebindable-signatures.md))
applied to a coinbase.

This is not just theory. It is demonstrated on-chain:

- In the **Braidpool** covenant discussion, AaronZhang states it plainly: "APO handles
  the input side: the update signature doesn't commit to the previous...txid, so you can
  **pre-sign the next state before the current one hits the chain**," and proves it with
  two transactions whose "witness bytes are byte-for-byte identical... only the prevout
  differs."
- On the Inquisition **signet**, ajtowns reports that most APO traffic were "spends of
  the coinbase payout... **All those spends reuse the same APOAS signature, spending
  multiple block rewards** back to faucet addresses." A *single* APOAS signature
  spending *many distinct* coinbase outputs is direct empirical confirmation.
- Ruben Somsen's **blind merged mining** construction builds a chain of ANYPREVOUT
  transactions "each only spendable by the next," establishing presigning-over-unknown-
  outpoints as accepted prior art (and, via the `s = 1 + e` trick, making the signatures
  publicly computable so no signing key need be custodied).

## (b) The amount-commitment problem: plain APO vs APOAS (the decisive caveat)

This is where the naive framing breaks. **Plain APO still commits to the `amount` and
`scriptPubKey`** of the output being spent — only the outpoint is dropped. A coinbase
output's value is `subsidy + fees`, which varies block to block and isn't known when you
presign. Therefore:

- **Plain APO is generally insufficient for a variable-value coinbase**: to make the
  signature valid you'd have to know the exact coinbase amount in advance, which defeats
  the purpose. It only works if you fix the coinbase output to a known constant value
  structurally (e.g. a fixed-value output plus a variable remainder elsewhere).
- **APOAS drops the amount (and script) commitment**, so one signature is valid
  regardless of the coinbase's value. This is exactly why the real signet activity used
  **APOAS** to spend many differently-valued block rewards with one signature.
- The tradeoff has teeth: ajtowns observed those APOAS coinbase spends lost "very large
  amounts to fees." That fee leakage is the **direct symptom of not committing to the
  amount** — the spend can't control how much value it moves, so surplus leaks to
  miners. Cointelegraph frames the same footgun generally: if a presigned tx binds to a
  larger UTXO than signed for, "the excess will be lost to miners unless the original
  signature included a change output." Rebinding is only safe when the value is handled
  deliberately.

> **Design implication**: for coinbase presigning you either (1) use **APOAS** and
> manage the value/fees explicitly (e.g. dedicated fee-absorbing outputs), or (2) fix
> the coinbase output value structurally so plain APO's amount commitment is satisfiable.

## (c) Coinbase maturity is an inclusion constraint, not a signing one

The 100-block rule is orthogonal to signing. A presigned APO/APOAS spend is a valid
signature the moment the coinbase exists, but the transaction is **non-includable in a
block until the coinbase matures**. jamesob's design states it directly: the spend "will
sit for 100 blocks until it becomes valid to mine." Practical consequences:

- You can construct/hold the presigned tx immediately; only broadcast/mining waits for
  maturity. You don't strictly need a relative timelock (consensus enforces the rule),
  but note APO **does commit to `nSequence`**, so any timelock choice is fixed at
  signing.
- **Fee bumping** after maturity is the real operational concern: the presigned tx is
  fixed, so it can't dynamically consume the coinbase's own value for fees. jamesob
  suggests an **anchor output for CPFP** or `SIGHASH_ANYONECANPAY` to crowdsource fees.
- In the Braidpool discussion maturity was flagged as a hard requirement and left partly
  unresolved — handled in practice by spending a *matured* coinbase or a **proxy UTXO
  funded from a matured coinbase**, so the interesting presigning happens over
  intermediate UTXOs rather than the raw immature coinbase.

## (d) Alternatives: CTV does this from the other side; ANYONECANPAY does not do it

- **CTV (BIP-119)** arguably solves the pure mining-payout case *more cleanly*: the
  coinbase's own scriptPubKey **commits to the outputs** of the fan-out tx via a
  consensus-enforced hash — "a single tiny consensus-enforced commitment to a fanout
  transaction of arbitrary size." No signature over the coinbase is needed at all,
  sidestepping both the unknown-txid and the amount-commitment problems. The Braidpool
  design pairs them: **APO on the input side + CTV on the output side.** They are
  complementary, not strictly competing.
- **SIGHASH_ANYONECANPAY (active today, no soft fork) does NOT solve it.** It still
  commits to the current input's own outpoint; it only frees the *other* inputs. This is
  the common trap — it's useful for fee crowdsourcing but cannot bind a signature to an
  unknown coinbase txid. See the
  [[covenant-primitives-comparison|covenant primitives comparison]] ([covenant primitives comparison](../references/covenant-primitives-comparison.md)).

## Bottom line

Yes — APO lets you presign a spend of an as-yet-unmined coinbase outpoint, because it
drops the outpoint from the sighash, and this is demonstrated on-chain. **But plain
APO's residual commitment to the output `amount` collides with the coinbase's variable
value, so in practice you need APOAS (drop the amount commitment) or must fix the value
structurally.** The alternative — and arguably cleaner for a pure payout fanout — is
**CTV**, which commits the payout outputs in the coinbase script and needs no presigned
coinbase signature at all. The **100-block maturity** rule is a separate
inclusion-timing constraint and remains a partly-unsolved engineering detail in the
leading proposals (handled via matured proxies / anchor-output CPFP). And none of this
is available on mainnet today — APO is
[[anyprevout-status-and-activation|Draft / signet-only]] ([Draft / signet-only](anyprevout-status-and-activation.md)).

> **Provenance note**: parts (a), (c), (d) are directly sourced from the cited
> discussions and on-chain data. The clean framing in (b) — *plain APO is inadequate for
> a variable-value coinbase; use APOAS or fix the value; CTV avoids the amount problem
> by committing outputs instead* — is a synthesis assembled from the BIP's commitment
> rules + the observed signet fee leakage + jamesob's CTV design; no single source states
> it as one packaged conclusion. The article is therefore tagged `compiled-from: mixed`.

## See Also

- [[../../../ark-boarding-sv2-mining/wiki/concepts/post-block-found-signing|Post-block-found signing (ark-boarding-sv2-mining)]] — the escape hatch: if you sign *after* the block is found, the coinbase outpoint is known, so no APO/CTV is needed. Analyzed as a thesis for an SV2 Ark-boarding extension.
- [[anyprevout-sighash-semantics|ANYPREVOUT sighash semantics]] ([ANYPREVOUT sighash semantics](../concepts/anyprevout-sighash-semantics.md)) — why APO-vs-APOAS is the crux here
- [[coinbase-maturity-and-unknown-txid|Coinbase outpoint: unknown txid & maturity]] ([Coinbase outpoint: unknown txid & maturity](../concepts/coinbase-maturity-and-unknown-txid.md)) — the three properties that define the problem
- [[rebindable-signatures|Rebindable signatures]] ([Rebindable signatures](../concepts/rebindable-signatures.md)) — the general capability
- [[covenant-primitives-comparison|Covenant primitives comparison]] ([Covenant primitives comparison](../references/covenant-primitives-comparison.md)) — CTV / ANYONECANPAY / APO fitness table
- [[anyprevout-status-and-activation|Status & activation]] ([Status & activation](anyprevout-status-and-activation.md)) — this is gated on a not-yet-activated primitive

## Sources

- [BIP-118 normative spec](../../raw/articles/2026-07-16-bip-118-anyprevout-spec.md) — outpoint/amount omission rules
- [Braidpool covenants (Delving Bitcoin)](../../raw/articles/2026-07-16-delving-bitcoin-braidpool-covenants-apo-ctv.md) — "pre-sign the next state" + on-chain rebinding demo + maturity
- [CTV/APO/CAT signet activity (ajtowns)](../../raw/articles/2026-07-16-delving-bitcoin-ctv-apo-cat-signet-activity.md) — one APOAS sig spends many coinbase outputs; fee leakage
- [jamesob — CTV Noncustodial Mining Payouts](../../raw/articles/2026-07-16-delving-bitcoin-jamesob-ctv-noncustodial-mining-payouts.md) — CTV output-side design, maturity, CPFP
- [Somsen — Blind Merged Mining with ANYPREVOUT](../../raw/articles/2026-07-16-somsen-blind-merged-mining-anyprevout.md) — presigned ANYPREVOUT chains prior art
- [Cointelegraph — Covenants Part 3](../../raw/articles/2026-07-16-cointelegraph-covenants-part3-anyprevout.md) — value-mismatch footgun
- [learnmeabitcoin — Coinbase transaction](../../raw/articles/2026-07-16-learnmeabitcoin-coinbase-transaction.md) — unknown txid + maturity facts
