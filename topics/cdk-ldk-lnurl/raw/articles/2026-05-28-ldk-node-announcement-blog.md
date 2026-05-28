---
title: "Announcing LDK Node (LDK blog, April 2024)"
type: article
source: https://lightningdevkit.org/blog/announcing-ldk-node/
fetched: 2026-05-28
published: 2024-04
confidence: medium
tags: [ldk-node, history, design-rationale]
summary: Origin announcement for LDK Node. Design pitch — ~30 API calls vs LDK's 900+. At launch Esplora-only chain source, VSS planned. Both have since shipped.
---

# Announcing LDK Node — April 2024

## Design pitch

- **~30 API calls** vs LDK's ~900+ — explicit "minimal API, mobile-first" framing
- Bundle LDK + a sane default for everything LDK leaves open (chain access, persistence, gossip, on-chain wallet)
- UniFFI bindings as first-class — Swift, Kotlin, Python (Flutter community-maintained)
- Mobile is the primary target

## At-launch limitations (now resolved)

- Esplora was the **only chain source** at launch. Bitcoin Core RPC, Electrum, and Bitcoin Core REST followed.
- **VSS was vapor**. Shipped in v0.4 (Oct 2024); hardened in v0.7 (Dec 2025).
- LSP support followed in v0.5 (Apr 2025).

## Public RGS endpoint

`https://rapidsync.lightningdevkit.org/<network>/snapshot` (v1) → `/v2/snapshot` in current README. LDK operates this.

## Performance

**No public benchmarks have been published** in any of the official sources surveyed. No startup time, channel sync time, or payment latency numbers in the announcement, the README, or subsequent release notes. The closest practitioner data point is the [[../../ldk-server/raw/articles/2026-05-26-fedimint-gateway-ldk-node-case-study.md|Fedimint Gateway case study]] (in the adjacent ldk-server wiki).

## Implications for CDK + LDK + LNURL

The "minimal API, mobile-first" design choice is precisely what makes LDK Node embeddable inside `cdk-mintd`. The price is the absence of fully-featured LN-node behaviors a CLN/LND operator expects (custom autopilot, sophisticated rebalancing, on-chain coin selection beyond BDK defaults).

For a small mint, that price is low. For a high-volume mint, those operational gaps push toward CLN/LND backends (`cdk-cln`, `cdk-lnd`).
