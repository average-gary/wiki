---
title: "BIP-341 / BIP-342 — Taproot & Tapscript sighash baseline (for APO comparison)"
source: "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki"
type: articles
ingested: 2026-07-16
tags: [bip-341, bip-342, taproot, tapscript, sighash, sigmsg, anyonecanpay, tapleaf-hash, key-version, baseline]
summary: "The BIP-341 Taproot SigMsg field layout and BIP-342 Tapscript extension that BIP-118 is defined as a delta on. Documents the exact fields (sha_prevouts/amounts/scriptpubkeys/sequences, per-input outpoint/amount/scriptPubKey/nSequence under ANYONECANPAY, sha_outputs, spend_type, tapleaf_hash, key_version=0x00, codesep_pos) so APO's omissions can be stated precisely."
---

# BIP-341 / BIP-342 — Taproot & Tapscript sighash baseline

BIP-118 is defined as a *delta* on the BIP-341/342 signature message (`SigMsg`), so
this is the essential companion reference.

## BIP-341 SigMsg field order/sizes

- **Control**: `hash_type` (1)
- **Transaction**: `nVersion` (4), `nLockTime` (4)
- **If NOT ANYONECANPAY**: `sha_prevouts` (32), `sha_amounts` (32),
  `sha_scriptpubkeys` (32), `sha_sequences` (32) — hashes over ALL inputs
- **If NOT NONE/SINGLE**: `sha_outputs` (32)
- `spend_type` (1) = `(ext_flag * 2) + annex_present`
- **If ANYONECANPAY**: this input's `outpoint` (36), `amount` (8), `scriptPubKey`
  (35), `nSequence` (4). **If NOT ANYONECANPAY**: `input_index` (4) instead.
- **If annex present**: `sha_annex` (32). **If SINGLE**: `sha_single_output` (32).

Digest = `hashTapSighash(0x00 || SigMsg(...))`; the leading `0x00` is the **sighash
epoch**. Key-path spends use an implied `key_version = 0x00`.

**Key point for APO**: ANYONECANPAY is what swaps the four all-input `sha_*` hashes
for this-input `outpoint/amount/scriptPubKey/nSequence`. BIP-118's APO then further
strips `outpoint` from that per-input set; APOAS also strips `amount`, `scriptPubKey`,
and `tapleaf_hash`.

## BIP-342 Tapscript extension

For tapscript spends (`ext_flag = 1`), the common message is extended with three
fields:
- `tapleaf_hash` (32) — the BIP-341 leaf hash committing to leaf version + script
- `key_version` (1) = `0x00` (BIP-118 overrides this to `0x01`)
- `codesep_pos` (4) — position of last executed `OP_CODESEPARATOR`

BIP-118 reuses this extension but overrides `key_version` to `0x01` and (for APOAS)
drops `tapleaf_hash`. So "omitting the tapscript" in APOAS means dropping the
`tapleaf_hash` commitment.
