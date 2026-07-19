---
title: CTV Coinbase Payout Tree
category: concept
created: 2026-07-17
updated: 2026-07-17
verified: 2026-07-17
confidence: medium
volatility: warm
tags: [ctv, csfs, checktemplateverify, coinbase, payout-tree, non-custodial-pool, truc, musig, anchor-output, ocean, p2pool, bip-119]
aliases: [CTV coinbase fanout, coinbase payout tree, CTV coinbase transaction, coinbase-playground, non-custodial coinbase payout, CTV payout fanout]
sources:
  - "raw/repos/2026-07-17-coinbase-playground-readme.md"
  - "raw/repos/2026-07-17-coinbase-playground-mine-ctv-coinbase.md"
  - "raw/repos/2026-07-17-coinbase-playground-mine-layered-ctv-coinbase.md"
  - "raw/repos/2026-07-17-coinbase-playground-parse-witness.md"
  - "raw/repos/2026-07-17-coinbase-playground-mine-and-send.md"
  - "raw/repos/2026-07-17-collection-coinbase-playground-manifest.md"
  - "raw/repos/2026-05-26-vnprc-coinbase-playground-github.md"
summary: "Using OP_CHECKTEMPLATEVERIFY (BIP-119) in a block's coinbase to commit to a large miner-payout transaction tree in a tiny on-chain footprint, enabling non-custodial pool payouts without hitting the Bitmain firmware coinbase-size limit. Documented via vnprc's coinbase-playground regtest: a flat tree (~319-output TRUC ceiling, 330-sat anchor, 1 sat/vB, immediate broadcast) versus a layered binary tree (nested unroll, fixed 500-sat fees), with a MuSig-tree + P2Pool-reboot endgame."
---

# CTV Coinbase Payout Tree

> A **CTV coinbase payout tree** commits a mining pool's entire miner-payout structure to a *single* covenant output in the block's coinbase, using OP_CHECKTEMPLATEVERIFY (BIP-119). Instead of paying every miner directly with a coinbase output — which balloons the coinbase and, more damningly, collides with the coinbase-size cap that ASIC firmware (notably Bitmain's) enforces — the coinbase pays one small CTV commitment that later *unrolls* into hundreds of payout outputs in follow-up transactions. The construction is the on-chain fanout primitive that would let a **non-custodial** pool pay arbitrarily many miners at block scale without taking custody of the reward. The reference exploration is vnprc's `coinbase-playground` regtest, which implements a flat single-spend tree and a layered/nested tree and sketches a MuSig-node endgame aimed at a [[p2pool-share-chain|P2Pool]] ([P2Pool](../concepts/p2pool-share-chain.md)) reboot.

## The problem it solves: the coinbase-size cap

A pool that pays miners *directly in the coinbase* is non-custodial by construction — the reward never passes through a pool-controlled wallet, it originates already split among the miners. [[tides|TIDES]] ([TIDES](../concepts/tides.md)) on OCEAN is the only production pool that does this today, and per the source it is "severely limited in the amount of outputs they can put in the coinbase." Two obstacles bound direct coinbase payout:

1. **Fee cannibalization** — every extra coinbase output is weight the miner could have sold to a fee-paying transaction, so a large coinbase eats into per-block fee revenue.
2. **Miner firmware restrictions** (the bigger problem) — the source claims **Bitmain**, the dominant ASIC manufacturer, caps coinbase-transaction size in miner firmware, and frames this as deliberate suppression of decentralized alternatives. It attributes P2Pool's "slow death" in large part to Antminer firmware restrictions. OCEAN reportedly works around the cap by fingerprinting each miner's hardware, tracking multiple work templates, and loosely validating miner-submitted blocks — described as "a really tough and completely unnecessary engineering problem."

The CTV insight: a covenant lets you **commit to a whole payout structure in a tiny transaction footprint**. The coinbase carries one CTV output (a 32-byte template hash under an OP_CTV taproot leaf); the hundreds of actual payout outputs live in a *separate* transaction that the covenant forces to exist exactly as committed. This sidesteps the firmware cap (the coinbase stays small) while still binding the reward to a fixed, publicly-verifiable split.

**Stated wins** (in the source's own priority order): (1) break Bitmain's stranglehold on the coinbase; (2) enable non-custodial pools at any scale; (3) maximize per-block fee revenue. **Downsides**: (1) miners must get *additional* transactions mined to actually claim their reward; (2) someone must make the **unroll transaction data** available so the tree can be spent.

## How CTV binds the tree

CTV (OP_CHECKTEMPLATEVERIFY, BIP-119) is a covenant opcode that lets an output commit in advance to the *exact* transaction that may spend it. The playground computes the BIP-119 **default template hash** directly (`calc_ctv_hash`): it hashes the spending transaction's `nversion`, `nlocktime`, input count, a `sha256` of the input sequences, the output count, a `sha256` of the serialized outputs, and the input index. Because the outputs are inside the hash, the covenant fully determines the payout split — the spend can only pay the addresses and amounts committed at coinbase-creation time.

The commitment is embedded as a **Taproot script-path leaf**: the tapleaf script is simply `PushBytes(<32-byte CTV hash>)` followed by `OP_CTV`, where `OP_CTV` is the opcode formerly known as `OP_NOP4`. (Pre-activation and in explorers that don't know about a CTV soft-fork, it still shows up as `OP_NOP4`.) The coinbase pays to a single-leaf Taproot address (`p2tr_tweaked`) with a freshly generated internal key; the spend reveals the leaf script plus control block in the witness. This is exactly what the `parse-witness` helper prints — block explorers such as esplora don't disassemble input witness scripts, so a dedicated tool was needed to *see* the on-chain CTV script at all.

## Flat payout tree

The primary design (`mine-ctv-coinbase`, default 50 outputs) is a **single-level fanout**:

- The coinbase pays into the CTV taproot address. After the mandatory **100-block coinbase maturity**, a single **version-3 (TRUC)** transaction spends it, producing N roughly-equal payout outputs (each to a distinct address).
- Per-output value = `(input_value − fee − anchor) / output_count`.
- **Fee**: a flat **1 sat/vB**, taken from the coinbase reward. `calculate_fee_with_anchor` builds a dummy witness-bearing spend, measures vsize (`weight = base_size*3 + total_size; vsize = (weight+3)/4`), and multiplies by the 1 sat/vB rate.
- **330-sat anchor output** (`ANCHOR_VALUE = 330`, scriptPubKey `OP_1 <0x4e73>`): an ephemeral-anchor-style output anyone can spend to **CPFP** fee-bump the payout transaction. Because anyone can attach to it, users can *crowdsource* the fee-bump collaboratively via `SIGHASH_ANYONECANPAY`.
- **Data-availability by immediacy**: the flat tree is meant to be broadcast to the mempool *immediately* after the block is mined, at 1 sat/vB. It then sits in the mempool for up to the ~100-block maturity window and gets mined whenever fees are low; impatient miners can bump it via the anchor. Avoiding nested transactions is what avoids the data-availability problem entirely — there is nothing to "unroll."
- **Empirical ceiling ≈ 319 payout outputs** before the spend hits **TRUC** (BIP-431 v3 transaction) size-policy limits. This is a measured limit reported in the README, not enforced in the script.

## Layered (nested) payout tree

The alternative design (`mine-layered-ctv-coinbase`) is a **binary tree**: root → 2 children → 4 leaves (2 levels, 4 leaves in the demo). Each node's CTV hash is computed over *its own* children's outputs, so the covenant chains down the tree. The tree is spent by **unrolling**: broadcast the root spend (creating the two child outputs), then broadcast each child spend (creating the leaf outputs), each as its own v3 transaction.

- Fees are **fixed sat amounts**, not rate-based: `ROOT_FEE = 500`, `CHILD_FEE = 500` per transaction. `spendable = coinbase_value − ROOT_FEE − 2*CHILD_FEE`; `child_value = spendable/2`; each leaf gets `(child_value − CHILD_FEE)/2`.
- The author calls it **"strictly worse than the flat structure"** for pool payouts — it reintroduces the exact **data-availability** problem the flat tree avoids, because the child transactions must be published and broadcast *after* the root confirms, or leaf owners cannot claim. It exists as a stepping stone.
- **Planned improvements**: replace the fixed fees with 0-value anchor outputs (as the flat tree uses); make leaf count, tree depth, and **radix** (children per node) configurable.

The flat-vs-layered tradeoff is the core lesson of the playground: nesting buys you a larger addressable payout set per unit of on-chain footprint, but every layer you add is another transaction someone must keep available and broadcast, so the practical sweet spot for pool payouts is the widest flat tree TRUC allows (~319) broadcast immediately.

## Endgame: MuSig nodes and a P2Pool reboot

The stated long-term goal moves past pure CTV: put an **n-of-n MuSig locking script at each tree node**. In the ~100 blocks between the coinbase confirming and maturity, leaf owners **trade outputs off-chain** to consolidate the tree into fewer, larger on-chain payouts — e.g. a leaf owner swaps off-chain funds for a sibling's signature(s) to collapse a subtree one level, taking a bigger single on-chain output with fewer transactions. This is explicitly tied to the **P2Pool reboot** and cites Kulpreet Singh's opdup "trading shares for bitcoin" user story. The MuSig-tree + off-chain-consolidation pattern is structurally the same shared-output transaction tree that [[ark-for-mining-payouts|Ark]] ([Ark](../concepts/ark-for-mining-payouts.md)) uses, and the same off-chain share-trading idea that [[p2pool-share-chain|p2poolv2]] ([p2poolv2](../concepts/p2pool-share-chain.md)) implements with HTLCs.

## Relationship to other covenant-payout designs

CTV coinbase fanout sits on the **on-chain payout-fanout primitives** axis of the [[payout-schema-taxonomy|taxonomy]] ([taxonomy](../concepts/payout-schema-taxonomy.md)) — it is orthogonal to the share-accounting scheme (PPLNS / TIDES / SLICE decide *how much* each miner is owed; the CTV tree is *how* the coinbase is physically split among them). It is the CTV-only analogue of two neighbours:

- [[braidpool|Braidpool]] ([Braidpool](../concepts/braidpool.md))'s UHPO custody uses **APO + CTV** for a recursive forward-rolling coinbase aggregation — a *different* covenant target (aggregate forward) than this design's *fan out now*. Braidpool's own critique that CTV-only "covenant pools" cannot sample hashrate faster than Bitcoin blocks and so are "not a pool in the usual sense" applies here: a CTV coinbase tree is a payout *fanout*, not a variance-reducing sharechain.
- **Activation dependency**: like all covenant-payout designs, the whole thing is gated on a BIP-119 (CTV) soft fork, plus BIP-348 (CSFS) for the CSFS-using experiments. The playground runs on `bitcoin-garrys-mod`, a Bitcoin Core fork with CTV+CSFS enabled, on regtest only.

## Status and provenance

Working **regtest** demonstration only — no mainnet, no testnet deployment, and blocked on CTV activation politics. The source is author advocacy (vnprc) plus a runnable demo with real regtest txids and screenshots; the covenant/TRUC mechanics are verifiable from the Rust code, so confidence in *how it works* is high, but claims about Bitmain's motives and P2Pool's cause of death are the author's framing (medium credibility). The repo has no LICENSE file. Two raw snapshots exist: a lighter 2026-05-26 metadata snapshot and this fuller 2026-07-17 collection pinned to commit `0ac7ed25`; the earlier snapshot's "179-byte coinbase / 319-output" figure is only partly re-confirmed here — the ~319-output TRUC ceiling is in the current README, but the 179-byte coinbase size is not re-verified in the 2026-07-17 material.

## See Also

- [[tides|TIDES (OCEAN)]] ([TIDES](../concepts/tides.md)) — the one production non-custodial coinbase-payout pool, whose output-count limit CTV aims to lift
- [[datum|DATUM]] ([DATUM](../concepts/datum.md)) — OCEAN's miner-side template construction; the pool inserts its payout coinbase outputs into miner-built templates, the same coinbase-space pressure CTV addresses
- [[braidpool|Braidpool]] ([Braidpool](../concepts/braidpool.md)) — APO+CTV UHPO covenant custody; a different covenant-payout target and the source of the "CTV-only pools aren't pools" critique
- [[ark-for-mining-payouts|Ark for Mining Payouts]] ([Ark for Mining Payouts](../concepts/ark-for-mining-payouts.md)) — the CTV-coinbase → VTXO hybrid and the shared-output-tree parallel to the MuSig endgame
- [[p2pool-share-chain|p2pool / p2poolv2]] ([p2pool / p2poolv2](../concepts/p2pool-share-chain.md)) — the P2Pool reboot the MuSig endgame targets; also solves output-cap fanout via HTLC share trading
- [[payout-schema-taxonomy|Payout Schema Taxonomy]] ([Payout Schema Taxonomy](../concepts/payout-schema-taxonomy.md)) — where on-chain fanout primitives sit relative to share-accounting schemes

## Sources

- [[../../raw/repos/2026-07-17-coinbase-playground-readme|coinbase-playground README]] — the non-custodial-pool argument, flat/layered trees, endgame
- [[../../raw/repos/2026-07-17-coinbase-playground-mine-ctv-coinbase|mine_ctv_coinbase.rs]] — flat-tree implementation: CTV template hash, 330-sat anchor, v3/TRUC spend, 1 sat/vB fee
- [[../../raw/repos/2026-07-17-coinbase-playground-mine-layered-ctv-coinbase|mine_layered_ctv_coinbase.rs]] — 2-level binary tree, per-node CTV hash, fixed 500-sat fees, manual unroll
- [[../../raw/repos/2026-07-17-coinbase-playground-parse-witness|parse_witness.rs]] — CTV witness/tapleaf parser (OP_CTV = OP_NOP4)
- [[../../raw/repos/2026-07-17-coinbase-playground-mine-and-send|mine_and_send.rs]] — regtest bootstrap helper
- [[../../raw/repos/2026-07-17-collection-coinbase-playground-manifest|coinbase-playground collection manifest]] — provenance for the 2026-07-17 ingest @ 0ac7ed25
- [[../../raw/repos/2026-05-26-vnprc-coinbase-playground-github|vnprc/coinbase-playground (2026-05-26 snapshot)]] — prior lighter metadata snapshot
