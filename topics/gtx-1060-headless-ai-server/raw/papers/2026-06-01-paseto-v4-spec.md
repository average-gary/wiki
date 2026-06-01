---
title: "PASETO Specification — Version 4 (v4.local + v4.public)"
source: https://github.com/paseto-standard/paseto-spec/blob/master/docs/01-Protocol-Versions/Version4.md
type: paper
tags: [paseto, v4, xchacha20, blake2b, ed25519, footer, implicit-assertion, spec]
date: 2026-06-01
quality: 4
confidence: high
agent: academic
summary: "v4.local: XChaCha20 stream cipher + BLAKE2b-MAC (encrypt-then-MAC, AEAD-equivalent). 32-byte key, 32-byte nonce, derived encryption + auth keys via BLAKE2b KDF. v4.public: Ed25519 signatures over the payload. Wire: v4.<purpose>.<base64url(payload)>[.<base64url(footer)>]. Header (v4.local. / v4.public.) is a fixed prefix that prevents algorithm-substitution attacks. Optional footer (unencrypted but authenticated via PAE) for non-secret hints — the canonical place for revocation epoch / seed-rotation generation. Optional implicit assertion binds context (NodeId) into auth tag without transmitting it."
---

# PASETO v4

Best-fit modern wire envelope if a token format is needed.

## v4.local (symmetric)

For a single GTX 1060 server validating its own tokens:

- **Cipher**: XChaCha20 stream cipher
- **MAC**: BLAKE2b (encrypt-then-MAC, AEAD-equivalent)
- **Key**: 32 bytes
- **Nonce**: 32 bytes (per token)
- **KDF**: BLAKE2b derives separate encryption + auth keys from the master key

## v4.public (asymmetric)

For multi-server federations:

- **Signature**: Ed25519
- **Verification**: just the public key

## Wire form

```
v4.local.<base64url(nonce || ciphertext || tag)>[.<base64url(footer)>]
v4.public.<base64url(payload || signature)>[.<base64url(footer)>]
```

Header `v4.local.` / `v4.public.` is a **fixed prefix** — prevents algorithm-substitution attacks (no `alg=none` foot-gun, see [[fly-api-tokens-survey]]).

## The footer

Unencrypted but **authenticated via Pre-Auth Encoding (PAE)**. Canonical place for:

- Key ID (`kid`)
- Issuer hint
- **Revocation epoch / seed-rotation generation number** (our use case!)
- Token type

```
footer = '{"kid":"farm-ai-2026-Q2","epoch":42}'
```

If the server's current epoch is 41, reject this token. If 42, accept. → Wesh-style seed rotation = bump the epoch; old footers fail validation; identity unchanged.

## The implicit assertion

Optional context bound into the auth tag **without being transmitted**:

```rust
// at issuance:
encrypt(key, payload, footer, implicit_assertion = node_id.to_bytes())

// at verification (server already knows its own node_id):
decrypt(key, ciphertext, footer, implicit_assertion = node_id.to_bytes())
```

→ Token cannot be re-used at another iroh node even if stolen. Equivalent to a hidden caveat.

## Sibling: v3

NIST-aligned variant for compliance shops:

- Local: AES-256-CTR + HMAC-SHA-384
- Public: ECDSA P-384 + SHA-384 with RFC 6979 deterministic k

Same envelope shape. **Use v4 unless an audit forces v3.**

## Comparison to alternatives

| | JWT | Branca | **PASETO v4** | Biscuit | CWT |
|--|------|--------|---------------|---------|-----|
| Algorithm agility | Yes (footgun) | None | None (per version) | None (per version) | Yes (header) |
| `alg=none` risk | Historic | None | None | None | None |
| Wire bloat | high | minimal (~45B) | medium | medium | low (CBOR) |
| Versioning | weak | none | strong | strong | weak |
| Caveat/attenuation | none | none | **footer epoch** | **Datalog blocks** | none |
| Rust crate maturity | many | branca 0.10 | rusty-paseto 0.10 | biscuit-auth 6.0 | coset (Google) |

## Implementation in Rust

`rusty_paseto` 0.10 (docs.rs, 2026-05). Three-tier feature model:

- `batteries_included` — JWT-style claims, auto `exp`/`iat`/`nbf`
- `generic` — custom builder/parser
- `core` — raw crypto

Mutually exclusive — `--all-features` is unsupported by design.

```rust
let token = PasetoBuilder::<V4, Local>::default()
    .set_implicit_assertion(node_id.as_bytes())
    .set_footer(Footer::from(r#"{"epoch":42}"#))
    .set_expiration(&(Utc::now() + Duration::hours(24)).to_rfc3339())
    .set_claim(CustomClaim::try_from(("flags", "single_use")).unwrap())
    .build(&key)?;

let parsed = PasetoParser::<V4, Local>::default()
    .set_implicit_assertion(node_id.as_bytes())
    .check_claim(CustomClaim::try_from(("epoch", 42)).unwrap())
    .parse(&token, &key)?;
```

## See also

- [[2026-06-01-rusty-paseto-crate]]
- [[2026-06-01-paragon-jwt-bad-standard]] — PASETO authors' rationale
- [[2026-06-01-fly-api-tokens-survey]] — counter-view
- [[2026-06-01-rfc-8725-jwt-bcp]]
