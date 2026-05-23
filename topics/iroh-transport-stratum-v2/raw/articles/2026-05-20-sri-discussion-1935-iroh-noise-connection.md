---
title: "RFC: Iroh [Noise] Connection (SRI Discussion #1935)"
source_url: https://github.com/stratum-mining/stratum/discussions/1935
type: discussion
date: 2025-10-03
author: EthnTuttle
org: Stratum Reference Implementation
credibility: high
quality: 5
relevance: direct
tags: [iroh, sv2, transport, sri-rfc, noise]
ingested: 2026-05-20
---

# RFC: Iroh [Noise] Connection — SRI Discussion #1935

The canonical upstream design discussion proposing Iroh as an alternative transport
for Stratum v2. The `feat/iroh-transport` branch in this repo is presumably an
implementation of this RFC.

## Proposal shape

- Replace `TcpStream` at the lowest level with iroh's `Endpoint` / `Connection`
  while preserving identical higher-level interfaces. All existing channel logic
  upstairs is untouched.
- Proposed types:
  - `NoiseIrohStream` — Noise_NX over iroh QUIC bidi stream
  - `IrohConnection` — encrypted iroh connection
  - `PlainIrohConnection` — plain iroh connection (no Noise — TLS-only)
  - `IrohNodeManager` — endpoint owner + accept loop
- All connection types return the same `(Receiver, Sender)` channel pair so
  `network_helpers` consumers swap transports transparently.

## Server-side

Dual-transport listener: TCP and Iroh simultaneously. A pool can keep its existing
`stratum2+tcp://...` ingress and add an Iroh endpoint listening on the same authority
key. Selected by client.

## Client-side

Outbound dial fallback: try TCP first (or Iroh first), fall back to the other.
This matches existing fallback patterns in `network_helpers_sv2`.

## Implementation phasing

Four phases (paraphrased from the RFC):
1. Spike: get a single SV2 frame across an iroh connection
2. Symmetric APIs: wrap iroh into the existing `Connection` trait shape
3. Server-side dual transport
4. Client-side fallback

## Motivation

> Drop DNS as a hard dependency for Sv2 pools.

Pools today must publish a hostname (e.g., `stratum2+tcp://thepool.com:34254`).
DNS is a censorship surface (e.g., a TLD operator can block the name) and a
single point of failure. Iroh dials by 256-bit pubkey (NodeId/EndpointId) routed
via discovery (pkarr / mainline DHT / DNS) and relays — pubkey is intrinsic to
the pool's authority key.

## Cited prior art

Fedimint's Iroh integration (TABConf talk, Fountain.fm episode referenced in a
follow-up comment).

## Status

Open Idea, only 1 reply at time of capture (2025-10). The local `feat/iroh-transport`
branch can become the canonical implementation answering this RFC.

## Why this matters for the wiki

This is the load-bearing source for the entire integration. Every design
decision in the branch should be traceable back to (or explicitly diverging from)
this RFC. Other sources answer "how" — this answers "why" and "what shape".
