---
title: "ANYPREVOUT sighash semantics (APO vs APOAS)"
category: concept
sources:
  - raw/articles/2026-07-16-bip-118-anyprevout-spec.md
  - raw/articles/2026-07-16-bip-341-342-taproot-sighash-baseline.md
  - raw/articles/2026-07-16-optech-anyprevout-topic.md
  - raw/articles/2026-07-16-cointelegraph-covenants-part3-anyprevout.md
created: 2026-07-16
updated: 2026-07-16
tags: [bip-118, anyprevout, apo, apoas, sighash, taproot, tapscript, key-version, flag-bytes]
aliases: [APO semantics, APOAS, SIGHASH_ANYPREVOUT, SIGHASH_ANYPREVOUTANYSCRIPT, 0x41, 0xc3]
confidence: high
volatility: cold
verified: 2026-07-16
summary: "Exactly what SIGHASH_ANYPREVOUT (APO, 0x40) and SIGHASH_ANYPREVOUTANYSCRIPT (APOAS, 0xc0) omit from the Taproot signature message: APO drops only the outpoint (still commits to amount + scriptPubKey); APOAS drops outpoint + amount + scriptPubKey + tapleaf_hash. Covers flag bytes, the valid hash_type set, the 0x01 pubkey-prefix opt-in, key_version=0x01 domain separation, and the tapscript-only restriction."
---

# ANYPREVOUT sighash semantics (APO vs APOAS)

> BIP-118 adds two Taproot **tapscript-only** signature-hash modes that let a signature
> omit its commitment to *which* output is being spent. **Plain APO drops only the
> `outpoint`** (it still commits to the input's amount and scriptPubKey); **APOAS
> additionally drops the amount, scriptPubKey, and the tapleaf script.** This is the
> precise mechanism behind [[rebindable-signatures|rebindable signatures]] ([rebindable signatures](rebindable-signatures.md)).

## Baseline: the BIP-341/342 signature message

BIP-118 is defined as a *delta* on the Taproot signature message (`SigMsg`), so the
semantics only make sense against that baseline. The BIP-341 message commits (among
other fields) to `nVersion`, `nLockTime`, per-input or all-input prevout/amount/
scriptPubKey/sequence data, the outputs (`sha_outputs`), `spend_type`, and — for
tapscript spends (BIP-342) — `tapleaf_hash`, `key_version` (normally `0x00`), and
`codesep_pos`. Crucially, `SIGHASH_ANYONECANPAY (0x80)` swaps the four *all-input*
`sha_*` hashes for **this input's own** `outpoint (36)`, `amount (8)`,
`scriptPubKey (35)`, and `nSequence (4)`. APO builds directly on that ANYONECANPAY
form.

## The two flags (exact bytes)

- `SIGHASH_ANYPREVOUT = 0x40` (bit 6)
- `SIGHASH_ANYPREVOUTANYSCRIPT = 0xc0` (bits 6+7; note `0xc0 = 0x40 | 0x80` — the
  ANYPREVOUT bit combined with the ANYONECANPAY bit).

Like ANYONECANPAY, these are never used alone. They are OR'd onto a base output mode
(`ALL=0x01`, `NONE=0x02`, `SINGLE=0x03`; `0x00` = DEFAULT ≈ ALL):

| Byte | Meaning |
|------|---------|
| `0x41 / 0x42 / 0x43` | ANYPREVOUT + ALL / NONE / SINGLE |
| `0xc1 / 0xc2 / 0xc3` | ANYPREVOUTANYSCRIPT + ALL / NONE / SINGLE |
| `0x00–0x03`, `0x81–0x83` | ordinary Taproot / ANYONECANPAY modes |

The complete set of valid `hash_type` bytes for a BIP-118 key is exactly: `0x00, 0x01,
0x02, 0x03, 0x41, 0x42, 0x43, 0x81, 0x82, 0x83, 0xc1, 0xc2, 0xc3`. `0x40` and `0xc0`
alone are invalid.

## What each mode omits (the load-bearing distinction)

Both are computed "as if `SIGHASH_ANYONECANPAY` was set," then remove more:

- **`SIGHASH_ANYPREVOUT` (0x40)** — removes **only the `outpoint`** (the 36-byte
  txid:vout). It **still commits to** the input's **`amount` and `scriptPubKey`** and
  its `nSequence`. → A signature can rebind to any UTXO with the *same script and same
  value*.
- **`SIGHASH_ANYPREVOUTANYSCRIPT` (0xc0)** — removes the `outpoint` **and** the
  `amount`, `scriptPubKey`, **and `tapleaf_hash`**. → A signature can rebind to any
  UTXO of *any* value and *any* script, so long as spending is authorized by the same
  key.

> **Common misconception (worth stating explicitly):** plain APO does **not** omit
> amount or scriptPubKey. Omitting the amount (and script, and tapleaf) is the
> distinguishing feature of **APOAS**. The BIP rationale: "Committing to the input
> value may provide additional safety that a signature can't be maliciously reused to
> claim funds that the signer does not intend to spend." APOAS drops it precisely to
> allow "a single signature to consolidate a group of UTXOs with the same spending
> condition into a single UTXO."

Fields committed in *all* BIP-118 cases: `nVersion`, `nLockTime`, `spend_type`,
`key_version = 0x01`, `codesep_pos`, the input's `nSequence`, and `sha_outputs` per
the ALL/NONE/SINGLE base bits. The digest is still
`hashTapSighash(0x00 || SigMsg || ext)` (the `0x00` sighash epoch is unchanged).

## The 0x01 pubkey-prefix opt-in

APO is not automatically available to every Taproot key. Inside a tapleaf, a "BIP-118
public key" is either the single byte `0x01` (meaning "use the taproot internal key")
or 33 bytes = `0x01` + a 32-byte x-only BIP-340 key. To verify, the `0x01` is stripped
and the remaining 32 bytes are used as a normal BIP-340 key. Ordinary BIP-342 keys use
a `0x00`-version convention.

The signature message sets **`key_version = 0x01`** (instead of `0x00`) in all BIP-118
cases. This **domain-separates** BIP-118 signatures from ordinary tapscript
signatures — a signature for one is never valid for the other — and lets addresses
"opt-in or opt-out of ANYPREVOUT support while remaining indistinguishable prior to
being spent."

## Tapscript-only

APO/APOAS signatures work **only via script-path spends**, never key-path spends. This
keeps the proposal independent of the BIP-341/342 core, preserves address privacy, and
confines the [[signature-replay-and-chaperone-signatures|replay]] ([replay](signature-replay-and-chaperone-signatures.md))
blast radius (a plain key-path spend can never be replayed).

## See Also

- [[rebindable-signatures|Rebindable signatures]] ([Rebindable signatures](rebindable-signatures.md)) — the capability these semantics create
- [[signature-replay-and-chaperone-signatures|Signature replay & chaperone signatures]] ([Signature replay & chaperone signatures](signature-replay-and-chaperone-signatures.md)) — the risk created by omitting the outpoint
- [[covenant-primitives-comparison|Covenant primitives comparison]] ([Covenant primitives comparison](../references/covenant-primitives-comparison.md)) — APO vs CTV vs ANYONECANPAY vs CSFS
- [[coinbase-outpoint-presigning|Presigning against an unmined coinbase outpoint]] ([Presigning against an unmined coinbase outpoint](../topics/coinbase-outpoint-presigning.md)) — where APO-vs-APOAS becomes decisive

## Sources

- [BIP-118 normative spec](../../raw/articles/2026-07-16-bip-118-anyprevout-spec.md) — flag bytes, omission rules, 0x01 prefix, key_version
- [BIP-341/342 sighash baseline](../../raw/articles/2026-07-16-bip-341-342-taproot-sighash-baseline.md) — the message layout APO modifies
- [Optech — SIGHASH_ANYPREVOUT](../../raw/articles/2026-07-16-optech-anyprevout-topic.md) — rebindable-signatures framing, naming history
- [Cointelegraph — Covenants Part 3](../../raw/articles/2026-07-16-cointelegraph-covenants-part3-anyprevout.md) — confirms amount/script commitment split
