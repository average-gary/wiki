---
title: "Stratum V2 Feature Set - Encryption, Hashrate-Hijacking, Template Authority"
url: https://braiins.com/blog/stratum-v2-mining-protocol
source_type: vendor-blog
ingested_by: path5
ingested_on: 2026-06-01
quality: medium-high
relevance: high
hypotheses_addressed: [2, 5, 6]
---

# Stratum V2 Feature Set - Encryption, Hashrate-Hijacking, Template Authority

## Provenance
Braiins (co-author of SV2 spec) corporate explainer. Useful for the canonical
feature framing even if marketing-shaded.

## Key Findings

- **Noise NX encryption** between miner and upstream is the standard SV2
  hashrate-hijacking mitigation. Applies *between miner and proxy* in a
  Path-3 deployment, NOT between proxy and OCEAN (DATUM Gateway speaks SV1
  upstream).
- **Miner-side transaction selection** (via Job Declaration) is the SV2
  decentralization story. SV2 "gives miners the power to choose which
  transactions they include in a block."
- **Mainnet reference implementation released March 2024** - by mid-2026
  this is mature enough to compose with non-SV2 upstreams as an exercise.

## Hypothesis Implications

- **H2 (internal Noise transport for the operator):** SUPPORTED. The proxy
  *does* gain SV2-encrypted miner sessions. But this is only meaningful when
  the threat is hashrate hijacking on the LAN/WAN between miner and proxy. If
  the proxy operator and miner operator are the same entity (single farm),
  the value is modest - LAN hijacking is not the primary attack surface.
- **H5 (censorship-resistance preservation):** UNCLEAR / SUBTLE. SV2's
  template authority story assumes the JD-Client can drive template creation.
  In a Path-3 deployment, *DATUM Gateway* is already driving template
  creation from the operator's bitcoind (with Knots policy). The downstream
  SV2 miner cannot independently pick transactions - that authority is
  pre-empted by the proxy/gateway/node stack one layer up. **The SV2 layer is
  effectively transparent to template choice; the proxy operator (via
  Gateway+Knots) is the censorship-resistance principal.**
- **H6 (dev tooling / SRI testing):** SUPPORTED. The proxy is a useful
  test-bed for SRI Translator + JD code paths against a real-pool upstream
  that isn't a synthetic SV2 pool.

## Threat-Model Implications

- **Miner-vs-proxy:** Noise NX between miner and proxy stops a network
  attacker from redirecting hashrate.
- **Proxy-vs-OCEAN:** SV1 link, no Noise. Standard TLS-or-nothing on the
  DATUM-protocol channel. Operator must protect the gateway-to-OCEAN link
  themselves.
- **Template authority is centralized at the proxy.** Downstream SV2 miners
  technically *speak* JD-style messages but the canonical template comes from
  the proxy's bitcoind+Gateway. This is a model (a) in Path 3's framing -
  proxy-driven templates - not model (b) miner-driven.

## Ingest Justification
Frames what SV2 actually delivers and forces the honest read: the SV2 layer
in a Path-3 proxy buys you *transport security and channel multiplexing*, not
template decentralization. Template decentralization was already DATUM's job.
