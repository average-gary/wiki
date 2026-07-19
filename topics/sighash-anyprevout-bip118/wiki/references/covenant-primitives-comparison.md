---
title: "Covenant primitives comparison: APO vs CTV vs ANYONECANPAY vs NOINPUT vs CSFS"
category: reference
sources:
  - raw/articles/2026-07-16-delving-bitcoin-txhash-csfs-decomposition.md
  - raw/articles/2026-07-16-spark-covenant-proposals-compared.md
  - raw/articles/2026-07-16-optech-anyprevout-topic.md
  - raw/articles/2026-07-16-delving-bitcoin-jamesob-ctv-noncustodial-mining-payouts.md
  - raw/articles/2026-07-16-bip-118-anyprevout-spec.md
created: 2026-07-16
updated: 2026-07-16
tags: [covenant-comparison, anyprevout, ctv, bip-119, anyonecanpay, noinput, csfs, lnhance, txhash, presigning]
aliases: [APO vs CTV, covenant comparison, LNHANCE, CTV vs ANYPREVOUT]
confidence: medium
volatility: warm
verified: 2026-07-16
summary: "Comparison of the Bitcoin primitives relevant to presigning / committing to a not-yet-known output: SIGHASH_ANYPREVOUT (signature omits the input), CTV/BIP-119 (output commits to its spender's template), SIGHASH_ANYONECANPAY (still commits the current outpoint — the 'trap'), SIGHASH_NOINPUT (APO's pre-Taproot ancestor), and CSFS/LNHANCE (CTV+CSFS can emulate APO). Includes a fitness assessment for the coinbase-presigning use case."
---

# Covenant primitives comparison

> The primitives below all touch the problem of *presigning a spend, or constraining a
> spend, of an output that isn't fully known yet.* They attack it from different sides:
> **APO frees the signature from the input** (unlock side); **CTV constrains the spender
> from the output** (locking side). For the anchor use case, see
> [[coinbase-outpoint-presigning|presigning against an unmined coinbase outpoint]] ([presigning against an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)).

## The conceptual axis (locking-side vs unlock-side)

The clearest framing (from the TXHASH+CSFS decomposition thread):

- **CTV** commits to the transaction template **in the locking script** — the output
  constrains what may spend it.
- **APO** commits via a **signature in the unlock script** — the signature simply
  doesn't bind to what it spends.

"The requirements for a transaction hash are different when committed to in the locking
script vs by a signature in the unlock script" — which is why they exist as separate
primitives. Both can be decomposed into **TXHASH** (produce a configurable tx hash) +
**CSFS** (verify a signature against an arbitrary hash).

## Comparison table

| Primitive | What it commits to | Soft fork? | Activation status | Fit for presigning a spend of an *unknown* outpoint |
|-----------|-------------------|-----------|-------------------|-----------------------------------------------------|
| **SIGHASH_ANYPREVOUT (BIP-118)** | Omits the `outpoint`. APO still commits to prev `scriptPubKey`+`amount`; APOAS also omits those + tapleaf. Commits tx version, locktime, this input's nSequence, outputs. | **Yes** | Draft; signet only (Inquisition, since 2022-09-06); no mainnet | **Direct fit.** Purpose-built: the signature is valid regardless of which outpoint it spends → sign before the txid exists. |
| **CTV (BIP-119)** | The output's script commits to a *template* of the spending tx (version, locktime, outputs, #inputs, sequences, scriptSig hash). Constrains the spender; doesn't omit the prevout. | **Yes** | Draft; on Inquisition signet; mainnet activation debated, not active | **Indirect fit.** Doesn't touch the input's txid; instead the coinbase's own output commits to the payout, so no advance signature over the coinbase is needed at all. Strong for vaults/congestion-control/payout-fanout. |
| **SIGHASH_ANYONECANPAY** | Omits *other* inputs, but **still commits to the current input's own `outpoint` (txid+vout)**. | **No — active today** | Live on mainnet | **Does NOT solve it.** The common trap: because it still signs the current outpoint, you cannot presign a spend whose txid is unknown. It only lets others add/remove inputs (useful for fee crowdsourcing). |
| **SIGHASH_NOINPUT** | Same idea as APO (omit the input reference) — the pre-Taproot ancestor. | Yes (never shipped) | Superseded/renamed → BIP-118 APO | Conceptually the fit, but obsolete; APO is its Taproot-era realization. Note the lineage (NOINPUT → NOINPUT_UNSAFE → ANYPREVOUT). |
| **CSFS / OP_CHECKSIGFROMSTACK (BIP-348)** | Verifies a signature over an arbitrary message on the stack; commitment scope is whatever the script hashes. | **Yes** | Draft; bundled in LNHANCE with CTV | Building block only. **CTV+CSFS together can emulate APO** (LNHANCE), covering eltoo/rebinding without a dedicated APO fork — though APO co-author AJ Towns disputes the equivalence in practice. |

## Use-case fit (structural)

- **CTV** → vaults, congestion control, timeout-trees, payout fanout — but **not**
  LN-Symmetry on its own.
- **APO** → LN-Symmetry / eltoo, watchtowers, prevout-agnostic presigning — but **not**
  vaults / congestion-control.
- **CTV+CSFS ("LNHANCE")** = CTV (BIP-119) + CSFS (BIP-348) + OP_INTERNALKEY → covers
  both sets except recursive covenants; described (secondary source, treat as
  directional) as the "frontrunner combination" among core devs.
- Only **OP_CAT**-style constructions enable recursion; APO and CTV are both
  non-recursive.

## Bottom line for the coinbase-presigning problem

- **APO/BIP-118 is the direct signature-side solution** (omits the outpoint); its
  ancestor is NOINPUT. For a *variable-value* coinbase you specifically need **APOAS**.
- **ANYONECANPAY is the trap** — active today but still binds the current outpoint, so
  it cannot presign an unknown-txid spend.
- **CTV** is arguably the cleaner path for pure payout fanout: it commits the payout
  outputs in the coinbase script, needing no presigned coinbase signature at all, and
  sidesteps APO's amount-commitment issue. The Braidpool design pairs them: **APO
  input-side + CTV output-side.**

> **Confidence note**: The structural use-case fit is well-corroborated across primary
> sources. Specific 2026 activation dates/percentages (e.g. CTV signaling windows,
> miner-signaling percentages) come from a single secondary source and are flagged
> low-confidence in the raw material; verify against Optech / Delving Bitcoin before
> citing.

## See Also

- [[anyprevout-status-and-activation|Status & activation]] ([Status & activation](../topics/anyprevout-status-and-activation.md)) — the CTV+CSFS-vs-APO activation debate in depth
- [[coinbase-outpoint-presigning|Presigning against an unmined coinbase outpoint]] ([Presigning against an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)) — where these primitives are applied
- [[anyprevout-sighash-semantics|ANYPREVOUT sighash semantics]] ([ANYPREVOUT sighash semantics](../concepts/anyprevout-sighash-semantics.md)) — the APO/APOAS detail behind this table

## Sources

- [Combined CTV/APO into minimal TXHASH+CSFS](../../raw/articles/2026-07-16-delving-bitcoin-txhash-csfs-decomposition.md) — locking-vs-unlock-side axis
- [Spark — Covenant Proposals Compared](../../raw/articles/2026-07-16-spark-covenant-proposals-compared.md) — use-case matrix + (low-confidence) activation data
- [Optech — SIGHASH_ANYPREVOUT](../../raw/articles/2026-07-16-optech-anyprevout-topic.md) — APO vs CTV substitution, extra vbytes
- [jamesob — CTV Noncustodial Mining Payouts](../../raw/articles/2026-07-16-delving-bitcoin-jamesob-ctv-noncustodial-mining-payouts.md) — CTV output-side payout design
- [BIP-118 normative spec](../../raw/articles/2026-07-16-bip-118-anyprevout-spec.md) — what APO/APOAS commit to
