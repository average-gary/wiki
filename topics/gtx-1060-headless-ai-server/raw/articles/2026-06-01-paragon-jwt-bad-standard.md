---
title: "JSON Web Tokens (JWT) is a Bad Standard That Everyone Should Avoid (Paragon Initiative)"
source: https://paragonie.com/blog/2017/03/jwt-json-web-tokens-is-bad-standard-that-everyone-should-avoid
type: article
tags: [jwt, paseto, paragon, contrarian, alg-none, key-confusion]
date: 2026-06-01
publication_date: 2017-03
quality: 4
confidence: high
agent: contrarian
summary: "PASETO authors' rationale for why JWT is fundamentally broken. alg=none: spec language 'understood and processed' is ambiguous, which historically allowed unsigned acceptance. HS256/RS256 key confusion: attacker sends HS256 header, server uses public key as HMAC secret, signature verifies. PASETO design rationale: 'restricts developers to a single vetted ciphersuite per protocol version rather than allowing dangerous algorithm selection, eliminating these confusion attacks by design.' Frames as inherent: 'not implementation bugs but inherent flaws in permitting algorithm negotiation within security tokens.'"
---

# Paragon Initiative — Why PASETO

Counter-source to fly.io's "PASETO is JWT-shaped." Paragon (PASETO authors) argues the version field is **not** algorithm negotiation.

## The two named JWT failure classes

1. **alg=none** — spec permits, libraries have accepted
2. **RS256 → HS256 key confusion** — attacker swaps header, server treats RSA pubkey as HMAC key, signature verifies

## PASETO's design philosophy

> "Restricts developers to a single vetted ciphersuite per protocol version rather than allowing dangerous algorithm selection, eliminating these confusion attacks by design."

i.e., `v4.local` is **always** XChaCha20+BLAKE2b. There's no header field selecting an algorithm. The version is part of the wire prefix and is checked before any crypto runs.

## Inherent vs implementation

> "Not implementation bugs but inherent flaws in permitting algorithm negotiation within security tokens."

**Algorithm agility = footgun.** Even RFC 8725 (BCP) acknowledges this implicitly by mandating "one key, one algorithm" — which is what PASETO/Biscuit enforce by design.

## Auth0 reference

Paragon cites Auth0 as having documented "critical vulnerabilities in most JWT libraries" — the practical evidence that the theoretical critique manifests in real code.

## How this maps to the iroh app token decision

If we're going to use a typed token format, **PASETO v4** is the right pick because:

- No algorithm field
- Version-locked cipher suite
- Footer for non-secret hints
- Implicit assertion for context binding

If we follow fly.io's contrarian advice and use random opaque tokens + DB lookup, we side-step the entire JWT-vs-PASETO debate. **Don't ever use JWT.**

## See also

- [[2026-06-01-rfc-8725-jwt-bcp]]
- [[2026-06-01-fly-api-tokens-survey]]
- [[2026-06-01-paseto-v4-spec]]
