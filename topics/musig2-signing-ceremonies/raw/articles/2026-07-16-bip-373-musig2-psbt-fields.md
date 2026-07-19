---
title: "BIP-373: MuSig2 PSBT Fields"
source: "https://github.com/bitcoin/bips/blob/master/bip-0373.mediawiki"
type: articles
ingested: 2026-07-16
tags: [bip-373, psbt, musig2, session-framing, pub-nonce, partial-sig, participant-pubkeys, hardware-wallet, coordinator]
summary: "Normative BIP defining per-input PSBT key types that carry MuSig2 ceremony state inside a shared PSBT: PSBT_IN_MUSIG2_PARTICIPANT_PUBKEYS (0x1a), PSBT_IN_MUSIG2_PUB_NONCE (0x1b), PSBT_IN_MUSIG2_PARTIAL_SIG (0x1c), plus PSBT_OUT_MUSIG2_PARTICIPANT_PUBKEYS (0x08). The PSBT itself is the session container passed between coordinator and signing devices; session correlation is the (participant pubkey, aggregate pubkey, tapleaf) tuple."
---

# BIP-373: MuSig2 PSBT Fields

Defines how a MuSig2 ceremony is framed for transport as a shared **PSBT** (Partially Signed Bitcoin Transaction) passed among a coordinator and signing devices/wallets — the "wire" is the PSBT itself.

## Per-input key types

- **`PSBT_IN_MUSIG2_PARTICIPANT_PUBKEYS`** (type `0x1a`): key data = 33-byte aggregate pubkey; value = ordered list of 33-byte participant pubkeys (this defines the aggregation order).
- **`PSBT_IN_MUSIG2_PUB_NONCE`** (type `0x1b`): key data = 33-byte participant pubkey ‖ 33-byte aggregate pubkey ‖ optional 32-byte tapleaf hash; value = 66-byte public nonce (Round 1 output of `NonceGen`).
- **`PSBT_IN_MUSIG2_PARTIAL_SIG`** (type `0x1c`): same key-data structure; value = 32-byte partial signature (Round 2 output of `Sign`).

## Per-output key type

- **`PSBT_OUT_MUSIG2_PARTICIPANT_PUBKEYS`** (type `0x08`): for change detection on receiving outputs.

## Session model / framing

- Session correlation is **implicit** in the tuple **(participant pubkey, aggregate pubkey, tapleaf)** inside a single PSBT — the PSBT is the session container.
- The two rounds are explicit: Round 1, each signer appends a `PUB_NONCE` field; after `NonceAgg`, Round 2, each signer appends a `PARTIAL_SIG` field; a final signer runs `PartialSigAgg` to produce the BIP-340 signature.

## What this source contributes

The normative source for how MuSig2 ceremonies are framed for hardware-wallet / coordinator-app transport: exact key types, byte layouts, and the PSBT-as-session-container model. Contrasts with the streaming/message-piggyback framing used in Lightning.
