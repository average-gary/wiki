---
title: "BIP141 — Segregated Witness (witness commitment in coinbase)"
source_url: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
type: paper
retrieved: 2026-07-21
credibility: high
corroboration: "coinbase-structure agent"
tags: [bitcoin, bip141, segwit, witness-commitment, coinbase, OP_RETURN, txid-vs-wtxid]
summary: "The coinbase witness-commitment output layout (OP_RETURN 6a24 aa21a9ed + 32-byte commitment) and why the witness reserved value is NOT part of the txid serialization (and thus not in the SV2 coinbase prefix/suffix)."
---

# BIP141 — Witness Commitment

## Commitment output layout

`OP_RETURN (0x6a)` + `push-36 (0x24)` + **4-byte header `0xaa21a9ed`** + **32-byte
commitment hash**. Minimum 38 bytes total.

- Commitment hash = `SHA256d( witness_root_hash ‖ witness_reserved_value )` (two
  32-byte values → 64 bytes → double-SHA256).
- The witness root hash is built like the normal merkle root but over `wtxid` values,
  with the **coinbase's wtxid taken as 0x00…00 (32 zero bytes)**.
- Witness reserved value: "the coinbase's input's witness must consist of a single
  32-byte array" — it lives in the **witness field of the coinbase input**, not in an
  output.
- If multiple outputs match, "the one with highest output index is assumed to be the
  commitment." If no tx has witness data, the commitment is optional.

## Critical txid-vs-wtxid consequence

The block merkle tree uses **txid** (double-SHA256 of the **non-witness / legacy**
serialization), which excludes the witness reserved value. So the SV2
`coinbase_tx_prefix`/`coinbase_tx_suffix` (the legacy serialization used to compute
the txid) **do not contain the witness reserved value**. A daemon that wants to check
the witness reserved value needs the full witness-serialized coinbase (from its own
template), not the SV2 job fields.

## Relevance

Check (d): "expected OP_RETURN witness commitment" — the `6a 24 aa21a9ed` marker +
32-byte commitment is checkable from an extended-channel coinbase (it's an output, in
prefix or suffix). The reserved value itself is not.
