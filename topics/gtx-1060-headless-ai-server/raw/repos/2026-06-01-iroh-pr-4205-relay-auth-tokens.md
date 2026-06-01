---
title: "iroh PR #4205 — feat(iroh, iroh-relay)!: support setting auth tokens for relays"
source: https://github.com/n0-computer/iroh/pull/4205
type: repo
tags: [iroh, iroh-relay, auth-tokens, bearer, multitenant, pr]
date: 2026-06-01
publication_date: 2026-05-06
quality: 5
confidence: high
agent: technical
summary: "MERGED 2026-05-06 (#4205); #4194 closed superseded. Adds RelayConfig::auth_token: Option<String> and RelayConfig::with_auth_token builder. Native: token sent as `Authorization: Bearer TOKEN` on the WS upgrade. Browser: `?token=TOKEN` query param. Server-side hook: AccessConfig::Restricted callback now (EndpointId, &HeaderMap) -> bool (or async via AccessCheck alias); ClientRequest::auth_token() extracts the token regardless of transport path. New ClientBuilder::auth_token and ConnectError::InvalidAuthToken variant. Includes a multitenant example in iroh-relay."
---

# iroh PR #4205 — relay auth tokens (merged 2026-05-06)

iroh's first-class **relay-tier** bearer-token auth. Complements `AccessLimit<P>` (protocol-tier).

## What landed

### Client side

```rust
let endpoint = Endpoint::builder()
    .relay_mode(RelayMode::Custom(RelayMap::from_url(relay_url)))
    .relay_auth_token("Bearer mytoken")  // native
    .bind()
    .await?;
```

Native: token sent as `Authorization: Bearer TOKEN` HTTP header on the WS upgrade.
Browser: token sent as `?token=TOKEN` query parameter.

### Server side

```rust
use iroh_relay::server::{AccessConfig, AccessCheck};

let server = ServerConfig::builder()
    .access_control(AccessConfig::Restricted(Box::new(
        |endpoint_id: EndpointId, headers: &HeaderMap| async move {
            let token = ClientRequest::auth_token(headers)?;
            validate_token(token, endpoint_id).await
        }
    )))
    .spawn()
    .await?;
```

The hook gets:

- `EndpointId` — Ed25519 pubkey of the connecting peer
- `&HeaderMap` — full HTTP headers (auth token, custom headers, etc.)

Sync via `Restricted` enum variant; async via `AccessCheck` alias.

## ClientRequest::auth_token

```rust
fn auth_token(headers: &HeaderMap) -> Option<&str>
```

Extracts the token regardless of transport path (Bearer header on native, `?token=` on browser).

## ConnectError::InvalidAuthToken

New error variant on the client side — graceful failure when the relay rejects the token.

## multitenant example

Located in `iroh-relay/examples/multitenant.rs`. Demonstrates a relay that accepts multiple tenants identified by token; each tenant has independent rate limits.

## How this differs from AccessLimit

| | AccessLimit (PR #3157, 2025-03) | Relay auth tokens (PR #4205, 2026-05) |
|--|---------------------------------|----------------------------------------|
| Where | Protocol handler tier (Router) | Relay tier (iroh-relay) |
| What it gates | Connections to a specific ALPN | Connections to the relay itself |
| Inputs | EndpointId only | EndpointId + HeaderMap (token) |
| Async | sync closure | async via `AccessCheck` |
| Use case | Allowlist friends per-service | Multi-tenant relay; pay-for-relay |

## Implication for the iroh app token wrapper

The wrapper ships a token format. **Same token can be used at both tiers**:

- Embed in `Authorization: Bearer` for relay auth (PR #4205)
- Validate in a separate ALPN handshake before AccessLimit allowlist update (PR #3157 + auth-hook.rs)

→ One token format, two integration points. The wiki's design doc should specify this dual-use explicitly.

## See also

- [[2026-06-01-iroh-pr-3157-accesslimit]]
- [[2026-06-01-iroh-auth-hook-example]]
