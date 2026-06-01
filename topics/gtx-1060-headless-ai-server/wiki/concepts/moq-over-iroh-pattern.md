---
title: "Media-over-QUIC over Iroh — moq-lite + moq-relay on iroh transport"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-draft-ietf-moq-transport-18.md
  - raw/papers/2026-06-01-draft-lcurley-moq-lite-04.md
  - raw/repos/2026-06-01-moq-dev-moq-monorepo.md
  - raw/repos/2026-06-01-moq-relay-cargo-features.md
  - raw/repos/2026-06-01-moq-net-crate.md
  - raw/articles/2026-06-01-moq-cloudflare-cdn-blog.md
  - raw/articles/2026-06-01-iroh-secure-video-everywhere-blog.md
  - raw/articles/2026-06-01-masque-connect-udp-warning.md
tags: [moq, moq-lite, moq-relay, iroh, web-transport, real-time-media]
---

# Media-over-QUIC over Iroh

The "publish a live stream from my homelab AI server to family/friends without a public IP" pattern.

## Architecture

```
[ AI server ]                           [ subscribers ]
    │                                          │
    │ moq-net (Producer side)                  │ moq-net (Consumer)
    │   ↓                                      │   ↑
    │ web-transport-iroh                       │ web-transport-iroh
    │   ↓                                      │   ↑
    │ iroh::Endpoint (ALPN: web-transport/...) │ iroh::Endpoint
    └────── QUIC over UDP, hole-punched ───────┘
                       (relay if needed)
```

For local fan-out: an `moq-relay` instance can run on the home server with `--features iroh` (default-on as of moq-relay 0.12.5) to serve many subscribers efficiently.

## moq-lite vs moq-transport

**moq-transport** is the IETF WG draft (rev -18, 2026-05-12). Four-level data model:

```
Track → Group → Subgroup → Object
```

Subgroups map 1:1 to QUIC streams for prioritization. WG plans IESG submission for the Pub/Sub Protocol in **December 2026**. See [[draft-ietf-moq-transport-18]].

**moq-lite** is Luke Curley's individual submission (rev -04, 2026-04-09). Hierarchy collapsed to:

```
broadcast → track → group → frame
```

Removes subgroups, datagrams, object IDs, paused subscriptions. Pull-only model. Self-described as "the bare minimum needed for a real-time application aiming to replace WebRTC." See [[draft-lcurley-moq-lite-04]].

→ moq-net negotiates between them at session setup; **most production deployments speak moq-lite today** because the IETF track hasn't shipped.

## Where iroh plugs in

The `moq-dev/moq` monorepo ships `moq-relay` and `moq-native` with these features:

```toml
# moq-relay 0.12.5
default = ["iroh", "quinn", "websocket"]

# moq-native 0.16.1
iroh = ["dep:web-transport-iroh", "dep:web-transport-proto"]
```

`web-transport-iroh = "0.5.1"` (2026-05-24) implements `web-transport-trait = "0.3.5"` over an iroh `Endpoint`. The relay can therefore accept iroh-dialed connections **out of the box** — no fork, no patch, default-on. See [[2026-06-01-moq-relay-cargo-features]].

## Code shape

```rust
use moq_native::{Net, Tls, Web};
use iroh::Endpoint;

// Spawn an iroh-backed moq endpoint
let endpoint = Endpoint::builder()
    .alpns(vec![web_transport_iroh::ALPN.to_vec()])
    .bind()
    .await?;

let net = Net::iroh(endpoint);
let session = net.connect(addr).await?;

// Then standard moq-net Producer / Consumer over `session`
let broadcast = session.publish("camera/main").await?;
let track = broadcast.create("video/h264", priority).await?;
let mut group = track.append_group();
group.write_frame(frame_bytes).await?;
```

(Surface is approximate; pin to current `moq-net` 0.1.8 docs.)

## Latency / throughput anchors

- Wink's MediaMTX MoQ integration reports **200-300 ms glass-to-glass** latency (HN thread on Cloudflare CDN announcement). See [[2026-06-01-moq-cloudflare-cdn-blog]].
- iroh handshake adds ~0.5 ms (first connection) or ~0.3 ms (0-RTT) on top of network RTT. See [[2026-06-01-iroh-0rtt-handshake-blog]].
- For LAN subscribers: latency dominated by encoder + jitter buffer, not transport. ~200 ms is realistic.
- For WAN subscribers behind NAT: relay fallback adds ~50-150 ms RTT (~10% of cases per [[2026-06-01-iroh-relay-fallback-rate]]).
- **No published moq-relay throughput / fan-out numbers** as of 2026-06-01 — would need independent measurement.

## QUIC-over-iroh-QUIC concerns

Per [[draft-ietf-masque-connect-udp]]: "When the protocol running over UDP that is being proxied uses congestion control (e.g., QUIC), the proxied traffic will incur at least two nested congestion controllers."

moq-net does **not** tunnel QUIC inside QUIC — it uses iroh's QUIC streams directly via `web-transport-trait`. So the MASQUE warning doesn't apply at the congestion-control level. The HoL concern is real but limited:

- moq-lite maps Subgroups (or in lite, frames within groups) 1:1 to QUIC streams
- iroh's per-stream HoL isolation handles per-track HoL
- Cross-track HoL (across iroh's stream-multiplex) is the residual concern; only a real issue under heavy loss

## Use cases for the GTX 1060 server

| Use case | Track structure | Notes |
|----------|-----------------|-------|
| Live transcription stream | `transcript/text` track, low priority | distil-large-v3 RTF ~0.1 → near-real-time |
| YOLO detection overlay | `detections/json` track + `frames/jpeg` track | frames at 5 fps fit in 6 GB VRAM YOLO11s |
| Camera feed | `camera/h264` track | NVDEC-encoded; iroh + MoQ gives encrypted home-camera streaming |
| Inference logs | `logs/text` track, lowest priority | for ops |

## See also

- [[multi-alpn-router-pattern]] — the Router that hosts moq + ssh + blobs on one Endpoint
- [[iroh-blobs-resumable-uploads]] — for non-real-time content (model weights, datasets)
- [[iroh-tickets-and-qr-pairing]] — how subscribers discover the server
- [[iroh-application-patterns-2026-synthesis]] — top-level synthesis
