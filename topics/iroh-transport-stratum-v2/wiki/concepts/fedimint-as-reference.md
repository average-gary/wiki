---
title: "Fedimint as the reference implementation"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/repos/2026-05-20-fedimint-iroh-integration.md
tags: [fedimint, iroh, reference-impl, production-lessons]
---

# Fedimint as the reference implementation

SRI Discussion #1935 cites Fedimint as prior art. The Fedimint codebase is
**directly portable to SV2** — the integration shape, identity model, ALPN
strategy, and operational primitives all map cleanly. This article extracts
the patterns worth copying.

## The trait

`fedimint-server/src/net/p2p_connector.rs`:

```rust
#[async_trait]
pub trait IP2PConnector<M>: Send + Sync + 'static {
    fn peers(&self) -> Vec<PeerId>;
    async fn connect(&self, peer: PeerId) -> anyhow::Result<DynP2PConnection<M>>;
    async fn accept(&self) -> anyhow::Result<(PeerId, DynP2PConnection<M>)>;
    fn connection_type(&self, peer: PeerId) -> Option<ConnectionType>;
}
```

Two implementations side-by-side: `mod iroh; mod tls;`. Same trait, different
transport. **This is structurally what SRI #1935 calls for.**

## ALPN per role (not a single shared ALPN)

```rust
pub(crate) const FEDIMINT_P2P_ALPN:     &[u8] = b"FEDIMINT_P2P_ALPN";       // guardian ↔ guardian
pub(crate) const FEDIMINT_API_ALPN:     &[u8] = b"FEDIMINT_API_ALPN";       // client ↔ guardian
pub(crate) const FEDIMINT_GATEWAY_ALPN: &[u8] = b"FEDIMINT_GATEWAY_ALPN";   // ln-gateway ↔ guardian
```

This is **stronger than the playbook's earlier "use a single `b"sv2/0"` ALPN"
recommendation**. Fedimint's three roles are exactly analogous to SV2's
roles. Better to split:

- `b"sv2/pool/0"` — pool ↔ proxy
- `b"sv2/jds/0"` — JD-Server ↔ pool / TP
- `b"sv2/jdc/0"` — JD-Client ↔ JD-Server
- `b"sv2/tproxy/0"` — Translator Proxy ↔ pool

Trade-off: more constants, but a misconfigured client is rejected at the QUIC
ALPN layer rather than failing partway through an SV2 handshake.

(Update to playbook: this changes the recommendation. See [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]] § ALPN.)

## Identity above iroh

```rust
pub struct IrohConnector {
    pub(crate) node_ids: BTreeMap<PeerId, NodeId>,
    pub(crate) endpoint: Endpoint,
    pub(crate) connection_overrides: BTreeMap<NodeId, NodeAddr>,
}

async fn accept(&self) -> anyhow::Result<(PeerId, DynP2PConnection<M>)> {
    let connection = self.endpoint.accept().await?.accept()?.await?;
    let node_id = connection.remote_node_id()?;
    let auth_peer = self.node_ids.iter()
        .find(|entry| entry.1 == &node_id)
        .with_context(|| format!("Node id {node_id} is unknown"))?
        .0;
    Ok((*auth_peer, connection.into_dyn()))
}
```

Two-layer identity:
- **iroh layer**: Ed25519 NodeId from `connection.remote_node_id()`.
- **App layer**: PeerId / SV2 authority pubkey, looked up in a config-time
  trust map.

For SV2: keep the existing secp256k1 authority pubkey as the SV2-layer
identity. Add an `iroh_node_id` field to pool/peer config alongside it. On
accept, look up `node_id → authority_pubkey`, then run Noise_NX (which checks
the secp256k1 signature) inside.

Result: a tampered iroh NodeId is rejected at accept; a forged Noise cert is
rejected during handshake; a peer must pass both.

## Connection overrides — escape hatch for testing

```rust
connection_overrides: BTreeMap<NodeId, NodeAddr>
```

Populated from `FM_IROH_CONNECT_OVERRIDES_ENV` via `parse_kv_list_from_env()`.

Lets ops/test override "look up this NodeId via discovery" with "use this
explicit NodeAddr." Useful for test harnesses, devnets, and air-gapped
deployments. SV2 should expose the same escape hatch.

## Discovery — toggleable per-mechanism

`build_iroh_endpoint` (in `fedimint-core/src/net/iroh.rs`) reads:
- `FM_IROH_RELAYS_ENABLE` (default on)
- `FM_IROH_PKARR_PUBLISHER_ENABLE` (default on)
- `FM_IROH_PKARR_RESOLVER_ENABLE` (default on)
- `FM_IROH_DHT_ENABLE` (default **off**, non-WASM only)
- `FM_IROH_N0_DISCOVERY_ENABLE` (default on)

**Each discovery mechanism is independently switchable.** Lets ops disable n0
discovery for privacy reasons without losing pkarr or DHT. SV2 should match.

## QUIC keepalive (mandatory for long-lived sessions)

PR #8422:
- `max_idle_timeout = 60s`
- `keep_alive_interval = 30s`

Without these, dead connections accumulate. SV2 mining sessions are even
longer-lived than Fedimint guardian connections — this is non-optional.

## Per-request timeout + explicit close on expiry

PR #8571 — production lesson learned the hard way (long-running client
wedging at 42–48 minutes post-restart):

```rust
let result = fedimint_core::runtime::timeout(timeout, async {
    let (mut sink, mut stream) = self.open_bi().await?;
    sink.write_all(&json).await?;
    sink.finish()?;
    stream.read_to_end(IROH_MAX_RESPONSE_BYTES).await
}).await;

// On expiry:
self.close(
    iroh::endpoint::VarInt::from_u32(1),
    b"request timeout",
);
```

Why: QUIC keepalive can succeed while the data path stalls (relay drift, NAT
rebinding). The connection looks healthy; bi-stream operations hang forever.
Wrap every bi-stream operation in `runtime::timeout`, and on expiry call
`Connection::close` so subsequent pool lookups detect `close_reason()` and
evict.

For SV2 this is even more important: stalled mining sessions = lost shares.

## Dual-stack iroh-version migration (PR #8400)

Fedimint pins **two iroh versions simultaneously**:
- `iroh = "=0.35.0"` — current production
- `iroh-next = "=0.96.1"` (packaged as `iroh`) — migration target

Servers publish their `iroh_next_endpoint` and `iroh_next_version` in signed
guardian metadata. Clients prefer the newer stack when both sides support it.

This is the **upgrade strategy SV2 will need** when iroh hits 1.0 → 1.1+ and
breaking changes happen. The federation-metadata channel is analogous to the
SV2 setup messages (which advertise capabilities).

## Observability — ship it from day one

- PR #8423: Prometheus metrics for iroh API connections and requests
- PR #8520: connection type exposed in `connection_status_stream`
  (`iroh-direct` vs `iroh-relay` vs `tcp`)
- PR #8524: log when DHT discovery is enabled

Don't bolt these on after a production stall. Ship them with the integration.

## Production gotchas to pre-empt in SV2

1. **Don't `read_to_end(arbitrary_constant)`** — Fedimint's 1MB cap broke
   federation catchup at scale (#8383). SV2 has spec-defined frame limits;
   use those.
2. **Don't panic on bind failure** — propagate the error (#8482, #8518).
3. **Set explicit keepalive** — don't rely on defaults (#8422).
4. **Wrap every bi-stream op in a timeout** — keepalive succeeding doesn't
   mean data is moving (#8571).

## See also

- [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]] — incorporates these lessons
- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
- [[Risks and tradeoffs|wiki/topics/risks-and-tradeoffs.md]]
- [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]]
