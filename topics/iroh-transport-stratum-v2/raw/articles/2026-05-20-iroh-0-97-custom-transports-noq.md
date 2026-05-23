---
title: "iroh 0.97.0 — Custom Transports & noq"
source_url: https://www.iroh.computer/blog/iroh-0-97-0-custom-transports-and-noq
type: blog
date: 2026-03
org: n0-computer
credibility: high
quality: 5
relevance: direct
tags: [iroh, release, custom-transports, noq, quinn]
ingested: 2026-05-20
---

# iroh 0.97.0 — Custom Transports & noq

## Custom transports — the supported extension surface

> "Any unreliable datagram transport that can support a minimum packet size of
> **1200 bytes** can be used as a custom transport for iroh."

API:
```rust
Endpoint::builder(preset)
    .add_custom_transport(...)
    .bind()
    .await?;
```

Reference custom-transport implementations exist for:
- **Tor** — for censorship-resistance
- **Nym** — for stronger anonymity
- (Community work) **Bluetooth LE**

## noq — the Quinn fork

> "All internal references have been updated from Quinn to **noq**, and types
> are now re-exported from noq directly."

n0 forked Quinn into "noq" (n0's QUIC) — diverged enough for multipath +
NAT traversal that they ship it as an independent project.

Implication: a project depending on iroh inherits a non-upstream Quinn fork.
Patches to upstream `quinn` (security fixes, perf) reach iroh only after n0
syncs. Track the noq repo for security disclosures, not Quinn's.

## Other 0.97 changes

- Preset API now requires explicit relay configuration.
- Customizable TLS trust roots.
- Address filtering for lookup services.
- Explicit endpoint-close lifecycle.

## Implications for SV2

- **Tor-as-iroh-transport** is the relevant custom transport for SV2: a
  censorship-resistant pool deployment can use Tor underneath iroh, getting
  iroh's identity/discovery/ALPN model on top of Tor's anonymity. Pair this
  with the b10c F2Pool OFAC censorship finding (2025) for a clean motivation.
- 1200-byte MTU is comfortable for SV2 frames (max 65,535 bytes payload over
  multiple QUIC packets — QUIC handles fragmentation internally).
- **Custom transports are gated behind `unstable-custom-transports`** as of
  1.0.0-rc.0 — they will remain unstable post-1.0. Don't ship a Tor-based SV2
  pool on this surface without accepting churn.
