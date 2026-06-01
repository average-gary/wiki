---
title: "Macaroons: Cookies with Contextual Caveats for Decentralized Authorization in the Cloud"
source: https://research.google/pubs/macaroons-cookies-with-contextual-caveats-for-decentralized-authorization-in-the-cloud/
type: paper
tags: [macaroons, capability, hmac, caveats, bearer, attenuation, paper, nsdi]
date: 2026-06-01
publication_date: 2014
authors: [Birgisson, Politz, Erlingsson, Taly, Vrable, Lentczner]
quality: 5
confidence: high
agent: academic+adjacent
summary: "NSDI 2014 / Google research. Bearer credential built from a chain of nested HMACs over a root secret known only to the target service. Each caveat appends a predicate (time<T, account=X, op=read) and re-MACs the running state — attenuation is offline, append-only, unforgeable without the root key. Third-party caveats let issuer say 'valid only with discharge from auth-service Y for predicate P.' No asymmetric crypto — just HMAC chains. Compact byte serialization."
---

# Macaroons (Birgisson et al., 2014)

Foundational citation for the Tailscale-flag layer in the iroh app token wrapper.

## Construction

Bearer credential = chain of nested HMACs over a root secret known only to the target service. Each "caveat" is a predicate (`time < T`, `account = X`, `op = read`) appended to the chain; the running HMAC is re-keyed with the previous tag.

```
token = (id, M0)
  M0 = HMAC(root_secret, id)
add caveat C1:
  token = (id, C1, M1)
  M1 = HMAC(M0, C1)
add caveat C2:
  token = (id, C1, C2, M2)
  M2 = HMAC(M1, C2)
verify:
  recompute the chain; only target with root_secret can do this
```

→ Attenuation is **offline, append-only, unforgeable**. Anyone with the token can append more caveats (which can only further restrict). No one without the root secret can produce a valid macaroon from scratch.

## Third-party caveats

Allow delegation:

> "This token is valid only if you also present a discharge macaroon from auth-service Y attesting predicate P."

The third party shares an encrypted root key embedded in the caveat — enables decentralized delegation without anyone seeing the original secret.

## Why this matters for an iroh app token

The "flag" payload (single-use, reusable, ephemeral, pre-approved, tag) in our iroh wrapper is **structurally a caveat set**. Macaroons give the formal model and the original security argument for "MAC-chained append-only restrictions on a bearer secret = capability."

| Iroh app-token field | Macaroon equivalent |
|----------------------|---------------------|
| Bearer secret        | Root HMAC key on server |
| `expiry: SystemTime` | First-party caveat `time < T` |
| `single_use` flag    | First-party caveat `nonce = X` (verified against consumed-set) |
| `ephemeral` flag     | First-party caveat `device_session = ...` |
| `tag: Role`          | First-party caveat `role = read|write|admin` |
| `endpoint_id` binding | First-party caveat `node_id = ...` |

## Comparison vs alternatives (per the paper)

- vs **cookies**: no server lookup
- vs **JWT**: no claim attenuation primitive (you can't "narrow" a JWT after issuance without re-signing)
- vs **SPKI/SDSI**: much simpler to deploy

## Implementation note

Symmetric crypto only. **Biscuit** (see [[2026-06-01-biscuit-spec-v3]]) is the asymmetric, Datalog-rich Rust descendant; it's the more usable modern choice. Macaroons are the cleaner pedagogical reference.

## See also

- [[2026-06-01-biscuit-spec-v3]] — Rust-native macaroon descendant
- [[2026-06-01-paseto-v4-spec]] — alternative envelope (no caveat semantics)
- [[2026-06-01-fly-api-tokens-survey]] — contrarian view: macaroon library ecosystem complexity
