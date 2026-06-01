---
title: "Iroh 0-RTT API blog post — handshake latency numbers"
source: https://www.iroh.computer/blog/0rtt-api
type: article
tags: [iroh, 0-rtt, handshake, latency, benchmark]
date: 2026-06-01
quality: 5
confidence: high
agent: 8
summary: "Baseline ping Europe-Asia: 235-354 ms (~250 ms typical). Initial (non-0-RTT) connection setup overhead beyond network RTT: ~537-556 microseconds. Subsequent 0-RTT connection setup overhead: ~231-384 microseconds. Average end-to-end with 0-RTT: ~231 ms (matches single-RTT — handshake adds essentially nothing)."
---

# Iroh 0-RTT handshake costs

Direct numbers for handshake / TTFB.

## Numbers

| Measurement | Value |
|-------------|------:|
| Europe-Asia baseline ping | 235-354 ms (~250 ms typical) |
| First connection setup overhead beyond network RTT | ~537-556 μs |
| 0-RTT connection setup overhead | ~231-384 μs |
| End-to-end with 0-RTT | ~231 ms |

## Translation to homelab AI server

For LAN-local clients (~1 ms RTT):

- First connect: ~1.5 ms total (1 ms RTT + ~0.5 ms handshake)
- 0-RTT subsequent: ~1.3 ms total

For a remote phone subscribing to a MoQ track on the home server:

- First connect (relayed): ~250 ms (relay RTT) + ~0.5 ms = ~250 ms
- After hole-punch (direct): ~50-100 ms typical home-internet RTT + 0-RTT = ~50-100 ms
- Glass-to-glass for a MoQ inference output: handshake << inference latency, so handshake is essentially free in steady state

## See also

- [[2026-06-01-iroh-relay-fallback-rate]]
- [[2026-06-01-iroh-secure-video-everywhere-blog]]
