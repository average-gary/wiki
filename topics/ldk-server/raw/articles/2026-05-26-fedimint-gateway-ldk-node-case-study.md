---
title: "Fedimint Lightning Gateway uses LDK Node (case study)"
source_url: https://lightningdevkit.org/blog/fedimint-lightning-gateway-uses-ldk-node-to-simplify-deployment-and-liquidity-management/
author: Justin Moeller
published: 2025-01-31
type: article
ingested: 2026-05-26
tags: [ldk-node, fedimint, case-study, deployment, hold-invoice]
quality: 4
confidence: high
summary: Fedimint embedded LDK Node into the Lightning Gateway daemon, replacing dual-process LND+gateway with a single binary. Drove upstream addition of hold-invoice (preimage-less) APIs. Tradeoff: operators lose direct CLI access to underlying node.
---

# Fedimint Lightning Gateway uses LDK Node

## Context

Fedimint runs Lightning Gateway daemons that bridge ecash federations to the Lightning Network. Previously these gateways called out to a separate LND or CLN process. The migration replaced that with **LDK Node embedded directly in the gateway binary**.

## What changed

- Single-process gateway: ecash + Lightning channel/UTXO management together.
- Operators no longer run a sidecar LND; less moving infrastructure.
- LDK Node ships sane defaults: integrated BDK on-chain wallet, SQLite DB.
- Fedimint already had a Lightning-impl abstraction, so swapping in LDK Node was tractable.

## Upstream feedback loop

**Hold-invoice (preimage-less) APIs were missing** from LDK Node. The LDK team added them upstream to unblock Fedimint's production use. This is the same surface that now appears in [[2026-05-26-ldk-server-api-guide.md|LDK Server's API]] as `Bolt11ReceiveForHash` / `Bolt11ClaimForHash` / `Bolt11FailForHash`.

## Tradeoffs

- **Operators lose direct CLI access** to the underlying node. Fedimint exposes ops + debug logs through the gateway interface instead.
- **Liquidity management** still requires planning; Fedimint exploring **LSPv1**-based automated liquidity.

## Shipping

- Fedimint v0.5 (existing federations).
- v0.6 (new federations).

## Why this matters for LDK Server

This is the largest visible production validation of the "embed the node, expose your own API" pattern. **LDK Server formalizes that pattern** — instead of every project (Fedimint, Alby Hub, Bitkit) writing its own LDK Node embedding, ship a daemon with a stable gRPC contract. Caveat: no public LDK Server production users found yet (as of 2026-05-26); the case studies are all LDK Node embeddings.

## See also

- [[2026-05-26-ldk-server-readme.md]]
- [[2026-05-26-ldk-node-overview.md]]
- [[wiki/concepts/grpc-api-surface.md|gRPC API surface]] — hold invoices section
