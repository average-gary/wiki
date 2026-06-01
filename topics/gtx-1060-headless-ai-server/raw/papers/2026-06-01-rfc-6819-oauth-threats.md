---
title: "RFC 6819 — OAuth 2.0 Threat Model and Security Considerations"
source: https://datatracker.ietf.org/doc/html/rfc6819
type: paper
tags: [oauth, refresh-token, rotation, family-revocation, replay, rfc]
date: 2026-06-01
publication_date: 2013-01
quality: 5
confidence: high
agent: adjacent
summary: "§5.2.2.3: 'Refresh tokens can automatically be replaced in order to detect unauthorized token usage by another party.' §5.2.1.1: 'If an authorization server observes multiple attempts to redeem an authorization code, the authorization server may want to revoke all tokens granted based on the authorization code.' Pairs short access-token TTLs (minutes or hours) with refresh rotation for passive revocation on expiry."
---

# RFC 6819 — OAuth threats: the family-revocation pattern

The canonical write-up of the **family/lineage detection pattern**: if a rotated-out token is ever presented again, treat it as compromise evidence and burn the lineage.

## The two key sections

### §5.2.2.3 — Refresh token rotation

> "Refresh tokens can automatically be replaced in order to detect unauthorized token usage by another party."

When the client uses refresh token N, server issues N+1 and marks N consumed. Two distinct uses of N → at least one party stole it. Server burns the family.

### §5.2.1.1 — Family revocation precedent

> "If an authorization server observes multiple attempts to redeem an authorization 'code', the authorization server may want to revoke all tokens granted based on the authorization 'code'."

Same idea applied to authorization codes. The mechanism is identical: lineage detection via consumed-mark.

## Direct application to the iroh app token

The Wesh-style seed-rotation pattern can use this exact mechanic for **leak detection**:

```
seed → bucket(t) → tag(t) = blake3::keyed_hash(seed, t)
```

If the server sees `tag(t-2)` after the bucket has rotated to `t`, this means:

1. Either: someone replayed an old QR (could be benign — late arrival)
2. Or: the seed has leaked and an attacker is using a rotated-out tag (compromise)

**Heuristic**: if a `bucket(t-2)` tag arrives after `bucket(t)` has already issued, log + alert. If multiple `t-2` tags arrive, **rotate the seed immediately** and invalidate all outstanding QRs.

```rust
fn handle_pairing_request(claimed_tag: Hash, claimed_bucket: u64, current: u64) -> Action {
    let stale = current.saturating_sub(claimed_bucket);
    match stale {
        0 | 1 => Action::Accept,           // current or previous bucket — fine
        2 => Action::AcceptButLog,          // late arrival, suspicious
        _ => Action::RejectAndRotateSeed,   // very stale → likely leak
    }
}
```

## The other half: short TTL + cheap reissue

> "Pairs short access-token TTLs (minutes or hours) with refresh rotation for passive revocation … on the expiry of the current access token."

This is the same insight as Adam Langley's "no, don't enable revocation checking" (see [[2026-06-01-langley-no-revcheck]]) and Let's Encrypt's 90-day cert lifetime: **don't try to revoke; just expire fast and reissue**.

For the iroh app token, this means:

- Tokens valid for hours, not weeks
- Renewal happens automatically on each successful pairing
- Seed rotation handles "I forgot to expire the device" case

## See also

- [[2026-06-01-langley-no-revcheck]]
- [[2026-06-01-rfc-6238-totp]]
- [[2026-06-01-wesh-berty-rendezvous]] — the Iroh-app-side
