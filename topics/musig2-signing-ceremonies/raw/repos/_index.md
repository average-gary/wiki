# repos Index

Last updated: 2026-07-16

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [libsecp256k1 / secp256k1-zkp MuSig module](2026-07-16-libsecp256k1-musig-module.md) | Canonical C reference impl of BIP-327: pubkey_agg → nonce_gen → nonce_agg → nonce_process → partial_sign → partial_sig_agg, with struct-level nonce-reuse guards (no-copy secnonce, zeroize-on-sign). Experimental feature. | libsecp256k1, secp256k1-zkp, reference-implementation, c-api, nonce-reuse-guard | 2026-07-16 |
| [LND MuSig2 Signer API](2026-07-16-lnd-musig2-signer-api.md) | LND signrpc RPC ceremony: CombineKeys/CreateSession/RegisterNonces/Sign/CombineSig, session_id correlation, have_all_nonces round gate, sign-once-per-session guard. Deployed but experimental. | lnd, signer-rpc, session-id, deployed-implementation | 2026-07-16 |

## Recent Changes

- 2026-07-16: Ingested 2 implementation sources — the libsecp256k1/secp256k1-zkp MuSig2 C module and the LND MuSig2 Signer RPC API.
