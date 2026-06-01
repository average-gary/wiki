---
title: "rusty_paseto crate — Rust implementation of PASETO"
source: https://docs.rs/rusty-paseto, https://github.com/rrrodzilla/rusty_paseto
type: repo
tags: [paseto, rusty-paseto, rust, crate, v4, footer, implicit-assertion]
date: 2026-06-01
quality: 4
confidence: high
agent: technical
summary: "docs.rs shows 0.10.0; latest GH release tag v0.9.0 (2025-12-09); repo last pushed 2026-05-11; 135 stars (version skew suggests a 0.10.x publish without a GH release tag — flag for verification). Supports V1 local/public, V2 local/public, V3 local, V4 local/public. V4 (Sodium Modern) recommended. Three-tier feature model: batteries_included (JWT-style claims), generic (custom builder/parser), core (raw crypto). Mutually exclusive — --all-features is unsupported by design."
---

# rusty_paseto Rust crate

Rust impl of PASETO. Best mainstream typed-token option for the iroh app token wrapper.

## Crate metadata

- **docs.rs**: 0.10.0
- **GH release tag**: v0.9.0 (2025-12-09)
- **Repo last push**: 2026-05-11
- **Stars**: 135
- **Note**: Version skew (docs.rs > tagged release) — verify by checking the published 0.10.x Cargo.toml before pinning

## Three-tier feature model

```toml
[dependencies]
rusty-paseto = { version = "0.10", features = ["batteries_included"] }
# OR (mutually exclusive):
rusty-paseto = { version = "0.10", features = ["generic"] }
# OR:
rusty-paseto = { version = "0.10", features = ["core"] }
```

| Tier | Use |
|------|-----|
| `batteries_included` | JWT-style claims — auto `exp`/`iat`/`nbf` |
| `generic` | Custom builder/parser — bring your own claim types |
| `core` | Raw crypto primitives only |

**Mutually exclusive** — `--all-features` is unsupported by design.

## Quick start (V4 local — symmetric)

```rust
use rusty_paseto::prelude::*;

let key = PasetoSymmetricKey::<V4, Local>::from(Key::from(secret_bytes));

let token = PasetoBuilder::<V4, Local>::default()
    .set_implicit_assertion(node_id.as_bytes())
    .set_footer(Footer::from(r#"{"epoch":42,"kid":"farm-ai"}"#))
    .set_expiration(&(Utc::now() + Duration::hours(24)).to_rfc3339())
    .set_claim(CustomClaim::try_from(("flags", "single_use"))?)
    .set_claim(CustomClaim::try_from(("cap", "transcribe"))?)
    .build(&key)?;

let parsed = PasetoParser::<V4, Local>::default()
    .set_implicit_assertion(node_id.as_bytes())
    .check_claim(CustomClaim::try_from(("epoch", 42))?)  // reject if epoch != 42
    .parse(&token, &key)?;
```

## V4 public (asymmetric, Ed25519)

```rust
let keypair = PasetoAsymmetricKeyPair::<V4, Public>::generate();

let token = PasetoBuilder::<V4, Public>::default()
    .build(&keypair.private)?;

let parsed = PasetoParser::<V4, Public>::default()
    .parse(&token, &keypair.public)?;
```

→ Multiple iroh nodes can verify tokens issued by one root, without sharing the signing key.

## Why this works for the iroh app token wrapper

PASETO v4's three knobs map onto the wrapper requirements:

| Wrapper requirement | PASETO v4 mechanism |
|---------------------|---------------------|
| Tailscale flags (single-use, etc.) | Custom claims |
| Wesh seed-rotation epoch | Footer (authenticated, not encrypted) |
| Bind to NodeID | Implicit assertion |
| Expiry | `set_expiration` |
| Capability scope | Custom claim |

→ All five wrapper features fit in PASETO v4 without extending the format.

## Integration with iroh auth-hook pattern

```rust
// auth ALPN handshake:
async fn handle_auth_request(token_str: &str, node_id: EndpointId) -> Result<Capability> {
    let parsed = PasetoParser::<V4, Local>::default()
        .set_implicit_assertion(node_id.as_bytes())
        .check_claim(CustomClaim::try_from(("epoch", current_epoch()))?)?
        .parse(token_str, &server_key)?;

    let flags: AuthKeyFlags = parsed.claim("flags")?;
    let cap: Capability = parsed.claim("cap")?;

    if flags.single_use && consumed_set.contains(&parsed.claim("jti")?) {
        return Err(AlreadyConsumed);
    }
    consumed_set.insert(parsed.claim("jti")?);

    Ok(cap)
}
```

## See also

- [[2026-06-01-paseto-v4-spec]]
- [[2026-06-01-iroh-auth-hook-example]]
