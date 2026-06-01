---
title: "Iroh tickets and QR pairing — Tailscale-style invite + Noise IK semantics"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-noise-protocol-framework-rev34.md
  - raw/papers/2026-06-01-bolt-8-noise-xk.md
  - raw/papers/2026-06-01-briar-bhp-protocol.md
  - raw/articles/2026-06-01-iroh-tickets-security-model.md
  - raw/articles/2026-06-01-tailscale-auth-keys.md
  - raw/articles/2026-06-01-wesh-berty-rendezvous.md
  - raw/articles/2026-06-01-iroh-paycode-case-study.md
  - raw/articles/2026-06-01-iroh-post-quantum-handshakes.md
tags: [iroh, ticket, qr-pairing, noise-ik, allowlist, revocation]
---

# Iroh tickets and QR pairing

How a phone learns to find the GTX 1060 AI server (and vice versa). What the iroh primitives give you, and what you must build on top.

## What iroh actually ships

`EndpointTicket` (renamed from `NodeTicket` at iroh 0.94, now in `iroh-tickets` crate, pinned to 1.0-rc.1):

```
EndpointTicket = base32(EndpointAddr {
    endpoint_id: PublicKey (Ed25519, 32 bytes),
    relay_url: Option<RelayUrl>,
    direct_addresses: Vec<SocketAddr>,
})
```

Typical encoded length ~140 chars. Fits comfortably in a QR code (Alphanumeric mode capacity ~4000 chars at version 25, Q error level).

Pattern:

```
print ticket → QR-encode → scan → EndpointTicket::from_str → endpoint.connect(addr, ALPN)
```

The Noise-IK-style key-confirmation step happens **implicitly inside iroh's QUIC handshake** against the public key embedded in the ticket. An attacker substituting a ticket fails the handshake (TLS-with-RPK validates the cert against the known EndpointID).

## Production deployment exists — Paycode

Paycode (Mexican toll booth payment terminals) ships exactly this: QR codes encode iroh tickets, gossip-based discovery establishes peer connections after pairing. See [[iroh-paycode-case-study]]. Polyglot embedding (Rust core + .NET 6 SDK + Kotlin POS app) demonstrates the pattern works in mixed-stack environments.

## What iroh tickets are NOT

Per **iroh's own docs** (docs.iroh.computer/concepts/tickets) and **maintainer discussion #3168**:

| Property | Status |
|----------|--------|
| Single-use | ❌ NOT enforced — anyone with the ticket can use it many times |
| Expiration | ❌ NOT built-in |
| Revocation | ❌ DOES NOT EXIST — once leaked, live forever |
| Client authentication | ❌ "tickets don't inherently provide client authentication" |
| Network-location privacy | ❌ Tickets embed current IP addresses |

Maintainer quote (#3168):

> "I would still recommend not relying on this for actual authentication."

**[CORRECTION 2026-06-01]**: PR #3157 was **MERGED 2025-03-14** — it introduced `AccessLimit<P>` itself (a minimal `Fn(EndpointId) -> bool` predicate), NOT a generic auth-wrapper layer. The "wrap protocols with a generic auth layer" gap is filled by the iroh app token wrapper described in [[iroh-app-token-design]] / [[iroh-app-token-integration]]. A complementary surface landed at the relay tier in PR #4205 (2026-05-06). See [[iroh-tickets-security-model]].

→ **Treat iroh tickets as the trust anchor for the EndpointID, not as auth credentials.**

## Layer your own

The application layer must add what iroh doesn't:

### Capability tokens (Tailscale auth-keys pattern)

```rust
struct AppToken {
    inner: EndpointTicket,
    capability: Capability,        // what this token grants
    flags: AuthKeyFlags,            // single-use, reusable, ephemeral, pre-approved, tag
    expiry: SystemTime,
    issuer_sig: HmacSha256,         // signed by app-server's HMAC key
}
```

Lift Tailscale's flag schema (single-use / reusable / ephemeral / pre-approved / tag). See [[tailscale-auth-keys]].

### Time-rotated rendezvous (Wesh / Berty pattern)

To get **revocation without identity rotation**, derive the rendezvous from a rotating seed:

```rust
fn rendezvous_tag(endpoint_id: EndpointId, seed: [u8; 32], time_bucket: u64) -> [u8; 32] {
    blake3(&[endpoint_id.as_bytes(), &seed, &time_bucket.to_le_bytes()].concat())
}

// rotate seed weekly: existing peers keep working (already paired);
// outstanding QR codes stop working.
```

See [[wesh-berty-rendezvous]].

### EndpointID allowlist via AccessLimit

```rust
use iroh::protocol::AccessLimit;

let allowed = read_allowlist();  // HashSet<EndpointId>
let gated = AccessLimit::new(handler, move |id| allowed.contains(&id));
```

Reject unknown peers at the Router layer before any handler logic runs.

## Noise IK relevance — what iroh does not need

Iroh uses TLS 1.3 over QUIC with **raw public keys (RPK)** instead of x509 (since 1.0-rc.0). This gives the same semantic as Noise IK — the responder's static pubkey (EndpointID) is known by the initiator before connecting; mutual authentication completes in the QUIC handshake.

→ **iroh does not use Noise**; the IK semantic is preserved by the RPK + QUIC handshake. See [[noise-protocol-framework-rev34]].

For defense-in-depth (independent crypto layers, or compatibility with non-iroh peers), Noise IK on top of iroh streams is possible via the `snow` crate. Not the recommended architecture for an iroh-native AI server.

### Post-quantum

Iroh 1.0-rc supports `X25519MLKEM768` hybrid KEM via the `prefer-post-quantum` rustls feature (requires `aws-lc-rs` backend). Adds ~1 KB per direction to handshake; opt-in. **Worth turning on** for ticket-bearing devices because of harvest-now/decrypt-later. See [[iroh-post-quantum-handshakes]].

## Why XK is not necessary (despite Lightning's choice)

Lightning's BOLT 8 uses Noise XK for stronger initiator identity-hiding (initiator static is sent in act 3, not act 1). See [[bolt-8-noise-xk]]. Iroh's TLS-RPK over QUIC already gives both peers anonymity at the QUIC layer (no static keys cleartext on the wire), so the XK-vs-IK distinction is moot at the application layer.

## QR pairing UX recipe

```
Server side:
  1. Server generates a one-time AppToken (single-use flag, expires in 24h)
  2. Encodes (EndpointTicket || AppToken) as base32
  3. Renders QR code on a screen / sends to user via secure channel

Client side:
  4. Phone camera scans QR
  5. Decodes EndpointTicket → endpoint.connect(addr, ALPN)
  6. Sends AppToken on the bidi stream
  7. Server validates token (HMAC, single-use mark consumed, expiry check, AccessLimit)
  8. Server adds the client's EndpointID to allowlist
  9. Subsequent connections from this client succeed without re-pairing
```

## Operator hygiene

- **Rotate the rendezvous seed weekly** (or on suspected leak) → all unused QRs invalidate
- **Audit the allowlist** quarterly; drop peers that haven't connected in N days
- **Don't print QRs to shared screens** without confirming they're not visible to cameras
- **Use single-use AppTokens** for new pairings; reusable tokens only for known-good ops scenarios
- **Enable post-quantum KEM** on long-lived tickets

## See also

- [[iroh-app-token-design]] — chosen token format and Rust crate matrix (added 2026-06-01)
- [[iroh-app-token-seed-rotation]] — Wesh-style revocation algorithm (added 2026-06-01)
- [[iroh-app-token-integration]] — AccessLimit + auth-hook integration (added 2026-06-01)
- [[iroh-tickets-security-model]] — first-party caveats
- [[wesh-berty-rendezvous]] — time-rotation pattern
- [[tailscale-auth-keys]] — flag schema reference
- [[briar-bhp-protocol]] — OOB-as-trust-anchor philosophy
- [[multi-alpn-router-pattern]] — where AccessLimit plugs in
- [[iroh-application-patterns-2026-synthesis]]
