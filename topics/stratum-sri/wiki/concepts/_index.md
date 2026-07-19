# Concepts Index

Last updated: 2026-07-17

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [SV2 Binary Encoding](sv2-binary-encoding.md) | The `binary_sv2` `no_std` type system, `derive_codec_sv2` proc-macros, and `parsers_sv2` bytes↔Rust-type layer. | sv2, binary-sv2, parsers-sv2, derive-codec-sv2, encoding | 2026-05-28 |
| [SV2 Framing](sv2-framing.md) | The 6-byte SV2 message header (extension_type, msg_type, msg_length) and the `channel_msg` bit. Implemented by `framing_sv2`. | sv2, framing-sv2, framing, header, channel-msg | 2026-05-28 |
| [SV2 Codec](sv2-codec.md) | `codec_sv2` Encoder/Decoder + Noise transport mode + the bench suite around the BufferPool 8-slot exhaustion boundary. | sv2, codec-sv2, encoder, decoder, noise | 2026-05-28 |
| [SV2 Noise Handshake](sv2-noise-handshake.md) | `noise_sv2` Noise-protocol handshake + AEAD transport (AES-GCM, ChaCha20-Poly1305), Initiator/Responder roles. | sv2, noise-sv2, noise-protocol, security | 2026-05-28 |
| [SV2 Buffer Pool](sv2-buffer-pool.md) | `buffer_sv2` Buffer trait + BufferPool back/front/alloc 8-slot state machine + benchmark numbers. | sv2, buffer-sv2, memory, performance | 2026-05-28 |
| [SV2 Channels](sv2-channels.md) | `channels_sv2` standard/extended/group channel state, share accounting, no_std client mode. | sv2, channels-sv2, share-accounting | 2026-05-28 |
| [SV2 Message Handlers](sv2-message-handlers.md) | `handlers_sv2` trait surface: server/client × per-subprotocol, sync + async variants. | sv2, handlers-sv2, traits | 2026-05-28 |
| [SV2 Extensions](sv2-extensions.md) | `extensions_sv2` Extensions Negotiation (0x0001) + Worker-Specific Hashrate Tracking (0x0002) + generic TLV utilities. | sv2, extensions-sv2, tlv | 2026-07-17 |
| [SV2 Extensions Negotiation (0x0001)](sv2-extensions-negotiation.md) | Normative RequestExtensions/.Success/.Error handshake after SetupConnection; positive-ACK resolution of sv2-spec issue #95. | sv2, extension-negotiation, extension-0x0001, request-extensions | 2026-07-17 |

## Categories

- **Wire layer**: sv2-binary-encoding, sv2-framing, sv2-codec, sv2-noise-handshake
- **Memory**: sv2-buffer-pool
- **Mining state**: sv2-channels
- **Application surface**: sv2-message-handlers, sv2-extensions, sv2-extensions-negotiation

## Recent Changes

- 2026-07-17: Added sv2-extensions-negotiation (extension 0x0001 handshake, resolving sv2-spec issue #95); updated sv2-extensions to cross-link it and fix the hex-prefixed spec paths.
- 2026-05-28: 8 concept articles compiled from the SRI git collection at HEAD `65c9688c`.
