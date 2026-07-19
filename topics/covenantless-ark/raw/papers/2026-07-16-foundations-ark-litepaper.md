---
title: "Ark: A UTXO-based Transaction Batching Protocol (Litepaper)"
source_url: https://assets.arklabs.xyz/ark-protocol.pdf
type: paper
authors: [Marco Argentieri, Zeta Avarikioti, Andrew Camilleri, Pim Keer, Matteo Maffei]
publisher: Ark Labs + TU Wien
ingested: 2026-07-16
research_path: foundations
credibility: high
confidence: high
quality_score: 5
tags: [ark, covenantless, clark, vtxo, batch, vtxt, connector, forfeit, commitment-tx, musig2, litepaper]
summary: Formal litepaper defining every round-mechanic object (batch output, virtual transaction tree, connector, commitment tx, forfeit tx) with exact Taproot script expressions, and explicitly stating that n-of-n MuSig2 presigning substitutes for the covenant on today's Bitcoin.
---

# Ark: A UTXO-based Transaction Batching Protocol (Litepaper)

Primary formal specification. The canonical source for the abstract object model. Note the litepaper uses **"commitment transaction" / "batch"**; the Second/`bark` ecosystem says **"round transaction" / "pool transaction"** — same object.

## Covenant substitution (§3.2)
- "A simple example of a covenant would be an *n-of-n* multi-signature output script, in which the *n* signers agree to only sign transactions that spend the output in a prearranged way. Note that this covenant relies on at least 1 out of the *n* signers to stick to the arrangement."
- New opcodes (OP_CTV, OP_CAT) "would allow for stronger covenants that do not require this 1-of-*n* honesty assumption," but "introducing such new opcodes would require a Bitcoin soft fork."
- The paper deliberately defines Ark "purely with the means that are currently available in Bitcoin Script" — i.e., the **covenantless** construction.

## VTXO (Def 4.1)
A VTXO is an unspent output `vtxo := (value, vtxoLockScript)` where vtxoLockScript is a Taproot script with:
1. an **unspendable key path**
2. at least one **collaborative** script path requiring signatures of BOTH the VTXO holder and operator O, delayable by an absolute timelock
3. at least one **unilateral** script path that does NOT require O's signature but must be delayed by a relative timelock `t_v` at least as long as a minimum set by O.
- Example single-sig VTXO script: `Taproot(False; checkSig_{pk_O ⊕ pk_A}, checkSig_{pk_A} ∧ relTimelock(t_v))`.

## Batch = the pool/round on-chain output (Def 4.3)
- "A batch is a transaction output which is locked by a taproot script `batchScript` with an unspendable key path and exactly two script paths: a **sweep path** that allows the Ark operator to claim the entire output after a time T_e, which we call the *batch expiry*, and an **unroll path** that specifies spending according to a VTXT with root spending the full batch, where each leaf of the VTXT has a VTXO as its only output."

## Virtual transaction tree / VTXT (Def 4.2)
- Directed rooted tree G=(V,A); one root r spends the full batch; leaves are the individual VTXOs.
- "A virtual transaction is just a regular Bitcoin transaction that will optimistically never go onchain."

## Tree presigning — the covenant emulation (Remark 4.5)
- "The structure of the VTXT is enforced by a covenant... When we emulate the covenant by using an *n-of-n* multi-signature lock (using for example Musig2), the operator needs to coordinate a signing session with all involved VTXO holders, producing for each node in the VTXT the appropriate signature."
- Design choice: either all VTXO holders sign every virtual transaction, OR (to reduce interactivity) each holder signs only the transactions on the path to their own VTXO.
- Rational-signer argument: a signer j whose value would be reduced in an alternative sub-VTXT "will not agree to sign" it, so "besides the operator, we do not require any signer outside of {1,...,n}."

## MuSig2 over Schnorr/Taproot (§3.1)
- "for *n* parties with public keys pk_1,...,pk_n, we denote the aggregate public key by ⊕pk_i ... These signatures can only be created if all parties cooperate, effectively yielding a *n-of-n* multi-signature locking script."

## Batch swap / forfeit / connector (§4.3–4.4)
- To atomically swap vtxo_B for a fresh vtxo_{B'}: operator broadcasts a commitment tx (Tx 2) with two outputs — `(b', checkMultiSig_{2,2;pk_O,pk_B})` and an **anchor/connector** output `(ε, checkSig_{pk_O})` with dust value ε.
- Operator creates virtual Tx 3 spending the b' output → outputs vtxo_{B'}.
- Bob builds the **forfeit transaction** (Tx 4): inputs = `vtxo_B` and `(ε, checkSig_{pk_O})` (the connector); output = `(b, checkSig_{pk_O})`.
- "Bob signs Transaction 4 ... The corresponding SIGHASH flag is SIGHASH_ALL. Bob's signature is only valid for this specific forfeit transaction, containing the anchor output. In other words, the forfeit transaction is only valid if Transaction 2 is included onchain." → forfeit-and-reissue is atomic.

## Connector (Def 4.8) & commitment tx (Def 4.9)
- A connector is a taproot output with unspendable key path whose script path spends according to a VTXT where the root spends the full connector and each leaf is an anchor output; "a connector thus encapsulates all the anchor outputs serving as inputs to forfeit transactions that can only be included onchain if the commitment transaction containing that connector is included onchain."
- Unlike a batch, the connector's virtual transactions are signed **only by the operator**.
- A **commitment transaction** = "a transaction broadcast by the Ark operator with at least one batch and one connector as outputs."

## Boarding (§4.5)
- Boarding tx output script: `Taproot(False; checkSig_{pk_O ⊕ pk_A}, checkSig_{pk_A} ∧ relTimelock(t_b))` — exit path (Alice alone after timeout t_b) plus cooperative path (Alice + operator).
- Operator verifies out'_A cannot be spent by Alice alone, then includes it as an input to the next commitment tx to fund vtxo_A.

## Exit cost properties (§2.3)
- Constant O(1) onchain footprint optimistically; O(1) cooperative exit; **O(log t) pessimistic unilateral exit** where t = number of VTXOs in the batch (broadcast path from batch root to your leaf).
- Batch expiry requires T_o < T_e (users' online period less than batch expiry).
