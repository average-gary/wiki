---
title: Concepts
type: index
updated: 2026-07-16
---

# Concepts (5)

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [anyprevout-sighash-semantics.md](anyprevout-sighash-semantics.md) | Exact APO (0x40) vs APOAS (0xc0) omissions: APO drops only the outpoint (keeps amount+script); APOAS drops outpoint+amount+script+tapleaf. Flag bytes, valid hash_type set, 0x01 pubkey prefix, key_version=0x01, tapscript-only. | anyprevout, apo, apoas, sighash, taproot | 2026-07-16 |
| [rebindable-signatures.md](rebindable-signatures.md) | The core capability: a signature that omits the prevout can be rebound to any compatible output — binds to a *class* of outputs, not one txid:vout. Powerful (presign before output exists) and dangerous (replay). | rebindable-signatures, floating-transactions, anyprevout, covenant | 2026-07-16 |
| [eltoo-ln-symmetry.md](eltoo-ln-symmetry.md) | APO's flagship motivation: state-number-ordered channel updates replacing LN-Penalty's 'toxic' revocation storage. PoC uses APOAS; pinning is the dominant obstacle. | eltoo, ln-symmetry, lightning, apoas, pinning | 2026-07-16 |
| [signature-replay-and-chaperone-signatures.md](signature-replay-and-chaperone-signatures.md) | The central designed-in risk: replay against outputs with matching fields. Chaperone signatures proposed then dropped; BIP-118 relies on 0x01 opt-in + tapscript scoping. Not a recursive covenant. | signature-replay, chaperone-signatures, anyprevout, footgun | 2026-07-16 |
| [coinbase-maturity-and-unknown-txid.md](coinbase-maturity-and-unknown-txid.md) | Three coinbase properties that define the presigning problem: unknown txid (BIP-34/extranonce/tags), variable value (subsidy+fees), 100-block maturity (inclusion, not signing, constraint). | coinbase-transaction, coinbase-maturity, txid, bip-34, mining-payout | 2026-07-16 |

## Recent Changes

- 2026-07-16: compile — 5 concept articles created.
