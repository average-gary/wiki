---
title: "Scaling Noncustodial Mining Payouts with CTV (jamesob, Delving Bitcoin)"
source: "https://delvingbitcoin.org/t/scaling-noncustodial-mining-payouts-with-ctv/1753"
type: articles
ingested: 2026-07-16
tags: [ctv, mining-payout, noncustodial, coinbase, coinbase-maturity, fanout, cpfp, anyonecanpay, jamesob, delving-bitcoin]
summary: "The canonical CTV-based noncustodial mining-payout design (jamesob). The coinbase's own scriptPubKey carries a single tiny consensus-enforced CTV commitment to a fanout transaction of arbitrary size — so NO advance signature over the coinbase is needed at all, sidestepping the unknown-txid and amount-commitment problems. Maturity handled explicitly ('it will sit for 100 blocks until it becomes valid to mine'); post-maturity fee-bumping via anchor-output CPFP or SIGHASH_ANYONECANPAY crowdsourcing."
---

# Scaling Noncustodial Mining Payouts with CTV

jamesob, Delving Bitcoin. The CTV alternative to APO for the mining-payout case, and
the natural comparison point for "does APO do this better/worse."

## Design

- "The coinbase could include a single tiny **consensus-enforced commitment** to a
  fanout transaction of arbitrary size." CTV commits the *outputs* of the spending tx
  in the coinbase's scriptPubKey itself, so **no advance signature over the coinbase
  is needed at all**.
- This sidesteps BOTH the unknown-coinbase-txid problem AND the amount-commitment
  problem (CTV commits to a fixed output set, not to the input's amount).

## Maturity handled explicitly

- "It will sit for 100 blocks until it becomes valid to mine."

## Fee-bumping the payout after maturity

- "Users can either wait for the mempool to empty out or use the anchor output to CPFP
  fee bump it. They could potentially use `SIGHASH_ANYONECANPAY` to crowdsource the
  fees."

## Relation to APO

For the mining-payout use case, CTV attacks the problem from the *output* side (the
coinbase output constrains its spender) rather than the *signature* side (APO frees the
signature from the input). The Braidpool design actually pairs them (APO input-side +
CTV output-side). For a pure payout fanout, CTV alone can suffice and avoids APO's
amount-commitment issue.
