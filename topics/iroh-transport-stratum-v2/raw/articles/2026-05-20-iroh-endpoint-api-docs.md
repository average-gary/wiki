---
title: "iroh::endpoint::Endpoint API (docs.rs)"
source_url: https://docs.rs/iroh/latest/iroh/endpoint/struct.Endpoint.html
type: docs
date: 2026-05-20
org: n0-computer
iroh_version: 0.98.2
credibility: high
quality: 5
relevance: direct
tags: [iroh, api, endpoint, alpn, transport]
ingested: 2026-05-20
---

# iroh `Endpoint` API

The main P2P QUIC interface. Recommended one instance per app.

## Construction

```rust
use iroh::{Endpoint, presets};

// Builder form
let ep = Endpoint::builder(presets::N0)
    .alpns(vec![b"sv2/0".to_vec()])
    .secret_key(secret_key)        // stable identity across restarts
    .bind()
    .await?;

// One-liner (uses default alpns = [])
let ep = Endpoint::bind(presets::N0).await?;
```

`presets::N0` selects n0's default relay set + default discovery. For production
SV2 deployments this should be replaced with a custom relay (see Relays page).

## Dial

```rust
pub async fn connect(
    &self,
    endpoint_addr: impl Into<EndpointAddr>,
    alpn: &[u8],
) -> Result<Connection, ConnectError>;

pub async fn connect_with_opts(
    &self,
    addr: impl Into<EndpointAddr>,
    alpn: &[u8],
    opts: ConnectOptions,
) -> Result<Connecting, ConnectError>;
```

ALPN is bytes, passed per dial. SV2 should pick something like `b"sv2/0"` or a
per-role variant (`b"sv2/pool/0"`, `b"sv2/jds/0"`, `b"sv2/jdc/0"`, `b"sv2/tproxy/0"`).

## Accept

```rust
pub fn accept(&self) -> Accept<'_>;
```

Returns a future yielding the next inbound `Connecting`. Loop and spawn per accept.

## Identity

```rust
fn secret_key(&self) -> &SecretKey;        // Ed25519
fn id(&self) -> EndpointId;                 // derived from public key
fn addr(&self) -> EndpointAddr;             // pubkey + relay url + direct addrs
fn watch_addr(&self);                       // observe addr changes
```

`EndpointId` is the public-key-as-identity primitive. SV2 currently uses a
secp256k1 authority pubkey embedded in `stratum2+tcp://thepool.com:34254/...`
URLs (base58check `[1, 0]` versioned). On Iroh that pubkey would be the Ed25519
`EndpointId` — note the curve mismatch (secp256k1 vs Ed25519).

## Relay management (dynamic)

```rust
fn insert_relay(url: RelayUrl, config: Arc<RelayConfig>);
fn remove_relay(url: &RelayUrl);
```

Lets a pool fail over between relay sets at runtime.

## NAT external addr (manual)

```rust
fn add_external_addr(addr: SocketAddr);
fn remove_external_addr(addr: &SocketAddr);
```

For pool ingress where the operator already has a static public IP and just
wants to publish it.

## Lifecycle

```rust
async fn online();           // wait until at least one relay is reachable
fn bound_sockets() -> ...;
async fn close();
fn is_closed() -> bool;
async fn closed();
```

## TLS access

```rust
fn tls_config(&self) -> &ClientConfig;
fn create_server_config_builder(alpns: ...) -> ServerConfigBuilder;
```

Direct hooks for the underlying rustls config — useful if SV2 wants to lock
ciphers (cf. ESP32 use case which restricts to `TLS13_AES_128_GCM_SHA256` + `X25519`).

## Verbatim docs.rs

> "It's recommended to create only one instance per application to optimize
> network behavior across all connections."

## Notes for this branch

- The crate's `presets::N0` default depends on n0's hardcoded relay servers.
  For a pool, plan to replace with a custom RelayConfig pointing at self-hosted
  relays (or no relay if pool has stable public IP).
- `Endpoint::builder` is the right hook for `IrohNodeManager` (cf. SRI #1935).
