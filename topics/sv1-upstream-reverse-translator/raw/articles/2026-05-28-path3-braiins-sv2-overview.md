---
title: "Braiins — Past and Future of Bitcoin Mining Protocols: Stratum V2 Overview"
url: https://braiins.com/blog/past-and-future-of-bitcoin-mining-protocols-stratum-v2-overview
type: article
source: braiins.com
captured: 2026-05-28
quality: 6
path: 3
tags: [braiins, sv2-overview, censorship, mev, decentralization, sri-1.0, deployment-status]
---

# Braiins — Stratum V2 Overview

## Why this matters for the reverse translator

Braiins is the primary author of SV2 and operates a major SV2-capable pool. Their narrative *frames the political case* for the protocol. That framing is exactly what collapses when the upstream pool is SV1.

## Key claims (and reverse-translator status)

| Claim | Mechanism | Survives reverse translator? |
|---|---|---|
| "Stronger security to prevent MITM attacks" | Noise NX | **partially-lost** at egress |
| "Reduces bandwidth usage, speeding up mining communications" | Binary framing | **partially-lost** — internal only |
| "Greater control over transaction selection" | Job Declaration | **lost** |
| "Construct their own block templates" | JDP full-template mode | **lost** |
| "Power back to the miners" | Decoupled work construction | **lost** |
| Hashrate hijacking prevention | Noise auth | **partially-lost** at egress |
| "Pool operator(s) compromised" → miner is alerted | JDP + auth | **lost** — SV1 has no alerting |

## Deployment status note

The post references the **March 2024 SRI v1.0 release**. As of capture date (2026-05), SRI is mature for v1→v2 (forward translator) but has **no v2→v1 reference role** — confirming the spec gap noted in [[2026-05-28-path3-sv2-spec-discussion-deployment-scenarios.md]].

## Quotes on censorship

- V2 addresses scenarios where "pool operator(s) were to be compromised"
- Concerns about "uneconomic block construction" (i.e., pool censorship driving suboptimal-fee blocks)

These benefits are *contingent on JDP*. An SV2-stack operator running against an SV1 pool inherits whatever filtering the SV1 pool applies, with zero protocol-level visibility or recourse.

## Quality / credibility note

Braiins has a commercial stake in SV2 adoption (they sell pool software and operate Braiins Pool). The post is light on quantitative metrics ("reduces bandwidth" with no number) and heavy on narrative. Treat as primary-source advocacy, not benchmarked engineering.

## Feature-survival summary

Every "miner sovereignty" claim Braiins makes for SV2 is contingent on the upstream pool also speaking SV2. The reverse translator buys you SV2 *internal plumbing* but does not deliver any of the political case.

## Ingest justification

Captures the *advocacy framing* of SV2 from the project's primary commercial backer. Important for understanding what marketing claims a reverse-translator topology *fails to deliver* — and therefore what an honest deployment guide must walk back.
