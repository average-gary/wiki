---
title: "SV2 Extensions"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-extensions-sv2-readme.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, extensions-sv2, tlv, extensions-negotiation, worker-hashrate]
aliases: ["extensions_sv2", "Sv2 extensions", "TLV"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "`extensions_sv2` is the SV2 extension layer: a generic TLV (Type-Length-Value) encoder/decoder plus two concrete extensions — Extensions Negotiation (0x0001) for capability handshake and Worker-Specific Hashrate Tracking (0x0002) for per-worker hashrate inside `SubmitSharesExtended`."
---

# SV2 Extensions

> SV2's main message types are versioned and stable; capabilities that aren't worth a protocol revision land as **extensions** — opt-in, negotiated, TLV-encoded message additions. `extensions_sv2` is the SRI crate that implements the negotiation message and the generic TLV encode/decode utilities used by individual extensions.

## What's in the crate

Per the README, `extensions_sv2` provides:

- Message types for two concrete extensions:
  - **Extensions Negotiation (`0x0001`)** — negotiates which optional extensions are supported during connection setup.
  - **Worker-Specific Hashrate Tracking (`0x0002`)** — tracks individual worker hashrates using TLV fields in `SubmitSharesExtended`.
- Generic **TLV (Type-Length-Value) encoding/decoding utilities** that any extension requiring structured optional data fields can reuse.

The TLV utilities are the load-bearing part of the crate — they're what new extensions reach for so they don't each invent their own packing scheme.

## Specs

The two extensions in this crate are specified in the SV2 spec repo (not here):

- [extensions-negotiation.md](https://github.com/stratum-mining/sv2-spec/blob/main/extensions/extensions-negotiation.md)
- [worker-specific-hashrate-tracking.md](https://github.com/stratum-mining/sv2-spec/blob/main/extensions/worker-specific-hashrate-tracking.md)

These specs are the source of truth for wire bytes; this crate implements them.

## Position in the framing

`framing_sv2` already reserves the `extension_type` U16 in every SV2 frame header (see [[sv2-framing|SV2 framing]] ([SV2 framing](sv2-framing.md))). The `channel_msg` bit on `extension_type` is a separate field-encoding concern; the rest of the U16 selects which extension owns the message. `extensions_sv2`'s messages are simply the ones whose `extension_type` matches `0x0001` or `0x0002`.

## Where new extensions add up

When the [[sri-pull-request-themes|recent PR series]] ([recent PR series](../references/sri-pull-request-themes.md)) introduces a new error code or a new submitted-share variant, the question of "is this a core mining-protocol change or an extension?" tends to come down to whether downstream roles need the change to interoperate at all (core) or only when they want the new capability (extension). The TLV utilities here are the path of least resistance for the latter.

## See Also

- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — the `extension_type` field framing routes on
- [[sv2-message-handlers|SV2 Message Handlers]] ([SV2 Message Handlers](sv2-message-handlers.md)) — `Extensions` handler dispatches extension messages
- [[sv2-mining-subprotocol|SV2 Mining Subprotocol]] ([SV2 Mining Subprotocol](../topics/sv2-mining-subprotocol.md)) — `SubmitSharesExtended` is where Worker-Specific Hashrate Tracking TLVs live
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `extensions_sv2`

## Sources

- [extensions_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-extensions-sv2-readme.md) — supported extensions and TLV utilities
