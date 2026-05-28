---
title: "iroh: Endpoint and ALPN"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-27
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-20-iroh-endpoint-api-docs.md
  - raw/articles/2026-05-20-iroh-crate-top-level-docs.md
  - raw/repos/2026-05-20-iroh-examples-framed-messages.md
tags: [iroh, endpoint, alpn]
---

# Endpoint and ALPN

The two primitives an SV2 integrator wires to.

## Endpoint

One per process. Owns:
- The Ed25519 secret key → derives `EndpointId` (the dial-by-pubkey identity).
- The QUIC `noq` stack (n0's Quinn fork).
- The relay configuration (which relays to use for fallback).
- The set of registered ALPNs the endpoint is willing to accept.

```rust
let ep = iroh::Endpoint::builder(presets::N0)
    .alpns(vec![b"sv2/0".to_vec()])
    .secret_key(loaded_or_generated)
    .bind()
    .await?;
```

The recommendation is **one Endpoint per app** — multiplex services over it
with multiple ALPNs, not multiple Endpoints.

## EndpointId

Public-key-as-identity. 32 bytes Ed25519. This is what miners dial; this is
what gets published in place of `stratum2+tcp://thepool.com:34254/<sec256k1pk>`.

Two consequences:
- **No DNS dependency** for resolving the pool. (See [[Why Iroh — DNS-free pool addressing|wiki/topics/why-iroh-for-sv2.md]].)
- **Curve mismatch with SV2's authority pubkey** (secp256k1). The two key
  spaces are not equivalent. Pool ends up with two keys: secp256k1 for legacy
  TCP URLs, Ed25519 for iroh. (See [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]].)

## ALPN

QUIC's "Application-Layer Protocol Negotiation". Bytes string identifying the
protocol that runs over a given QUIC connection.

iroh convention: `iroh/<protocol>/<version>` (e.g. `b"iroh/blobs/0"`).

For SV2, recommended: `b"sv2/0"` for the main wire protocol. Per-role
variants (`b"sv2/pool/0"`, `b"sv2/jds/0"`) are an alternative that lets a
single endpoint expose multiple SV2 services.

## Bidi streams

Inside an established `Connection`, peers open `accept_bi()` / `open_bi()` for
request/response. SV2 maps cleanly: one bidi stream per `Connection`, kept
open for the session, carrying the existing SV2 frame byte stream.

## See also

- [[iroh: Relays|wiki/concepts/iroh-relays.md]]
- [[iroh: Custom transports (Tor, BLE)|wiki/concepts/iroh-custom-transports.md]]
- [[Integration playbook: Iroh transport for SV2|wiki/topics/sv2-iroh-transport-playbook.md]]
