---
title: "SV2 Spec — Protocol Security (04, Noise NX_25519_ChaChaPoly_BLAKE2s)"
url: https://github.com/stratum-mining/sv2-spec/blob/main/04-Protocol-Security.md
type: paper
source: stratum-mining/sv2-spec
captured: 2026-05-28
quality: 9
path: 3
tags: [noise, encryption, threat-model, mitm, sv1-upstream, plaintext-egress, hashrate-hijacking]
---

# SV2 Spec — Protocol Security (04)

## Why this matters for the reverse translator

The reverse translator terminates Noise on the operator-internal SV2 segment but emits **plaintext JSON-RPC** to the SV1 pool upstream. This recreates exactly the SV1 attack surface that Noise was designed to eliminate, only now for a smaller wire segment between the proxy egress and the upstream pool. Encryption *partially survives* — but the boundary is the new attack surface.

## Stated SV2 security guarantees (Noise NX)

- **AEAD** delivers confidentiality, integrity of ciphertexts, integrity of associated data
- **Performance privacy**: "Data transferred by the mining protocol MUST not provide an adversary with information that they can use to estimate the performance of any particular miner"
- **Authentication**: secp256k1 ECDH + Schnorr (BIP340) certs; initiator "confirms the identity of the server by verifying the signature in the certificate"

## Attacks Noise prevents (between SV2 endpoints)

- Hashrate hijacking via BGP MITM / ISP tampering
- Plaintext share observation (per-miner performance estimation)
- Forged server certificates (requires authority private key)
- Undetected message injection (MAC authentication fails)

## What happens at the reverse-translator boundary (SV2-internal → SV1-upstream)

The spec **does not address** SV2-proxy-to-SV1-pool topologies. The egress from the operator's SV2 stack to the SV1 pool reintroduces:

- **Plaintext share observation** — upstream sees raw hashrate / worker identity
- **No authentication** — upstream cannot verify the proxy or the miner; proxy cannot verify the pool isn't a hijacker
- **Active MITM feasibility** — pool responses (job templates, difficulty) traverse unprotected
- **Credential exposure** — worker credentials transmitted in plaintext to upstream
- **No attestation** binds an SV1 upstream connection to Noise-authenticated downstream clients

The spec mandates that "remote access to upstream nodes" be encrypted. The reverse-translator topology violates that mandate by definition.

## Feature-survival verdict (reverse translator)

| Feature | Status | Why |
|---|---|---|
| Noise NX between miner ↔ proxy | **survives** | Internal to operator's SV2 stack |
| Noise NX proxy ↔ upstream | **lost** | SV1 has no Noise; egress is plaintext or stunnel-wrapped TCP |
| Hashrate hijacking prevention | **partially-lost** | Internal protected; egress segment exposed |
| Per-miner performance privacy from upstream | **lost** | Upstream sees aggregated hashrate but in plaintext |
| Authority-bound server identity | **lost-but-replaceable** | Could be replicated with TLS+pinning to SV1 pool, but no protocol mandate |

## Ingest justification

Defines the threat model that the reverse translator *partially* breaks. Critical for any operator running this topology in a hostile network: encryption is only as strong as its weakest hop, and the SV1 egress is the new weakest hop.
