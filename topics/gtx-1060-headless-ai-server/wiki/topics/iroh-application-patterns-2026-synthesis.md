---
title: "Iroh application patterns 2026 — synthesis for a homelab AI server"
type: topic
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - wiki/concepts/moq-over-iroh-pattern.md
  - wiki/concepts/multi-alpn-router-pattern.md
  - wiki/concepts/iroh-blobs-resumable-uploads.md
  - wiki/concepts/iroh-as-ssh-transport.md
  - wiki/concepts/iroh-tickets-and-qr-pairing.md
tags: [iroh, synthesis, homelab, ai-server, application-patterns, 2026]
---

# Iroh application patterns 2026 — for the GTX 1060 AI server

Five Iroh-native patterns the homelab AI server should ship together. As of 2026-06-01, **all five are technically feasible today on iroh 1.0-rc.1**; some need application-layer wrappers to be production-grade.

## Top-of-stack picture

```
       phone / friend's laptop                           GTX 1060 AI server
              ▲   ▲   ▲                                       ▲   ▲   ▲
              │   │   │                                       │   │   │
       moq    │   │   ssh                          moq-relay  │   │   sshd
       client │   │   client                                  │   │   (localhost:22)
              │   │                                           │   │
   iroh ALPN= │   │     iroh ALPN=                iroh ALPN=  │   │ iroh ALPN=
  web-trans-  │   │   DUMBPIPEV0                  web-trans-  │   │ DUMBPIPEV0
   port-iroh  │   │                                port-iroh  │   │
              │   │                                           │   │
              │   ↓                                           │   ↓
              │ (iroh-blobs/0)                                │ (iroh-blobs/0)
              ↓                                               ↓
        ┌───────────────────────────────────────────────────────────┐
        │                  iroh QUIC + TLS-RPK                      │
        │              (UDP, hole-punched or relayed)               │
        └───────────────────────────────────────────────────────────┘
```

One Endpoint, one EndpointID, multiple ALPNs. See [[multi-alpn-router-pattern]].

## The five patterns

| # | Pattern | What it gives you | Concept article |
|---|---------|-------------------|-----------------|
| 1 | Multi-ALPN dispatch on one Router | Single identity for every service the box exposes | [[multi-alpn-router-pattern]] |
| 2 | Media-over-QUIC over iroh | Fan-out live streams (transcripts, detections, camera) to friends | [[moq-over-iroh-pattern]] |
| 3 | iroh-blobs resumable uploads | Upload videos / push model weights with BLAKE3 verification, multi-receiver replication | [[iroh-blobs-resumable-uploads]] |
| 4 | Iroh as SSH transport | Replace Tailscale-SSH; allowlist via `AccessLimit<P>` | [[iroh-as-ssh-transport]] |
| 5 | QR-pairing protocol | Tailscale-style invite + Noise-IK semantics + Wesh-style revocation | [[iroh-tickets-and-qr-pairing]] |

## Stack pin (2026-06-01)

```toml
[dependencies]
iroh = "=1.0.0-rc.1"               # 2026-05-27
iroh-tickets = "=1.0.0-rc.1"
iroh-blobs = "=0.102.0"            # 2026-05-27, pinned to iroh 1.0-rc.1
dumbpipe = "=0.38.0"               # 2026-05-27
moq-net = "=0.1.8"                 # 2026-06-01
moq-relay = "=0.12.5"              # iroh feature default-on
moq-native = "=0.16.1"
web-transport-iroh = "=0.5.1"      # 2026-05-24
web-transport-trait = "=0.3.5"
noq = "=1.0.0-rc.1"                # n0's QUIC fork, in lockstep
```

All released within a 2-week window — the ecosystem is genuinely synchronized.

## Critical breaking changes since the existing wiki was written

- **`Node` → `Endpoint` rename** (0.94, 2025-10-21) — already reflected in older `iroh-transport-stratum-v2` notes
- **`NodeTicket` → `EndpointTicket`** (0.94) — moved to dedicated `iroh-tickets` crate
- **Raw public key TLS** replaces x509 (1.0-rc.0, 2026-05-07)
- **Paths API redesign**: `Connection::paths()` snapshot + `Connection::path_events()` stream; `ConnectionInfo` removed
- **AccessControl trait** replaces enum (1.0-rc.1)
- **iroh-blobs 0.90 ground-up rewrite** (2025-07-08) — all pre-0.90 docs are stale; README's "0.35 recommended for production" is **wrong**

See [[iroh-changelog-0-91-to-1-0-rc-1]].

## What ships today vs what you must build

| Capability | Ships in iroh? | Status |
|------------|----------------|--------|
| Multi-ALPN dispatch | ✅ `iroh::protocol::Router` | Production |
| ALPN allowlist (NodeID set) | ✅ `iroh::protocol::AccessLimit<P>` | Production |
| moq over iroh | ✅ `moq-relay --features iroh` (default-on) | Production at Cloudflare; community-supported in moq-rs |
| iroh-blobs resumable + verified | ✅ iroh-blobs 0.102 | Pre-1.0; **issue #233 (poisoned store) is unresolved** |
| iroh-blobs ConnectionPool | ✅ since 0.95 | Production |
| BLAKE3 verified streaming | ✅ via bao-tree 0.16 | Production |
| Iroh as SSH transport (raw) | ✅ dumbpipe / iroh-ssh | Works, but **no allowlist** |
| **Iroh-as-SSH with allowlist** | ❌ — operator must wrap with `AccessLimit` | DIY |
| Iroh ticket as QR | ✅ `EndpointTicket::from_str` | Production |
| **Ticket revocation / expiry / single-use** | ❌ — must layer at app | DIY |
| **Capability tokens (Tailscale-style)** | ❌ — must layer at app | DIY |
| **Time-rotated rendezvous (Wesh-style)** | ❌ — must layer at app | DIY |
| Hard-NAT holepunching | ✅ since 1.0-rc.1 | New |
| Post-quantum KEM | ✅ opt-in via `prefer-post-quantum` | Opt-in |

## End-to-end recipe for the GTX 1060 AI server

```rust
use iroh::{Endpoint, protocol::{Router, AccessLimit}};
use iroh_blobs::store::fs::FsStore;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let secret_key = load_or_create_secret("/etc/farm-ai/iroh-secret")?;
    let allowed = read_allowlist("/etc/farm-ai/allowed_endpoint_ids")?;
    let admin_allowed = read_allowlist("/etc/farm-ai/admin_endpoint_ids")?;

    let endpoint = Endpoint::builder()
        .secret_key(secret_key)
        .alpns(vec![
            iroh_blobs::ALPN.to_vec(),
            b"DUMBPIPEV0".to_vec(),
            web_transport_iroh::ALPN.to_vec(),
            b"farm-ai/transcribe/1".to_vec(),
            b"farm-ai/detect/1".to_vec(),
            b"farm-ai/admin/1".to_vec(),
        ])
        .bind()
        .await?;

    println!("EndpointID: {}", endpoint.endpoint_id());
    println!("Ticket: {}", endpoint.endpoint_addr_ticket().await?);

    let store = FsStore::load("/var/lib/farm-ai/blobs").await?;
    let model = load_yolo11s().await?;
    let whisper = load_distil_large_v3().await?;

    let router = Router::builder(endpoint)
        // public-ish: any peer can fetch announced blobs
        .accept(iroh_blobs::ALPN, store.protocol_handler())
        // gated: known peers only
        .accept(b"DUMBPIPEV0",
            AccessLimit::new(SshTunnel::new("localhost:22"),
                {let a = allowed.clone(); move |id| a.contains(&id)}))
        .accept(web_transport_iroh::ALPN,
            MoqRelayHandler::new(/* ... */))
        .accept(b"farm-ai/transcribe/1",
            AccessLimit::new(TranscribeHandler::new(whisper.clone()),
                {let a = allowed.clone(); move |id| a.contains(&id)}))
        .accept(b"farm-ai/detect/1",
            AccessLimit::new(DetectHandler::new(model.clone()),
                {let a = allowed.clone(); move |id| a.contains(&id)}))
        // admin-only
        .accept(b"farm-ai/admin/1",
            AccessLimit::new(AdminHandler::new(),
                move |id| admin_allowed.contains(&id)))
        .spawn();

    tokio::signal::ctrl_c().await?;
    router.shutdown().await;
    Ok(())
}
```

## Operational gotchas

### Memory / long-running

iroh has open issues #3565 (idle memory growth) and #3963 (Router::accept span leak). For a daemon hosting many handlers on a 16 GB box: **schedule a weekly restart** via systemd `RuntimeMaxSec=` until these are fixed. See [[iroh-memory-leak-issues]].

### iroh-blobs poisoned-store

Crash mid-upload can brick the store (issue #233). Mitigations: supervised systemd unit, periodic integrity check, `mem` store for ephemeral content, wait for stable 1.0. See [[iroh-blobs-poisoned-store-issue-233]].

### Pin everything

Iroh's RC churn means a `cargo update` will rebuild against incompatible APIs. **Use `=1.0.0-rc.1` pins** until 1.0 stable.

### Tracing instrumentation

Filter the `router.accept` span in the tracing-subscriber config — it's the source of the #3963 leak.

## Latency budget for the homelab AI server

| Hop | Cost |
|-----|------|
| iroh handshake (first connect) | ~0.5 ms |
| iroh handshake (0-RTT) | ~0.3 ms |
| Hole-punch (when needed) | ~50-200 ms one-time |
| Direct path RTT (LAN) | ~1 ms |
| Direct path RTT (home internet) | ~50-100 ms |
| Relay RTT (10% of cases) | +50-150 ms |
| BLAKE3 hashing on i7-7700HQ | not the bottleneck (~3-4 GiB/s single-thread) |
| Whisper distil-large-v3 transcription | RTF ~0.1 (10× real-time) |
| YOLO11s inference per 1080p frame | ~30-60 ms on GTX 1060 |
| MoQ glass-to-glass (Wink/MediaMTX reference) | ~200-300 ms |

→ For interactive usage (subscribe → see frame): ~250-400 ms steady-state. For ssh-style interaction (keystroke → response): ~50-100 ms LAN, ~100-250 ms WAN. All comfortably within human perceptual thresholds.

## Privacy / security posture

| Concern | Status |
|---------|--------|
| End-to-end encryption | TLS 1.3 over QUIC, RPK; ML-KEM hybrid opt-in |
| Identity = pubkey | Ed25519 (no PQ signatures yet) |
| Network location | EndpointTicket leaks current IPs to anyone with the ticket |
| Authentication | iroh tickets are NOT auth credentials — layer your own |
| Observability | Relays know who talks to whom; ALPN visible to anyone who connects |
| Forward secrecy | Yes (per-session ephemerals) |
| Quantum-resistant FS | Optional via `prefer-post-quantum` |

## Open questions

1. moq-relay throughput / fan-out / CPU-per-subscriber numbers — not published; would need independent measurement
2. iroh-blobs sustained throughput on a single connection — proxy estimate via BLAKE3 hashing only
3. NodeTicket exact byte size — approximately 80-200 bytes encoded; measure with `iroh node ticket` CLI for current build
4. moq-rs glass-to-glass latency — only Wink/MediaMTX 200-300 ms data point; first-party numbers not published
5. When does iroh 1.0 stable ship? rc.1 was billed as "the last one" but no ship date as of 2026-06-01

## See also

- [[multi-alpn-router-pattern]]
- [[moq-over-iroh-pattern]]
- [[iroh-blobs-resumable-uploads]]
- [[iroh-as-ssh-transport]]
- [[iroh-tickets-and-qr-pairing]]
- [[gtx-1060-headless-ai-server-synthesis]] — original hardware/AI synthesis
- Sister wiki: `iroh-transport-stratum-v2` — Iroh primitives applied to SV2 transport
