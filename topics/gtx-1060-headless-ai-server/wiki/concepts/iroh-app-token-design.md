---
title: "Iroh app token wrapper — design and Rust crate matrix"
type: concept
created: 2026-06-01
updated: 2026-06-01
verified: 2026-06-01
volatility: hot
confidence: high
sources:
  - raw/papers/2026-06-01-macaroons-birgisson-2014.md
  - raw/papers/2026-06-01-biscuit-spec-v3.md
  - raw/papers/2026-06-01-paseto-v4-spec.md
  - raw/papers/2026-06-01-branca-spec.md
  - raw/papers/2026-06-01-rfc-8392-cwt.md
  - raw/papers/2026-06-01-rfc-8725-jwt-bcp.md
  - raw/repos/2026-06-01-iroh-pr-3157-accesslimit.md
  - raw/repos/2026-06-01-iroh-pr-4205-relay-auth-tokens.md
  - raw/repos/2026-06-01-iroh-auth-hook-example.md
  - raw/repos/2026-06-01-biscuit-auth-rust-crate.md
  - raw/repos/2026-06-01-rusty-paseto-crate.md
  - raw/repos/2026-06-01-blake3-keyed-hash-rust.md
  - raw/repos/2026-06-01-redb-sled-token-persistence.md
  - raw/articles/2026-06-01-fly-api-tokens-survey.md
  - raw/articles/2026-06-01-paragon-jwt-bad-standard.md
tags: [iroh, app-token, capability, design, rust-crate-matrix, token-format]
---

# Iroh app token wrapper — design and crate matrix

This concept article picks the **token format** for the iroh app token wrapper. The seed-rotation algorithm is in [[iroh-app-token-seed-rotation]]; the AccessLimit/auth-hook integration is in [[iroh-app-token-integration]].

## The decision tree

```
Need offline attenuation (recipient narrows token before sharing)?
├─ Yes → Biscuit v3 (biscuit-auth = 6.0.0)
└─ No
   ├─ Need byte-tightest QR (sticker, single line)?
   │   ├─ Yes → Branca (branca = 0.10.2)
   │   └─ No
   │       ├─ Multi-server federation (no shared secret)?
   │       │   ├─ Yes → PASETO v4.public (Ed25519, rusty-paseto)
   │       │   └─ No (single homelab box)
   │       │       └─ PASETO v4.local OR random-opaque-32B + redb
   └─ Specific BUSINESS reason for JWT compat?
       └─ Don't. Use one of the above. JWT is unsafe by default.
```

## Why not JWT (ever)

Per [[fly-api-tokens-survey]], [[paragon-jwt-bad-standard]], [[rfc-8725-jwt-bcp]]:

| Trap | JWT | PASETO v4 | Biscuit | Branca | Random+DB |
|------|-----|-----------|---------|--------|-----------|
| `alg=none` accepted | Historic | No (fixed prefix) | No | No | N/A |
| RS256/HS256 confusion | Yes | No (one cipher per version) | No | No | N/A |
| Weak HMAC keys | Possible | Spec mandates 32 random bytes | N/A (Ed25519) | Spec mandates 32 random bytes | N/A |
| `kid` injection | Yes (string) | No (footer is structured) | No (root_key_id is u32) | N/A | N/A |
| Cross-token confusion | Yes | Mitigated by implicit assertion | Mitigated by Datalog scoping | Manual | Type-tagged DB row |

Per the [[howmanydays-jwt-alg-none]] tracker, alg=none vulns recur in production code in **2026** (most recent: AWS Ops Wheel, 38 days before this research). **Don't use JWT.**

## The four serious options

### Option 1 — Random opaque + redb (default)

The fly.io contrarian: most homelabs don't need cryptographic complexity.

```rust
struct AppToken([u8; 32]);  // just random bytes

struct ServerState {
    tokens: redb::Database,
}

#[derive(Serialize, Deserialize)]
struct TokenMeta {
    cap: Capability,
    flags: AuthKeyFlags,
    expiry: SystemTime,
    consumed: bool,
    issued: SystemTime,
}

fn validate(state: &ServerState, presented: &[u8]) -> Result<Capability> {
    let txn = state.tokens.begin_write()?;
    let mut table = txn.open_table(TOKENS)?;
    let meta: TokenMeta = match table.get(presented)? {
        Some(v) => bincode::deserialize(v.value())?,
        None => return Err(Unknown),
    };
    if meta.expiry < SystemTime::now() { return Err(Expired); }
    if meta.flags.single_use && meta.consumed { return Err(Consumed); }
    if meta.flags.single_use {
        let mut updated = meta.clone();
        updated.consumed = true;
        table.insert(presented, &bincode::serialize(&updated)?[..])?;
    }
    txn.commit()?;
    Ok(meta.cap)
}
```

**Pros**: simplest possible, footgun-free, no version-cipher coupling, no parsing.
**Cons**: requires DB access on every validate (no offline verification by other peers); tokens are not self-describing.

### Option 2 — PASETO v4.local (typed envelope, single key)

When you want a self-describing token but still have a single validating server.

```rust
let token = PasetoBuilder::<V4, Local>::default()
    .set_implicit_assertion(my_endpoint_id.as_bytes())  // bind to this server
    .set_footer(Footer::from(json!({
        "epoch": current_epoch(),
        "kid": "farm-ai-2026-Q2"
    }).to_string()))
    .set_expiration(&(Utc::now() + Duration::hours(24)).to_rfc3339())
    .set_claim(CustomClaim::try_from(("flags", flags))?)
    .set_claim(CustomClaim::try_from(("cap", cap))?)
    .set_claim(CustomClaim::try_from(("jti", jti))?)
    .build(&server_key)?;
```

Validate side:

```rust
let parsed = PasetoParser::<V4, Local>::default()
    .set_implicit_assertion(my_endpoint_id.as_bytes())
    .check_claim(CustomClaim::try_from(("epoch", current_epoch()))?)
    .parse(&token, &server_key)?;
let cap: Capability = parsed.get_claim("cap")?;
let flags: AuthKeyFlags = parsed.get_claim("flags")?;
let jti: [u8; 16] = parsed.get_claim("jti")?;

if flags.single_use && consumed_set.contains(&jti) {
    return Err(Consumed);
}
consumed_set.insert(jti);
```

**Pros**: self-describing, version-locked cipher (no agility), footer for revocation epoch, implicit assertion binds to NodeID.
**Cons**: rusty-paseto version skew (docs.rs 0.10 vs GH tag v0.9 — verify before pinning); larger wire size than random+DB.

### Option 3 — Biscuit v3 (offline attenuation, public verification)

When friends should be able to attenuate tokens before sharing with their family.

```rust
let root = KeyPair::new();  // Ed25519

// Issue:
let token = Biscuit::builder()
    .add_fact(fact!(r#"right("transcribe")"#))
    .add_fact(fact!(r#"flag("reusable")"#))
    .add_check(check!(r#"check if time($t), $t < {expiry}"#))
    .build(&root)?;

// Friend attenuates before giving to family:
let attenuated = token.append(block!(r#"
    check if endpoint_id("family-member-id");
    check if operation("transcribe");
"#))?;

// Server verifies:
let mut authz = parsed_token.authorizer()?;
authz.add_fact(fact!(r#"endpoint_id({:?})"#, connecting_id))?;
authz.add_fact(fact!(r#"time({})"#, &SystemTime::now()))?;
authz.add_fact(fact!(r#"operation("transcribe")"#))?;
authz.add_policy("allow if right($op), operation($op)")?;
authz.add_policy("deny if true")?;
authz.authorize()?;
```

**Pros**: offline attenuation without issuer key; public verification; matches iroh's Ed25519 model.
**Cons**: per fly.io critique, "moves all authorization logic into your tokens" — overkill for 5-friend homelab.

### Option 4 — Branca (byte-tight)

Pick only if printed-sticker QR with strict char budget matters.

Per [[branca-spec]]: 45-byte fixed overhead + base62 (~37% bloat). 64-byte payload → ~149 chars wire. PASETO v4.local with same payload → ~160 chars. **The 11-char delta does not justify giving up PASETO's footer + implicit assertion.**

→ **Branca is rarely the right pick** for the iroh app token. Documented for completeness; not recommended.

## Recommendation

For the GTX 1060 homelab AI server with 5–50 paired devices:

1. **Default**: random opaque (32B) + redb consumed-set (Option 1)
   - Reason: simplest; matches fly.io's "boring tokens" advice; debuggable; no parsing; no version surface
2. **Upgrade path**: PASETO v4.local (Option 2)
   - Reason: when you want offline server-side validation across multiple iroh nodes (e.g., a small federation); footer carries the revocation epoch
3. **Skip**: Biscuit unless friends-attenuate-tokens is a real workflow
4. **Skip**: Branca, CWT, JWT, macaroon-rs (dormant)

## The Capability enum

Common across all options:

```rust
#[derive(Serialize, Deserialize, Debug, Clone)]
enum Capability {
    DocRead { namespace_id: NamespaceId },
    DocWrite { namespace_secret: NamespaceSecret },
    Alpn { alpn: Vec<u8>, args: serde_json::Value },
    Multiple(Vec<Capability>),
}

#[derive(Serialize, Deserialize, Debug, Clone)]
struct AuthKeyFlags {
    single_use: bool,
    reusable: bool,
    ephemeral: bool,        // auto-remove on N hours offline
    pre_approved: bool,     // skip "trust this peer?" prompt
    tag: Role,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
enum Role { Read, Write, Admin }
```

→ Mirror Tailscale's flag schema (per [[tailscale-auth-keys]]).

## Crate matrix (versions as of 2026-06-01)

| Crate           | Version | Status | Pick for |
|-----------------|---------|--------|----------|
| `redb`          | 4.1.0   | Active | Consumed-set (recommended) |
| `sled`          | 0.34.7  | Pre-1.0, cautious | Skip |
| `blake3`        | 1.8.5   | Active | keyed_hash for seed rotation |
| `rusty-paseto`  | 0.10.0 / 0.9.0 (skew — verify) | Active | PASETO v4 |
| `biscuit-auth`  | 6.0.0 (2025-07-16) | Active | Capability + attenuation |
| `branca`        | 0.10.2 (2025-07-22) | Maintenance | Byte-tight only |
| `coset`         | 0.3+ (2026-03) | Active (Google) | CWT/COSE if already in CBOR |
| `macaroon`      | 0.3.0 (2023-01) | **Dormant** | Skip |
| `iroh`          | 1.0.0-rc.1 | Active | Required |

## See also

- [[iroh-app-token-seed-rotation]] — the rotation algorithm
- [[iroh-app-token-integration]] — how to plug into AccessLimit
- [[iroh-application-patterns-2026-synthesis]] — top-level synthesis
- [[iroh-tickets-and-qr-pairing]] — what iroh provides today
