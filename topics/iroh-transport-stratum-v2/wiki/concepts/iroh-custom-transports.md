---
title: "iroh: Custom transports (Tor, Nym, BLE)"
type: concept
created: 2026-05-20
updated: 2026-05-20
verified: 2026-05-20
volatility: hot
confidence: medium
sources:
  - raw/articles/2026-05-20-iroh-0-97-custom-transports-noq.md
  - raw/articles/2026-05-20-iroh-1-0-0-rc-0.md
tags: [iroh, custom-transport, tor, nym, censorship-resistance]
---

# iroh: Custom transports

Since iroh 0.97 (March 2026), iroh's transport layer is pluggable for any
"unreliable datagram transport that can support a minimum packet size of 1200
bytes."

API:
```rust
Endpoint::builder(preset)
    .add_custom_transport(...)
    .bind()
    .await?;
```

## Reference implementations

- **Tor** — censorship-resistance / anonymity
- **Nym** — stronger anonymity (mixnet)
- **Bluetooth LE** — community work, no internet required

## Stability

> Custom transports moved behind `unstable-custom-transports` feature flag in
> 1.0.0-rc.0 and **will remain unstable post-1.0**.

So in 2026, this is an experimental surface. Don't ship a critical pool
deployment riding this API.

## Why this matters for SV2

The b10c finding that F2Pool was **OFAC-censoring transactions in 2025**
(reproducing the 2024 finding that prompted SV2 in the first place) is a clean
motivation. A Tor-based SV2 deployment using iroh-on-tor would let a miner:

- Connect to a pool whose relay/IP is unknown to the miner's ISP
- Obscure the pool ↔ miner relationship from on-path observers
- Defeat IP-level pool blocking

But: gated behind `unstable-custom-transports`, and Tor ↔ QUIC has its own
performance pathologies. Treat as future work, not v1.

## See also

- [[Why Iroh — censorship resistance|wiki/topics/why-iroh-for-sv2.md]]
- [[iroh: Endpoint and ALPN|wiki/concepts/iroh-endpoint-and-alpn.md]]
