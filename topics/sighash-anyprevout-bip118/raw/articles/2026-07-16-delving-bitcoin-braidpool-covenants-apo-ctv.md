---
title: "Challenge: Covenants for Braidpool — APO input-side + CTV output-side (Delving Bitcoin)"
source: "https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370"
type: articles
ingested: 2026-07-16
tags: [braidpool, mining-payout, anyprevout, apoas, ctv, coinbase-presigning, rebindable-signatures, on-chain-demo, coinbase-maturity, mcelrath, delving-bitcoin]
summary: "The single most on-point source for the coinbase-presigning anchor question. AaronZhang + mcelrath design APO+CTV covenants for Braidpool payouts. APO handles the INPUT side: the update signature doesn't commit to the previous txid, so you can 'pre-sign the next state before the current one hits the chain.' Includes an on-chain signet demo: one APO signature spends two UTXOs (same script, same amount, different txids) with byte-identical witnesses. CTV handles the OUTPUT side (payout template). mcelrath flags the 100-block coinbase-maturity rule as a requirement; AaronZhang concedes it's unresolved (deferred to wallet-funded proxies)."
---

# Challenge: Covenants for Braidpool

Delving Bitcoin design discussion (AaronZhang, Bob McElrath / mcelrath). Directly on
the anchor question of this wiki.

## APO on the input side (the direct answer)

- AaronZhang: "APO handles the input side: the update signature doesn't commit to the
  previous RCA's txid, so you can **pre-sign the next state before the current one hits
  the chain**." (RCA = a rolling covenant/aggregation address analogous to a pool's
  coinbase-fed UTXO.)
- **On-chain demonstration**: "Two UTXOs, same script, same amount, different txids.
  One APO signature spends both — witness bytes are byte-for-byte identical across the
  two spend transactions, only the prevout differs." "The proof is in the input: each
  spends a different prevout, but the witness bytes are identical."

## CTV on the output side (complementary, not competing)

- "**CTV handles the output side**: each new RCA commits to the current period's UHPO
  template." "Dynamic payouts through a sequence of per-round static commits."
- So the Braidpool design pairs them: **APO for the input side** (rolling state,
  unknown prior txid) **+ CTV for the output side** (deterministic payout template).

## Amount/script commitment caveat (flagged reconciliation)

- AaronZhang notes: "BIP 118 Msg118 for input 0 includes `sha_amounts` and
  `sha_scriptpubkeys` covering all inputs — including the coinbase from a completely
  different address... If the coinbase input's scriptPubKey is missing from the array,
  the sighash digest is wrong and the signature is invalid."
- **Reconciliation** (research synthesis): the BIP text says APO is computed
  *as-if-ANYONECANPAY*, which uses this input's single-input `amount`/`scriptPubKey`
  fields, NOT the aggregated `sha_amounts`/`sha_scriptpubkeys` arrays. The consistent
  reading is that his fanout tx had multiple inputs (coinbase + wallet-funded fee
  inputs) and the described input was signed SIGHASH_ALL-style (covering the aggregated
  arrays). Load-bearing takeaway either way: to keep a presigned spend valid you must
  get the committed amount/script exactly right; a variable-value coinbase forces you
  to APOAS or to fix the value structurally.

## Coinbase maturity

- mcelrath's requirement 7: "You must take into account the 100 block coinbase maturity
  rule."
- AaronZhang concedes it's unresolved: "100-block coinbase maturity (wallet-funded
  proxies — addressed in follow-up)." In practice the pool spends a *matured* coinbase,
  or a proxy UTXO funded from a matured coinbase, so the interesting presigning happens
  over intermediate UTXOs rather than the raw immature coinbase.
