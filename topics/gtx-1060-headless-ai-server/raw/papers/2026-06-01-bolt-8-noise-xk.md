---
title: "BOLT 8 — Lightning Network Encrypted and Authenticated Transport"
source: https://github.com/lightning/bolts/blob/master/08-transport.md
type: paper
tags: [noise, xk, bolt, lightning, identity-hiding, key-rotation]
date: 2026-06-01
quality: 5
confidence: high
agent: 7
summary: "Lightning's Noise_XK transport — three fixed-size acts (50/50/66 bytes). Initiator must pre-know responder's static pubkey, giving responder identity-hiding (key never travels in cleartext). Post-handshake framing: 2-byte encrypted length + MAC, then encrypted payload + MAC, max 65,535 bytes. Key rotation every 1,000 messages via HKDF, nonces reset to zero."
---

# BOLT 8 — Noise XK in production

Lightning's transport handshake. Cleanest production reference for "I already know your pubkey → dial you" semantics, with the XK choice (vs IK) for stronger identity-hiding.

## Three acts (fixed sizes)

| Act | Size  | Direction | Contents |
|-----|------:|-----------|----------|
| 1   | 50 B  | initiator → responder | ephemeral pubkey + MAC |
| 2   | 50 B  | responder → initiator | ephemeral pubkey + MAC |
| 3   | 66 B  | initiator → responder | encrypted initiator static + MAC |

The fixed sizes give traffic-analysis resistance — handshakes are byte-identical to a network observer.

## Why XK and not IK

XK delays the initiator's static-key transmission to act 3 (after both ephemeral exchanges have completed), giving stronger initiator identity-hiding. IK sends initiator static in act 1, encrypted only with the responder's static — vulnerable to retroactive identity decryption if the responder's static leaks (Noise §7.7).

## Post-handshake framing

```
[ 2-byte length (encrypted) ][ 16-byte MAC ][ payload (encrypted) ][ 16-byte MAC ]
```

Max payload 65,535 bytes. **Key rotation every 1,000 messages** via HKDF; nonces reset to zero.

> "A successful check of the MAC by the receiver indicates implicitly that all authentication has been successful up to that point." — BOLT 8

## Patterns to mirror in iroh-app land

1. Fixed-size handshake bytes for traffic-analysis resistance
2. Key rotation every N messages on long-lived sessions
3. Per-frame MAC with explicit length encryption
4. **XK over IK when responder identity-hiding matters** — but iroh's TLS-RPK already gives both peers anonymity at the QUIC layer, so this concern is partially addressed at a different layer

See also: [[2026-06-01-noise-protocol-framework-rev34]], [[2026-06-01-briar-bhp-protocol]].
