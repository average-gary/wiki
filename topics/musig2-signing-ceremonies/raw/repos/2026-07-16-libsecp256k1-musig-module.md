---
title: "libsecp256k1 / secp256k1-zkp MuSig2 module (secp256k1_musig.h)"
source: "https://github.com/bitcoin-core/secp256k1/blob/master/include/secp256k1_musig.h"
type: repos
ingested: 2026-07-16
tags: [libsecp256k1, secp256k1-zkp, musig2, reference-implementation, c-api, secnonce, nonce-reuse-guard, zeroize, session, experimental]
summary: "The canonical C reference implementation of BIP-327 MuSig2, present in both bitcoin-core/secp256k1 and BlockstreamResearch/secp256k1-zkp. Exposes the two-round API (pubkey_agg → nonce_gen → nonce_agg → nonce_process → partial_sign → partial_sig_agg) plus verification. Enforces nonce-reuse safety at the API/struct level: the secnonce MUST NOT be copied/serialized, partial_sign zeroizes it and aborts on an all-zero secnonce, and each nonce_gen needs unique session randomness. Still gated as an experimental feature."
---

# libsecp256k1 / secp256k1-zkp MuSig2 module

The canonical C reference implementation of **BIP-327**. The MuSig2 module lives in both `bitcoin-core/secp256k1` and Blockstream's `secp256k1-zkp` fork; the header explicitly states it implements "BIP 327 MuSig2 for BIP340-compatible Multi-Signatures". At the repository level the module is still built behind `--enable-experimental` ("APIs should not be considered stable"), even though the header presents a finalized BIP-327 v1.0.0 implementation.

## Opaque data types (in-memory struct sizes; differ from BIP wire sizes)

`secp256k1_musig_keyagg_cache` (197 B), `secp256k1_musig_secnonce` (132 B), `secp256k1_musig_pubnonce` (132 B), `secp256k1_musig_aggnonce` (132 B), `secp256k1_musig_session` (133 B), `secp256k1_musig_partial_sig` (36 B).

## API flow (maps one-to-one onto BIP-327 algorithms)

- **Key agg / tweak**: `secp256k1_musig_pubkey_agg` (aggregate key + init keyagg_cache), `secp256k1_musig_pubkey_ec_tweak_add` (plain BIP32 tweak), `secp256k1_musig_pubkey_xonly_tweak_add` (x-only BIP341/Taproot tweak).
- **Round 1**: `secp256k1_musig_nonce_gen` (secnonce + pubnonce from fresh `session_secrand32`), `secp256k1_musig_nonce_agg`.
- **Round 2**: `secp256k1_musig_nonce_process` (build session from aggnonce + message), `secp256k1_musig_partial_sign`, `secp256k1_musig_partial_sig_agg`. Verification: `secp256k1_musig_partial_sig_verify`.
- A `nonce_gen_counter` variant exists; its doc warns "you must never call ... twice with the same keypair and nonrepeating_cnt value."

## Nonce-reuse guardrails (quoted)

- `secp256k1_musig_secnonce`: *"WARNING: This structure MUST NOT be copied or read or written to directly"* and *"Copying this data structure can result in nonce reuse which will leak the secret signing key."*
- `secp256k1_musig_partial_sign` *"overwrites the given secnonce with zeros and will abort if given a secnonce that is all zeros. This is a best effort attempt to protect against nonce reuse."*
- `nonce_gen`: *"Avoid copying (or serializing) the secnonce. This reduces the possibility that it is used more than once for signing"*; *"Remember that nonce reuse will leak the secret key!"* Each call needs a UNIQUE `session_secrand32` that must not be reused.
- Signers should verify that `keyagg_cache`, `pubnonce`, and `pubkey` match their session to prevent cross-session forgery.

## What this source contributes

The reference C API most wallets/nodes link against, mapping the BIP algorithms to a concrete function/type-per-step session model, plus the exact API-level enforcement (zeroize-on-sign, no-copy secnonce struct, unique session randomness) behind BIP-327's non-reuse rule.
