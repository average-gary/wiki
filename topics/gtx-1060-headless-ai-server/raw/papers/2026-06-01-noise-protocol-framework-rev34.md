---
title: "Noise Protocol Framework — Revision 34"
source: https://noiseprotocol.org/noise.html
type: paper
tags: [noise, ik, xk, handshake, cryptography, perrin]
date: 2026-06-01
publication_date: 2018-07-11
quality: 5
confidence: high
agent: 1
summary: "Spec Revision 34, status 'official/unstable'. IK pattern letters: I = initiator's static is sent Immediately (msg 1), K = responder's static is Known to initiator (pre-message). Pattern: pre-msg `<- s`; then `-> e, es, s, ss` and `<- e, ee, se`. Initiator's first payload is 0-RTT-encryptable; full mutual auth in 1-RTT. KCI vulnerability on first payload until later messages complete; no SAS/short-authentication-string equivalent."
---

# Noise IK — when the responder's static key is already known

The handshake pattern that fits "I have your NodeID/QR ticket → dial you."

## IK pattern wire shape

```
<- s                  (responder static is pre-known by initiator)
...
-> e, es, s, ss       (initiator: ephemeral, ECDH(e,S), static, ECDH(s,S))
<- e, ee, se          (responder: ephemeral, ECDH(e,e), ECDH(S,e))
```

- Initiator sends static immediately, encrypted to responder's static — gives **identity-hiding-from-the-net** for both parties on msg 1
- Mutual authentication completes in 1-RTT
- 0-RTT encryption to responder is possible because responder's static is known up front

## Comparison

| Pattern | Init static | Resp static | Round trips | Notes |
|---------|-------------|-------------|-------------|-------|
| **NK**  | none        | known       | 1-RTT       | Initiator anonymous; no init-auth |
| **IK**  | sent msg 1  | known       | 1-RTT       | Mutual auth in one flight; KCI risk |
| **XK**  | sent msg 3  | known       | 1.5-RTT     | Stronger init identity-hiding; +1 flight |

Lightning's BOLT 8 chose **XK**; WireGuard chose **IK** (with PSK2 mixin → `Noise_IKpsk2_25519_ChaChaPoly_BLAKE2s`).

## Security caveats (Noise §7.7, §7.8, §14)

- **KCI** (key-compromise impersonation): first message's source authentication relies on static-static DH; if the responder's static key is compromised an attacker can impersonate any sender to the responder
- Initiator's pubkey is encrypted with **no forward secrecy** on msg 1 — responder static-key leak retroactively reveals all past initiator identities across all prior IK sessions
- **No SAS** — Noise spec offers no short-authentication-string protocol to confirm an out-of-band-shared key. If a QR ticket is photographed-from-screen, replay/MITM via swap is silent.

## Iroh relevance

Iroh does NOT use Noise — it uses TLS 1.3 over QUIC with raw public keys (RPK) instead of x509 (since 1.0-rc.0, see [[2026-06-01-iroh-1-0-0-rc-1]]). The IK semantic ("I know your static pubkey, dial you") is preserved by the NodeID/EndpointID model. PQ-hybrid X25519MLKEM768 is opt-in (see [[2026-06-01-iroh-post-quantum-handshakes]]).

For an app layer that wants Noise IK on top of iroh streams (defense-in-depth or compatibility with non-iroh peers), the snow crate is the canonical Rust impl.
