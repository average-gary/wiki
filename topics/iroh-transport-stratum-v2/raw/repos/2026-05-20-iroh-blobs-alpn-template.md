---
title: "iroh-blobs — canonical ALPN protocol over iroh"
source_url: https://github.com/n0-computer/iroh-blobs
type: repo
date: 2026-05-20
org: n0-computer
credibility: high
quality: 5
relevance: direct
tags: [iroh, alpn, protocol-template, repo]
ingested: 2026-05-20
---

# iroh-blobs as a template for SV2-over-iroh

The closest existing real-world template for putting a stateful binary wire
protocol on iroh. Powers Sendme (n0's flagship app, ~v0.34, May 2026).

## Pattern

- Registers a single ALPN constant: `iroh_blobs::ALPN`.
- Accept handler runs against an `iroh::protocol::Router`.
- Entire request/response exchange is **one bidi QUIC stream**.

> "The requester opens a QUIC stream to the provider and sends the request. The
> provider answers with the requested data."

> "Communication occurs over one bidirectional QUIC stream per request… Data
> integrity relies on BLAKE3 verification throughout transmission."

> "Nodes can simultaneously function as both providers and requesters."

## Why this template fits SV2

| iroh-blobs | SV2 over iroh |
|------------|---------------|
| BLAKE3 hash + range request | SV2 frame (header + payload) |
| BLAKE3-verified streamed response | SV2 reply frames |
| 1 bidi stream per request | 1 bidi stream per SV2 connection (long-lived) |
| Symmetric request/responder | Symmetric peer (proxy ↔ proxy, miner ↔ pool) |

The structural difference: SV2 connections are **long-lived** (a miner stays
connected for hours), whereas blob requests are short-lived. So SV2 maps to
"one bidi stream per Connection, kept open for the session" rather than "one
stream per request".

## Adapt this for SV2

- Define ALPN constant: `pub const SV2_ALPN: &[u8] = b"sv2/0";`
- Implement `iroh::protocol::ProtocolHandler` for an SV2 server type.
- In `accept`: get peer endpoint id, accept_bi, hand the streams off to a
  `network_helpers_sv2::iroh_connection` adapter that produces the same
  `(Receiver<Sv2Frame>, Sender<Sv2Frame>)` pair as the existing `noise_connection`.

## Battle-test status

iroh-blobs powers **Sendme** which n0 ships as a production app. ~1k stars,
37 releases, ~v0.34 — confirms this pattern is not toy code.
