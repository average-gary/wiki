---
title: "Coinbase reconstruction and merkle fold"
type: concept
created: 2026-07-21
updated: 2026-07-21
confidence: high
tags: [bitcoin, coinbase, extranonce, merkle-root, double-sha256, txid, wtxid, endianness, bip34, bip141]
---

# Coinbase reconstruction and merkle fold

The byte-level algorithm a daemon runs on each `NewExtendedMiningJob` to rebuild the
coinbase and derive the block merkle root. This is the mechanical heart of the tool.

## Inputs

From `NewExtendedMiningJob`: `coinbase_tx_prefix`, `coinbase_tx_suffix`,
`merkle_path[]`, `version`. From channel open: `extranonce_prefix` + a locally chosen
`extranonce` (total `extranonce_size` bytes).

## Algorithm

1. **Assemble the raw coinbase (legacy / non-witness serialization):**
   `coinbase_tx = coinbase_tx_prefix ‖ extranonce_prefix ‖ extranonce ‖ coinbase_tx_suffix`.
   The split is placed so `extranonce_prefix‖extranonce` lands inside the coinbase
   input's scriptSig (after the [[wiki/concepts/coinbase-transaction-anatomy|BIP34 height push]]).
   No segwit marker/flag byte, no witness stanza — which is exactly why the txid
   excludes the witness reserved value.
2. **Coinbase txid:** `coinbase_txid = SHA256d(coinbase_tx)` — internal little-endian,
   not reversed. (txid ≠ wtxid; the block tree uses txid.)
3. **Fold the merkle path** (coinbase is always the leftmost leaf, index 0):
   `h = coinbase_txid; for e in merkle_path: h = SHA256d(h ‖ e)` — running hash is
   always the **left** operand, path element the right. The odd-node duplication rule
   is already baked into what the pool put in `merkle_path`.
4. **Result = block merkle root** → header bytes 36–67:
   `version | prev_block(32) | merkle_root(32) | time(4) | bits(4) | nonce(4)`.
   Block hash = `SHA256d(header)`.

— [[raw/articles/2026-07-21-coinbase-structure-merkle-reconstruction-refs]],
[[raw/articles/2026-07-21-sv2-spec-mining-protocol-channels-jobs]]

## Byte-ordering cheatsheet

- All header integer fields + the merkle root are **little-endian internally**;
  explorers/txids are shown **byte-reversed** (big-endian).
- Every hash is **double-SHA256**.
- `txid = SHA256d(legacy tx)`; `wtxid = SHA256d(witness tx)`; coinbase wtxid is defined
  as all-zero. The [[wiki/concepts/coinbase-transaction-anatomy|BIP141 witness reserved value]]
  is *not* in the SV2 prefix/suffix (it's witness data, outside the txid serialization).

## You don't have to write this yourself

SRI's `channels_sv2::merkle_root::merkle_root_from_path(prefix, suffix, extranonce,
path)` does steps 1–3 as a standalone free function (depends only on `bitcoin` +
`alloc`). `ExtendedChannel::validate_share` does the whole thing including the header
build + target compare. — [[raw/repos/2026-07-21-sri-channels-sv2-client-extended-validate-share]]

## See also

- [[wiki/concepts/coinbase-transaction-anatomy]]
- [[wiki/concepts/expected-value-checks-taxonomy]]
- [[wiki/concepts/sri-client-crate-stack]]
