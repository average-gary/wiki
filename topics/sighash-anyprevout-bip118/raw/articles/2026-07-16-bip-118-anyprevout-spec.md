---
title: "BIP-118: SIGHASH_ANYPREVOUT for Taproot Scripts (normative spec)"
source: "https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki"
type: articles
ingested: 2026-07-16
tags: [bip-118, anyprevout, apo, apoas, sighash, taproot, tapscript, signature-replay, decker, ajtowns, specification]
summary: "The normative BIP-118 specification (Christian Decker, Anthony Towns; Status: Draft; Consensus soft fork). Defines SIGHASH_ANYPREVOUT (0x40) and SIGHASH_ANYPREVOUTANYSCRIPT (0xc0), the 0x01 pubkey-prefix opt-in, tapscript-only restriction, exact sighash omission rules, key_version=0x01 domain separation, and the designed-in signature-replay tradeoff."
---

# BIP-118: SIGHASH_ANYPREVOUT for Taproot Scripts

- **Authors**: Christian Decker, Anthony Towns
- **Status**: Draft. **Layer/Type**: Consensus (soft fork). Builds on BIP-340/341/342.
- **Created**: 2017-02-28. Deployment section is "TODO" (not activated on mainnet).
- **History**: Original "NOINPUT" concept first proposed by Joseph Poon (Feb 2016).
  Renamed NOINPUT → ANYPREVOUT and rebased onto Taproot (tapscript-only) via BIP PR
  #943 in July 2021, because signatures still commit to *some* input fields.

## The two flags (exact byte values)

- `SIGHASH_ANYPREVOUT = 0x40` (bit 6)
- `SIGHASH_ANYPREVOUTANYSCRIPT = 0xc0` (bits 6+7; `0xc0 = 0x40 | 0x80`, i.e. the
  ANYPREVOUT bit combined with the ANYONECANPAY bit).

Like `SIGHASH_ANYONECANPAY (0x80)`, these are never used alone — they are OR'd onto a
base output mode: `SIGHASH_ALL=0x01`, `SIGHASH_NONE=0x02`, `SIGHASH_SINGLE=0x03`
(`0x00` = SIGHASH_DEFAULT ≈ ALL). Thus:
- `0x41/0x42/0x43` = ANYPREVOUT + ALL / NONE / SINGLE
- `0xc1/0xc2/0xc3` = ANYPREVOUTANYSCRIPT + ALL / NONE / SINGLE

**Complete set of valid `hash_type` bytes for a BIP-118 key**: `0x00, 0x01, 0x02,
0x03, 0x41, 0x42, 0x43, 0x81, 0x82, 0x83, 0xc1, 0xc2, 0xc3`. `0x40` and `0xc0` alone
are NOT valid.

## Exact omission rules (verbatim from spec)

- **`SIGHASH_ANYPREVOUT`**: "the digest is calculated as if `SIGHASH_ANYONECANPAY`
  was set, except `outpoint` is not included in the digest." → It **still commits to**
  this input's **`amount` (8 bytes) and `scriptPubKey`** and its **`nSequence`**;
  only the 36-byte `outpoint` (txid:vout) is dropped.
- **`SIGHASH_ANYPREVOUTANYSCRIPT`**: "the digest is calculated as if
  `SIGHASH_ANYONECANPAY` was set, except `outpoint`, `amount`, `scriptPubKey` and
  `tapleaf_hash` are not included in the digest." → Commits to neither value, script,
  nor the executing tapscript.

> **Common misconception corrected**: plain APO does **NOT** omit amount or
> scriptPubKey. It omits *only* the outpoint. Omitting amount + scriptPubKey + tapleaf
> is the distinguishing feature of **APOAS**.

Because both are computed "as if ANYONECANPAY," the message uses this input's own
single-input `amount`/`scriptPubKey` fields (36/8/35-byte per-input data), not the
aggregated `sha_amounts`/`sha_scriptpubkeys` arrays used by SIGHASH_ALL.

## Fields committed in ALL BIP-118 cases

`nVersion`, `nLockTime`, `spend_type`, `key_version = 0x01`, `codesep_pos`, this
input's `nSequence`, and `hashOutputs/sha_outputs` per the ALL/NONE/SINGLE base bits.
Digest = `hashTapSighash(0x00 || SigMsg || ext)` (the `0x00` sighash epoch is
unchanged from BIP-341).

## The 0x01 pubkey-prefix opt-in

A "BIP-118 public key" inside a tapleaf is either the single byte `0x01` (= "use the
taproot internal key") or 33 bytes = `0x01` + 32-byte x-only BIP-340 key. To verify,
strip the `0x01` and use the remaining 32 bytes as a normal BIP-340 key. Ordinary
BIP-342 keys use a `0x00`-version convention. **`key_version` is set to `0x01`** (vs
`0x00`) in all BIP-118 cases — this domain-separates BIP-118 signatures from ordinary
BIP-342 tapscript signatures, so a signature for one is never valid for the other.

This lets addresses "opt-in or opt-out of ANYPREVOUT support while remaining
indistinguishable prior to being spent" (privacy-preserving scoping).

## Tapscript-only

Verbatim: "This proposal only supports ANYPREVOUT signatures via script path spends,
and does not support ANYPREVOUT signatures for key path spends." Rationale: keeps it
independent of BIP-341/342 core changes, preserves address privacy, and confines the
replay blast radius (a key-path spend can never be replayed).

## Rebinding rationale (verbatim)

"Removing this commitment allows dynamic rebinding of a signed transaction to another
previous output that requires authorisation by the same key." On committing to the
amount: "Committing to the input value may provide additional safety that a signature
can't be maliciously reused to claim funds that the signer does not intend to spend,
so by default it seems sensible to commit to it." APOAS drops it to allow "a single
signature to consolidate a group of UTXOs with the same spending condition into a
single UTXO."

## Signature replay (designed-in tradeoff, verbatim)

"By design, `SIGHASH_ANYPREVOUT` and `SIGHASH_ANYPREVOUTANYSCRIPT` introduce
additional potential for signature replay … when compared to `SIGHASH_ALL`." Replay
is possible for ANYPREVOUT against "different UTXOs with the same `scriptPubKey` and
the same value"; for ANYPREVOUTANYSCRIPT against "any UTXOs that reuse the same BIP
118 public key." Implementers "must ensure keys are only reused where replay cannot
cause fund loss." **Chaperone signatures** were considered and **dropped** — no
chaperone requirement in the final spec.
