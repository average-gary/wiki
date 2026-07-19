---
title: "VTXOs and the VTXO tree"
type: concept
created: 2026-07-16
updated: 2026-07-17
confidence: high
volatility: hot
verified: 2026-07-17
sources:
  - raw/papers/2026-07-16-foundations-ark-litepaper.md
  - raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md
  - raw/repos/2026-07-16-implementations-arkd-go-source.md
  - raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md
  - raw/articles/2026-07-17-second-docs-learn-vtxo.md
  - raw/articles/2026-07-17-second-docs-learn-intro.md
tags: [ark, clark, vtxo, vtxt, transaction-tree, taproot, csv, cltv, radix, quad-tree, leaf, branch]
aliases: [VTXO, Virtual UTXO, VTXT, VTXO tree, quad tree, transaction tree]
summary: "The VTXO is Ark's off-chain unit of value: a leaf of a pre-signed transaction tree over the batch output, with a two-path Taproot script (cooperative multisig vs timelocked unilateral exit). arkd uses a binary tree (radix 2) with second-based timelocks; bark uses a quad tree (radix 4) with exact scripts CLTV <expiry-height> on roots/branches and CSV <144> (~1 day) on user exits."
---

# VTXOs and the VTXO tree

A **VTXO (Virtual UTXO)** is the core unit of value in Ark: "an off-chain representation of Bitcoin value... outputs within a tree of pre-signed transactions that are not yet broadcast to the blockchain" ([[../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md|DeepWiki]]). Optech calls a VTXO "a package of offchain transactions."

## VTXO script (litepaper Def 4.1)

A VTXO is `vtxo := (value, vtxoLockScript)` where the lock script is a Taproot output with ([[../../raw/papers/2026-07-16-foundations-ark-litepaper.md|litepaper]]):

1. an **unspendable key path**;
2. at least one **collaborative** path requiring signatures of BOTH the holder and operator O (delayable by an absolute timelock);
3. at least one **unilateral** path that does NOT need O's signature but is delayed by a relative timelock `t_v`.

arkd's `NewDefaultVtxoScript(owner, signer, exitDelay)` builds exactly two taproot leaves ([[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|arkd source]]):
- `MultisigClosure{owner, signer}` — collaborative 2-of-2, **no timelock**;
- `CSVMultisigClosure{owner, exitDelay}` — unilateral exit, **owner-only after a relative CSV timelock**.

Written as policy: **`(A + S) | (A after Δt)`** — Second's docs implement the second leaf "using OP_CHECKSEQUENCEVERIFY (CSV)". Arkade's delegation design adds a third leaf `A+B+S` (user+delegate+server); see [[../topics/clark-evolution.md|evolution]].

### bark's exact spend-path scripts

Second's newer docs give the concrete opcodes for the two paths, which differ by tree level ([[../../raw/articles/2026-07-17-second-docs-learn-vtxo.md|bark VTXO docs]]):

- **Path 1 — cooperative**: for **branches**, "**n-of-n multisigs (MuSig2)** between all users sharing that branch plus the server"; for **leaf** transactions, "**2-of-2 multisigs** between user and server."
- **Path 2 — timelocked recovery**: for **roots/branches**, an **absolute CLTV** timelock `<expiry-height> OP_CHECKLOCKTIMEVERIFY`; for **user exits**, a **relative CSV** timelock `<144> OP_CHECKSEQUENCEVERIFY` — i.e. **~1 day** at 144 blocks.

So bark's recovery path uses an *absolute* CLTV on the shared upper levels (the whole tree becomes recoverable at a fixed height) and a *relative* CSV on the individual exit (the per-user delay counted from when the exit confirms). This is the two-clock model, spelled out in opcodes; see [[unilateral-exit-and-timeouts.md|unilateral exit and timeouts]].

## The virtual transaction tree (VTXT)

The [[n-of-n-batch-output.md|batch output]] is subdivided by a **directed rooted tree** of "virtual transactions" — "regular Bitcoin transactions that will optimistically never go onchain" (litepaper Def 4.2). One **root** spends the full batch; intermediate **branch** nodes carry aggregated cosigners; **leaves** each produce a single VTXO owned by one user.

Implementation detail ([[../../raw/repos/2026-07-16-implementations-arkd-go-source.md|arkd `BuildVtxoTree`]]):
- **arkd VTXO tree radix = 2** (binary tree of transactions).
- Nodes are PSBTs; a node's inputs reference the parent node's outputs; outputs are either child nodes or leaf VTXOs.
- Each VTXO carries a **sweep tapscript with CSV** so the operator can reclaim it after expiry.
- Expiry propagates through the builder via a `vtxoTreeExpiry RelativeLocktime` parameter.

**The two implementations use different tree radices.** Where arkd's VTXO tree is **binary (radix 2)**, bark's refresh-VTXO tree is a **quad tree (radix 4)** — "each branch transaction splits into four outputs" — which minimizes exit costs through logarithmic scaling ([[../../raw/articles/2026-07-17-second-docs-learn-vtxo.md|bark VTXO docs]]). bark names the three tx roles explicitly: **Root** (the only on-chain tx), **Branch** (off-chain value splits), and **Leaf** (a user's individual exit tx). Board VTXOs have the shallowest structure ("Root → Leaf", 2 txs); refresh VTXOs are deeper ("Root → Branches → Leaf", 3+ txs); and because deeper users share upper branches, "users exiting earlier subsidize users exiting later" (a shared-branch broadcast benefits everyone below it). The connector tree (arkd) is separately radix 4; see [[forfeit-and-connectors.md|forfeits and connectors]].

Tracked VTXO fields in arkd: txid, output index, sat amount, controlling pubkey, root commitment txid, commitment-tx chain, expiration block height, spent/swept status, and a **preconfirmation flag** (out-of-round vs batch-confirmed).

## Per-branch signing (interactivity optimization)

The litepaper allows two signing regimes: all holders sign every virtual tx, or — to reduce interactivity — **each holder signs only the transactions on the path to their own VTXO**. Ark Labs later reduced this from each participant signing **(2n−1)** transactions with ephemeral keys to each user signing only **~log₂(n)** transactions (those affecting their own descendants) using their wallet keys ([[../../raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md|Ark Labs]]). See [[tree-presigning-musig2.md|tree presigning]].

## VTXO types

bark names three VTXO types by how they are created ([[../../raw/articles/2026-07-17-second-docs-learn-vtxo.md|bark VTXO docs]], [[../../raw/articles/2026-07-17-second-docs-learn-intro.md|bark intro]]):

- **Board VTXOs** — created by [[boarding.md|boarding]] on-chain funds; shallowest tree; completely trustless recovery.
- **Refresh VTXOs** — created/refreshed in a [[clark-round-lifecycle.md|round]] (arkd calls this "settle"); trustless like board.
- **Spend VTXOs** — instant payments via **arkoor (out-of-round)**; "extend board and refresh VTXOs" by adding new leaf transactions, and follow **state chain** security (trust = sender + server don't collude). See [[out-of-round-payments.md|out-of-round payments]].

Every VTXO carries a bounded **lifetime** (~28-30 days standard, ~3 days for Lightning-receive), and spending does *not* reset it — see [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]].

## See also

- [[n-of-n-batch-output.md|The n-of-n batch output]]
- [[tree-presigning-musig2.md|Tree presigning (MuSig2)]]
- [[unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]]
- [[vtxo-lifetime-and-expiry.md|VTXO lifetime and expiry]]
- [[lightning-integration.md|Lightning integration]]
- [[../reference/clark-glossary-and-timelocks.md|Glossary + timelock reference]]

## Sources

- [Ark litepaper](../../raw/papers/2026-07-16-foundations-ark-litepaper.md) — VTXO script Def 4.1, VTXT Def 4.2, two signing regimes
- [DeepWiki — exit and rounds](../../raw/repos/2026-07-16-dropout-deepwiki-exit-and-rounds.md) — VTXO definition and tracked fields
- [arkd Go source](../../raw/repos/2026-07-16-implementations-arkd-go-source.md) — `NewDefaultVtxoScript`, `BuildVtxoTree`, radix 2
- [Ark Labs — tree signing](../../raw/articles/2026-07-16-evolution-unlock-liquidity-tree-signing.md) — the (2n−1) → ~log₂(n) per-branch signing reduction
- [Ark VTXOs (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-vtxo.md) — three types, quad tree (radix 4), exact CLTV/CSV scripts
- [Intro to the Ark protocol (Second/Bark docs)](../../raw/articles/2026-07-17-second-docs-learn-intro.md) — board/spend/refresh VTXO overview
