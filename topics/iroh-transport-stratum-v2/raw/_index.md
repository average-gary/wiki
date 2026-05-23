---
title: Raw Sources
type: index
updated: 2026-05-20
---

# Raw Sources (20 total)

## papers/ (3)

- [[2024-erosion-routing-attacks-mining-pools.md|papers/2024-erosion-routing-attacks-mining-pools.md]] — **Erosion (Tran et al., S&P 2024)** — 91% of pools vulnerable to single-packet tampering on SV2/TCP
- [[2026-trautwein-dcutr-imc-measurement.md|papers/2026-trautwein-dcutr-imc-measurement.md]] — Trautwein et al. IMC '26 — 4.4M DCUtR attempts, 70% success, TCP/QUIC indistinguishable
- [[2026-spath-quic-kernel-bypass-noms.md|papers/2026-spath-quic-kernel-bypass-noms.md]] — Späth et al. NOMS '26 — QUIC userspace ceiling, 3.5× CPU vs TCP+TLS

## articles/ (13)

### Upstream RFC
- [[2026-05-20-sri-discussion-1935-iroh-noise-connection.md|articles/2026-05-20-sri-discussion-1935-iroh-noise-connection.md]] — **SRI Discussion #1935** (the RFC this branch implements)

### iroh side (n0 docs / blog)
- [[2026-05-20-iroh-endpoint-api-docs.md|articles/2026-05-20-iroh-endpoint-api-docs.md]] — `iroh::endpoint::Endpoint` API
- [[2026-05-20-iroh-crate-top-level-docs.md|articles/2026-05-20-iroh-crate-top-level-docs.md]] — crate top-level concepts
- [[2026-05-20-iroh-relays-concept.md|articles/2026-05-20-iroh-relays-concept.md]] — relay model + production caveats
- [[2026-05-20-iroh-1-0-0-rc-0.md|articles/2026-05-20-iroh-1-0-0-rc-0.md]] — 1.0.0-rc.0 release notes
- [[2026-05-20-iroh-0-97-custom-transports-noq.md|articles/2026-05-20-iroh-0-97-custom-transports-noq.md]] — custom transports + noq fork
- [[2026-05-20-iroh-paycode-case-study.md|articles/2026-05-20-iroh-paycode-case-study.md]] — Paycode production deployment

### SV2 side
- [[2026-05-20-sv2-protocol-security-noise-nx.md|articles/2026-05-20-sv2-protocol-security-noise-nx.md]] — Noise NX spec (acts, frame sizes, cert)
- [[2026-05-20-sv2-protocol-overview-framing.md|articles/2026-05-20-sv2-protocol-overview-framing.md]] — frame header, channels

### Adjacent / contrarian
- [[2026-05-20-tailscale-nat-traversal.md|articles/2026-05-20-tailscale-nat-traversal.md]] — Tailscale NAT-traversal baseline
- [[2026-05-20-probelab-dcutr-success-rate.md|articles/2026-05-20-probelab-dcutr-success-rate.md]] — ProbeLab 72% / 13.3k DCUtR attempts
- [[2026-05-20-iroh-issue-2951-regression.md|articles/2026-05-20-iroh-issue-2951-regression.md]] — silent regression spanning iroh 0.27→0.31
- [[2026-05-20-loke-http3-udp-throttling.md|articles/2026-05-20-loke-http3-udp-throttling.md]] — silent UDP throttling on consumer ISPs

## repos/ (4)

- [[2026-05-20-fedimint-iroh-integration.md|repos/2026-05-20-fedimint-iroh-integration.md]] — **Fedimint** (the reference implementation cited by SRI #1935)
- [[2026-05-20-iroh-blobs-alpn-template.md|repos/2026-05-20-iroh-blobs-alpn-template.md]] — iroh-blobs as ALPN protocol template
- [[2026-05-20-iroh-examples-framed-messages.md|repos/2026-05-20-iroh-examples-framed-messages.md]] — framed-messages + custom-router
- [[2026-05-20-deltachat-peer-channels.md|repos/2026-05-20-deltachat-peer-channels.md]] — Delta Chat production integration shape
