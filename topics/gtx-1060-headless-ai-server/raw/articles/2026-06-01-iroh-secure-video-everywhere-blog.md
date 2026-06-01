---
title: "What if your security camera was secure? (iroh + MoQ on Raspberry Pi)"
source: https://www.iroh.computer/blog/secure-video-everywhere
type: article
tags: [iroh, moq, raspberry-pi, camera, allowlist, identity-first]
date: 2026-06-01
publication_date: 2026-03-11
quality: 4
confidence: high
agent: 3
summary: "Dated 2026-03-11; Raspberry Pi prototype security camera streaming over iroh + MoQ. Encrypted direct QUIC peer link from camera to phone app; falls back to relay only when no direct path. Explicit poll-based MoQ subscriptions ('streams are only created when someone asks for them') to save battery. Authorization model framed identity-first: 'I know exactly who can see this video stream, and it's only people that I choose' — i.e., NodeId allowlist as the access primitive, not a perimeter. Prototype, not production; no measured latency numbers given."
---

# Secure Video Everywhere — iroh + MoQ on a Pi

Best n0-published illustration of iroh-as-transport-for-MoQ on a low-power home device. Maps directly to a self-hosted home AI server streaming camera/inference frames.

## Architecture

- Raspberry Pi running camera + iroh endpoint
- Phone app subscribes to a MoQ track exposed by the Pi
- Encrypted QUIC peer link directly Pi ↔ phone
- Relay fallback only when no direct path (~10% of cases per [[2026-06-01-iroh-relay-fallback-rate]])

## Subscriptions are pull-only

> "streams are only created when someone asks for them" — battery-saving detail

The Pi doesn't push frames unless a subscriber is actively pulling. This is exactly the MoQ pub-on-demand semantics — which moq-lite supports natively.

## Authorization model (identity-first)

> "I know exactly who can see this video stream, and it's only people that I choose"

Translation: a NodeID allowlist at the application layer. The Pi maintains a set of authorized EndpointIDs and only honors subscriptions from those peers. The pattern would be:

```rust
let allowed: HashSet<EndpointId> = load_allowlist();
let camera_handler = AccessLimit::new(
    CameraHandler::new(...),
    move |id| allowed.contains(&id),
);
let router = Router::builder(endpoint)
    .accept(MOQ_ALPN, camera_handler)
    .spawn();
```

(see [[2026-06-01-iroh-router-protocolhandler-docs]] for `AccessLimit`)

This is **NOT** what `dumbpipe` or `iroh-ssh` ship today — both lack allowlist enforcement.

## Caveats

- Prototype, not production
- No measured latency numbers in the post
- Camera is single-track (one camera → many subscribers); not the homelab AI server case of multi-modal output

## Direct mapping to GTX 1060 AI server

Same pattern, different payload:

| Pi camera demo | GTX 1060 AI server |
|----------------|---------------------|
| Camera frames over MoQ track | Inference output over MoQ track (e.g., live YOLO detections, transcription) |
| Phone app subscribes | Laptop / phone subscribes |
| NodeID allowlist | Same |
| ~50 ms inference latency | distil-whisper RTF ~0.1, YOLO 30-60 ms — comfortable |
| Pi 4 (1.5 GHz ARM Cortex-A72) | i7-7700HQ + GTX 1060 — much more headroom |
