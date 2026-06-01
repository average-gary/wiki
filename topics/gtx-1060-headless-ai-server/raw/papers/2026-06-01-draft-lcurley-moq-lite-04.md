---
title: "draft-lcurley-moq-lite-04 — Media over QUIC Lite"
source: https://datatracker.ietf.org/doc/draft-lcurley-moq-lite/
type: paper
tags: [moq, moq-lite, ietf, individual-submission, quic, kixelated]
date: 2026-06-01
publication_date: 2026-04-09
quality: 5
confidence: high
agent: 1
summary: "Individual submission (Luke Curley aka kixelated), NOT a WG document. Rev -04 dated 2026-04-09. Hierarchy reduced to broadcasts → tracks → groups → frames. Removes subgroups, datagrams, object IDs, paused subscriptions. Pull-only model. Uses QUIC streams directly instead of request IDs. Self-described as 'the bare minimum needed for a real-time application aiming to replace WebRTC.'"
---

# draft-lcurley-moq-lite-04

The pragmatic, deployable subset that the canonical Rust stack (`moq-dev/moq`) actually implements.

## What's removed vs moq-transport

- **Subgroups** — gone; objects sequence directly inside groups (frames)
- **Datagrams** — gone; only QUIC streams
- **Object IDs** — gone
- **Paused subscriptions** — gone
- **Multi-group fetch** — replaced with HTTP-like single request/response FETCH

## Hierarchy

```
broadcast → track → group → frame
```

(vs IETF moq-transport's track → group → subgroup → object)

## Status

- Status: I-D Exists, individual submission, NOT WG-endorsed
- Rev -04 dated 2026-04-09
- Author: Luke Curley (kixelated, also moq-dev maintainer)
- Self-description: "forwards-compatible subset of the IETF moq-transport draft" (works against any moq-transport CDN; Cloudflare specifically named)
- Justified by maintainer: "standards are SLOW… my goal is to get MoQ in production now, even if it's not a standard yet."

## Why this matters for an Iroh AI server

The `moq-net` crate (`moq-dev/moq`) implements both the lite and IETF wire protocols and negotiates at session setup. A homelab box hosting MoQ today is almost certainly speaking moq-lite over `web-transport-iroh`. See [[2026-06-01-moq-dev-moq]].
