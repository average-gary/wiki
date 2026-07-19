---
title: "Coinbase outpoint: unknown txid & 100-block maturity"
category: concept
sources:
  - raw/articles/2026-07-16-learnmeabitcoin-coinbase-transaction.md
  - raw/articles/2026-07-16-delving-bitcoin-jamesob-ctv-noncustodial-mining-payouts.md
  - raw/articles/2026-07-16-delving-bitcoin-braidpool-covenants-apo-ctv.md
created: 2026-07-16
updated: 2026-07-16
tags: [coinbase-transaction, coinbase-maturity, txid, bip-34, extranonce, block-subsidy, fees, mining-payout]
aliases: [coinbase maturity, coinbase txid, 100-block maturity, unknown outpoint]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "Two consensus facts that define the coinbase-presigning problem: (1) a coinbase transaction's txid is unknowable before mining because it depends on the block height (BIP-34), extranonce, and miner tags finalized only when the block is found; and (2) coinbase outputs cannot be spent until 100 blocks deep (reorg protection). The value is also variable (subsidy + fees). Together these determine why presigning a coinbase spend needs a prevout-agnostic (and often amount-agnostic) signature."
---

# Coinbase outpoint: unknown txid & 100-block maturity

> This concept grounds the whole [[coinbase-outpoint-presigning|coinbase-presigning question]] ([coinbase-presigning question](../topics/coinbase-outpoint-presigning.md)).
> Three properties of a coinbase output make it hard to pre-sign a spend of: its **txid
> is unknowable in advance**, its **value is variable**, and it is **unspendable for
> 100 blocks**.

## 1. The txid is unknowable before mining

A coinbase transaction's txid is a hash of its contents, and those contents are not
fixed until the block is mined:

- **BIP-34 block height** must appear in the coinbase `scriptSig`.
- The **extranonce** (part of the mining search space) is varied while hashing.
- **Miner tags / arbitrary coinbase data** are included by the miner.

Because all of these are finalized only when the block is found, the coinbase txid
**cannot be computed beforehand**. A normal Bitcoin signature commits to the outpoint
(`txid:vout`), so it cannot be produced in advance to spend a coinbase output — this is
exactly the gap that a prevout-omitting signature
([[anyprevout-sighash-semantics|ANYPREVOUT]] ([ANYPREVOUT](anyprevout-sighash-semantics.md)))
or an output-side commitment (CTV) is needed to bridge.

## 2. The value is variable

A coinbase output pays `block subsidy + total transaction fees`. Fees vary block to
block and are not known when a payout would be pre-signed. This is why plain
[[anyprevout-sighash-semantics|APO]] ([APO](anyprevout-sighash-semantics.md)) — which
still commits to the amount — is awkward for coinbase presigning, and why the amount-
agnostic **APOAS** variant (or a structural fix of the value) is generally required.

## 3. The 100-block maturity rule

"The output(s) of a coinbase transaction can only be spent *after* the transaction is
**100 blocks deep** in the blockchain," a consensus rule that protects against reorgs.

This is a **consensus-inclusion** constraint, not a signing constraint: a pre-signed
spend of a coinbase output is a valid signature the moment the coinbase exists, but the
transaction is **non-includable in a block until maturity**. In jamesob's CTV payout
design the fanout "will sit for 100 blocks until it becomes valid to mine." In the
Braidpool discussion, maturity was flagged as a hard requirement (mcelrath's
requirement 7) and left partly unresolved — handled in practice by spending a *matured*
coinbase or a proxy UTXO funded from one.

## See Also

- [[coinbase-outpoint-presigning|Presigning against an unmined coinbase outpoint]] ([Presigning against an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)) — the synthesis this concept feeds
- [[anyprevout-sighash-semantics|ANYPREVOUT sighash semantics]] ([ANYPREVOUT sighash semantics](anyprevout-sighash-semantics.md)) — why the amount commitment matters for variable coinbase value

## Sources

- [learnmeabitcoin — Coinbase transaction](../../raw/articles/2026-07-16-learnmeabitcoin-coinbase-transaction.md) — unknown txid causes + 100-block maturity
- [jamesob — Scaling Noncustodial Mining Payouts with CTV](../../raw/articles/2026-07-16-delving-bitcoin-jamesob-ctv-noncustodial-mining-payouts.md) — "sit for 100 blocks"
- [Braidpool covenants (Delving Bitcoin)](../../raw/articles/2026-07-16-delving-bitcoin-braidpool-covenants-apo-ctv.md) — maturity as requirement 7
