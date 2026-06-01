---
title: "Fedimint InviteCode — bech32 ticket carrying (federation_id, peers, optional bearer)"
source: https://docs.rs/fedimint-core/latest/fedimint_core/invite_code/struct.InviteCode.html
type: article
tags: [fedimint, invite-code, bech32, ticket, p2p, prior-art]
date: 2026-06-01
quality: 5
confidence: high
agent: applied
summary: "Token shape (Rust struct): federation_id, BTreeMap<PeerId, SafeUrl> peer endpoints, optional api_secret (bearer token for federation API), at-least-one guardian URL invariant. Wire format: bech32 (FromStr/Display), plus consensus Encodable/Decodable, plus serde JSON, plus hex. Single self-contained string carries identity (federation_id) + connection info (peer URLs) + optional bearer (api_secret). Client decodes, dials any guardian quorum, downloads full configs (which it then verifies against the federation_id). Rotation: invite codes are essentially immutable advertisements; api_secret rotation handled out-of-band."
---

# Fedimint InviteCode — direct prior art for the iroh app ticket shape

The closest existing **Rust p2p ticket format** that bundles identity + connection info + optional bearer in a single bech32 string.

## Rust shape

```rust
pub struct InviteCode {
    federation_id: FederationId,
    peers: BTreeMap<PeerId, SafeUrl>,
    api_secret: Option<String>,
}
```

Invariant: at least one guardian URL.

## Wire formats

| Format | Use |
|--------|-----|
| bech32 (`FromStr`/`Display`) | Human-friendly QR/URL |
| consensus `Encodable`/`Decodable` | Internal protocol |
| serde JSON | Web APIs |
| hex | CLI |

## Self-contained ticket — three things in one string

| Component | Equivalent in iroh app token |
|-----------|------------------------------|
| `federation_id` | `endpoint_id` |
| `peers: BTreeMap<PeerId, SafeUrl>` | `relay_url`, `direct_addresses` |
| `api_secret: Option<String>` | `app_token: Option<Vec<u8>>` |

→ **Mirror this exactly** in the iroh app token wrapper. The iroh-app-ticket should be:

```rust
pub struct AppTicket {
    endpoint_id: EndpointId,
    relay_url: Option<RelayUrl>,
    direct_addresses: Vec<SocketAddr>,
    app_token: Option<Vec<u8>>,  // PASETO/Biscuit/random-opaque bytes
}
```

Wire format: bech32-style with `appti` HRP (or similar), Display/FromStr, fits in a QR code.

## Verification flow

Fedimint's pattern:

1. Client decodes invite code → gets `federation_id` + peer URLs
2. Dials any guardian (quorum)
3. Downloads full federation configs over the API
4. **Verifies configs against the federation_id** — federation_id is the trust anchor; api_secret is the gate

For the iroh app:

1. Client decodes app ticket → gets `endpoint_id` + relay + addresses + optional token
2. Dials iroh endpoint (TLS-RPK validates against endpoint_id)
3. Optionally presents `app_token` via auth ALPN handshake
4. **endpoint_id is the trust anchor; app_token gates capability**

## Rotation

Per fedimint: "api_secret rotation handled out-of-band." Same pattern for iroh:

- `endpoint_id` is forever (rotating it = changing identity)
- `app_token` rotates per the wrapper's flags (single-use / expiry / epoch)
- Out-of-band: re-print a QR code with a new app_token

## bech32 advantages

- Error-correcting checksum (catches typos, OCR errors from QR scans)
- Limited charset (no `0/O`, `1/I` confusion)
- Length-prefixed; can be split across lines if needed
- Already standard in Bitcoin / Lightning ecosystems → operator familiarity

## See also

- [[2026-06-01-iroh-docs-namespace-doctickets]] — adjacent iroh ticket
- [[2026-06-01-iroh-tickets-security-model]] — base EndpointTicket
- [[2026-06-01-lnurl-auth-derivation]] — per-domain key derivation pattern
