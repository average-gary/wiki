---
title: "Coinbase tx structure, extranonce, merkle root + block header (Mastering Bitcoin ch12 + Bitcoin wiki)"
source_url: https://raw.githubusercontent.com/bitcoinbook/bitcoinbook/develop/ch12_mining.adoc
source_url_2: https://en.bitcoin.it/wiki/Protocol_documentation
source_url_3: https://en.bitcoin.it/wiki/Block_hashing_algorithm
source_url_4: https://en.bitcoin.it/wiki/Merged_mining_specification
type: article
retrieved: 2026-07-21
credibility: high
corroboration: "coinbase-structure agent; merkle/header rules also confirmed by SV2 spec"
tags: [bitcoin, coinbase, extranonce, merkle-root, block-header, endianness, merged-mining, fabe6d6d]
summary: "Byte-level references for the coinbase-reconstruction-and-merkle-fold algorithm: coinbase input/output wire format, the 2–100 byte scriptSig envelope + extranonce region, the double-SHA256 merkle pairing rule, the 80-byte header layout and LE-internal / reversed-display convention, and the 0xfabe6d6d merged-mining tag."
---

# Coinbase structure + merkle reconstruction — byte-level references

## Coinbase transaction structure (Mastering Bitcoin ch12; Bitcoin wiki protocol doc)

- Coinbase **input**: prev-output hash = 32 bytes of zero; output index =
  `0xFFFFFFFF`; `scriptSig` length (1 byte, value **2–100**); scriptSig data
  (arbitrary, BIP34 height required first); sequence = `0xFFFFFFFF`.
- Except the BIP34 height, the scriptSig "is arbitrary data" — where **pool tags,
  miner signatures, and the extranonce** live. Since ~2012 this region is the extra
  nonce space (8 bytes extranonce + 4 bytes header nonce ≈ 2^96 search space).
- Coinbase **outputs** (`tx_out`): `value` = 8-byte int64 **little-endian** (satoshis);
  `script length` varint; `scriptPubKey`. Modern coinbase usually has ≥2 outputs: the
  OP_RETURN segwit commitment (0 value) + the actual payout output(s).
- Envelope: `version` 4-byte int32 LE | `tx_in count` varint | inputs | `tx_out count`
  varint | outputs | `lock_time` 4-byte uint32 LE.
- **Block reward** = subsidy + fees. Subsidy starts 50 BTC = 5,000,000,000 sat,
  halves every 210,000 blocks. Fees = Σ(inputs) − Σ(outputs) over the block's txs.

## Merkle root (Bitcoin wiki)

- Every hash is **double-SHA256**. Each parent = double-SHA256 of the 64-byte
  concatenation of the two child hashes. Odd row → the final hash is duplicated
  (paired with itself) to make the row even.

## Block header (Bitcoin wiki: Block hashing algorithm)

- 80 bytes, all **little-endian**: `version` 4 | `hashPrevBlock` 32 | `hashMerkleRoot`
  32 | `time` 4 | `bits` 4 | `nonce` 4.
- Transactions influence the block hash **only** via the merkle root — "hashing a
  block with 1 transaction takes exactly the same effort as 10,000."
- Block hash = `SHA256d(header)`. Internal/consensus form is little-endian; explorers
  display big-endian (reversed). Same reversal applies to txids/merkle root display.

## Merged-mining tag (Bitcoin wiki: Merged mining spec)

- Magic `0xfabe6d6d` (bytes `fa be 6d 6d` = "\xfa\xbe" + "mm"), placed as exactly one
  header inside the parent coinbase scriptSig. Structure (44 bytes): Magic 4 +
  AuxBlockHash 32 + MerkleSize 4 + MerkleNonce 4.

## Reconstruction algorithm (from SV2 job parts)

1. `coinbase_tx = coinbase_tx_prefix ‖ extranonce_prefix ‖ extranonce ‖ coinbase_tx_suffix`
   (legacy/non-witness serialization — no segwit marker/flag, no witness stanza).
2. `coinbase_txid = SHA256d(coinbase_tx)` (internal LE, not reversed).
3. Fold: `h = coinbase_txid; for e in merkle_path: h = SHA256d(h ‖ e)` — coinbase is
   always the left operand (index 0). Odd-node duplication is already baked into what
   the pool put in `merkle_path`.
4. Result = block merkle root → header bytes 36–67.

**Byte-ordering cheatsheet:** header ints + merkle root are LE internally; explorers/
txids shown byte-reversed. txid = SHA256d(legacy tx); wtxid = SHA256d(witness tx);
coinbase wtxid defined as all-zero.
