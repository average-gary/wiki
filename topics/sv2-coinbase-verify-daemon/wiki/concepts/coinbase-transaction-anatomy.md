---
title: "Coinbase transaction anatomy"
category: concept
created: 2026-07-21
updated: 2026-07-21
volatility: warm
confidence: high
tags: [bitcoin, coinbase, scriptsig, bip-34, bip141, witness-commitment, op-return, extranonce, merged-mining, fabe6d6d]
summary: "What's actually inside a coinbase, field by field — so a daemon knows what it's parsing and what each \"expected value\" check targets."
---

# Coinbase transaction anatomy

What's actually inside a coinbase, field by field — so a daemon knows what it's
parsing and what each "expected value" check targets.

## Input (exactly one)

- `previous_output`: 32 bytes of **zero** + index `0xFFFFFFFF` (the null prevout that
  marks a coinbase).
- `scriptSig`: length 1 byte, value **2–100**. Contents:
  - **BIP34 height** — the first pushed item, minimally-encoded little-endian
    (`03 <h0> <h1> <h2>` on mainnet). A consensus requirement, so reliably present.
    — [[raw/papers/2026-07-21-bip34-height-in-coinbase]]
  - **Arbitrary region** — pool tags / miner signatures / the **extranonce** rolling
    space (since ~2012). Optionally a **merged-mining tag** `0xfabe6d6d` (44-byte
    header: magic + AuxBlockHash + MerkleSize + MerkleNonce).
- `sequence`: `0xFFFFFFFF`.

## Outputs (≥1, usually ≥2)

- One or more **payout** outputs: `value` (8-byte LE satoshis) + `scriptPubKey` (the
  address being paid).
- The **segwit witness-commitment** output (BIP141): `scriptPubKey =
  OP_RETURN(0x6a) push36(0x24) 0xaa21a9ed <32-byte commitment>`. The commitment =
  `SHA256d(witness_root ‖ witness_reserved_value)`. If multiple match, the
  highest-index output is the commitment. — [[raw/papers/2026-07-21-bip141-segwit-witness-commitment]]

## Envelope + value

`version(4 LE) | txin_count | input | txout_count | outputs | locktime(4 LE)`. Total
**block reward = subsidy + fees**; subsidy starts 50 BTC (5,000,000,000 sat), halves
every 210,000 blocks; fees = Σinputs − Σoutputs across the block. The SV2 Template
Distribution `coinbase_tx_value_remaining` field carries subsidy+fees directly.
— [[raw/articles/2026-07-21-coinbase-structure-merkle-reconstruction-refs]],
[[raw/articles/2026-07-21-sv2-spec-template-distribution-protocol]]

## Witness reserved value caveat

Lives in the coinbase **input's witness** (a single 32-byte array), *not* in an output,
and is excluded from the txid serialization — so it is **not** present in the SV2
`coinbase_tx_prefix`/`coinbase_tx_suffix`. Checkable only if the daemon holds the full
witness-serialized coinbase (its own template).

## See also

- [[wiki/concepts/coinbase-reconstruction-and-merkle-fold]]
- [[wiki/concepts/expected-value-checks-taxonomy]]
- [[../sv2-coinbase-identity/wiki/concepts/sv2-coinbase-scriptsig-layout|SV2 coinbase scriptSig layout (sv2-coinbase-identity)]]
- [[sourcing-the-expected-value.md|Sourcing the expected value]]
