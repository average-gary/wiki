---
title: "Delta Chat — peer_channels.rs (production iroh deployment)"
source_url: https://github.com/deltachat/deltachat-core-rust/blob/main/src/peer_channels.rs
type: repo
date: 2026-05-20
org: Delta Chat / Merlinux
credibility: high
quality: 5
relevance: direct
tags: [iroh, production, delta-chat, integration-pattern]
ingested: 2026-05-20
---

# Delta Chat peer_channels.rs — production iroh integration shape

Highest-volume real iroh deployment in the wild (millions of Delta Chat installs).
Exact integration shape is directly portable to SV2.

## Endpoint construction

```rust
let endpoint = Endpoint::builder()
    .tls_x509()                              // x509 mode (not raw-public-key)
    .secret_key(secret_key)                  // stable identity across restarts
    .alpns(vec![GOSSIP_ALPN.to_vec()])
    .relay_mode(relay_mode)
    .bind()
    .await?;
```

Key takeaways:
- **Stable identity**: `secret_key` persisted to SQLite means restart preserves
  the EndpointId. SV2 must do the same — pool's iroh keypair is identity, lose
  it = miners can't dial.
- `tls_x509()` not `tls_raw_public_keys()`. Choice depends on whether the
  ecosystem's clients can handle RPK. For SV2, RPK is preferable (matches the
  "dial-by-pubkey" identity model and avoids X.509 baggage).

## Router pattern

```rust
iroh::protocol::Router::builder(endpoint)
    .accept(GOSSIP_ALPN, gossip.clone())
    .spawn()
```

Same pattern an SV2 server would use — swap `gossip` for an SV2 handler.

## Resource bounds

```rust
Gossip::builder()
    .max_message_size(128 * 1024)
    .spawn(endpoint.clone())
    .await?
```

Explicit message-size tuning. SV2 frames cap at 65,535 ciphertext bytes
(noise) or 16M for plaintext per spec, so config the equivalent ceiling.

## Lazy initialization

> "lazy initialization of peer channels — connections activate only when WebXDC
> apps call realtime methods, minimizing unnecessary P2P overhead."

Pattern for SV2 proxies that don't need iroh up at startup — only spin it up
when a downstream actually wants to connect upstream.

## Persistence

Topic IDs stored in SQLite for cross-restart peer discovery — equivalent to
caching `EndpointAddr` for SV2 upstream routing. SV2 should persist the
last-known-good `EndpointAddr` for each known upstream so reconnect is fast.

## Why this template is load-bearing

- Demonstrates that the boilerplate is small (~30 lines of integration glue).
- Confirms iroh is robust enough to back a multi-million-user app with strict
  privacy requirements.
- Identifies the operational decisions an SV2 integration must make: persisted
  identity, x509 vs RPK, max message size, lazy startup, address persistence.
