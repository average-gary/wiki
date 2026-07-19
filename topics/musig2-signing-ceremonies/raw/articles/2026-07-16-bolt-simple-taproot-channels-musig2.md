---
title: "BOLT: Simple Taproot Channels (MuSig2 nonce/partial-sig framing)"
source: "https://github.com/lightning/bolts/blob/master/bolt-simple-taproot.md"
type: articles
ingested: 2026-07-16
tags: [lightning, simple-taproot-channels, musig2, tlv, nonce-piggybacking, partial-signature-with-nonce, next-local-nonce, stateless-nonce, shachain, channel-reestablish, wire-protocol]
summary: "The Lightning Simple Taproot Channels extension BOLT (PR #995, feature bits 80/81). MuSig2 is used for the 2-of-2 funding output; nonces and partial signatures are piggybacked into existing channel messages via TLV fields (next_local_nonce, partial_signature_with_nonce, next_local_nonces map) with no new round trips. Secret nonces are regenerated deterministically from the revocation shachain rather than persisted, and recovered on reconnect via channel_reestablish."
---

# BOLT: Simple Taproot Channels — MuSig2 on the wire

Extension BOLT (from lightning/bolts PR #995; merged as an extension BOLT per Optech #404, May 2026; feature bits **80/81**). The single most concrete real-world example of MuSig2 folded into a running wire protocol.

## Funding output

`combined_funding_key = musig2.KeyAgg(musig2.KeySort(pubkey1, pubkey2))`; a P2TR key-path output `OP_1 <funding_key>` with a **BIP-86 tweak to disable the script-path spend**. Cooperative spends look like ordinary single-key Taproot spends (a 64-byte Schnorr signature).

## Nonce-carrying TLVs (piggybacked into existing messages — no new rounds)

- `open_channel` / `accept_channel`: TLV **type 4** `next_local_nonce` (66 B) — each peer's Round-1 public nonce for the first commitment.
- `funding_created` / `funding_signed`: TLV **type 2** `partial_signature_with_nonce` (98 B = 32-byte partial sig ‖ 66-byte public nonce).
- `channel_ready`: TLV **type 4** `next_local_nonce` (66 B) — fresh nonce for the first post-confirmation commitment.
- `commitment_signed`: TLV **type 2** `partial_signature_with_nonce` (98 B); the legacy non-TLV signature field is set to 64 zero bytes; HTLC sigs remain full 64-byte Schnorr (not MuSig2 partials).
- `revoke_and_ack` and `channel_reestablish`: TLV **type 22** `next_local_nonces` (variable) — a **map from `funding_txid` to a 66-byte public nonce**, one entry per active commitment (supports splicing / multiple funding txs and reconnection recovery).

## Stateless nonce regeneration (avoids persisting secret nonces)

Nonces derive deterministically from the revocation shachain — but keyed so each commitment height gets a *distinct* nonce, which sidesteps the reuse hazard of persisting a secret nonce:

- `shachain_root_hash = sha256(shachain_root)`
- `musig2_shachain_root = hmac("taproot-rev-root" ‖ funding_txid, shachain_root_hash)`
- commitment height N uses the Nth shachain leaf preimage as the `rand'` input to `musig2.NonceGen`.

Nonces are ephemeral and discarded on disconnect; they are recovered via `channel_reestablish` on reconnection.

## What this source contributes

Exact TLV type numbers, byte lengths, and message placements showing how MuSig2's two rounds are carried without adding round trips, plus a concrete deterministic-nonce-regeneration scheme that resolves the "persist the secret nonce" state-machine pitfall — the applied counterpart to BIP-327's abstract session model.
