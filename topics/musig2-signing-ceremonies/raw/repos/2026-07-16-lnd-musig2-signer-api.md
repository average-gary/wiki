---
title: "LND MuSig2 Signer API (signrpc)"
source: "https://github.com/lightningnetwork/lnd/blob/master/docs/musig2.md"
type: repos
ingested: 2026-07-16
tags: [lnd, musig2, signer-rpc, session-id, create-session, register-nonces, sign, combine-sig, coordinator, deployed-implementation, experimental]
summary: "LND's Signer-subserver MuSig2 RPC surface: MuSig2CombineKeys, MuSig2CreateSession, MuSig2RegisterNonces, MuSig2Sign, MuSig2CombineSig. The session_id (bytes) is the correlation handle threaded through every call. have_all_nonces gates the Round-1 → Round-2 transition; MuSig2Sign may be called only once per session_id (nonce-reuse guard). Supports protocol v0.4.0 (x-only) and v1.0.0rc2 (compressed). Flagged HIGHLY EXPERIMENTAL."
---

# LND MuSig2 Signer API (signrpc)

LND exposes MuSig2 as a concrete deployed RPC ceremony in its `signrpc` subserver (available since v0.15-beta; version argument mandatory from v0.16+).

## RPC call sequence

1. **`MuSig2CombineKeys`** — stateless helper to compute the aggregate key from all participant pubkeys.
2. **`MuSig2CreateSession`** — request: `key_loc`, `all_signer_pubkeys`, optional `other_signer_public_nonces`, `tweaks`, `taproot_tweak`, `version`, optional `pregenerated_local_nonce` (97 B). Response: `session_id`, `combined_key`, `taproot_internal_key`, `local_public_nonces` (two nonces packed into 66 B), `have_all_nonces`.
3. **`MuSig2RegisterNonces`** — request: `session_id` + `other_signer_public_nonces[]`; response: `have_all_nonces`. This is Round 1; callable repeatedly as peers' nonces arrive.
4. **`MuSig2Sign`** — produces the local partial signature; **may only be called once per `session_id`** (nonce-reuse protection).
5. **`MuSig2CombineSig`** — combines partial sig(s) with the local one into the final BIP-340 Schnorr signature.

## Session framing & topology

- **`session_id`** (bytes) is the correlation handle threaded through every subsequent RPC; the protocol version is inferred from the session.
- **Topology**: interactive n-of-n; the caller acts as one signer that collects other signers' 66-byte public nonces (Round 1) before signing (Round 2). The `have_all_nonces` flag gates the round transition.
- **Versions**: v0.4.0 (shipped in lnd 0.15.x, 32-byte x-only nonces) and v1.0.0rc2 (33-byte compressed). Marked "HIGHLY EXPERIMENTAL" with no backward-compat guarantee until BIP-327 finalized. As of 2025, Lightning Loop defaulted to MuSig2.

## What this source contributes

The ceremony as an actual deployed API: the exact call graph, `session_id` correlation, nonce byte sizes, the `have_all_nonces` round gate, and the single-call-per-session signing guard that a practitioner runs — the RPC-level realization of the BIP-327 session state machine.
