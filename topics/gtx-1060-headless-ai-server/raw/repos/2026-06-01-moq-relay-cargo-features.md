---
title: "moq-relay + moq-native Cargo.toml — iroh feature is default-on"
source: https://github.com/moq-dev/moq/blob/main/rs/moq-relay/Cargo.toml, https://github.com/moq-dev/moq/blob/main/rs/moq-native/Cargo.toml
type: repo
tags: [moq, moq-relay, moq-native, iroh, cargo-features, web-transport-iroh]
date: 2026-06-01
quality: 5
confidence: high
agent: 2
summary: "moq-relay 0.12.5 has `default = [\"iroh\", \"quinn\", \"websocket\"]`. The iroh feature is just `[\"moq-native/iroh\"]`. moq-native 0.16.1 features: `iroh = [\"dep:web-transport-iroh\", \"dep:web-transport-proto\"]`; quinn / quiche / noq each have parallel features. web-transport-iroh is at v0.5.1 (2026-05-24). The transport is genuinely swappable through the web-transport-trait abstraction (v0.3.5)."
---

# moq-relay's transport seam

The technical answer to "moq over iroh" is **already shipped, default-on, no fork**.

## Feature flags

```toml
# moq-relay 0.12.5
[features]
default = ["iroh", "quinn", "websocket"]
iroh = ["moq-native/iroh"]
quinn = ["moq-native/quinn"]
quiche = ["moq-native/quiche"]
noq = ["moq-native/noq"]
websocket = ["moq-native/websocket"]
jemalloc = [...]
```

```toml
# moq-native 0.16.1
[features]
iroh    = ["dep:web-transport-iroh", "dep:web-transport-proto"]
quinn   = ["dep:quinn", "dep:web-transport-quinn", ...]
quiche  = ["dep:web-transport-quiche", ...]
noq     = ["dep:web-transport-noq", ...]
```

## The web-transport ecosystem

| Crate                | Version | Role |
|----------------------|---------|------|
| `web-transport-trait` | 0.3.5  | The abstraction |
| `web-transport-iroh`  | 0.5.1  | iroh adapter (updated 2026-05-24) |
| `web-transport-quinn` | 0.11.9 | raw QUIC/quinn adapter |
| `web-transport-quiche`| —      | Cloudflare's quiche |
| `web-transport-noq`   | —      | n0's QUIC fork |

Repo: https://github.com/moq-dev/web-transport

## Implication

Anyone wanting to graft moq-lite onto a different QUIC implementation has a clear seam: implement `web-transport-trait`, register a feature in `moq-native`, done.

For an Iroh AI server: `cargo install moq-relay --features iroh` (default) → relay accepts iroh-dialed connections out of the box. The relay can host MoQ Tracks served to subscribers connecting via `Endpoint::connect(addr, MOQ_ALPN)`.

See also: [[2026-06-01-moq-dev-moq-monorepo]], [[2026-06-01-moq-net-crate]].
