---
title: "The first Media over QUIC CDN: Cloudflare (moq.dev/blog)"
source: https://moq.dev/blog/first-cdn/
type: article
tags: [moq, cloudflare, cdn, moq-rs, deployment, latency]
date: 2026-06-01
publication_date: 2025-08-22
quality: 5
confidence: high
agent: 3
summary: "Luke Curley (kixelated) blog post 2025-08-22 announcing Cloudflare's MoQ relay tech preview. Free during preview; planned 5 cents/GB outbound at GA. Cloudflare runs a fork of moq-rs ('They're using a fork of my terrible code so bugs are guaranteed'). Public relay endpoint: relay.cloudflare.mediaoverquic.com. Implements draft-ietf-moq-transport-07 (older); only SUBSCRIBE supported in preview, no auth, no ANNOUNCE. HN thread captures Wink built MoQ support for MediaMTX with 200-300ms latency."
---

# Cloudflare MoQ CDN — first production deployment (2025-08-22)

Best single anchor for "MoQ in production today."

## Deployment scope

- **Public relay**: `relay.cloudflare.mediaoverquic.com`
- Cloudflare's relay is a **fork of moq-rs** (kixelated's stack)
- Tech preview, free during preview
- Planned pricing at GA: **5¢/GB outbound**
- Cloudflare engineering blog (companion): https://blog.cloudflare.com/moq/ — relay runs "on every Cloudflare server in datacenters in 330+ cities"

## Wire protocol version

- **draft-ietf-moq-transport-07** (older — current draft is -18)
- Preview limitations: **SUBSCRIBE only**, no auth, no ANNOUNCE
- Use `moq-cli` configured for the older draft

## Latency anchor — Wink's MediaMTX integration

From the HN thread (https://news.ycombinator.com/item?id=44987924, 292 points, 121 comments):

- Wink built MoQ support for MediaMTX (the Rust media server)
- Reports **200-300 ms glass-to-glass latency**
- Bridges existing RTMP/RTSP into MoQ for both WebTransport browsers and native QUIC server-to-server

This is the only reasonably-cited end-to-end latency number in the public MoQ ecosystem as of 2026.

## Cloudflare's architectural patterns

From blog.cloudflare.com/moq/ (also 2025-08-22):

- 3-layer stack: QUIC/WebTransport → MoQT pub/sub (ANNOUNCE/SUBSCRIBE) → streaming format (e.g. WARP)
- Latency target framing: "sub-second" vs RTMP's "2-5 seconds" and HLS's "15-30 seconds"
- Uses Cloudflare Durable Objects to track announced namespaces globally — a real architectural pattern for distributed pub/sub state
- Interop tested with: Meta's Moxygen, moq.dev/moq-rs/moq-js, Norsk, Vindral

## Demo

`moq.dev/publish/` reported "buttery" by HN testers. Mobile rendering glitches (horizontal black lines) noted. Safari WebTransport behind a flag.

## What this means for an Iroh AI server

- A homelab Iroh server that wants to fan-out MoQ tracks to many subscribers can either:
  1. Run its own `moq-relay` with the iroh feature on — direct path
  2. Push to Cloudflare's relay over WebTransport — gives global distribution but costs $/GB and is not iroh-native

For private LAN / friend-graph use cases, option 1 is the homelab fit.
