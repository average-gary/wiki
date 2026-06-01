---
title: "SV2 Noise Handshake"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-noise-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-noise-sv2-benches.md
  - raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-readme.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, noise-sv2, noise-protocol, aes-gcm, chacha20-poly1305, security, no-std]
aliases: ["noise_sv2", "Sv2 Noise", "Noise initiator", "Noise responder"]
confidence: high
volatility: cold
verified: 2026-05-28
summary: "`noise_sv2` implements the Noise-protocol handshake and AEAD transport that SV2 uses for encryption and authentication between roles. AES-GCM and ChaCha20-Poly1305 ciphers, Initiator/Responder roles, no_std-compatible. Driven by `codec_sv2` once the `noise_sv2` feature is enabled."
---

# SV2 Noise Handshake

> SV2 secures role-to-role communication with the [Noise protocol](http://noiseprotocol.org/). `noise_sv2` is the SRI crate that implements the handshake states, the AEAD transport, and the cryptographic helpers that [[sv2-codec|`codec_sv2`]] ([codec_sv2](sv2-codec.md)) uses when its `noise_sv2` feature is on. The normative spec is the [SV2 Protocol Security spec](https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md).

## Capabilities

Per the README:

- **Secure communication** — encryption and authentication for messages exchanged between SV2 roles.
- **Cipher support** — both `AES-GCM` and `ChaCha20-Poly1305`.
- **Handshake roles** — `Initiator` and `Responder` are explicit types; both sides of a connection drive their half of the Noise handshake.
- **Cryptographic helpers** — manage handshake state and per-message encrypt/decrypt operations.

The crate is `no_std`-compatible (build with `--no-default-features` to drop `std`).

## Handshake structure

The Noise handshake establishes shared transport keys via a small fixed sequence of EllSwift key-exchange messages. The codec-side benchmarks expose the steps explicitly:

- `noise/handshake/step_0` — Initiator generates the first EllSwift key-exchange message.
- `noise/handshake/step_1` — Responder processes step 0 and generates its response.
- `noise/handshake/complete` (in `codec_sv2`'s `encoder.rs` bench) — full 3-step handshake under the encoder API.

The `noise/encode_only` and `noise/roundtrip` benches measure transport-mode AEAD cost after the handshake is established (`encode_only` with a persistent session, `roundtrip` with a fresh session each iteration to defeat state reuse).

## Frame integration

`framing_sv2` ships a separate "Noise Handshake Framing" path, used during the handshake when transport keys do not exist yet. After the handshake completes, the same `Sv2Frame` framing is used for application messages, with `codec_sv2` interposing AEAD encrypt/decrypt around payloads — this is what the codec README means by "abstracts the complexity of message encoding/decoding with optional Noise protocol support."

## Example

The crate ships a [Noise Handshake Example](https://github.com/stratum-mining/stratum/blob/main/protocols/v2/noise-sv2/examples/handshake.rs) that establishes a secure line between an Initiator and Responder and then encrypts/decrypts a message.

## Benchmarks

Criterion benches under `benches/` cover:

- `handshake.rs` — handshake performance (per-step costs).
- `roundtrip.rs` — encrypted message roundtrips after handshake.

Results are explicitly intended for regression tracking and relative comparison; they are not absolute performance claims.

## See Also

- [[sv2-codec|SV2 Codec]] ([SV2 Codec](sv2-codec.md)) — drives the handshake and toggles transport-mode AEAD via the `noise_sv2` feature
- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — provides the dedicated handshake-framing path
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `noise_sv2`

## Sources

- [noise_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-noise-sv2-readme.md) — capabilities, ciphers, role types
- [noise_sv2 BENCHES](../../raw/articles/2026-05-28-stratum-sri-sv2-noise-sv2-benches.md) — bench scope (handshake, roundtrip)
- [codec_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-codec-sv2-readme.md) — handshake state and the `noise_sv2` feature gate
