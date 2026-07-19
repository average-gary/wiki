---
title: "coinbase-playground: parse_witness.rs (CTV witness parser)"
source: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/parse_witness.rs"
type: repo
ingested: 2026-07-17
quality: 3
credibility: medium
confidence: high
tags: [collection, coinbase-playground, ctv, witness, taproot, tapscript, op-nop4, debugging, rust]
summary: "Rust utility that fetches a tx via RPC and disassembles each input's witness/spend type, flagging OP_CTV (OP_NOP4) tapleaf spends. Written because esplora does not parse input witness scripts, so the author couldn't otherwise see the on-chain CTV script."
collection: "coinbase-playground"
adapter: git
upstream_id: "scripts/src/parse_witness.rs"
upstream_type: git-file
revision: "0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6"
sha: "ad923bf2e98ea3a5fd1cc76856fe815eb6323f54"
canonical_url: "https://github.com/vnprc/coinbase-playground/blob/0ac7ed25a21806a0c9ba96fe50c34b9ce2c2cce6/scripts/src/parse_witness.rs"
content_format: text
license: "unknown"
authors: [vnprc]
fetched: 2026-07-17
---

# parse_witness.rs — CTV witness/spend-type parser

Part of the [[2026-07-17-collection-coinbase-playground-manifest.md|coinbase-playground collection]]. Behind `just parse-witness <txid> [index]`. A debugging tool.

## What it does
- Fetches the tx by txid via RPC; for one input (if index given) or all inputs, prints an analysis.
- Coinbase input (null prevout) → prints "Coinbase input (no prevout)".
- Otherwise fetches the prevout's scriptPubKey and **classifies the spk** (`classify_spk`): p2wpkh / p2wsh / p2tr / p2sh / p2pkh / nonstandard (via witness-program version+length).
- Flags CTV: if the spk's instructions contain `OP_CTV` (= `OP_NOP4`), prints "💡 This input spends an OP_CTV contract... Look for OP_NOP4 in Esplora!".
- For p2tr: 1 witness item = key-path spend; ≥2 = script-path (tapleaf) → disassembles `witness[0]` via `parse_script_witness`. For p2wsh: disassembles the last witness item.

## Script disassembly
`parse_script_witness` walks `ScriptBuf::instructions()` and prints `Op(OP_CTV)` specially, other ops as `Op(<opcode>)`, and pushes as `PushBytes(0x<hex>)`. This is how the README shows the tapleaf `PushBytes(<32-byte hash>) / Op(OP_CTV)`.

## Why it exists
"esplora doesn't parse the input witness script and I wanted to see the `OP_CTV` script for myself." Documents a real tooling gap: block explorers don't surface CTV tapleaf scripts, and (per README) esplora shows CTV as `OP_NOP4` because it's unaware of the node's activation code.
