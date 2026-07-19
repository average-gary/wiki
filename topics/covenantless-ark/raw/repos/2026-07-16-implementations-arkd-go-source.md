---
title: "arkade-os/arkd — Go server + ark-lib source code"
source_url: https://github.com/arkade-os/arkd
type: repo
publisher: Ark Labs (Arkade OS)
ingested: 2026-07-16
research_path: implementations
credibility: high
confidence: high
quality_score: 5
tags: [ark, arkd, arkade, clark, vtxo-tree, musig2, forfeit, connector, timelocks, go, implementation]
summary: Ground-truth Go implementation of clArk round mechanics — VTXO tree builder (radix 2), connector tree (radix 4), MuSig2 signing option flags, forfeit tx (version-3/TRUC + anchor), and exact default timelock seconds.
---

# arkade-os/arkd — Go server + ark-lib source code

Fetched master branch 2026-07-16 (raw.githubusercontent.com). Key paths: `pkg/ark-lib/tree/{builder,forfeit_tx,musig2,tx_tree,validation}.go`, `pkg/ark-lib/script/vtxo_script.go`, `internal/config/config.go`.

Ecosystem note: Ark Labs / `arkade-os/arkd` (Go, evolved from ark-network/arkd) renamed the round to a **"batch swap"** producing a **"commitment transaction,"** and added **checkpoint transactions** and a **BIP322 intent** system. Second's `bark` (Rust) keeps classic "round" terminology. Both implement the same n-of-n MuSig2 presigned-tree core.

## VTXO tree builder (`pkg/ark-lib/tree/builder.go`)
- `BuildVtxoTree` "creates the vtxo tree, ie. the tree of transactions from the one spending the batch output to those creating the vtxos (the leaves)." Uses **`vtxoTreeRadix = 2`** (binary tree).
- `BuildConnectorTree` builds "the tree of transactions from the one spending the connector output to those creating the connectors used to forfeit vtxos" using **`connectorsTreeRadix = 4`** (quaternary).
- `BuildBatchOutput` and `BuildConnectorOutput` generate the taproot script + amount for the two commitment-tx outputs.
- Tree node model: `node` interface (`getAmount()`, `getOutputs()`, `getChildren()`, `getCosigners()`, `getInputScript()`, `tree()`); `leaf` struct = terminal VTXO nodes; `branch` struct = intermediate nodes carrying aggregated cosigners.
- Expiry propagates via `vtxoTreeExpiry arklib.RelativeLocktime` through `BuildVtxoTree`.

## VTXO script (`pkg/ark-lib/script/vtxo_script.go`)
- Default construction: **`"A + S | A after T"`** (A = owner pubkey, S = signer/LP key, T = exit delay).
- `NewDefaultVtxoScript(owner, signer, exitDelay)` returns two taproot leaves:
  - `CSVMultisigClosure{owner, exitDelay}` — unilateral exit, owner-only after relative CSV timelock
  - `MultisigClosure{owner, signer}` — collaborative 2-of-2, no timelock
- Closure types: `MultisigClosure`, `CLTVMultisigClosure` (absolute), `ConditionMultisigClosure`, `CSVMultisigClosure` (relative), `ConditionCSVMultisigClosure`.
- Leaves assembled via `txscript.NewBaseTapLeaf` → `txscript.AssembleTaprootScriptTree`; taproot output key uses an **unspendable internal key**.

## Forfeit tx (`pkg/ark-lib/tree/forfeit_tx.go`)
- `BuildForfeitTx(inputs []*wire.OutPoint, sequences []uint32, prevouts []*wire.TxOut, signerScript []byte, txLocktime uint32) (*psbt.Packet, error)`.
- Sums prevout values, subtracts `txutils.ANCHOR_VALUE`, builds a single forfeit output to the operator, delegates to `BuildForfeitTxWithOutput`.
- **Transaction version = 3** (TRUC/v3 for ephemeral-anchor CPFP); appends an anchor output; adds witness UTXOs per input.
- Inputs = one VTXO + one connector; outputs = forfeit output (operator) + anchor.

## MuSig2 signing (`pkg/ark-lib/tree/musig2.go`)
- `generateNonces()` → `musig2.GenNonces(musig2.WithPublicKey(signerPubKey))` per cosigner.
- `AggregateNonces()` → `musig2.AggregateNonces(allNonces)`.
- `Sign()` → `musig2.Sign(secretNonce, signer, combinedNonce, cosigners, message, musig2.WithSortedKeys(), musig2.WithTaprootSignTweak(batchOutSweepClosure), musig2.WithFastSign())`.
- `CombineSigs()` → `musig2.CombineSigs(...)` → final Schnorr sig.
- **Keys sorted deterministically** via `WithSortedKeys()`. Cosigners parsed from PSBT: `txutils.ParseCosignerKeysFromArkPsbt()`; `getCosignersPublicKeys()` checks membership before signing. Sweep-path taproot tweak (`batchOutSweepClosure`) applied when signing tree txs.

## Timelock defaults (`internal/config/config.go`, seconds, non-regtest)
- `defaultVtxoTreeExpiry = 604672` (~7 days)
- `defaultUnilateralExitDelay = 86400` (24 h)
- `defaultCheckpointExitDelay = 86400` (24 h)
- `defaultBoardingExitDelay = 7776000` (~90 days)
- `defaultHeartbeatInterval = 60`s
- Config keys: `UNILATERAL_EXIT_DELAY`, `ROUND_INTERVAL`, `ARK_NETWORK` (mainnet/testnet3/signet/mutinynet/regtest).

## RPCs
- Clients call `SubmitSignedForfeitTxs`; offchain flow uses `SubmitTxRequest` / `FinalizeTxRequest`.
- Indexer exposes `GetBatchSweepTransactions` (returns whether operator claimed after expiry vs. a user unrolled the tree).
