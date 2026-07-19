---
title: "BOLT #2: Interactive Transaction Construction Protocol"
source: "https://github.com/lightning/bolts/blob/master/02-peer-protocol.md"
type: articles
ingested: 2026-07-16
tags: [lightning, bolt-2, interactive-tx, dual-funding, session-framing, serial-id, tx-add-input, tx-complete, turn-taking, wire-protocol]
summary: "The Lightning BOLT #2 interactive transaction construction protocol (dual funding). Two peers build a shared transaction by exchanging tx_add_input/tx_add_output/tx_remove_*/tx_complete messages. The session is keyed by channel_id; turn-taking uses even/odd serial_ids; the negotiation terminates when both peers send consecutive tx_complete. The canonical wire-protocol exemplar of an interactive multi-party ceremony (no central coordinator)."
---

# BOLT #2: Interactive Transaction Construction Protocol

The Lightning dual-funding / interactive-tx protocol: two peers cooperatively build a single transaction over the wire. This is the closest normative exemplar of *session framing* for an interactive multi-party ceremony, and the transport into which MuSig2 nonce/partial-sig exchange is folded for taproot channels (see the Simple Taproot Channels source).

## Messages

- **`tx_add_input`** (type 66): fields `channel_id`, `serial_id`, `prevtx_len`, `prevtx`, `prevtx_vout`, `sequence`.
- **`tx_add_output`** (type 67): `channel_id`, `serial_id`, `sats`, `scriptlen`, `script`.
- **`tx_remove_input`** / **`tx_remove_output`** (types 68 / 69): `channel_id` + `serial_id`.
- **`tx_complete`** (type 70): `channel_id` only.

## Session identification & coordination

- **Session ID**: the exchange is keyed by `channel_id` (or `temporary_channel_id` pre-funding).
- **Topology**: turn-based full-mesh between the *two* peers — no central coordinator.
- **Turn-taking / ordering**: the initiator uses **even** `serial_id` values; the non-initiator uses **odd** `serial_id`. Inputs and outputs in the final transaction MUST be sorted by `serial_id`, giving both peers a deterministic, identical transaction.
- **Termination / round sync**: negotiation continues until **both** nodes have sent and received a consecutive `tx_complete`; each then independently constructs the transaction and fails if any discrepancy is found.

## What this source contributes

A concrete, normative model of how an interactive multi-party ceremony is framed on the wire: explicit session ID, deterministic ordering via serial numbers, turn-taking, and a two-sided completion handshake. This is the framing skeleton that taproot-channel MuSig2 nonce exchange is layered onto.
