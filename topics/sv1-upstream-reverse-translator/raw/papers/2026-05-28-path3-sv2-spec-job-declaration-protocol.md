---
title: "SV2 Spec — Job Declaration Protocol (06)"
url: https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md
type: paper
source: stratum-mining/sv2-spec
captured: 2026-05-28
quality: 9
path: 3
tags: [jdp, job-declaration, censorship-resistance, mev, custom-templates, sv1-upstream]
---

# SV2 Spec — Job Declaration Protocol (06)

## Why this matters for the reverse translator

JDP is the *headline political claim* of SV2: miner-chosen templates → censorship resistance, miner-retained MEV, fee-revenue sovereignty. **None of it survives an SV1 upstream.** SV1 has zero JD primitives; the upstream pool builds the template, and the operator's SV2 stack downstream of SV1 is reduced to a pretty wrapper around legacy semantics.

## Core primitives JDP introduces

- **Two operational modes**:
  1. **Coinbase-only** — miner proposes fee structure without revealing tx data (mempool privacy)
  2. **Full-Template** — miner declares complete tx set with cryptographic validation
- **Architecture**: Job Declarator Server (JDS) on pool side; Job Declarator Client (JDC) on miner side; token-based work authorization
- **Message types**: `AllocateMiningJobToken`, `DeclareMiningJob`, `DeclareMiningJob.Success`, `ProvideMissingTransactions`, `PushSolution`

## What JDP enables

- **Custom block templates** — miners maintain autonomous mempool selection rather than accepting pool-imposed transactions
- **Censorship resistance** — "the miner [can] never stop mining on their preferred templates," preventing pools from forcing transaction exclusions
- **MEV claim retention** — miners retain coinbase output control, directing fee revenue to their addresses rather than the pool's unilateral choice
- **Inversion of authority** — under JDP, "Pools that opt into this protocol are only responsible for accounting shares and distributing rewards"

## Why SV1 cannot deliver any of this

SV1 is a *unidirectional instruction protocol*: pools send work, miners execute. There are no JD primitives, no template-decoupling messages, no token-grant flow. The structural inversion JDP creates is impossible to bolt onto SV1 from the operator side — the upstream pool retains complete work-generation authority by protocol design.

## Feature-survival verdict (reverse translator)

| Feature | Status | Why |
|---|---|---|
| JDP itself | **lost** | No SV1 equivalent messages; nothing to negotiate against |
| Custom block template selection | **lost** | Pool ships the template, period |
| Censorship resistance via miner templates | **lost** | Operator inherits whatever filtering the SV1 pool applies |
| MEV-retention via coinbase control | **lost** | SV1 coinbase is constructed by pool |
| Coinbase-only fee declaration | **lost** | No SV1 wire format for it |

## Ingest justification

This is the single most important spec document for understanding which SV2 *political* benefits evaporate behind an SV1 upstream. The whole MEV/censorship-resistance argument for SV2 lives or dies on JDP, and JDP cannot survive an SV1 pool.
