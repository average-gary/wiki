---
title: "p2poolv2 wiki — Using Stratum v2"
source_url: https://github.com/p2poolv2/p2poolv2/wiki/Using-Stratum-v2
type: project-wiki
ingested: 2026-05-22
quality: 4
confidence: high
tags: [p2poolv2, sv2, deployment, jdc]
---

# p2poolv2 wiki — Using Stratum v2

Authoritative project statement on SV2 intent and architecture. Living doc — current as of May 2026.

## Status
SV2 integration is positioned as **future / aspirational, not implemented**. (Confirmed by absence of SV2 deps in `Cargo.toml` and absence of SV2 PRs in repo history.)

## Two target deployment scenarios

### 1. Local / on-prem (cloud-style farm)
- ASICs connect directly via encrypted SV2 channels
- Replaces nginx-style stratum proxies
- Pool operator runs p2poolv2 + SV2 mining frontend in same network as miners

### 2. Remote (public pool)
- Miners run a JDC against the pool
- Pool runs JDS validating against p2poolv2's share-chain rules
- This is where the sv2-apps `JobValidationEngine` trait fits naturally

## Open
- No timeline given.
- No current SV2 role implementation specified — design only.

## Implication
The "remote" scenario maps almost 1:1 onto the sv2-apps architecture: a `JobValidationEngine` implementation backed by p2poolv2's share-chain validator. The "local" scenario is a more invasive change requiring p2poolv2 to terminate SV2 mining channels itself (sibling `stratum_v2/` module).
