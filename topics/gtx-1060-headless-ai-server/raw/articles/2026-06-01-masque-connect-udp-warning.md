---
title: "draft-ietf-masque-connect-udp — UDP Proxying over HTTP (the QUIC-over-QUIC warning)"
source: https://datatracker.ietf.org/doc/html/draft-ietf-masque-connect-udp
type: article
tags: [masque, quic, tunneling, congestion, hol, contrarian]
date: 2026-06-01
quality: 5
confidence: high
agent: 5
summary: "§6.2 explicitly warns: 'When the protocol running over UDP that is being proxied uses congestion control (e.g., QUIC), the proxied traffic will incur at least two nested congestion controllers.' §6.4 rules out TCP carriage to avoid nested HoL: 'UDP proxying SHOULD be performed over HTTP/3 to allow leveraging the QUIC DATAGRAM frame.' §6.1 / §5.5 cap payloads at 65527 bytes and forbid sending UDP payloads that won't fit into a single QUIC DATAGRAM through capsules — i.e. PMTU mismatches force drops, not fragmentation."
---

# IETF formal guidance: don't tunnel QUIC reliably over QUIC

Authoritative source backing the QUIC-over-QUIC overhead / HoL / MTU critique.

## The three concrete problems

### §6.2 — Nested congestion controllers

> "When the protocol running over UDP that is being proxied uses congestion control (e.g., QUIC), the proxied traffic will incur at least two nested congestion controllers."

Each layer separately backs off on loss. Result: TCP-like throughput collapse on top of QUIC.

### §6.4 — Stream-based carriage causes HoL

> "UDP proxying SHOULD be performed over HTTP/3 to allow leveraging the QUIC DATAGRAM frame."

Tunneling UDP-bearing-QUIC over a reliable QUIC stream means the inner connection's recovery is gated by the outer connection's reliable delivery → head-of-line blocking, exactly the thing QUIC was designed to avoid.

### §6.1 / §5.5 — PMTU mismatch

- Payloads cap at 65,527 bytes
- Forbid sending UDP payloads that won't fit into a single QUIC DATAGRAM through capsules
- Result: PMTU mismatches force **drops, not fragmentation**

## Implication for "moq over iroh"

moq-net rides on `web-transport-trait`, which over iroh becomes streams on iroh's QUIC. **moq-lite uses streams (not datagrams)**; one inner stream per Subgroup/Group/frame.

→ inner-stream loss recovery sits on top of iroh's QUIC stream loss recovery: **two reliable layers, but only one congestion controller** (the outer one). Not the same problem MASQUE warns about (no UDP-bearing-QUIC inner protocol), but the HoL concern is real:

- A burst loss on the iroh QUIC layer stalls all moq streams sharing that connection
- Mitigation: moq-lite already maps Subgroups to QUIC streams 1:1; QUIC's per-stream HoL isolation handles the per-track case
- Cross-track HoL (across iroh's stream-multiplex) is the residual concern

## Implication for "iroh as SSH transport"

SSH inside `dumbpipe connect` is TCP-semantics over a QUIC stream. **NOT** QUIC-over-QUIC. The MASQUE warning doesn't apply directly. The latency cost is one QUIC handshake + one relay hop (if relayed). See [[2026-06-01-iroh-0rtt-handshake-blog]] for handshake cost numbers.

## See also

- [[2026-06-01-iroh-0rtt-handshake-blog]]
- [[2026-06-01-blake3-bench-data]]
