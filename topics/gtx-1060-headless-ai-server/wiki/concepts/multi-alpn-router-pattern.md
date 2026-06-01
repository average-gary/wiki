---
title: "Multi-ALPN dispatch on one Iroh Router"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-rfc-7301-alpn.md
  - raw/repos/2026-06-01-iroh-router-protocolhandler-docs.md
  - raw/repos/2026-06-01-iroh-examples-custom-router.md
  - raw/articles/2026-06-01-iroh-1-0-0-rc-1.md
  - raw/articles/2026-06-01-iroh-memory-leak-issues.md
tags: [iroh, router, alpn, protocolhandler, accesslimit, dispatch]
---

# Multi-ALPN dispatch on one Iroh Router

Host every service the homelab AI server exposes — moq, blobs, ssh-tunnel, inference RPC, metrics, admin — on **one** iroh `Endpoint`, dispatched by ALPN.

## The pattern

```rust
use iroh::Endpoint;
use iroh::protocol::{Router, AccessLimit};

let endpoint = Endpoint::builder()
    .secret_key(persistent_key)
    .alpns(vec![
        b"iroh/blobs/0".to_vec(),
        b"DUMBPIPEV0".to_vec(),
        web_transport_iroh::ALPN.to_vec(),
        b"my/inference/1".to_vec(),
        b"my/metrics/1".to_vec(),
        b"my/admin/1".to_vec(),
    ])
    .bind()
    .await?;

let allowed = load_allowlist();  // HashSet<EndpointId>

let router = Router::builder(endpoint)
    .accept(b"iroh/blobs/0", blobs_handler)
    .accept(b"DUMBPIPEV0",
        AccessLimit::new(SshTunnel::new(),
            move |id| allowed.contains(&id)))
    .accept(web_transport_iroh::ALPN, moq_handler)
    .accept(b"my/inference/1", InferenceHandler::new(model.clone()))
    .accept(b"my/metrics/1", MetricsHandler::new())
    .accept(b"my/admin/1",
        AccessLimit::new(AdminHandler::new(),
            move |id| admin_allowed.contains(&id)))
    .spawn();

// Optional: dynamic registration after spawn
router.accept(b"my/healthcheck/1", HealthHandler).await?;
```

## How dispatch works

1. Client sends ALPN extension list in TLS 1.3 ClientHello (per [[rfc-7301-alpn]])
2. iroh's QUIC handshake sees the list
3. iroh server picks the best match against the registered set in the `Router`
4. iroh routes the accepted `Connection` to the registered `ProtocolHandler::accept(connection)`

This is **RFC 7301 selection happening inside the QUIC TLS 1.3 handshake**, with server-side dispatch delegated to a Rust hashmap.

## Naming conventions

- Iroh-canonical: `iroh/<protocol>/<version>` (e.g., `iroh/blobs/0`)
- App-specific: any byte string (e.g., `DUMBPIPEV0`, `sv2/0`)
- Per-role variants: `iroh/myproto/role-A/0` for sub-services on the same identity

## ALPN preference / version negotiation

Clients can send a preference-ordered list:

```rust
endpoint.connect(addr, &[b"my/proto/2", b"my/proto/1"]).await?;
```

Server picks the highest match it supports → graceful version transitions.

## AccessLimit — the allowlist primitive

`AccessLimit<P: ProtocolHandler>` is iroh's official seam for allowlist-gated handlers:

```rust
let gated = AccessLimit::new(MyHandler::new(), |id: EndpointId| {
    allowed.contains(&id)
});
```

This is what you wrap around any handler that should reject unknown peers. **dumbpipe and `rustonbsd/iroh-ssh` both lack this** — see [[iroh-as-ssh-transport]] for the production hardening recipe.

## Why one Endpoint, not many

- One persistent secret key → one `EndpointID` → one identity to share
- One NAT punch / hole-punch budget
- One QUIC listener socket
- Cleaner ops (one ticket, one allowlist file, one log stream)
- Simpler client config (one ticket for everything)

The recommendation from iroh docs is **"one Endpoint per app — multiplex services over it with multiple ALPNs, not multiple Endpoints."**

## Ops gotchas

### Memory leak risk on long-running handlers

iroh issue #3963 documents that the tracing span on `Router::accept` persists for the handler's lifetime, accumulating child spans on long-lived idle connections. Affects 0.93.0 and main. See [[2026-06-01-iroh-memory-leak-issues]].

**Mitigations:**
- Push connection work to a tokio task; return from `accept()` quickly
- Filter the `router.accept` span in tracing-subscriber config
- Schedule weekly process restart via systemd

### ALPN string collisions

Two services with the same ALPN bytes will silently route to whichever handler was registered last. Use namespaced ALPN strings, never bare names like `b"chat"`.

### No load-balancing per-ALPN

If you want different ALPNs to land on different machines, `Router` doesn't help — that's an upstream concern (e.g., DNS-based EndpointID rotation).

## Reference example

`iroh-examples/custom-router` is the canonical multi-ALPN code sample. See [[2026-06-01-iroh-examples-custom-router]].

## See also

- [[moq-over-iroh-pattern]] — one of the ALPNs to register
- [[iroh-blobs-resumable-uploads]] — another ALPN
- [[iroh-as-ssh-transport]] — another ALPN, with allowlist gating
- [[rfc-7301-alpn]] — the underlying TLS extension
- [[iroh-application-patterns-2026-synthesis]]
