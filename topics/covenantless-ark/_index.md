---
title: Covenantless Ark (clArk) — Wiki
type: wiki-root
created: 2026-07-16
updated: 2026-07-17
scope: hub-topic
---

# Covenantless Ark (clArk) — Wiki

Topic wiki for **covenantless Ark** (clArk) — the variant of the Ark Bitcoin L2 protocol that works on today's Bitcoin (no `OP_CHECKTEMPLATEVERIFY`/`OP_CTV` covenant opcode), substituting **n-of-n multisignature presigning** for the covenant. First research session focus: **round transaction mechanics** — the n-of-n batch/pool output, the presigned VTXO transaction tree, the dropout/abort ("freeze") dynamics, and the timeout-driven unilateral refund/exit path.

## Layout

- `wiki/concepts/` — atomic concept articles (15)
- `wiki/topics/` — synthesizing topic articles (4)
- `wiki/reference/` — glossary + timelock reference (1)
- `raw/` — ingested source material with provenance (41 files)
- `output/` — generated artifacts (none yet)
- `theses/` — 6 candidate theses for follow-up

## Stats

- Sources ingested: **41** (36 articles [1 superseded], 1 paper, 4 repos)
- Articles compiled: **20** wiki articles (15 concepts + 4 topics + 1 reference)
- Outputs: 0
- Theses: 6 candidate theses surfaced
- Last research session: 2026-07-16 (standard mode, 5 agents)
- Last compiled: **2026-07-17** — 25 new sources (second.tech/docs Learn collection + bark repo design-docs collection) → 4 new articles, 13 updated. Corrected hArk from proposal to LIVE (Jan 2026); added quad-tree (radix 4), exact CLTV/CSV scripts, VTXO lifetimes, liquidity formula, checkpoints trilogy, Ark addresses/mailbox/movements/offboard-swaps.
- Last ingest: 2026-07-17 — bark repo design-docs collection (10 files: manifest + 9 children, incl. checkpoints trilogy); earlier same day: second.tech/docs Learn collection (15 files)

## TL;DR

- **clArk = covenantless Ark**: Ark on today's Bitcoin, replacing the `OP_CTV` covenant with an **n-of-n MuSig2 pseudo-covenant** — all parties pre-sign the VTXO tree and delete ephemeral keys. Security = **1-of-n honest key-deletion**.
- **A round produces one on-chain tx** (round tx / commitment tx) with two outputs: the **n-of-n batch output** (unroll path via the pre-signed tree + operator sweep path after absolute expiry `T_exp`) and a **connector tree** output.
- **Ordering is the safety property**: users MuSig2-sign the tree and their **forfeit txs FIRST**; the ASP broadcasts the funding tx **LAST**. Forfeits are bound to confirmation via **connectors** (arkd) or **hash-locks** (bark rounds).
- **Dropout = atomic abort**, no on-chain footprint; honest users retry. The deep problem is the **receiver-DoS asymmetry** — a receiver with no VTXO at stake can grief a round for free, so clArk cannot admit pure receivers (send-to-others goes **out-of-round**).
- **Timeout refund path uses two clocks**: absolute `T_exp` (operator sweeps un-refreshed funds; ~7 d arkd / 14 d docs / ~30 d bark) and relative `Δt` (unilateral-exit CSV, ~24 h arkd). Exit = broadcast your tree branch (TRUC/v3, P2A-anchor CPFP), wait `Δt`, spend to sole control; cost **O(log t)**.
- **Covenantless-specific costs**: users must **store exit data client-side** (lose it → no exit), and everyone must be **online to refresh** before expiry.
- **Two production implementations**: Second's **`bark`** (Rust; mainnet 2026-06-09) and Ark Labs' **`arkd`/Arkade** (Go; beta 2025-10-20). Different terminology, different forfeit-atomicity designs.
- **hArk is LIVE, not just a proposal**: Second's `bark` shipped a covenantless **hash-lock "hArk" enhancement in January 2026** (non-interactive refresh, immediate on-chain broadcast, no soft fork). The fuller CTV/CSFS successors — **Erk** (rebindable sigs → async + offline refresh) and the CTV-based hArk proposal — still await a soft fork. "Ark v2" is not a formal release.

## Start here

- [[wiki/concepts/clark-overview.md|clArk overview]] — orient
- [[wiki/topics/clark-round-transaction-mechanics.md|Round transaction mechanics (primary synthesis)]] — the end-to-end walkthrough
- [[wiki/concepts/clark-round-lifecycle.md|Round lifecycle]] — the ceremony phase by phase
- [[wiki/concepts/n-of-n-batch-output.md|The n-of-n batch output]] / [[wiki/concepts/vtxo-and-vtxo-tree.md|VTXOs and the tree]] / [[wiki/concepts/tree-presigning-musig2.md|Tree presigning]]
- [[wiki/concepts/forfeit-and-connectors.md|Forfeits and connectors]] — atomic refresh + fraud penalty
- [[wiki/concepts/dropout-and-round-abort.md|Dropout, abort, and griefing]] — the "freeze" question
- [[wiki/concepts/unilateral-exit-and-timeouts.md|Unilateral exit and timeouts]] — the refund path
- [[wiki/concepts/offboarding-and-onchain-payments.md|Offboarding and on-chain payments]] / [[wiki/concepts/lightning-integration.md|Lightning integration]] / [[wiki/concepts/out-of-round-payments.md|OOR payments]] — the payment paths
- [[wiki/concepts/vtxo-lifetime-and-expiry.md|VTXO lifetime and liquidity economics]] / [[wiki/concepts/ark-addresses-and-delivery.md|Ark addresses and delivery]] — economics + addressing
- [[wiki/concepts/checkpoint-transactions.md|Checkpoint transactions]] — the partial-exit attack and the two-output fix
- [[wiki/topics/clark-vs-covenant-ark.md|clArk vs covenant-based Ark]] / [[wiki/topics/clark-limitations-and-trust.md|Limitations and trust]] / [[wiki/topics/clark-evolution.md|Evolution]]
- [[wiki/reference/clark-glossary-and-timelocks.md|Reference: glossary + timelock table]] — terminology map, script policies, constants

## Open questions

- Does the **hash-lock (bark) vs connector (arkd)** round-forfeit divergence have different security properties in edge cases (reorg, preimage leakage)? See [[wiki/concepts/forfeit-and-connectors.md|forfeits]].
- What is the *explicit* cost of a round rebuild after kicking a non-responsive participant (latency, retry)? Lightly documented — a gap. See [[wiki/concepts/dropout-and-round-abort.md|dropout]].
- Do **Delegation/Intents** actually remove the liveness burden in practice, or shift trust to the delegate? See [[wiki/topics/clark-evolution.md|evolution]].
- Is a **mass unilateral exit** feasible for small VTXOs under realistic fees? See [[wiki/topics/clark-limitations-and-trust.md|limitations]].
- Will **V-PACK/MVV** cross-implementation VTXO verification (incl. ASP-backdoor detection) land?
- Does any covenantless trick let clArk admit **pure receivers** into a round without CTV?

## Adjacent wikis

- [[../fedimint/_index.md|fedimint]] — federated Chaumian e-cash; adjacent off-chain shared-custody pattern
- [[../ldk-server/_index.md|ldk-server]] / [[../cdk-ldk-lnurl/_index.md|cdk-ldk-lnurl]] — Lightning stacks (Ark uses Lightning via Boltz for boarding/liquidity)
