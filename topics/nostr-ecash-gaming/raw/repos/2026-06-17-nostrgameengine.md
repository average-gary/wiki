---
title: "NostrGameEngine — production game engine on Nostr (jMonkeyEngine, Java)"
source: https://github.com/NostrGameEngine/ngengine
secondary: https://ngengine.org/
type: repo
tags: [nostr, gaming, game-engine, jmonkeyengine, java, webrtc, p2p, nostrrtc, lightning, multiplatform]
fetched: 2026-06-17
confidence: high
credibility: high
quality_score: 5
relevance: direct
direction: nuances
summary: |
  Independent production-grade game engine built on jMonkeyEngine (Java 21+) that uses Nostr
  for identity, signaling, and (planned) payments. v0.2.0 shipped Oct 2025; active commits
  through Jun 2026. Ships to Win/Linux/macOS/Android/iOS/web. WebRTC P2P over Nostr signaling
  ("NostrRTC") removes server costs. v0.5.x roadmap commits to Bitcoin Lightning
  microtransactions, in-game purchases, and P2P commerce. Cashu integration not yet
  announced. Most realistic "build a Nostr game right now" path; competing architecture to
  EthnTuttle's Cashu-validator approach.
---

# NostrGameEngine

## Source

- GitHub org: https://github.com/NostrGameEngine
- Org page: https://ngengine.org/
- Main repo: https://github.com/NostrGameEngine/ngengine
- Quality: 5

## Snapshot

| Field | Value |
|---|---|
| Engine | jMonkeyEngine (Java 21+) |
| License | BSD-3 |
| Targets | Win / Linux / macOS / Android / iOS / web |
| Releases | v0.0 Jun 2024, v0.1 Sep 2024, **v0.2.0 Oct 15 2025** |
| Activity | Active commits through Jun 2026 |
| Repos in org | 23 |
| Distribution | Maven Central |

## Notable repos in the org

- `nostr4j` — Java Nostr client lib (includes "Wallets")
- `nostrads` — in-game ad protocol on Nostr
- `nge-platforms` — platform shims
- `libJGLIOS` — Java graphics on iOS (a meaningful piece of the multiplatform claim)
- `bolt11`, `bech32` — Lightning + bech32 helpers
- Tech demos: `sea-of-nostriches-demo`, `adcity-demo`

## Architectural distinctives

- **NostrRTC** — WebRTC P2P signaling carried over Nostr, eliminating dedicated signaling
  servers
- **v0.5.x payments milestone**: Bitcoin Lightning microtransactions, in-game purchases, P2P
  commerce. **Cashu integration NOT yet announced** but plausible given `nostr4j` already
  has wallet primitives.

## How this compares with the EthnTuttle trio

| Axis | NostrGameEngine | kirk / manastr / nutchain |
|---|---|---|
| Engine basis | Traditional jMonkeyEngine, server-side game logic possible | Nostr events + Cashu mint as referee |
| Currency layer | Lightning-first (Cashu probable) | Cashu-first |
| Coordination | WebRTC P2P + Nostr signaling | Pure Nostr event chain |
| State authority | Game logic / server | Mint validator + event chain |
| Maturity | Production releases on Maven | Experimental Rust libs / standalone game |
| Lang | Java | Rust (kirk, manastr) + spec (nutchain) |

These are **not** the same architecture. NostrGameEngine is "traditional engine, with Nostr
plumbing." The Tuttle trio is "Cashu mint as referee + event-chain as authoritative state."
Two emerging factions in this space.

## Funding / community signals

- Verified org with own domain
- Releases on Maven Central
- v0.5.x payments planned for production ecash hookup

## Status

Active and shipping. The most realistic answer today to "I want to build a Nostr game without
inventing a protocol."
