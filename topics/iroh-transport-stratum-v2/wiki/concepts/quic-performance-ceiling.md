---
title: "QUIC performance ceiling vs TCP"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/papers/2026-spath-quic-kernel-bypass-noms.md
  - raw/articles/2026-05-20-loke-http3-udp-throttling.md
tags: [quic, performance, contrarian, ceiling]
---

# QUIC performance — the ceiling

Peer-reviewed evidence (Späth et al., NOMS 2026) that QUIC's userspace design
imposes a structural performance ceiling vs kernel TCP that only DPDK / SR-IOV
/ GSO+GRO can close — none realistic for typical mining infra.

## Numbers

- Without offload, four leading QUIC stacks: **2.2–8.3 Gbit/s goodput**.
- With DPDK: up to **3× (LSQUIC, 10.8 Gbit/s)**.
- Citing Google: **QUIC burns 3.5× more CPU** than TCP+TLS (single-connection,
  POSIX socket).
- 1% packet reorder rate: **3–5× throughput collapse** for some stacks.
- Single-connection POSIX-socket QUIC: 325–489 Mbit/s; netmap kernel-bypass:
  4121 Mbit/s — **10× gap**.

## Sizing for SV2

| Workload | CPU concern? |
|----------|--------------|
| Single miner (KB/sec) | None. CPU cost irrelevant. |
| Translator proxy (10s of miners) | Minimal. Same regime. |
| Top-10 pool ingress (10⁵ miners) | **Significant.** Budget 2-3× the CPU vs. SV2-over-TCP at the same workload. |

## Silent UDP throttling

Production observation (Loke):
- ISP UDP policing can cap throughput to **~1 Mbps** silently.
- P99 latency spiked when HTTP/3 enabled; H2 was 2× faster.
- Failure mode: silent. Error logs stay green. Stale-share rate climbs but no
  signal.

## Mitigations for the SV2 transport

1. **Always provide TCP fallback**. Already in SRI #1935 — server-side dual
   transport, client auto-falls-back.
2. **Telemetry**: log per-connection RTT and throughput so a miner can detect
   "my ISP is throttling UDP" vs "the pool is slow."
3. **Pool sizing**: budget extra CPU for QUIC ingress, or invest in NIC offload
   (GSO/GRO support in the noq stack — track the upstream feature).
4. **Don't run an iroh-only pool**. Dual transport is mandatory for the
   foreseeable future.

## See also

- [[NAT traversal — baseline|wiki/concepts/nat-traversal-baseline.md]]
- [[Risks and tradeoffs|wiki/topics/risks-and-tradeoffs.md]]
