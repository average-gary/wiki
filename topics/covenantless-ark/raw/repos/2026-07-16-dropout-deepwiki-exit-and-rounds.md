---
title: "DeepWiki (ark-network/ark): Exit Mechanisms + Batch Processing + Tree Structures"
source_url: https://deepwiki.com/ark-network/ark/3.5-exit-mechanisms
type: repo
publisher: DeepWiki (auto-generated over ark-network/ark reference impl)
ingested: 2026-07-16
research_path: dropout
credibility: high
confidence: high
quality_score: 4
tags: [ark, arkd, exit, checkpoint, forfeit, sweep, timelocks, csv, cltv, round-abort, musig2, commitment-tx, connector]
summary: Implementation-derived docs giving the exact env-var timelock defaults, the two-stage unilateral exit for preconfirmed VTXOs, forfeit-vs-exit code paths (the covenantless penalty mechanism), operator sweep algorithm, four round phases, and the "any participant fails → round aborted" rule.
---

# DeepWiki (ark-network/ark) — Exit, Rounds, Tree Structures

Auto-generated over the official `ark-network/ark` (arkd) codebase. Three pages consolidated:
`/3.5-exit-mechanisms`, `/3.2-batch-processing-and-rounds`, `/5.1-transaction-trees-and-vtxo-structures`.

## Exit Mechanisms (`/3.5`)
- **Two-stage unilateral exit for preconfirmed VTXOs** (off-chain transferred): Stage 1 = broadcast checkpoint transaction(s) gated by `checkpointExitDelay` CSV; Stage 2 = broadcast the ark transaction spending the checkpoint output, gated by `unilateralExitDelay` CSV. Leaf VTXOs (direct batch recipients) instead broadcast the minimal tree branch from the commitment tx down to the leaf via the "exit closure tapscript path," then wait for the timelock.
- **Exact timelock defaults (second-based, BIP-68 multiples of 512):** `ARKD_UNILATERAL_EXIT_DELAY` = 86400 s (24 h); `ARKD_PUBLIC_UNILATERAL_EXIT_DELAY` = 86400 s (24 h); `ARKD_CHECKPOINT_EXIT_DELAY` = 86400 s (24 h); `ARKD_BOARDING_EXIT_DELAY` = 7776000 s (~3 months) for unconfirmed boarding UTXOs.
- **VTXO expiry window:** `expiresAt = commitmentBlockTime + vtxoTreeExpiry`, where `ARKD_VTXO_TREE_EXPIRY` default = 604672 s (~7 days). Intents/VTXOs rejected once `scheduler.AfterNow(vtxo.ExpiresAt)` fails.
- **ASP/operator sweep after expiry:** sweeper queries `GetSweepableRounds()`, computes `expiryTimestamp = blockTime + vtxoTreeExpiry`, calls `findSweepableOutputs()`, broadcasts a sweep tx collecting expired tree outputs. For checkpoint outputs computes `sweepAt = blockTime + csvDelay` and sweeps via the `CSVMultisigClosure` (operator-signature) path. Sweep tasks are DB-backed and survive server restarts.
- **Forfeit vs exit distinction (core to the covenantless safety model):**
  - *Forfeit txs* used when a VTXO was settled in a prior batch; retrieved from the round's `ForfeitTxs`, they use a `MultisigClosure`/`CLTVMultisigClosure` path requiring BOTH user and operator signatures, and **penalize a fraudulent unilateral-exit attempt** (operator claims the funds via the connector).
  - *Exit txs* (honest unroll, no fraud) use the `CSVMultisigClosure` path requiring only operator-side CSV satisfaction after the delay.
- **Exit closure script shape:** `CSVMultisigClosure` requires the operator signature plus CSV satisfaction; the sweep/expiry leaf is the same closure the server uses to reclaim after expiry.
- **Collaborative-exit intent validation:** enforces `vtxo.Spent == false`, non-expired, not banned (`checkIfBanned`), above `vtxoMinOffchainTxAmount` dust; forbids mixing boarding inputs with exit ops.

## Batch Processing and Rounds (`/3.2`)
- **Four round phases:** (1) Intent Collection — server accepts intents for a window, default **30 seconds**; (2) Batch Assembly — registration closes, VTXO + connector trees built; (3) Tree Signing (MuSig2) — server collects and aggregates nonces from all participants, then requests partial signatures, aggregated into one Schnorr sig; (4) Finalization — server signs and broadcasts the commitment tx, creating VTXOs with expiry timestamps.
- **Dropout = round abort:** "If any participant fails to submit, the round is aborted." Abort leaves no on-chain footprint; users retry in a subsequent round.
- **Ban duration:** **300 seconds** (penalize/ban misbehaving scripts); MuSig2 session timeout defaults to the session duration.
- The MuSig2 nonce+partial-sig ceremony requires all cosigners present simultaneously — a single non-responder stalls and aborts the round.

## Transaction Trees and VTXO Structures (`/5.1`)
- VTXO = "off-chain representation of Bitcoin value... outputs within a tree of pre-signed transactions that are not yet broadcast." Tracked fields: txid, output index, sat amount, controlling pubkey, root commitment txid, commitment-tx chain, expiration block height, spent/swept status, preconfirmation flag.
- **Commitment tx output ordering (exact):** Output 0 = VTXO tree root (P2TR, if a batch exists); Output 1 = Connector tree root (present when forfeits needed) — "always at index 1 when present, and may be the second output even if no batch output exists"; Outputs 2+ = on-chain collaborative exit payments; Final output = operator change (if above dust).
- VTXO tree = PSBT nodes; inputs reference parent-node outputs; outputs are child nodes or leaf VTXOs; spending via Tapscript. Each VTXO carries a **sweep tapscript with CSV** timelock enabling operator reclamation after expiry.
- **Forfeit tx structure (impl-enforced):** "Each forfeit transaction requires exactly two inputs: (1) the VTXO being forfeited, (2) a connector output the operator controls."
- Tapscript closure types in code: Multisig, CSVMultisig, CLTVMultisig, ConditionMultisig.
- Validation: `VerifyVtxoTapscriptSigs` (parses PSBTs, verifies all taproot script-spend sigs present); `VerifyForfeitTxs` (confirms exactly two inputs, matches connectors, validates CLTV expiration, reconstructs expected txids).
- Storage (`LiveStore`): current-round commitment tx, connector trees, user intents before batch processing.
