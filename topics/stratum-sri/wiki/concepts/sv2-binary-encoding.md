---
title: "SV2 Binary Encoding"
category: concept
sources:
  - raw/articles/2026-05-28-stratum-sri-sv2-binary-sv2-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-binary-sv2-derive-codec-readme.md
  - raw/articles/2026-05-28-stratum-sri-sv2-parsers-sv2-readme.md
created: 2026-05-28
updated: 2026-05-28
tags: [sv2, binary-sv2, parsers-sv2, derive-codec-sv2, encoding, no-std]
aliases: ["binary_sv2", "binary-sv2", "SV2 type system", "Sv2 types"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "How SV2 messages move between bytes and Rust types: the `binary_sv2` no-std type system, the `derive_codec` proc-macros that auto-generate (de)serializers, and the `parsers_sv2` Rust-type ↔ wire-bytes layer that sits on top."
---

# SV2 Binary Encoding

> SV2 is a binary protocol with fixed message framing. The encoding stack in SRI is split across three crates: `binary_sv2` defines the type system, `derive_codec_sv2` provides proc-macros that auto-generate (de)serialization for structs of those types, and `parsers_sv2` converts raw wire bytes into typed Rust messages and between Rust message variants.

## Type system (`binary_sv2`)

`binary_sv2` is a `no_std` Rust crate that maps SV2 wire types to Rust types. The mapping at this revision is:

| Rust type | SV2 type |
|-----------|----------|
| `bool` | `BOOL` |
| `u8` | `U8` |
| `u16` | `U16` |
| `U24` | `U24` |
| `u32` | `U32` |
| `u64` | `U64` |
| `f32` | `F32` |
| `Str0255` | `STR0_255` |
| `Signature` | `SIGNATURE` |
| `[u8]` | `BYTES` |
| `Seq0255` | `SEQ0_255[T]` |
| `Seq064K` | `SEQ0_64K[T]` |

`U24` is exposed as a Rust newtype because the SV2 wire has a 3-byte unsigned integer that no native Rust integer matches; the size-bounded string and sequence types (`Str0255`, `Seq0255`, `Seq064K`) similarly enforce protocol limits in the type rather than at runtime.

The crate is `no_std` by default and exposes two opt-in features:

- `prop_test` — property-test scaffolding for downstream crates.
- `with_buffer_pool` — optimizes encoding to use the [[sv2-buffer-pool|SV2 buffer pool]] ([SV2 buffer pool](sv2-buffer-pool.md)) instead of fresh allocations.

## Auto-derived codecs (`derive_codec_sv2`)

`derive-codec-sv2` is a `no_std` proc-macro crate that generates serialization/deserialization impls for SV2 message structs. It exposes three derives:

- `Encodable` — generates the wire-encoding impl.
- `Decodable` — generates the wire-decoding impl, supports field lifetimes, generics, and static references.
- `GetSize` — computes per-field/total wire size for dynamic message framing.

It also recognizes the `#[already_sized]` attribute, used to mark fixed-size structs so size lookups skip per-field walking.

Without these derives every message type would need a hand-written encoder/decoder; with them, fields whose types are in the table above just work. This is the bridge that lets the four subprotocol crates — [[sv2-mining-subprotocol|mining]] ([mining](../topics/sv2-mining-subprotocol.md)), [[sv2-job-declaration-subprotocol|JDP]] ([JDP](../topics/sv2-job-declaration-subprotocol.md)), [[sv2-template-distribution-subprotocol|TDP]] ([TDP](../topics/sv2-template-distribution-subprotocol.md)), and `common_messages_sv2` — declare messages as plain Rust structs.

## Parser layer (`parsers_sv2`)

`parsers_sv2` is a `no_std` crate that "provides logic to convert raw Stratum V2 (Sv2) message data into Rust types, as well as logic to handle conversions among Sv2 Rust types." Most of its logic is tightly coupled to `binary_sv2`. Practically, this is the layer that the [[sv2-codec|codec]] ([codec](sv2-codec.md)) hands a decoded payload to in order to get a typed message variant the [[sv2-message-handlers|handlers]] ([handlers](sv2-message-handlers.md)) can dispatch on.

## Layering

```
                       ┌─────────────────────────────┐
   typed Rust msgs ◄──►│        parsers_sv2          │
                       │  (raw bytes ↔ Rust types,   │
                       │   variant conversions)      │
                       └─────────────┬───────────────┘
                                     │
                       ┌─────────────▼───────────────┐
   field codecs   ◄──► │      derive_codec_sv2       │
                       │ (proc-macros generate       │
                       │  ser/de for binary_sv2 fields)│
                       └─────────────┬───────────────┘
                                     │
                       ┌─────────────▼───────────────┐
   wire types     ◄──► │         binary_sv2          │
                       │ (U24, Str0255, Seq0_255…)   │
                       └─────────────────────────────┘
```

`framing_sv2` operates one layer above `parsers_sv2`, wrapping the resulting message bytes in the 6-byte SV2 header described in [[sv2-framing|SV2 framing]] ([SV2 framing](sv2-framing.md)).

## See Also

- [[sv2-framing|SV2 Framing]] ([SV2 Framing](sv2-framing.md)) — wraps the encoded payload in the 6-byte SV2 header
- [[sv2-codec|SV2 Codec]] ([SV2 Codec](sv2-codec.md)) — drives encode/decode end-to-end and bolts on Noise
- [[sv2-buffer-pool|SV2 Buffer Pool]] ([SV2 Buffer Pool](sv2-buffer-pool.md)) — backs `with_buffer_pool` encoding mode
- [[sv2-message-handlers|SV2 Message Handlers]] ([SV2 Message Handlers](sv2-message-handlers.md)) — consumes parsed Rust messages
- [[stratum-core-umbrella|stratum-core Umbrella Crate]] ([stratum-core Umbrella Crate](../topics/stratum-core-umbrella.md)) — re-exports `binary_sv2` and `parsers_sv2`

## Sources

- [binary-sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-binary-sv2-readme.md) — type-system mapping and feature flags
- [derive_codec_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-binary-sv2-derive-codec-readme.md) — proc-macro role
- [parsers_sv2 README](../../raw/articles/2026-05-28-stratum-sri-sv2-parsers-sv2-readme.md) — bytes ↔ Rust-type conversion
