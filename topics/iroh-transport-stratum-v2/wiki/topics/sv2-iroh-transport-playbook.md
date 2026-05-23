---
title: "Integration playbook — Iroh transport for SV2"
type: topic
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: hot
confidence: high
sources:
  - raw/articles/2026-05-20-sri-discussion-1935-iroh-noise-connection.md
  - raw/articles/2026-05-20-iroh-endpoint-api-docs.md
  - raw/articles/2026-05-20-iroh-1-0-0-rc-0.md
  - raw/articles/2026-05-20-iroh-relays-concept.md
  - raw/articles/2026-05-20-sv2-protocol-security-noise-nx.md
  - raw/articles/2026-05-20-sv2-protocol-overview-framing.md
  - raw/repos/2026-05-20-deltachat-peer-channels.md
  - raw/repos/2026-05-20-iroh-blobs-alpn-template.md
  - raw/repos/2026-05-20-iroh-examples-framed-messages.md
tags: [iroh, sv2, integration, playbook]
---

# Integration playbook — Iroh transport for SV2

The synthesis. The deliverable. Read [[Why Iroh|wiki/topics/why-iroh-for-sv2.md]]
first if you need the motivation; this document is _how_.

## Scope

Replace SV2's TCP+Noise transport with an Iroh-based alternative that:

- Preserves SV2's existing `(Receiver<Sv2Frame>, Sender<Sv2Frame>)` channel
  abstraction so higher-level code (`roles_logic_sv2`, channel management) is
  untouched.
- Lets a pool run **dual transport** (TCP + Iroh simultaneously) for migration.
- Lets a client **fall back** between transports for resilience.

This is the SRI Discussion #1935 RFC. The branch implementing this is the local
`feat/iroh-transport`.

## API shape

Mirror the existing `network_helpers_sv2::noise_connection` API:

```rust
// Existing
pub async fn connect_with_noise<M>(
    stream: TcpStream,
    authority_pub_key: Option<Secp256k1PublicKey>,
) -> Result<NoiseTcpStream<M>, Error>;

// New (parallel)
pub async fn connect_iroh<M>(
    endpoint: &iroh::Endpoint,
    addr: iroh::EndpointAddr,
    authority_pub_key: Option<Secp256k1PublicKey>,
) -> Result<NoiseIrohStream<M>, Error>;
```

`NoiseIrohStream<M>` produces the same `(Receiver, Sender)` pair as
`NoiseTcpStream<M>`. Higher-level code does not know it switched transports.

## Architectural decisions (with rationale)

### A. Keep Noise_NX inside iroh — do NOT drop it

See [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]] § "Recommendation".

- Pro: AEAD frame-integrity defends against the same class of attack Erosion
  exploits, even if the QUIC stack is later compromised. Defense in depth.
- Pro: Preserves the formally-analyzed Noise_NX security profile.
- Pro: Smallest refactor — `noise_sv2` and `codec_sv2` keep doing what they do.
- Con: Double encryption (~2× crypto cost per byte). Negligible at
  share-submission throughput.

Implementation: the Noise handshake runs **on top of** an iroh bidi QUIC stream.
The Noise frames are written into the QUIC stream; iroh does its own TLS
encryption underneath. Two layers, both authenticated.

Provide `PlainIrohConnection` (no Noise, iroh-TLS-only) behind a feature flag
for operators who want minimum CPU.

### B. ALPN per role (revised based on Fedimint reference impl)

**Per-role ALPNs**, mirroring Fedimint's three (`FEDIMINT_P2P_ALPN`,
`FEDIMINT_API_ALPN`, `FEDIMINT_GATEWAY_ALPN`):

```rust
pub const SV2_POOL_ALPN:    &[u8] = b"sv2/pool/0";
pub const SV2_JDS_ALPN:     &[u8] = b"sv2/jds/0";
pub const SV2_JDC_ALPN:     &[u8] = b"sv2/jdc/0";
pub const SV2_TPROXY_ALPN:  &[u8] = b"sv2/tproxy/0";
```

A misconfigured client is rejected at the QUIC ALPN layer rather than failing
partway through an SV2 handshake. See [[Fedimint as the reference implementation|wiki/concepts/fedimint-as-reference.md]]
§ ALPN per role.

(Earlier draft of this playbook recommended a single `b"sv2/0"` ALPN. The
Fedimint reference convinced us per-role is better — keeping the rationale here
for transparency.)

### C. One bidi QUIC stream per Connection

Run the existing SV2 byte stream over a single bidi stream. SV2 channels stay
inside the stream, multiplexed by `channel_msg` bit.

Don't try to map SV2 channels to QUIC streams in v1 — too big a refactor. See
[[SV2 framing|wiki/concepts/sv2-framing.md]] § Choice A.

### D. Dual transport on the server, fallback on the client

```
Server: bind(TCP listener) || bind(iroh::Endpoint) — both run, both accept.
Client: try iroh → fall back to TCP on connect failure or RTT regression.
```

Configuration: each side declares which transports it supports. Negotiation is
"dial what's published, fall back if it fails."

### E. EndpointId vs SV2 Authority Pubkey — dual-publish

iroh's `EndpointId` is Ed25519, 32 bytes. SV2's `Authority Pubkey` is
secp256k1, 32 bytes. They are different keys.

Pool config publishes both:
- `stratum2+tcp://thepool.com:34254/<base58check secp256k1>`
- `iroh://<base58check Ed25519 EndpointId>?relay=<relay-url>&...`

The Noise_NX cert continues to use the secp256k1 authority key (no spec
change). The iroh layer authenticates by Ed25519. The two are linked
operationally (same pool, same machine), not cryptographically.

(Future spec work: extend SV2 cert to allow Ed25519. Out of scope for v1.)

### F. Persisted iroh secret key

Generate once, store at `~/.config/sv2/iroh-secret-key` or alongside the
existing key files in `stratum-apps/src/key_utils.rs`. Losing the key means
miners need a new ticket — same lifecycle as losing the SV2 authority key.

### F2. Identity above iroh — match Fedimint's two-layer model

```rust
pub struct IrohSv2Connector {
    // SV2 authority pubkey → iroh NodeId, populated from config
    pub node_ids: BTreeMap<Secp256k1PublicKey, NodeId>,
    pub endpoint: Endpoint,
    pub connection_overrides: BTreeMap<NodeId, NodeAddr>,
}
```

On accept: get `connection.remote_node_id()`, look it up in the trust map.
Reject if unknown. Then run Noise_NX inside (which validates the secp256k1
authority signature). Two-layer identity: forged NodeId is rejected at accept;
forged Noise cert is rejected during handshake.

### F3. Connection overrides escape hatch

Match Fedimint's `FM_IROH_CONNECT_OVERRIDES_ENV` pattern. Useful for testnets,
air-gapped deployments, and integration tests.

### G. Self-hosted relays for production

n0's default public relays are explicitly "development and testing only".
Pool config exposes a `relay_url` field; default to a self-hosted relay (or to
"no relay" if the pool has a public IP and miners always reach it directly).

### H. TCP fallback is not optional

UDP throttling is real and silent. The transport must always offer TCP as an
alternative until/unless we have years of production data showing iroh
performs equivalently across the long tail of consumer ISPs.

### I0. Mandatory operational primitives (Fedimint lessons)

These were all bugs filed and fixed in Fedimint production. **Ship them
pre-emptively**.

1. **Explicit QUIC keepalive** (Fedimint PR #8422):
   - `max_idle_timeout = 60s`
   - `keep_alive_interval = 30s`
   - Long-lived mining sessions need this even more than Fedimint API calls.

2. **Per-request timeout + `Connection::close` on expiry** (PR #8571):
   ```rust
   let result = fedimint_core::runtime::timeout(timeout, async {
       let (mut sink, mut stream) = self.open_bi().await?;
       sink.write_all(&payload).await?;
       sink.finish()?;
       stream.read_to_end(SV2_MAX_RESPONSE_BYTES).await
   }).await;

   if result.is_err() {
       self.close(VarInt::from_u32(1), b"request timeout");
   }
   ```
   QUIC keepalive can succeed while the data path stalls. Wrap every bi-stream
   op in a timeout, force-close on expiry so the pool evicts.

3. **Don't panic on bind failure** — propagate the error (Fedimint #8482, #8518).

4. **Don't `read_to_end(arbitrary_N)`** — derive the cap from the SV2 spec.
   Fedimint's hardcoded 1MB broke federation catchup (#8383). For SV2:
   `B0_64K` = 65,535 ciphertext-bytes-per-frame, `B0_16M` = 16,777,215 for
   plaintext frames; pick from the spec.

5. **Discovery toggleable per-mechanism** — match Fedimint's per-discovery env
   vars (`FM_*_RELAYS_ENABLE`, `FM_*_PKARR_PUBLISHER_ENABLE`, etc.). Pool
   operators with privacy concerns may want pkarr without n0.

6. **Observability ships with v1**:
   - Prometheus metrics for iroh connections and requests
   - Per-connection transport-type tag (iroh-direct / iroh-relay / tcp)
   - Log discovery configuration at startup

### I. Target iroh 1.0+ (not 0.9x)

iroh hit 1.0.0-rc.0 in May 2026. The naming churn (Node→Endpoint,
Discovery→AddressLookup, ConnectionType→TransportAddr) is settled in 1.0.
MSRV 1.91 is fine.

Don't depend on `unstable-custom-transports` (Tor / Nym / BLE) from the
default build — gate behind explicit feature flags only.

## Phased rollout (matches SRI #1935)

### Phase 1 — Spike

- New crate `stratum-apps/src/network_helpers/iroh_connection.rs`.
- Get a single SV2 frame across an iroh `Endpoint::connect` → `accept_bi` →
  Noise handshake → encoded frame → decoded frame.
- Integration test in `integration-tests/` that exercises the round trip.

### Phase 2 — Symmetric APIs

- `IrohConnection` mirrors `noise_connection`'s API: same return types, same
  error variants where they map.
- `PlainIrohConnection` for the no-Noise path (feature-gated).
- `IrohNodeManager`: holds the `Endpoint`, runs the accept loop, hands off
  connections.

### Phase 3 — Server-side dual transport

- Pool / JD / JDC / Translator each gain optional iroh listeners alongside
  their TCP listeners. Config surface adds `[network.iroh]` section.
- Feature-flagged at the crate level (`iroh-transport`) so operators must opt
  in for the first few releases.

### Phase 4 — Client-side fallback

- Outbound dial tries the configured transports in order, falls back on
  failure. RTT regression (e.g., handshake > 5s) treated as failure for
  fallback purposes.
- Telemetry: log per-connection transport + RTT for operators to diagnose
  UDP throttling.

## Code shape (concrete)

```rust
// network_helpers/iroh_connection.rs
use iroh::{Endpoint, EndpointAddr, presets, protocol::ProtocolHandler};
use stratum_core::{
    binary_sv2::{Deserialize, GetSize, Serialize},
    codec_sv2::HandshakeRole,
    noise_sv2::{Initiator, Responder},
};

pub const SV2_ALPN: &[u8] = b"sv2/0";

pub struct IrohNodeManager {
    endpoint: Endpoint,
}

impl IrohNodeManager {
    pub async fn new(secret_key: SecretKey, alpns: Vec<Vec<u8>>) -> Result<Self, Error> {
        let endpoint = Endpoint::builder(presets::N0)
            .secret_key(secret_key)
            .alpns(alpns)
            .bind()
            .await?;
        Ok(Self { endpoint })
    }

    pub async fn connect_with_noise<M>(
        &self,
        addr: EndpointAddr,
        authority_pub_key: Option<Secp256k1PublicKey>,
    ) -> Result<NoiseIrohStream<M>, Error>
    where
        M: Serialize + Deserialize<'static> + GetSize + Send + 'static,
    {
        let conn = self.endpoint.connect(addr, SV2_ALPN).await?;
        let (send, recv) = conn.open_bi().await?;
        let initiator = match authority_pub_key {
            Some(k) => Initiator::from_raw_k(k.into_bytes())?,
            None => Initiator::without_pk()?,
        };
        NoiseIrohStream::new(send, recv, HandshakeRole::Initiator(initiator)).await
    }

    pub async fn accept_with_noise<M>(
        &self,
        pub_key: Secp256k1PublicKey,
        prv_key: Secp256k1SecretKey,
        cert_validity: u64,
    ) -> Result<NoiseIrohStream<M>, Error>
    where
        M: Serialize + Deserialize<'static> + GetSize + Send + 'static,
    {
        let connecting = self.endpoint.accept().await.ok_or(Error::SocketClosed)?;
        let conn = connecting.await?;
        let (send, recv) = conn.accept_bi().await?;
        let responder = Responder::from_authority_kp(
            &pub_key.into_bytes(),
            &prv_key.into_bytes(),
            Duration::from_secs(cert_validity),
        )?;
        NoiseIrohStream::new(send, recv, HandshakeRole::Responder(responder)).await
    }
}
```

`NoiseIrohStream<M>` is structurally identical to the existing `NoiseTcpStream<M>`
in `network_helpers/noise_stream.rs`, swapping `tokio::net::tcp::OwnedReadHalf`/
`OwnedWriteHalf` for iroh's `RecvStream`/`SendStream`. Both pairs implement
`AsyncRead`/`AsyncWrite`, so the body of the read/write loops should be
copy-paste with type renames.

## Test plan

- **Unit**: handshake + roundtrip a frame on a `quinn` in-memory pair (no
  network).
- **Integration**: pool ↔ proxy round trip in `integration-tests/`. Compare
  against TCP variant — same fixtures, different transport.
- **NAT scenarios**: behind two different residential routers (manual /
  CI-with-network-namespace).
- **Fallback**: kill UDP, confirm client falls back to TCP.
- **Erosion-class**: simulate single-packet tampering on the QUIC path —
  confirm it's silently dropped, session continues. (TCP path: same test
  reproduces the Erosion failure for comparison.)

## What's explicitly NOT in v1

- Per-channel QUIC streams (deferred — see [[SV2 framing|wiki/concepts/sv2-framing.md]]).
- 0-RTT resumption (defer until profiling shows handshake latency matters).
- Custom transports (Tor, Nym) — gated behind `unstable-custom-transports`,
  not stable enough yet.
- Spec-level changes to SV2 authority pubkey encoding (Ed25519). Operate
  under the dual-publish model.
- iroh-blobs / iroh-gossip / iroh-docs — out of scope; this is a transport,
  not a content layer.

## Future-proofing — dual-stack iroh-version migration

Fedimint pins TWO iroh versions simultaneously (PR #8400):
- `iroh = "=0.35.0"` — current production
- `iroh-next = "=0.96.1"` — migration target, packaged as `iroh`

Servers advertise their `iroh-next` capability via signed metadata; clients
prefer the new stack when both sides support it.

SV2 v1 doesn't need this (target 1.0+ from the start). But when iroh 1.0 → 1.1
ships breaking changes, the federation-metadata-style channel is analogous to
the SV2 SetupConnection / capability-advertisement messages — use them.

## See also

- [[Why Iroh for SV2|wiki/topics/why-iroh-for-sv2.md]]
- [[Risks and tradeoffs|wiki/topics/risks-and-tradeoffs.md]]
- [[Fedimint as the reference implementation|wiki/concepts/fedimint-as-reference.md]] — load-bearing for this playbook
- [[Integration pattern|wiki/concepts/integration-pattern-iroh-blobs.md]]
- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
- [[SV2 Noise NX|wiki/concepts/sv2-noise-nx.md]]
- [[SV2 framing|wiki/concepts/sv2-framing.md]]
