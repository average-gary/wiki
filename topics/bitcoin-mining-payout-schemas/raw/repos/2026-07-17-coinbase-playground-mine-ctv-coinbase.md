---
title: "coinbase-playground: mine_ctv_coinbase.rs (flat CTV payout tree)"
source: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/mine_ctv_coinbase.rs"
type: repo
ingested: 2026-07-17
quality: 4
credibility: medium
confidence: high
tags: [collection, coinbase-playground, ctv, coinbase, flat-tree, anchor, truc, ctv-hash, taproot, rust, regtest]
summary: "Rust script that mines a coinbase to a Taproot CTV contract address and spends it to N equal outputs (default 50). Documents the concrete CTV template-hash construction, a 330-sat CPFP anchor output, v3/TRUC transaction, and a 1 sat/vB fee taken from the coinbase reward."
collection: "coinbase-playground"
adapter: git
upstream_id: "scripts/src/mine_ctv_coinbase.rs"
upstream_type: git-file
revision: "0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6"
sha: "ca81ded7ddaa88c4d577f771b53c4bdc56cf66d8"
canonical_url: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/mine_ctv_coinbase.rs"
content_format: text
license: "unknown"
authors: [vnprc]
fetched: 2026-07-17
---

# mine_ctv_coinbase.rs — flat CTV payout tree

Part of the [[2026-07-17-collection-coinbase-playground-manifest.md|coinbase-playground collection]]. The primary flat-tree implementation behind `just mine-ctv-coinbase`.

## Flow
1. Ensure a `devwallet` regtest wallet exists.
2. Generate a fresh keypair → x-only pubkey (Taproot internal key).
3. Mine a **dummy block** to learn the actual coinbase value (`dummy_coinbase_tx.output[0].value`).
4. `build_ctv_contract(...)` → builds the payout outputs, the CTV tapleaf, the Taproot address, and the (unsigned) spend tx.
5. Mine a block **to the CTV contract address** (so the coinbase pays into the covenant).
6. Mine **100 blocks** to mature the coinbase.
7. Set the spend tx's prevout to the coinbase; push the CTV script + control block as witness; broadcast; mine.

## CTV contract construction
- Per-output value = `(input_value − fee − anchor) / output_count`; each output pays a fresh `getnewaddress` (regtest).
- If `include_anchor` (default true), append a **330-sat anchor** output (`ANCHOR_VALUE = 330`), scriptPubKey = `OP_PUSHNUM_1 <0x4e73>` (i.e. `OP_1 <ANCHOR_PUSHBYTES>`), for CPFP fee-bumping.
- Tapleaf script = `Builder::push_slice(<ctv_hash>).push_opcode(OP_CTV)` where `const OP_CTV: Opcode = OP_NOP4`.
- Taproot: single leaf at depth 0, internal key = the generated x-only pubkey; address = `Address::p2tr_tweaked(output_key, Regtest)`.
- Spend tx = **version 3** (TRUC), one input (the coinbase), `Sequence::ENABLE_RBF_NO_LOCKTIME`.

## CTV template hash (`calc_ctv_hash`)
Concretely builds the BIP-119 default-template-hash preimage:
- `version` = 3 (LE i32), `locktime` = 0 (LE i32), `input count` = 1 (LE u32)
- `sha256(sequences)` — here `sha256(Sequence::ENABLE_RBF_NO_LOCKTIME)` (or `sha256(Sequence(timeout))` if a timeout is given)
- `output count` (LE u32), then `sha256(concat(consensus_encode(each output)))`
- `input index` = 0 (LE u32)
- final = `sha256(buffer)`.

## Fee model
- `calculate_fee_with_anchor` builds a dummy tx (with witness: dummy CTV script + control block), computes vsize, and returns `vsize * fee_rate` (`fee_rate = 1` sat/vB).
- `get_virtual_bytes`: `weight = base_size*3 + total_size; vsize = (weight + 3)/4`.

## Notes
- Matches the README's flat-tree design (immediate broadcast, 1 sat/vB, 330-sat anchor). The ~319-output TRUC ceiling is an empirical limit reported in the README, not enforced in this file.
- All outputs pay distinct fresh addresses (the README's "pretend they are different" caveat is noted as fixed).
