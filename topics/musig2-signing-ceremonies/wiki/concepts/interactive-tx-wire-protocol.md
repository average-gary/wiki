---
title: "Interactive Transaction Wire Protocol"
category: concept
sources: [raw/articles/2026-07-16-bolt2-interactive-tx-construction.md, raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md]
created: 2026-07-16
updated: 2026-07-16
tags: [lightning, bolt-2, interactive-tx, dual-funding, serial-id, tx-complete, turn-taking, session-framing, wire-protocol]
aliases: [interactive tx, interactive transaction construction, dual funding protocol]
confidence: high
volatility: warm
verified: 2026-07-16
summary: "The Lightning BOLT #2 interactive transaction construction protocol is the canonical wire-protocol exemplar of an interactive multi-party ceremony. Two peers build a shared transaction via tx_add_input/tx_add_output/tx_complete, keyed by channel_id, with even/odd serial_id turn-taking and a two-sided completion handshake. Simple taproot channels layer MuSig2 nonce/partial-sig exchange onto this skeleton."
---

# Interactive Transaction Wire Protocol

> Lightning's interactive transaction construction protocol (BOLT #2, the dual-funding flow) is worth studying on its own as the clearest normative example of how a real wire protocol frames an interactive multi-party ceremony. It is also the exact transport that MuSig2 signing is folded into for taproot channels, so its framing choices directly shape how those MuSig2 ceremonies run.

## The messages

Two peers cooperatively assemble one transaction by exchanging:

- **`tx_add_input`** (type 66): `channel_id`, `serial_id`, `prevtx_len`, `prevtx`, `prevtx_vout`, `sequence`.
- **`tx_add_output`** (type 67): `channel_id`, `serial_id`, `sats`, `scriptlen`, `script`.
- **`tx_remove_input`** / **`tx_remove_output`** (types 68 / 69): `channel_id` + `serial_id`.
- **`tx_complete`** (type 70): `channel_id` only.

## Framing mechanics worth stealing

- **Session identity**: the exchange is keyed by `channel_id` (or `temporary_channel_id` before funding). Every message names its session.
- **Turn-taking via parity**: the initiator uses **even** `serial_id` values, the non-initiator **odd**. This partitions the identifier space so the two peers never collide and each contribution is unambiguously attributable.
- **Deterministic ordering**: inputs and outputs in the final transaction MUST be sorted by `serial_id`. Both peers therefore construct a **byte-identical transaction** independently, with no central coordinator.
- **Two-sided completion handshake**: negotiation continues until **both** peers have sent and received a consecutive `tx_complete`; each then builds the transaction and fails if it finds any discrepancy.
- **Topology**: two-party full mesh, no coordinator.

## How MuSig2 layers on top

Once the interactive-tx flow has produced an agreed funding transaction with a 2-of-2 MuSig2 Taproot output, the *signing* of commitments over that output is carried by [[session-framing-and-state|piggybacking MuSig2 nonces and partial signatures]] ([piggybacking MuSig2 nonces and partial signatures](session-framing-and-state.md)) as TLV fields on the ongoing channel messages (`open_channel`, `commitment_signed`, `revoke_and_ack`, etc.). The `channel_id` session identity and the reconnection machinery (`channel_reestablish`) established by this base protocol are reused verbatim — the MuSig2 ceremony inherits its session framing from the interactive-tx layer rather than defining its own.

## Why it matters as a model

This protocol demonstrates that a robust interactive ceremony needs only a handful of framing primitives — a named session, an attributable turn-taking scheme, deterministic ordering for a reproducible result, and an explicit two-sided completion signal. Those same primitives reappear (in different clothing) in the [[session-framing-and-state|PSBT and RPC framings]] ([PSBT and RPC framings](session-framing-and-state.md)) of MuSig2.

## See Also

- [[session-framing-and-state|Session Framing and State]] ([Session Framing and State](session-framing-and-state.md)) — the three MuSig2 framing patterns, including TLV piggybacking on this protocol
- [[dropout-abort-and-robustness|Dropout, Abort, and Robustness]] ([Dropout, Abort, and Robustness](dropout-abort-and-robustness.md)) — reconnection and completion handling
- [[musig2-interactive-signing-ceremonies|MuSig2 Interactive Signing Ceremonies]] ([MuSig2 Interactive Signing Ceremonies](../topics/musig2-interactive-signing-ceremonies.md)) — the umbrella topic

## Sources

- [BOLT #2: Interactive Tx Construction](../../raw/articles/2026-07-16-bolt2-interactive-tx-construction.md) — the message set, serial_id turn-taking, and completion handshake
- [BOLT: Simple Taproot Channels (MuSig2)](../../raw/articles/2026-07-16-bolt-simple-taproot-channels-musig2.md) — how MuSig2 reuses this framing
