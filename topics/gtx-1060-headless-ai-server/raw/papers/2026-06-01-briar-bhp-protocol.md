---
title: "Briar BHP — Bramble Handshake Protocol"
source: https://code.briarproject.org/briar/briar-spec/-/raw/master/protocols/BHP.md
type: paper
tags: [briar, bhp, handshake, qr, ecdh, oob, pairing]
date: 2026-06-01
quality: 4
confidence: high
agent: 7
summary: "Out-of-band long-term key exchange (QR/NFC/Bluetooth) followed by an in-band 4-message ECDH handshake. BHP is deliberately silent on how long-term keys arrived. Roles assigned by lexicographic order of long-term pubkeys — no flip-flop on initiator. Triple-DH derives ephemeral master key. Security explicitly contingent on OOB exchange being uncompromised — the QR is the trust anchor, the protocol just rides on it."
---

# Briar BHP — the QR is the trust anchor

Cleanest articulation of the philosophy that should govern Iroh QR-pairing.

## Two-stage shape

1. **Out-of-band**: long-term static pubkey of each party is exchanged via QR / NFC / Bluetooth / paper. BHP says nothing about this layer — explicitly someone else's problem.
2. **In-band**: 4-message ECDH handshake using the OOB-acquired keys to bootstrap a session.

## Symmetric initiator selection

Roles assigned by **lexicographic order of long-term pubkeys** — there's no protocol-level "client" vs "server"; both peers can simultaneously initiate and the comparison decides who acts as Alice vs Bob. Useful for symmetric pairing UX where neither side is privileged.

## Triple-DH (3-DH)

The handshake mixes three Diffie-Hellman exchanges to derive an ephemeral master key:
1. ECDH(ephemeral_a, ephemeral_b)
2. ECDH(static_a, ephemeral_b)
3. ECDH(ephemeral_a, static_b)

Forward secrecy via ephemerals; mutual authentication via statics. Same idea as Noise XK.

## Companion BTP — Bramble Transport Protocol

Delay-tolerant transport, latency milliseconds → days; "does not reveal any plaintext fields that would make it easily distinguishable from other protocols" — traffic-analysis resistance built in.

## Patterns for iroh-app land

1. **The QR (or ticket) IS the trust statement** — protocol just rides on top
2. **Lexicographic pubkey ordering** for symmetric pairing — no need to encode "I am the inviter"
3. **Separate identity-acquisition from session-establishment** — BHP separates concerns; Iroh's NodeTicket conflates them somewhat (a ticket carries identity AND addressing hints)

## Caveat the wiki should remember

If the QR is photographed-from-screen, every later guarantee collapses. BHP makes no claim against that — it's the OOB exchange's job to be uncompromised.

See also: [[2026-06-01-iroh-tickets-security-model]], [[2026-06-01-noise-protocol-framework-rev34]].
