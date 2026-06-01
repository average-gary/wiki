---
title: "API Tokens: A Tedious Survey (fly.io / tptacek)"
source: https://fly.io/blog/api-tokens-a-tedious-survey/
type: article
tags: [tptacek, fly-io, jwt, paseto, biscuit, macaroons, contrarian, survey]
date: 2026-06-01
quality: 5
confidence: high
agent: contrarian
summary: "tptacek long-form on bearer tokens. JWT is a 'design-by-committee cryptographic kitchen sink.' alg=none, RS256/HS256 confusion, missing domain separation. PASETO assessment: 'essentially the same thing as JWT' with similar fundamental problems; supporting eight versions undermines protocol versioning. Biscuit: ambitious (Datalog + pubkey sigs) but 'requires you to move essentially all your authorization logic into your tokens — a footgun for small servers.' Macaroon attenuation IS the security property but library ecosystem struggles. Conclusion: 'boring, trustworthy random tokens' are underrated."
---

# Fly.io: API Tokens — A Tedious Survey

The contrarian counterweight. Most useful for **the road not taken** in the iroh app token wiki article.

## The argument

> "JWT is a design-by-committee cryptographic kitchen sink. Most servers don't face database scaling problems that justify cryptographic complexity. Boring, trustworthy random tokens are underrated."

## On each format

### JWT

- alg=none: spec permits unsigned tokens; libraries have repeatedly accepted them
- Algorithm/key confusion: switching `RS256` → `HS256` lets an attacker use the RSA public key as the HMAC secret
- Missing domain separation: "doesn't bind purpose or even domain parameters to keys"

### PASETO

> "Essentially the same thing as JWT" with similar fundamental problems; supporting eight versions undermines protocol versioning's benefits.

(Counter-view: PASETO Initiative argues v4 is *more* opinionated, not less, and the version field is bound to a specific cipher suite. See [[paragon-jwt-bad-standard]].)

### Biscuit

> "Ambitious (Datalog + pubkey sigs) but requires you to move essentially all your authorization logic into your tokens — a footgun for small servers."

For the GTX 1060 homelab with 5 friends as authorized clients, this is an apt critique. Datalog rules in tokens make sense at scale, not at homelab scale.

### Macaroons

> "Caveats can only restrict, never expand — that IS the security property; but the library ecosystem struggles with caveat complexity; third-party caveats create operational friction; symmetric cryptography limits architectural flexibility."

## The contrarian conclusion

> **"Boring, trustworthy random tokens" are underrated.**
>
> Most systems "don't face database scaling problems that justify cryptographic complexity."

For a single homelab server with 5-50 paired devices, a 32-byte random opaque token + redb key-value lookup is plausibly the right answer:

```rust
struct AppToken([u8; 32]);  // just random bytes

struct ServerState {
    tokens: redb::Database,  // (token_bytes -> TokenMeta)
}

struct TokenMeta {
    capability: Capability,
    flags: AuthKeyFlags,
    expiry: SystemTime,
    consumed: AtomicBool,
}

fn validate(server: &ServerState, presented: &[u8]) -> Option<&TokenMeta> {
    let meta = server.tokens.get(presented)?;
    if meta.expired() { return None; }
    if meta.is_single_use() && meta.consumed.swap(true, ...) { return None; }
    Some(meta)
}
```

→ No HMAC chain, no Datalog, no Protobuf, no version-cipher coupling. Just bytes + DB.

## Trade-off matrix

| Approach | Pro | Con |
|----------|-----|-----|
| Random opaque + DB | Simple, footgun-free, explicit consumed-set | Requires DB, no offline verification |
| HMAC + footer (PASETO-shape) | Stateless on server, recomputable on multiple replicas | Footer parsing & versioning complexity |
| Biscuit | Offline attenuation, public verification | Datalog overhead for small auth |
| Macaroon | Append-only attenuation | Symmetric only, library tooling weak |

## Verdict for the iroh app token wrapper

For the GTX 1060 homelab:

1. **Default**: random opaque + redb (per fly.io's argument)
2. **If you need offline attenuation** (a friend gives a sub-token to a family member): Biscuit
3. **If you need versioned envelope** (forward-compatible upgrades): PASETO v4
4. **If you need byte-tight QR**: Branca
5. **Don't use JWT** ever

## Recurring alg=none

> "alg=none is not a one-time mistake; it recurs in production code in 2026, nearly a decade after it was first publicized."

Per the [[howmanydays-jwt-alg-none]] tracker — most recent (as of 2026-06-01): AWS Ops Wheel, 38 days ago. JWT is **not** safe to roll into a homelab project.

## See also

- [[2026-06-01-rfc-8725-jwt-bcp]]
- [[2026-06-01-paragon-jwt-bad-standard]]
- [[2026-06-01-paseto-v4-spec]]
- [[2026-06-01-biscuit-spec-v3]]
