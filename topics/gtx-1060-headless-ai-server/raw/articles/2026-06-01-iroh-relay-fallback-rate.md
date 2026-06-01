---
title: "Iroh Concepts: Relays — '~9 out of 10 networking conditions allow direct'"
source: https://docs.iroh.computer/concepts/relays
type: article
tags: [iroh, relay, fallback, nat-traversal, holepunching]
date: 2026-06-01
quality: 4
confidence: high
agent: 8
summary: "Per official iroh docs: 'Roughly 9 out of 10 networking conditions allow a direct connection' — i.e. ~10% relay fallback rate. With iroh 1.0.0-rc.1's hard-NAT holepunching, this number is expected to improve."
---

# Iroh direct-vs-relay split

## Number

**~10% of connections fall back to relay**, ~90% direct (with holepunching).

> "Roughly 9 out of 10 networking conditions allow a direct connection."
> — docs.iroh.computer/concepts/relays

## What changes with rc.1

Iroh 1.0.0-rc.1 ships **hard-NAT holepunching** (servers behind symmetric NAT can be reached directly when previously they could only be reached via relay). The 90% direct number is from before rc.1 — likely improves.

## Implication for the GTX 1060 server

Behind home CGNAT is the most common case:

- ~80-90% of incoming connections hole-punch directly (after rc.1's improvements, likely higher)
- ~10-20% fall back through relay
- Relay adds ~50-150 ms RTT on top (depending on geographic distance to chosen relay)
- Once a direct path is found mid-session, iroh migrates onto it (multipath QUIC since 0.96)

## Cost / privacy notes

- Relays know who talks to whom (per [[2026-06-01-iroh-tickets-security-model]] discussion #3168)
- Default uses n0's free relays — bandwidth cost on n0
- Self-hosted relay: 0.97 ships an embeddable relay; 0.98 ships iroh-relay-v2 protocol with Health frames; rc.0 adds auth tokens

## See also

- [[2026-06-01-iroh-1-0-0-rc-1]]
- [[2026-06-01-iroh-0rtt-handshake-blog]]
