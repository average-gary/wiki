---
title: "Tailscale Auth Keys — bearer-token flag schema"
source: https://tailscale.com/kb/1085/auth-keys
type: article
tags: [tailscale, auth-keys, bearer-token, pairing-ux, flags]
date: 2026-06-01
quality: 4
confidence: high
agent: 7
summary: "Pre-auth keys are bearer tokens with flags: one-off vs reusable, ephemeral (auto-cleanup on offline), pre-approved (skip admin gate), tag (auto-assign role). Two-tier expiry: auth key (1-90 d, default 90) provisions, then node key (default 180 d) is the long-lived identity. Revoking the auth key does NOT kick already-connected devices."
---

# Tailscale auth-key flag schema

Sets the bar for what an "Iroh ticket" should encode at the application layer.

## Flag schema

| Flag          | Effect |
|---------------|--------|
| **Single-use** | Token consumed on first use; subsequent reuse rejected |
| **Reusable**   | Token can pair multiple devices |
| **Ephemeral**  | Auto-cleanup nodes when they go offline; for short-lived workers |
| **Pre-approved** | Skip admin approval step in tailnet |
| **Tag**        | Auto-assign a tag/role to the new node |

## Two-tier expiry

```
auth_key.expiry  = 1-90 days (default 90)  ← provisions
node_key.expiry  = 180 days (default)       ← long-lived identity
```

**Revoking the auth key does NOT kick already-connected devices.** That's a separate operation on the node-key.

## UX shape

```bash
tailscale up --auth-key=tskey-...
```

One env-var-friendly token; flags are pre-baked at admin issuance time.

## Translation to Iroh ticket design

Iroh's `EndpointTicket` today is roughly equivalent to a Tailscale node-key (long-lived identity + addressing). It does NOT encode auth-key flags.

A production iroh-app design should layer **its own auth-key wrapper**:

```rust
// pseudo-code
struct AppToken {
    inner: EndpointTicket,
    capability: Capability,        // what this token grants
    flags: AuthKeyFlags,            // single-use, reusable, ephemeral, pre-approved, tag
    expiry: SystemTime,
    issuer_sig: HmacSha256,         // signed by app-server's HMAC key
}
```

Then `AccessLimit<P>` validates the token before honoring connections.

## Pattern to mirror

| Tailscale flag | Iroh-app analog |
|----------------|-----------------|
| Single-use     | Client uses token once → server marks consumed |
| Reusable       | Multiple uses OK |
| Ephemeral      | Auto-remove from allowlist on N hours offline |
| Pre-approved   | Skip "do you trust this peer?" prompt |
| Tag            | Map peer to role (read-only / read-write / admin) |

This is the abstraction worth lifting; not the `tskey-…` literal string.

## See also

- [[2026-06-01-iroh-tickets-security-model]] — what tickets do/don't guarantee
- [[2026-06-01-briar-bhp-protocol]] — separate identity-acquisition from session
