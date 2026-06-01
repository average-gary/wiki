---
title: "Biscuit Authentication and Authorization Token — SPECIFICATIONS.md (v3)"
source: https://github.com/biscuit-auth/biscuit/blob/main/SPECIFICATIONS.md
type: paper
tags: [biscuit, datalog, ed25519, capability, attenuation, rust, spec]
date: 2026-06-01
quality: 5
confidence: high
agent: academic
summary: "Biscuit v3, datalog version 3.3 (format versions 3.0 → 3.3 encoded as 3-6). Token = append-only list of blocks (authority + restriction blocks). Each block carries facts/rules/checks in a Datalog variant (no negation), plus symbol table, next-block public key, signature. Signing uses Ed25519 (or ECDSA secp256r1) with a chain of ephemeral keypairs — each block signs the next block's public key, so attenuation is offline and earlier blocks are tamper-evident. Final proof is the last ephemeral private key. Authorization is policy-driven: check if, check all, reject if, allow/deny. Wire format: Protobuf."
---

# Biscuit v3 specification

The Rust-native macaroon descendant. **Top recommendation** if a token format is needed for the iroh app token wrapper.

## Why Biscuit over macaroons

| | Macaroons | **Biscuit v3** |
|--|-----------|---------------|
| Crypto | HMAC chain (symmetric) | **Ed25519 chain (asymmetric)** |
| Verification | Requires root secret | **Just root pubkey** |
| Attenuation | Offline, append-only | Offline, append-only |
| Policy language | Boolean caveats | **Datalog (facts, rules, checks)** |
| Wire format | Custom byte-packed | **Protobuf** |
| Iroh fit | Requires server-side root secret | **Matches iroh's Ed25519 NodeID model** |

→ Biscuit's "verifier needs only root pubkey" maps directly onto iroh's "any peer knows the server's EndpointID" — clients can verify they're being given a legit server-issued token without server roundtrip.

## Token structure

```
Biscuit {
    authority_block: Block { facts, rules, checks, next_pubkey, signature },
    blocks: [Block, Block, ...],   // attenuation blocks
    proof: Signature OR LastPrivateKey,  // depending on sealed/unsealed
    root_key_id: Option<u32>,
}

Block {
    symbols: [Symbol],   // string-table
    facts: [Fact],
    rules: [Rule],
    checks: [Check],
    next_pubkey: PublicKey,  // signs the *next* block
    signature: Signature,    // by *previous* block's ephemeral key
}
```

Each block signs the next block's public key → attenuation is tamper-evident. Final proof is the last ephemeral private key (or, for sealed tokens, a signature over a challenge).

## Datalog policy

Authorization is policy-driven, evaluated in order:

```datalog
// in token (authority block):
right("read", "/farm-ai/transcribe")
right("read", "/farm-ai/detect")

// in token (attenuation block):
check if time($t), $t < 2026-06-15T00:00:00Z

// in verifier:
check if right($op, $resource)
allow if time($t), $t > 2026-06-01T00:00:00Z
deny if revoked($id)
```

Checks: `check if`, `check all`, `reject if`. Policies: `allow`, `deny` evaluated in order until match.

## Wire format

Protobuf message `Biscuit { authority + blocks + proof + optional root_key_id }`. Plus base64-url for transport.

## Format versions

- v3.0–v3.3 = format versions 3, 4, 5, 6 (integers)
- Repo: github.com/eclipse-biscuit/biscuit-rust (was github.com/biscuit-auth/biscuit-rust before org move)
- Rust crate: `biscuit-auth = 6.0.0` (2025-07-16)

## Trade-offs (per the contrarian source)

Per [[fly-api-tokens-survey]]: "Biscuit is ambitious (Datalog + pubkey sigs) but requires you to move essentially all your authorization logic into your tokens — a footgun for small servers."

→ For a homelab GTX 1060 server with 2-5 friends as authorized clients, Biscuit is **likely overkill**. Lighter options:

1. PASETO v4.local with footer for revocation epoch
2. Branca (~45 byte fixed overhead)
3. Custom HMAC-SHA256 + redb for "consumed" marks

But Biscuit shines for:

- Offline-attenuated capabilities (give a friend a token, they re-attenuate before sharing with their family)
- Public verification (other peers can verify without server contact)
- Match iroh's Ed25519 model (no extra crypto primitive)

## See also

- [[2026-06-01-macaroons-birgisson-2014]] — predecessor
- [[2026-06-01-biscuit-auth-rust-crate]] — implementation
- [[2026-06-01-fly-api-tokens-survey]] — contrarian critique
