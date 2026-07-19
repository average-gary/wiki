---
title: "coinbase-playground: mine_layered_ctv_coinbase.rs (2-level CTV tree)"
source: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/mine_layered_ctv_coinbase.rs"
type: repo
ingested: 2026-07-17
quality: 4
credibility: medium
confidence: high
tags: [collection, coinbase-playground, ctv, coinbase, layered-tree, binary-tree, unroll, taproot, rust, regtest]
summary: "Rust script building a 2-level binary CTV tree (root → 2 children → 4 leaves) from a coinbase. Each node commits via a CTV hash to its children; the tree is 'unrolled' by broadcasting root then both child txs in sequence. Fixed 500-sat fee per tx (root + each child)."
collection: "coinbase-playground"
adapter: git
upstream_id: "scripts/src/mine_layered_ctv_coinbase.rs"
upstream_type: git-file
revision: "0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6"
sha: "0647380fef7a83b4319c09f916f9decf7a555f29"
canonical_url: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/mine_layered_ctv_coinbase.rs"
content_format: text
license: "unknown"
authors: [vnprc]
fetched: 2026-07-17
---

# mine_layered_ctv_coinbase.rs — 2-level binary CTV tree

Part of the [[2026-07-17-collection-coinbase-playground-manifest.md|coinbase-playground collection]]. Behind `just mine-layered-ctv-coinbase`. Demonstrates the **nested/unrolled** CTV tree (contrast the flat tree's single immediate spend).

## Structure
- Root coinbase output commits (via CTV) to a spend with **two children** (left/right), each ~half the spendable value.
- Each child output commits (via CTV) to **two leaf outputs** → 4 leaves total.
- `CHILD_FEE = 500`, `ROOT_FEE = 500` (fixed sat fees). `spendable = coinbase_value − ROOT_FEE − 2*CHILD_FEE`; `child_value = spendable/2`; leaf `half = (child_value − CHILD_FEE)/2`.

## Flow
1. Mine dummy block → read coinbase value.
2. Build 4 leaf outputs (fresh regtest addresses); left script commits to leaves[0..2], right to leaves[2..4].
3. Build root CTV script committing to `[left_out, right_out]`; Taproot single-leaf address.
4. Mine a block to the taproot address (coinbase pays into root covenant); mature 100 blocks.
5. Broadcast **root spend tx** (v3, witness = root script + control block) → creates left/right child outputs; mine.
6. Broadcast **left child tx** (spends root vout 0 → leaves 0..2) and **right child tx** (spends root vout 1 → leaves 2..4); mine.
- Prints root/left/right txids — this sequence is the manual "unroll."

## CTV hash
Same `calc_ctv_hash` as the flat script (v3, locktime 0, 1 input, `sha256(ENABLE_RBF_NO_LOCKTIME)`, output count, `sha256(outputs)`, input index 0) — computed **per node** over that node's own child outputs.

## Notes / limitations (per README)
- "Strictly worse" than the flat tree for pool payouts; a stepping stone.
- Uses fixed 500-sat fees rather than anchors; planned improvements = 0-value anchor outputs, configurable leaf count / depth / **radix**.
- This nested design reintroduces the **data-availability** problem the flat tree avoids: children must be broadcast/unrolled after the root confirms (the README's downside #2).
