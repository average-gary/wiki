---
title: "Stratum V2 Spec — 06 Job Declaration Protocol"
source_url: https://github.com/stratum-mining/sv2-spec/blob/main/06-Job-Declaration-Protocol.md
type: protocol-spec
ingested: 2026-05-22
quality: 5
confidence: high
tags: [sv2, jdp, jds, jdc, protocol, spec]
---

# Stratum V2 Spec — 06 Job Declaration Protocol

Authoritative protocol specification. Defines the JDS/JDC roles that are the central integration surface for any "decentralized share-chain pool plugged into SV2."

## Roles
- **JDC (Job Declarator Client)** — miner-side. Negotiates a custom mining job (template) with a JDS.
- **JDS (Job Declarator Server)** — pool-side. Accepts declared jobs, validates them, returns a job token, then routes shares back to the share-accounting subsystem.

## Two declaration modes
- **Coinbase-only**: pool sees only coinbase fee revenue (preserves miner mempool privacy).
- **Full-Template**: pool validates full wtxid list. Higher trust, lower miner privacy.

## Message flow
```
JDC -> JDS : AllocateMiningJobToken
JDS -> JDC : AllocateMiningJobToken.Success
JDC -> JDS : DeclareMiningJob
JDS -> JDC : DeclareMiningJob.Success | DeclareMiningJob.Error | ProvideMissingTransactions
(if missing tx): JDC -> JDS : ProvideMissingTransactionsSuccess
... share submission via Mining Protocol channel ...
JDC -> JDS : PushSolution (when block found)
```

## Core quote (scope)
> Pools that opt into this protocol are only responsible for accounting shares and distributing rewards.

This precisely scopes what p2poolv2 needs to replace/decentralize: **share accounting + reward distribution** is the only remaining centralized function once SV2's JDP is in place.

## Honesty incentive
If a pool rejects valid shares for an acknowledged job, JDC can transparently switch pools or mine solo — making SV2 pools defectable on-the-fly.

## Why this matters for p2poolv2
The JDS interface is the *exact* contract any p2poolv2-as-pool integration must satisfy. p2poolv2 already has a share-chain consensus layer; wrapping it in a `JobValidationEngine` (sv2-apps's pluggable backend) lets it accept SV2 JDC clients without re-implementing the JDP wire protocol.

## Sibling specs
- 03 framing + Noise
- 04 secp256k1 / Noise security
- 05 Mining Protocol (channels, share submission)
- 07 Template Distribution Protocol (`NewTemplate`, `SetNewPrevHash`, solution submission)
- 09 Extensions framework (relevant for p2pool-specific share-chain extensions)
