---
title: "iroh-docs — NamespaceSecret, DocTicket, and the missing capability-rotation layer"
source: https://docs.rs/iroh-docs/latest/iroh_docs/
type: article
tags: [iroh-docs, namespace, doc-ticket, capability, no-revocation, gap]
date: 2026-06-01
quality: 4
confidence: high
agent: applied
summary: "Two-keypair model: NamespaceSecret = 'token of write capability' to entire replica; AuthorId = per-entry authorship signature (semantically interpreted by app). NamespaceId = pubkey of NamespaceSecret. Entries bind (key, author, namespace, BLAKE3(content)|len|timestamp). DocTicket = namespace key (secret OR public) + peer list — analogous to fedimint InviteCode for documents. Holding the secret variant of the namespace key IS the write bearer. NO built-in role/ACL/expiry/revocation — explicitly delegated to the application layer. Rotation: not provided; namespace keys are forever."
---

# iroh-docs — what's there and what's missing

iroh-docs already has the `(key, peers)` ticket pattern. **What it lacks is exactly what the wrapper provides.**

## Two-keypair model

```rust
struct NamespaceSecret(SecretKey);  // 32-byte Ed25519 secret
struct NamespaceId(PublicKey);       // pubkey of namespace
struct AuthorId(PublicKey);          // per-entry signer

// Entry = (key, author, namespace, BLAKE3(content)|len|timestamp)
```

- `NamespaceSecret` = "token of write capability" to entire replica
- `NamespaceId` = pubkey identity of the doc
- `AuthorId` = per-entry authorship signature (app-interpreted)

**Holding NamespaceSecret IS the write bearer.** Anyone with it can write any entry.

## DocTicket

```rust
struct DocTicket {
    capability: Capability,   // either NamespaceSecret (write) or NamespaceId (read-only)
    nodes: Vec<NodeAddr>,     // peers to dial
}
```

Analogous to fedimint's InviteCode: single string (bech32-ish), carries everything needed to join.

## What's missing — the gap the wrapper fills

| Feature | iroh-docs DocTicket | iroh app token wrapper (target) |
|---------|---------------------|---------------------------------|
| Identity | ✅ NamespaceId | ✅ EndpointID |
| Connection info | ✅ peer URLs | ✅ relay + direct addrs |
| Bearer | ✅ NamespaceSecret (or read pubkey) | ✅ token bytes |
| Expiry | ❌ none | ✅ via PASETO `exp` or random-opaque DB row |
| Single-use | ❌ none | ✅ via consumed-set in redb |
| Revocation | ❌ none — namespace keys are forever | ✅ via seed rotation |
| Capability scope | ✅ read-only vs write (binary) | ✅ per-ALPN (transcribe / detect / admin) |
| Tag / role | ❌ none | ✅ Tailscale-style flag schema |
| Pre-approval | ❌ implicit (anyone with cap can use it) | ✅ flag |
| Ephemeral | ❌ none | ✅ flag |

→ **The wrapper extends iroh-docs's pattern with the operations layer.**

## Implication

The iroh app token wrapper crate could:

1. Define a `Capability` enum that includes iroh-docs's read/write distinction as one variant among many
2. Wrap `DocTicket` for the doc-ticket case, with the wrapper's flags + epoch layered on
3. Provide a parallel `AppTicket` type for non-doc cases (transcribe, detect, ssh-tunnel)

```rust
enum Capability {
    DocRead { namespace_id: NamespaceId },
    DocWrite { namespace_secret: NamespaceSecret },
    Alpn { alpn: Vec<u8>, args: serde_json::Value },
    Multiple(Vec<Capability>),
}

struct AppToken {
    cap: Capability,
    flags: AuthKeyFlags,
    expiry: SystemTime,
    epoch: u64,
    issuer_sig: Signature,  // by server's HMAC or Ed25519 key
    jti: [u8; 16],          // unique ID for single-use marking
}
```

## See also

- [[2026-06-01-iroh-tickets-security-model]] — the broader EndpointTicket caveats
- [[2026-06-01-fedimint-invite-code]]
- [[2026-06-01-iroh-auth-hook-example]]
