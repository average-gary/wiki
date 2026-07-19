---
title: "Arkade OS official docs (docs.arkadeos.com)"
source_url: https://docs.arkadeos.com/
type: article
publisher: Ark Labs (Arkade OS)
ingested: 2026-07-16
research_path: implementations
credibility: high
confidence: high
quality_score: 5
tags: [ark, arkade, batch-swap, commitment-tx, forfeit, connector, checkpoint-tx, intent, bip322, vtxo-lifecycle, musig2]
summary: Authoritative prose describing the six-stage batch-swap (round) lifecycle, the two-input/two-output forfeit structure, checkpoint transactions (arkd-specific), the BIP322 intent system, and VTXO lifecycle/liveness.
---

# Arkade OS official docs (docs.arkadeos.com)

Fetched 2026-07-16. Prose maps directly to arkd Go code. Key pages: `settlement-and-finality`, `forfeit-transactions`, `checkpoint-transactions`, `offchain-execution`, `onchain-settlement`, `vtxo-lifecycle-and-liveness`, `glossary`.

## Batch swap (round) lifecycle — six stages (`/learn/core-concepts/settlement-and-finality`)
1. **Participation signal** — users "submit an intent to the operator containing the VTXOs they want to swap, the desired parameters for their new VTXOs (scripts, amounts), and cosigner keys."
2. **Commitment construction** — operator builds a commitment tx "with two outputs: a batch output (encapsulating all participants' new VTXOs) and a connector output."
3. **Virtual tree assembly** — operator builds the presigned tree "defining unilateral exit paths, collaborative spending conditions, timelocks, and anchor outputs."
4. **Forfeit linking** — each old VTXO linked via a forfeit tx that "spends the old VTXO and consumes a connector output, ensuring the operator can only claim old VTXOs if the new commitment transaction confirms onchain."
5. **Cryptographic sign-off** — users verify tree + sign forfeits; the Arkade Signer signs the commitment tx and new virtual paths; "Neither party can finalize without the other's cooperation."
6. **Broadcast & confirmation** — operator broadcasts; on confirmation new VTXOs become valid, old ones invalidated via forfeit.

## Onchain settlement signing detail (`/arkd/transactions/onchain-settlement`)
- Operator "builds unsigned VTXO tree, commitment transaction and connector outputs."
- Clients "create random nonces for every branch transaction" and submit tree signatures (MuSig2 nonce-then-sign), then "create forfeit transactions with connector outputs" and "submit signed forfeit transactions."
- Atomicity: "the commitment transaction atomically creates both the new VTXOs and the connector output that enables the operator to claim forfeited funds."

## Forfeit transaction structure (`/arkd/server-security/forfeit-transactions`)
- **Two inputs, two outputs** — "One VTXO input and one connector input" → "Forfeit output (to operator) and anchor output."
- Built by `BuildForfeitTx`. Clients submit via `SubmitSignedForfeitTxs`.
- On fraud: operator broadcasts the connector branch first ("the connector UTXO is available onchain before the forfeit transaction can be broadcast"), then signs+broadcasts the forfeit. "Can include CLTV locks for time-based constraints."

## Checkpoint transactions (`/arkd/server-security/checkpoint-transactions`)
- Intermediate offchain states with a Taproot two-path script — **A+S** (collaborative user+operator) and **S+CSV** (server unilateral claim after timelock).
- "essentially a self-send of the user, but removing the exit script path from the VTXO script leaf, transferring it to the server."
- Purpose: anti-griefing — operator defends with "one single onchain transaction" instead of broadcasting whole offchain chains.
- "In the offchain environment no forfeit transaction is signed, but only once a VTXO is batch swapped."

## Offchain execution (`/arkd/transactions/offchain-execution`)
- 3-step protocol: (1) client sends `SubmitTxRequest` with "a signed Arkade transaction and unsigned checkpoint transactions"; (2) server verifies and returns "the fully signed Arkade transaction, its ID, and partially signed checkpoint transactions"; (3) client sends `FinalizeTxRequest` with fully signed checkpoints → "the spend is preconfirmed."
- Each virtual-tx input "requires both the user's signature and the operator's cosignature (the collaborative spending path)."

## VTXO lifecycle & liveness (`/learn/core-concepts/vtxo-lifecycle-and-liveness`)
- VTXOs expire on a schedule inside the batch output; "Before that window closes, the VTXO must be renewed or settled."
- On expiry, "the operator gains the ability to sweep the underlying Bitcoin through the batch output's sweep path."
- VTXO script has **three paths**: User+Operator (cooperative), User+timelock (unilateral exit), User+Delegate+Operator (delegation).
- Two-sided liveness: user must act during expiry window to keep exit rights; "When the operator goes offline, users cannot initiate new transactions until the operator returns" (funds safe, but no new activity).

## Unilateral exit cost model (`/learn/core-concepts/security-and-trust-model`)
- User broadcasts tree txs sequentially root→leaf; cost = tree depth (direct child of batch output = 1 tx, second level = 2, third = 3).
- Virtual mempool is a **DAG** (nodes = txs, edges = VTXO dependencies).

## Glossary (`/glossary`)
- Commitment tx = "onchain Bitcoin transaction that finalizes Batch Outputs as settlements."
- Intent = "presigned Bitcoin transactions based on BIP322 that prove ownership of inputs and specify outputs."
- Batch swap = "aggregating multiple Arkade Transactions into a single onchain Commitment Transaction."
