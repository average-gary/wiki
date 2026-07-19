---
title: "SRI noise-sv2 cargo bench: Noise_NX handshake & transport costs"
source_url: https://github.com/stratum-mining/stratum/blob/main/sv2/noise-sv2/BENCHES.md
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, connections, noise, sv2, benchmark, handshake, cpu, primary-source]
---

# SRI noise-sv2 benchmarks — primary-source CPU costs

Authoritative cargo-bench output committed to the Stratum Reference Implementation
repo. Tests `Noise_NX` (the SV2 handshake pattern: `<- e`, `<- e, ee, s, es, SIG`,
`-> s, se`) plus AEAD transport roundtrips using ChaCha20-Poly1305.

## Handshake (single-pair, in-process, criterion)

| Step                  | Time (median) |
|-----------------------|---------------|
| step_0_initiator      | **18.7 µs**   |
| step_1_responder      | **178.1 µs**  |
| step_2_initiator      | **120.9 µs**  |
| **full handshake**    | **317.4 µs**  |

So a full SV2 Noise_NX handshake is ~**317 µs of CPU on one core**, dominated by
the responder side (step_1 = 178 µs ≈ 56% of total) — which is the cost the
**pool** pays per inbound connection (the pool is the responder).

## Transport roundtrip (encrypt + decrypt one frame)

| Payload | Roundtrip   |
|---------|-------------|
| 64 B    | 5.20 µs     |
| 256 B   | 5.50 µs     |
| 1024 B  | 7.28 µs     |
| 4096 B  | 16.39 µs    |

## Connection-rate ceiling implied by these numbers

If a pool dedicates **one core entirely** to Noise responder work:
- 1 core ÷ 178 µs/conn = ~**5,600 new SV2 connections/sec/core** (handshake-bound)
- 8 cores ÷ 178 µs ≈ **45,000 new conn/sec** sustained

For steady-state share traffic (most messages 64–256 B), one core can encrypt+decrypt
~**180k–190k frames/sec**, i.e. ~190k share submissions/sec/core if all CPU went
to crypto (it does not — JSON parsing, validation, channel accounting consume more).

## Implications for scale-test simulator

- Handshake is a **massive thundering-herd risk**: 100k miners reconnecting after
  a pool restart at 5.6k handshakes/sec/core needs ~18s × cores to drain.
- Vardiff floor (1 share / 30-60s typical) means at 100k connections, share rate
  is 1,666–3,333 sps. At 5 µs encrypt + 5 µs decrypt = 10 µs framing CPU per
  share, that's 16–33 ms of crypto CPU per second — **<2% of one core**. Crypto
  is NOT the steady-state bottleneck; handshake reconnect storms are.

## Notes / caveats

- These are criterion micro-benches on a single thread, no syscall overhead, no
  TCP. Real-world per-connection cost includes accept(), epoll registration,
  TCP handshake (~1 RTT), tokio task spawn, TLS-style frame buffering.
- "Performance has improved" line in the bench output suggests a recent
  optimization PR; numbers may shift again.
- secp256k1 ECDH is the dominant cost in step_1; further speedups likely come
  from batched verification or hardware acceleration.

## Reproducing

```bash
git clone https://github.com/stratum-mining/stratum
cd stratum/sv2/noise-sv2
cargo bench
```
