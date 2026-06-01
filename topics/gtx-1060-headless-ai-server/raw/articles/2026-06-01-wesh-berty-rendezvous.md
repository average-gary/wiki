---
title: "Wesh / Berty Protocol — Contact Add and Time-Rotated Rendezvous"
source: https://berty.tech/docs/protocol/
type: article
tags: [wesh, berty, qr, rendezvous, time-rotation, revocation]
date: 2026-06-01
quality: 4
confidence: high
agent: 7
summary: "QR encodes only two things: account ID (pubkey) + RDV seed. The rendezvous point is a derived value: rendezvousPoint(accountID, seed, currentTime). Time-rotated, so old QRs expire silently. Owner can rotate the RDV seed to revoke all outstanding pairing links without rotating identity. Handshake: ephemeral exchange → sealed-box proof of identity knowledge → ack. X25519 + Ed25519. Offline-first: when on BLE/Wi-Fi Direct, peers exchange a list of RDV points they're listening on for synchronous local discovery."
---

# Wesh / Berty — the cleanest QR-rendezvous-rotation pattern

The pattern that solves the "iroh ticket has no revocation" problem.

## QR contents (minimal)

```
QR = encode(account_id, rdv_seed)
```

Just two values:
- `account_id` — long-term Ed25519 identity
- `rdv_seed` — short-lived rendezvous seed

## The rendezvous trick

Instead of "publish your address," peers compute:

```
rendezvous_point = H(account_id, rdv_seed, current_time_bucket)
```

Both peers (knowing both inputs) compute the same point and meet there. The point rotates over time → old QRs silently stop working.

## Revocation without identity rotation

**Owner rotates `rdv_seed`** → all outstanding pairing QRs become invalid → identity stays the same.

Compare to iroh tickets which have NO revocation (see [[2026-06-01-iroh-tickets-security-model]]).

## Handshake

After meeting at the rendezvous:
1. Ephemeral key exchange (forward secrecy)
2. Sealed-box proof of identity knowledge (proves possession of `account_id`'s secret)
3. ACK

Curves: X25519 + Ed25519.

## Offline mode

When on BLE / Wi-Fi Direct:
- Peers exchange a **list of RDV points they're listening on** for synchronous local discovery
- No internet, no server, still finds peers

## Patterns to mirror in iroh-app land

1. **Time-bucketed rendezvous derived from a seed** — old QRs expire silently
2. **Seed rotation = revocation** — orthogonal to identity rotation
3. **Two values in the QR**, not one fat ticket

For an Iroh AI server with QR pairing:

```rust
// app-layer wrapper around iroh's NodeID-based discovery
struct PairingInvitation {
    endpoint_id: EndpointId,
    rdv_seed: [u8; 32],
}

// rotate the seed weekly:
fn rotate_seed(&mut self) {
    self.rdv_seed = generate();
    // existing peers (already paired) keep working
    // outstanding QR codes stop working
}

// derived rendezvous tag
fn rendezvous_tag(&self, time_bucket: u64) -> [u8; 32] {
    blake3(self.endpoint_id || self.rdv_seed || time_bucket)
}
```

Iroh's gossip layer or DNS pkarr could be used for the actual rendezvous point — the seed-rotation logic is application-layer.

## See also

- [[2026-06-01-iroh-tickets-security-model]] — why this matters
- [[2026-06-01-briar-bhp-protocol]] — separate OOB key exchange from session
