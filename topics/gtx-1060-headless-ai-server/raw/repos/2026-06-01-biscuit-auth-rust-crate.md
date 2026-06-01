---
title: "biscuit-auth crate — Rust implementation of Biscuit v3"
source: https://docs.rs/biscuit-auth, https://github.com/eclipse-biscuit/biscuit-rust
type: repo
tags: [biscuit, biscuit-auth, rust, crate, ed25519, datalog]
date: 2026-06-01
publication_date: 2025-07-16
quality: 5
confidence: high
agent: technical
summary: "biscuit-auth = 6.0.0 released 2025-07-16 (also biscuit-quote 0.3.0, biscuit-parser 0.2.0 same day). Repo last pushed 2026-04-22. 241 stars. Now under eclipse-biscuit/ org (moved from biscuit-auth/). KeyPair enum supports Ed25519 (default) and ECDSA P-256 signing. Build: Biscuit::builder() accepts Datalog; first block is the authority block. Attenuate: biscuit.append(block) adds restriction blocks offline (no issuer key needed). Verify: construct an Authorizer, add facts/rules/policies."
---

# biscuit-auth Rust crate (v6.0.0)

The Rust-native Biscuit implementation. The natural pick if a structured token format is wanted.

## Crate metadata

- **Version**: 6.0.0 (2025-07-16)
- **Org**: eclipse-biscuit/ (moved from biscuit-auth/)
- **Stars**: 241
- **Last push**: 2026-04-22
- **Companion crates**: `biscuit-quote = 0.3.0`, `biscuit-parser = 0.2.0`

## Construction

```rust
use biscuit_auth::{KeyPair, Biscuit, builder::*};

let root = KeyPair::new();  // Ed25519 default

let token = Biscuit::builder()
    .add_fact(fact!(r#"right("read", "/farm-ai/transcribe")"#))
    .add_check(check!(r#"check if time($t), $t < 2026-12-31T00:00:00Z"#))
    .build(&root)?;

let serialized = token.to_base64()?;  // single string
```

## Attenuation (offline, no issuer key needed)

```rust
let token: Biscuit = Biscuit::from_base64(&serialized, root.public())?;

let attenuated = token.append(block!(r#"
    check if endpoint_id("abc123...");
    check if operation("read");
"#))?;
// attenuated has additional restrictions; original token's restrictions still apply
```

## Verification

```rust
let mut authorizer = token.authorizer()?;

authorizer.add_fact(fact!(r#"endpoint_id("abc123...")"#))?;
authorizer.add_fact(fact!(r#"time({})"#, &SystemTime::now()))?;
authorizer.add_fact(fact!(r#"operation("read")"#))?;
authorizer.add_fact(fact!(r#"resource("/farm-ai/transcribe")"#))?;

authorizer.add_policy("allow if right($op, $resource), operation($op), resource($resource)")?;
authorizer.add_policy("deny if true")?;

authorizer.authorize()?;  // returns Result
```

## Integration with iroh AccessLimit

```rust
use iroh::protocol::AccessLimit;

let root_key = load_root_keypair();
let revoked_set = load_revoked_token_ids();

let validator = move |endpoint_id: EndpointId| -> bool {
    // AccessLimit only sees EndpointId — token validation must happen before
    // (in a separate auth ALPN) and update an allow-set.
    allowed.contains(&endpoint_id)
};

let gated = AccessLimit::new(handler, validator);
```

The auth ALPN (per [[iroh-auth-hook-example]]) accepts a Biscuit, verifies it against the root pubkey, runs Datalog policies, and on success adds the connecting EndpointID to the allowed set.

## Caveats (per fly.io critique)

> "Biscuit is ambitious (Datalog + pubkey sigs) but requires you to move essentially all your authorization logic into your tokens — a footgun for small servers."

For a homelab GTX 1060 with 5 friends as authorized clients, **Biscuit is overkill**. Reach for it when:

- Friends want to attenuate tokens before sharing with their family
- Multi-server federation requires offline verification
- You want a structured policy language anyway

For simpler cases, prefer:

- **Random opaque + redb** (per [[fly-api-tokens-survey]])
- **PASETO v4 footer + redb** (per [[paseto-v4-spec]])

## See also

- [[2026-06-01-biscuit-spec-v3]]
- [[2026-06-01-fly-api-tokens-survey]]
