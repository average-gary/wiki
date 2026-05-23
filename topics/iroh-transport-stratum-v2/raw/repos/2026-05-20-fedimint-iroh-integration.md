---
title: "Fedimint — production Iroh transport (reference implementation)"
source_url: https://github.com/fedimint/fedimint
secondary_urls:
  - https://github.com/fedimint/fedimint/blob/master/fedimint-server/src/net/p2p_connector/iroh.rs
  - https://github.com/fedimint/fedimint/blob/master/fedimint-connectors/src/iroh.rs
  - https://github.com/fedimint/fedimint/blob/master/fedimint-core/src/net/iroh.rs
  - https://github.com/fedimint/fedimint/pull/8400
  - https://github.com/fedimint/fedimint/pull/8571
  - https://github.com/fedimint/fedimint/pull/8422
  - https://github.com/fedimint/fedimint/issues/8383
type: repo
date: 2026-05-20
org: Fedimint
credibility: high
quality: 5
relevance: direct
tags: [fedimint, iroh, reference-impl, production, alpn, dual-stack]
ingested: 2026-05-20
---

# Fedimint — production Iroh transport

The reference implementation cited in SRI Discussion #1935. Fedimint runs Iroh
in production for federation guardian-to-guardian P2P, guardian-to-client API,
and lightning gateway connectivity.

## Versions pinned (workspace `Cargo.toml`)

```
iroh           = "=0.35.0"     # stable / current production
iroh-base      = "=0.35.0"
iroh-relay     = "=0.35.0"
iroh-next      = "=0.96.1"     # packaged as "iroh"      — migration target
iroh-next-base = "=0.96.1"     # packaged as "iroh-base"
```

**Dual-stack migration pattern**: workspace pins both 0.35.x stable AND 0.96.x
"next" simultaneously via `iroh-next` rename. PR #8400 (`feat: iroh-next
server-side connectivity and iroh server side migration`) coordinates upgrade
via guardian metadata: servers publish their `iroh_next_endpoint` and
`iroh_next_version`; clients prefer the new stack when both sides support it.

> "Current Fedimint uses semi-stable Iroh 0.35, lagging behind improvements.
> The PR enables gradual migration without requiring synchronized upgrades
> across all participants."

## Three ALPNs, three roles

```rust
pub(crate) const FEDIMINT_P2P_ALPN:     &[u8] = b"FEDIMINT_P2P_ALPN";
pub(crate)        FEDIMINT_API_ALPN:     ... = ...
pub(crate)        FEDIMINT_GATEWAY_ALPN: ... = ...
```

- `FEDIMINT_P2P_ALPN` — guardian ↔ guardian consensus / gossip
- `FEDIMINT_API_ALPN` — client ↔ guardian RPC (the "API")
- `FEDIMINT_GATEWAY_ALPN` — lightning gateway ↔ guardian

Direct parallel for SV2: per-role ALPNs would be `b"sv2/pool/0"`,
`b"sv2/jds/0"`, `b"sv2/jdc/0"`, `b"sv2/tproxy/0"`.

## P2P connector shape (this is what SRI #1935 looks like in practice)

`fedimint-server/src/net/p2p_connector.rs`:

```rust
#[async_trait]
pub trait IP2PConnector<M>: Send + Sync + 'static {
    fn peers(&self) -> Vec<PeerId>;
    async fn connect(&self, peer: PeerId) -> anyhow::Result<DynP2PConnection<M>>;
    async fn accept(&self) -> anyhow::Result<(PeerId, DynP2PConnection<M>)>;
    fn connection_type(&self, peer: PeerId) -> Option<ConnectionType>;
}

pub type DynP2PConnector<M> = Arc<dyn IP2PConnector<M>>;
```

Two implementations live side-by-side:
```rust
mod iroh;
mod tls;
```

This is structurally identical to what SV2 wants: a transport-agnostic trait
with `iroh` and `tcp+noise` implementations.

## IrohConnector

`fedimint-server/src/net/p2p_connector/iroh.rs`:

```rust
use iroh::{Endpoint, NodeAddr, NodeId, SecretKey};
use iroh_base::ticket::NodeTicket;
use fedimint_core::net::iroh::build_iroh_endpoint;
use fedimint_core::envs::{FM_IROH_CONNECT_OVERRIDES_ENV, parse_kv_list_from_env};

pub(crate) const FEDIMINT_P2P_ALPN: &[u8] = b"FEDIMINT_P2P_ALPN";

#[derive(Debug, Clone)]
pub struct IrohConnector {
    pub(crate) node_ids: BTreeMap<PeerId, NodeId>,
    pub(crate) endpoint: Endpoint,
    pub(crate) connection_overrides: BTreeMap<NodeId, NodeAddr>,
}

impl<M> IP2PConnector<M> for IrohConnector {
    async fn connect(&self, peer: PeerId) -> anyhow::Result<DynP2PConnection<M>> {
        let node_id = *self.node_ids.get(&peer).expect("No node id found for peer");
        let connection = match self.connection_overrides.get(&node_id) {
            Some(node_addr) => self.endpoint.connect(node_addr.clone(), FEDIMINT_P2P_ALPN).await?,
            None            => self.endpoint.connect(node_id,           FEDIMINT_P2P_ALPN).await?,
        };
        Ok(connection.into_dyn())
    }

    async fn accept(&self) -> anyhow::Result<(PeerId, DynP2PConnection<M>)> {
        let connection = self.endpoint.accept().await
            .context("Listener closed unexpectedly")?
            .accept()?
            .await?;
        let node_id = connection.remote_node_id()?;
        let auth_peer = self.node_ids.iter()
            .find(|entry| entry.1 == &node_id)
            .with_context(|| format!("Node id {node_id} is unknown"))?
            .0;
        Ok((*auth_peer, connection.into_dyn()))
    }
}
```

Identity model:
- `PeerId` (Fedimint guardian index) → `NodeId` (iroh Ed25519 EndpointId) is a
  config-time map.
- On accept, get `remote_node_id()`, look it up in the trust map. Reject if
  unknown.
- This is exactly how SV2 should authenticate the iroh layer's peer identity
  against the existing SV2 authority pubkey trust list.

## build_iroh_endpoint — central construction helper

`fedimint-core/src/net/iroh.rs`:

```rust
pub async fn build_iroh_endpoint(
    secret_key: SecretKey,
    bind_addr: SocketAddr,
    iroh_dns: Option<SafeUrl>,
    iroh_relays: Vec<SafeUrl>,
    alpn: &[u8],
) -> Result<Endpoint, anyhow::Error> {
    // ...
    let builder = builder
        .relay_mode(relay_mode)
        .secret_key(secret_key)
        .alpns(vec![alpn.to_vec()]);
    // ... bind to IPv4 or IPv6 based on SocketAddr type ...
}
```

Discovery configuration via env vars (each individually toggleable):
- `FM_IROH_RELAYS_ENABLE` (default: enabled)
- `FM_IROH_PKARR_PUBLISHER_ENABLE` (default: true)
- `FM_IROH_PKARR_RESOLVER_ENABLE` (default: true)
- `FM_IROH_DHT_ENABLE` (default: **disabled**, non-WASM only)
- `FM_IROH_N0_DISCOVERY_ENABLE` (default: true)

Operational lesson: each discovery mechanism is independently switchable.
Lets ops disable n0 discovery (privacy) without losing pkarr or DHT.

## Production gotcha — the 1MB read_to_end limit (#8383)

Closed bug (March 2026):
- Code at three sites in `fedimint-connectors/src/iroh.rs`:
  ```rust
  let response = stream.read_to_end(1_000_000)...
  ```
- Real-world impact: a peer fell behind to session 53,913 while others
  reached 57,136+. "Transport error: stream too long" on catch-up download.
- Lesson: **don't pick an arbitrary `read_to_end` limit**. SV2 frames are
  bounded by `B0_64K` (65,535 bytes) so the framing itself caps it, but if
  you're tempted to write `read_to_end(N)` somewhere, derive N from the spec.

## Production gotcha — bi-stream stall + connection eviction (#8571 — May 2026)

> "The iroh `IGuardianConnection::request` implementation lacked per-request
> timeouts, relying only on QUIC-level `close_reason` checks. When QUIC
> keepalive remained functional but data paths stalled (relay drift, NAT
> rebinding, peer congestion), subsequent `open_bi` calls succeeded yet
> `read_to_end` never resolved. The cached connection appeared healthy
> indefinitely."

The fix:
```rust
let result = fedimint_core::runtime::timeout(timeout, async {
    let (mut sink, mut stream) = self.open_bi().await?;
    sink.write_all(&json).await?;
    sink.finish()?;
    stream.read_to_end(IROH_MAX_RESPONSE_BYTES).await
}).await;

// On timeout:
self.close(
    iroh::endpoint::VarInt::from_u32(IROH_REQUEST_TIMEOUT_ERROR_CODE),  // = 1
    IROH_REQUEST_TIMEOUT_ERROR_REASON,                                  // = b"request timeout"
);
```

Two-tier timeout selection by method name:
- 60-second default for prompt endpoints (`block_count`, `status`, queries)
- 60-minute long-poll for `await_*` / `wait_*` methods

> "Long-running client previously wedging at 42–48 minutes post-restart
> achieved 11+ hours with zero timeouts after pinning this fix."

## Production gotcha — explicit QUIC idle/keepalive (#8422)

`max_idle_timeout = 60s`, `keep_alive_interval = 30s` on the server-side iroh
endpoint. Without these, dead connections accumulate and exhaust connection
limits.

For SV2: long-lived mining sessions need **explicit QUIC keepalive**. Don't
rely on iroh defaults — set them explicitly in the endpoint builder.

## Production gotcha — bind error swallowing (#8482, #8518)

> "fix(iroh): bind failure returns error instead of panicking"

Earlier code panicked on iroh bind failure. SV2 should propagate bind errors,
not panic — same lesson.

## Production observability adds (#8423, #8520, #8524)

- Prometheus metrics for iroh API connections and requests
- Connection type exposed in `connection_status_stream` (so dashboards can
  show "this peer is over iroh-direct vs iroh-relay vs TCP")
- DHT discovery enable/disable logged at startup

For SV2: budget observability hooks at integration time, not after.

## Synthesis for SV2

1. **The `IP2PConnector` trait pattern** is exactly what SRI #1935 wants —
   transport-agnostic trait with iroh and TLS impls living side-by-side. Copy
   this shape.
2. **Per-role ALPN**: Fedimint splits into 3 ALPNs (P2P, API, gateway). SV2
   should split per role (pool, JDS, JDC, tproxy).
3. **Identity above iroh**: `BTreeMap<DomainPeerId, NodeId>`. On accept,
   `remote_node_id()` → trust-map lookup. Direct port for SV2 authority key
   trust.
4. **Dual-stack version pinning**: Fedimint pins iroh-stable AND iroh-next via
   the `iroh-next` package rename. SV2 doesn't need this initially but should
   remember it when iroh 1.0 → 1.1 lands.
5. **Mandatory operational primitives**: explicit QUIC keepalive
   (60s/30s), per-request timeouts with explicit `Connection::close` on
   expiry, bind errors propagated not panicked, prometheus metrics, env-var
   toggles for each discovery mechanism (relay / pkarr-pub / pkarr-res / DHT
   / n0). These were all bugs filed and fixed in production. Ship them
   pre-emptively.
6. **Don't pick arbitrary `read_to_end` limits**. Derive from spec.

## Key URLs

- Connector trait: https://github.com/fedimint/fedimint/blob/master/fedimint-server/src/net/p2p_connector.rs
- Iroh impl: https://github.com/fedimint/fedimint/blob/master/fedimint-server/src/net/p2p_connector/iroh.rs
- Build helper: https://github.com/fedimint/fedimint/blob/master/fedimint-core/src/net/iroh.rs
- Client connector: https://github.com/fedimint/fedimint/blob/master/fedimint-connectors/src/iroh.rs
- Migration PR: https://github.com/fedimint/fedimint/pull/8400
- Timeout PR: https://github.com/fedimint/fedimint/pull/8571
- Keepalive PR: https://github.com/fedimint/fedimint/pull/8422
- 1MB-limit bug: https://github.com/fedimint/fedimint/issues/8383
