---
title: "iroh::protocol::Router and ProtocolHandler — docs.rs API surface"
source: https://docs.rs/iroh/latest/iroh/protocol/struct.Router.html
type: repo
tags: [iroh, router, protocolhandler, alpn, accesslimit, dispatch]
date: 2026-06-01
quality: 5
confidence: high
agent: 2
summary: "iroh 1.0.0-rc.1 (2026-05-27). Router::builder(endpoint) → RouterBuilder; .accept(alpn, handler).spawn(). Router is Clone + Debug + Send + Sync. RouterBuilder supports adding multiple ALPNs; Router::accept(alpn, handler) is also available at runtime on a spawned router for dynamic protocol registration. ProtocolHandler trait: required fn accept(&self, connection: Connection) → impl Future<Output = Result<(), AcceptError>> + Send. Bound: Send + Sync + Debug + 'static. Blanket impls for Box<T>, Arc<T>, plus an AccessLimit<P> wrapper for access-controlled handlers — the official allowlist hook."
---

# iroh::protocol::Router — multi-ALPN dispatch on one Endpoint

## Construction

```rust
use iroh::protocol::Router;

let router = Router::builder(endpoint)
    .accept(b"sv2/0",       SvHandler::new())
    .accept(b"iroh/blobs/0", blobs.clone())
    .accept(b"DUMBPIPEV0",  DumbpipeHandler)
    .accept(b"my/inference/1", InferenceHandler)
    .spawn();

// dynamic registration after spawn:
router.accept(b"my/admin/1", AdminHandler).await?;

// graceful shutdown:
router.shutdown().await;
```

## ProtocolHandler trait

```rust
pub trait ProtocolHandler: Send + Sync + Debug + 'static {
    fn accept(&self, connection: Connection)
        -> impl Future<Output = Result<(), AcceptError>> + Send;

    // provided
    fn on_accepting(&self, accepting: Accepting)
        -> impl Future<Output = Result<Connection, AcceptError>> + Send;
    fn shutdown(&self) -> impl Future<Output = ()> + Send;
}
```

Blanket impls for `Box<T: ProtocolHandler>` and `Arc<T: ProtocolHandler>`.

## AccessLimit<P> — the allowlist primitive

`AccessLimit<P>` is a `ProtocolHandler` wrapper that gates calls to the inner handler by NodeID. It's the official seam for allowlist-gated production deployments.

```rust
use iroh::protocol::AccessLimit;

let allowed: HashSet<EndpointId> = load_allowlist();
let gated = AccessLimit::new(MyHandler::new(state),
    move |id| allowed.contains(&id));

let router = Router::builder(endpoint)
    .accept(b"my/proto/1", gated)
    .spawn();
```

This is what dumbpipe's main.rs lacks (see [[2026-06-01-dumbpipe-binary]]) and what `rustonbsd/iroh-ssh` lacks (see [[2026-06-01-iroh-ssh-rustonbsd]]).

## ALPN preference order

Peers may offer multiple ALPNs in client preference order for explicit version negotiation:

```rust
endpoint.connect(addr, &[b"my-protocol/2", b"my-protocol/1"]).await?;
```

The server picks the highest-preference one it supports per RFC 7301 ([[2026-06-01-rfc-7301-alpn]]).

## Lifecycle

- `abort-on-drop` semantics
- explicit `shutdown()` and `is_shutdown()` for graceful handler termination
- important for CLIs and tests where you can't rely on process exit

## Companion: iroh-base 1.0.0-rc.1

Ships alongside; description "base type and utilities for Iroh." Tickets moved to dedicated `iroh-tickets` crate at 0.94 (see [[2026-06-01-iroh-tickets-security-model]]).
