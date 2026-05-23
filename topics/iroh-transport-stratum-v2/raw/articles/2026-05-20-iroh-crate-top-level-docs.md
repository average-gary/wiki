---
title: "iroh crate top-level docs"
source_url: https://docs.rs/iroh/latest/iroh/index.html
type: docs
date: 2026-05-20
org: n0-computer
iroh_version: 0.98.2
credibility: high
quality: 5
relevance: direct
tags: [iroh, api, quic, tls, alpn]
ingested: 2026-05-20
---

# iroh crate top-level docs (key facts)

## Identity model

- `EndpointId` is derived from a `PublicKey` (Ed25519). Each endpoint has a
  `SecretKey`.
- "There is no client, server or server TLS key and certificate chain" — peers
  authenticate by public key (RFC 7250 raw public keys in TLS).
- "an API for dialing by public key" is the elevator pitch.

## Transport

- "Peer-to-peer QUIC connections" — encryption "is an integral part of TLS as
  used in QUIC".
- ALPN: "Application-Layer Protocol Negotiation identifies which
  application-specific protocol governs the QUIC connection".
- Modules: `endpoint`, `address_lookup` (DNS-based discovery), `tls`,
  `protocol` (accept-loop routing), `metrics`, `dns`.
- (Note: iroh 0.98 changed the discovery namespace from `discovery` →
  `address_lookup`; pre-0.98 code referencing `iroh::discovery` will not compile.)

## Minimal client

```rust
use iroh::{Endpoint, presets};

let ep = Endpoint::bind(presets::N0).await?;
let conn = ep.connect(addr, b"my-alpn").await?;
let mut send_stream = conn.open_uni().await?;
send_stream.write_all(b"msg").await?;
```

## Minimal server

```rust
use iroh::{Endpoint, presets};

let ep = Endpoint::builder(presets::N0)
    .alpns(vec![b"my-alpn".to_vec()])
    .bind()
    .await?;

let conn = ep.accept().await?.await?;
let mut recv_stream = conn.accept_uni().await?;
```

## Implications for SV2

- The handshake is **TLS 1.3 with raw public keys**. Doing the SV2 Noise_NX
  handshake _on top of_ this TLS-secured channel gives belt-and-suspenders
  authenticated encryption.
- An alternative is to skip Noise (`PlainIrohConnection` from SRI #1935) and
  rely solely on iroh's TLS. Tradeoff: drop a formally-analyzed Noise handshake
  (Girol et al. USENIX Sec 2020; Kobeissi & Nicolas EuroS&P 2019) for a
  TLS-RPK handshake (RFC 7250). Both are credible — but moving away from Noise
  changes the threat model and forfeits the AEAD-frame integrity property that
  defeats Erosion-style single-packet tampering (see Erosion S&P 2024).
