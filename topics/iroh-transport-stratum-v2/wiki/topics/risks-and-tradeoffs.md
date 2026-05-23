---
title: "Risks and tradeoffs"
type: topic
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: warm
confidence: high
sources:
  - raw/papers/2026-spath-quic-kernel-bypass-noms.md
  - raw/articles/2026-05-20-loke-http3-udp-throttling.md
  - raw/articles/2026-05-20-iroh-issue-2951-regression.md
  - raw/articles/2026-05-20-iroh-relays-concept.md
  - raw/articles/2026-05-20-probelab-dcutr-success-rate.md
tags: [iroh, sv2, risks, contrarian]
---

# Risks and tradeoffs

The steelman against. Each risk has a mitigation; if you can't accept the
mitigations, don't ship.

## R1 — QUIC CPU penalty at scale

**Evidence**: Späth et al. NOMS 2026; Yang/Eggert SIGCOMM EPIQ 2020.
- 3.5× CPU vs TCP+TLS (Google's own number).
- 50% of CPU is data copy between user/kernel space; with kernel bypass,
  crypto becomes 40%+.
- 1% packet reorder rate → 3-5× throughput collapse for some QUIC stacks.

**Affects**: top-tier pools doing 10⁵+ concurrent miner connections.

**Does not affect**: individual miners, translator proxies, JD-Client/Server,
small private pools.

**Mitigation**:
- Pool sizing: budget 2-3× the CPU vs SV2-over-TCP.
- Track noq's GSO/GRO support. Once enabled, the gap shrinks substantially.
- Don't make iroh the ingress for 10⁵-miner pools until noq has NIC offload.

## R2 — Silent UDP throttling on consumer ISPs

**Evidence**: Loke production observations.
- ISP UDP policing can throttle to ~1 Mbps silently.
- P99 latency spikes; H2 outperforms H3.
- **Failure mode is silent** — error logs stay green.

**Affects**: residential miners on UDP-policed ISPs. Hard to predict population
size — varies wildly by region.

**Mitigation**:
- **Mandatory TCP fallback** (already in SRI #1935 — server-side dual
  transport).
- Per-connection RTT and throughput telemetry → operators detect throttling.
- Document this clearly in operator-facing docs. Some miners _will_ need TCP.

## R3 — n0 relay centralization

**Evidence**: iroh docs (vendor admission).
- Default n0 relays "carry no uptime or performance guarantees".
- Recommended for "development and testing" only.
- ~10% of sessions go through relays in iroh's own claim; ~30% in
  permissionless settings.

**Mitigation**:
- **Self-host relays for production**. The `iroh-relay` binary is the reference
  implementation.
- For pools with stable public IP and miners that can dial them directly:
  relays not required at all in the steady state.

## R4 — Pre-1.0 stability churn

**Evidence**: Iroh issue #2951 — 6.25% silent transfer failure across iroh
0.27 → 0.31. Multi-GB trace logs required to diagnose.

**Mitigation**:
- iroh hit 1.0.0-rc.0 in May 2026. Target the 1.0+ API.
- Pin to a known-good iroh version. Treat iroh-version bumps with extra
  scrutiny.
- Gate iroh transport behind `iroh-transport` feature flag for the first
  several SV2 releases. Don't make it default.
- Build observability hooks (per-connection RTT, throughput, transport-type)
  from day one.

## R5 — Curve mismatch with SV2 authority pubkey

**Evidence**: SV2 spec — authority pubkey is secp256k1 (32B). Iroh
EndpointId is Ed25519 (32B). Different curves, different math.

**Mitigation**:
- Dual-publish: pool exposes both an SV2 secp256k1 cert and an iroh Ed25519
  EndpointId. They're linked operationally, not cryptographically.
- The Noise_NX cert continues to use secp256k1 — no spec change.
- Future SV2 spec extension could allow Ed25519, but out of scope for v1.

## R6 — Observability is harder than TCP

**Evidence**: industry experience with QUIC; iroh issue #2951 required
multi-GB qlog traces.

**Mitigation**:
- Use SSLKEYLOGFILE-equivalent (qlog) at the noq layer.
- Per-connection structured logs for RTT, throughput, transport-type, peer
  EndpointId.
- Don't promise to debug a stuck connection in seconds the way you can with
  tcpdump.

## R7 — Operational practice (DDoS scrubbing, traffic auditing)

**Pattern**: Pools often run their stratum ingress behind Cloudflare / Voxility
DDoS scrubbing, or do regulatory traffic capture for compliance. These are
TCP-shaped tools.

**Mitigation**:
- Dual transport: keep TCP for operators who need scrubbed/audited paths.
- A self-hosted iroh relay can be the DDoS chokepoint instead — but that's
  new operational tooling.
- Acknowledge: this is a real reason some pools won't migrate quickly.

## What this list does NOT include

These were considered and dismissed as not load-bearing:

- "QUIC is unproven" — iroh runs in production at hundreds of thousands of
  devices (Paycode, Delta Chat). Not a real risk.
- "Hole-punch success rate is bad" — for pool ↔ miner, NAT is irrelevant on
  the pool side because the pool has a public IP. Hole-punch failure modes
  only matter for miner ↔ miner P2P.
- "Iroh depends on Quinn fork (noq)" — n0 maintains noq actively; the fork
  is documented and tracked. Not zero risk but not load-bearing for v1.

## See also

- [[Why Iroh|wiki/topics/why-iroh-for-sv2.md]]
- [[Integration playbook|wiki/topics/sv2-iroh-transport-playbook.md]]
- [[QUIC performance ceiling|wiki/concepts/quic-performance-ceiling.md]]
