---
title: "Integration pattern — iroh-blobs and Delta Chat as templates"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-20-iroh-blobs-alpn-template.md
  - raw/repos/2026-05-20-deltachat-peer-channels.md
  - raw/repos/2026-05-20-iroh-examples-framed-messages.md
  - raw/articles/2026-05-20-iroh-paycode-case-study.md
tags: [iroh, integration, alpn, pattern]
---

# Integration pattern — copy these

The shape of an iroh transport integration is well-established across multiple
production codebases.

## The 30-line template

From Delta Chat (`peer_channels.rs`, in production at millions-of-installs scale):

```rust
let endpoint = Endpoint::builder()
    .secret_key(secret_key)                    // load from disk
    .alpns(vec![SV2_ALPN.to_vec()])
    .relay_mode(relay_mode)                    // configurable
    .bind()
    .await?;

let router = iroh::protocol::Router::builder(endpoint.clone())
    .accept(SV2_ALPN, Sv2Handler::new(state))
    .spawn();
```

Where `Sv2Handler` is:

```rust
struct Sv2Handler { /* state */ }

impl iroh::protocol::ProtocolHandler for Sv2Handler {
    async fn accept(&self, connection: Connection) -> Result<(), AcceptError> {
        let peer = connection.get_remote_endpoint_id()?;
        let (send, recv) = connection.accept_bi().await?;
        // Hand off to network_helpers_sv2::iroh_connection adapter,
        // which produces the same (Receiver<Sv2Frame>, Sender<Sv2Frame>) pair
        // as noise_connection does today.
        run_sv2_session(peer, send, recv, self.state.clone()).await
    }
}
```

## The framing

From `iroh-examples/framed-messages`: wrap iroh streams with the existing SV2
codec — just substitute `tokio_util::codec::LengthDelimitedCodec` (which the
example uses) for `codec_sv2::StandardSv2Frame` (which SV2 already has).

## The dial

```rust
let conn = endpoint.connect(addr, SV2_ALPN).await?;
let (send, recv) = conn.open_bi().await?;
// hand to same adapter
```

## The ticket

From Paycode (production, payment terminals):

```
ticket = encode(EndpointAddr { id, addrs, relay })
```

Pool publishes the ticket. Equivalent of today's
`stratum2+tcp://thepool.com:34254/<base58check>` URL — but with addrs and
relay hints instead of DNS.

## Stable identity

From all three (iroh-blobs, Delta Chat, Paycode): persist the secret key.
Ed25519, 32 bytes. SQLite for Delta Chat; JSON config for SV2 fits the existing
`stratum-apps/src/key_utils.rs` pattern.

## Multiple ALPNs on one endpoint

From `iroh-examples/custom-router`:

```rust
let router = Router::builder(endpoint)
    .accept(b"sv2/0", Sv2MainHandler::new(...))
    .accept(b"sv2/admin/0", Sv2AdminHandler::new(...))
    .accept(b"sv2/metrics/0", Sv2MetricsHandler::new(...))
    .spawn();
```

Cleaner than running multiple TCP listeners on different ports — one endpoint,
one identity, multiple services.

## See also

- [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]]
- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
