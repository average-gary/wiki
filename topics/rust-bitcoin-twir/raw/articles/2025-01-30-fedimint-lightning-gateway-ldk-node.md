---
title: "Fedimint Lightning Gateway uses LDK Node to simplify deployment"
source: https://lightningdevkit.org/blog/fedimint-lightning-gateway-uses-ldk-node-to-simplify-deployment-and-liquidity-management
type: integration
tags: [fedimint, ldk-node, justin-moeller, hold-invoice, lspv1]
ingested: 2026-06-22
date: 2025-01-30
author: Justin Moeller
verified: 2026-06-22
volatility: cold
credibility: high
twir-fit: maybe-back-fill
twir-section: Project/Tooling Updates
agent: applied
---

# Fedimint Lightning Gateway uses LDK Node

LDK blog post by Justin Moeller (Fedimint), 2025-01-30.

## Key findings
- Fedimint replaced a dual-daemon setup by **embedding `ldk-node`**.
- Documents **HOLD invoice support** that LDK Node didn't originally expose.
- Channel/UTXO management moves inside the gateway.
- Plans for automated liquidity via **LSPv1**.

## TWiR fit
- **Section**: Project/Tooling Updates — clean ecosystem-adoption story.
- Pair with Fedimint H1 2025 review (`2025-06-30-fedimint-review-first-half`) for a multi-quarter Fedimint-on-LDK arc.
