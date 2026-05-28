---
title: "How to Run an Ecash Mint (Bitcoin Magazine + ereignishorizont) — Nutshell + LNbits + Caddy pattern"
type: article
source: https://bitcoinmagazine.com/technical/how-to-guide-running-an-ecash-mint
secondary_source: https://ereignishorizont.xyz/en/cashu-en/
fetched: 2026-05-28
confidence: medium
tags: [cashu, deployment, nutshell, lnbits, caddy, history]
summary: Practitioner walkthrough using nutshell (Python) as the mint, LNbits as the LN backend (which itself fronts LND/CLN), and Caddy as the reverse proxy. Older but representative of the pre-CDK-maturity DIY pattern. Confirms: no native LNURL on the mint host.
---

# Running an Ecash Mint — pre-CDK pattern

Two parallel walkthroughs document the most-deployed DIY pattern, both predating CDK's LDK Node backend (v0.12, Aug 2025):

- Bitcoin Magazine: "How to Run an Ecash Mint"
- ereignishorizont.xyz: "Cashu (en)"

## Stack

- **Mint**: nutshell (Python)
- **LN backend**: LNbits (`MINT_BACKEND_BOLT11_SAT=LNbitsWallet`, `MINT_LNBITS_ENDPOINT`, `MINT_LNBITS_KEY`)
- LNbits in turn fronts LND/CLN/Eclair — i.e., LNbits is the **de facto LN abstraction layer** in DIY mint setups
- **Reverse proxy**: Caddy, terminating TLS, forwarding to mint on `127.0.0.1:3338` with `X-Forwarded-Host`

## What's NOT in either guide

**Neither configures LNURL or Lightning Address on the mint host.** This is consistent across the entire DIY ecosystem of Cashu deployment guides — the mint exposes Cashu NUT endpoints; LNURL is layered separately (typically by LNbits' own LNURLp extension if present, or a separate LNURL workload, or a sidecar like npubcash-server).

## Why ingest

Documents the **historical baseline pattern** that operators graduating to cdk-mintd are coming from. Anchors the narrative: "your existing nutshell + LNbits + Caddy setup translates to cdk-mintd + cdk-ldk-node by replacing the mint binary and reconsidering whether you still need LNbits as the LN abstraction." For most mints, the answer is "yes, keep LNbits as a useful proxy for LN ops + LNURL."

## Migration sketch (nutshell → CDK)

| Layer | Old (nutshell) | New (cdk-mintd + cdk-ldk-node) |
|---|---|---|
| Mint binary | `nutshell` (Python) | `cdk-mintd --features ldk-node` |
| LN backend | LNbits → LND/CLN | embedded LDK Node (or keep LNbits) |
| Persistence | nutshell SQLite | mintd SQLite/Postgres + LDK Node SQLite |
| LNURL | LNbits LNURLp ext | npubcash-server sidecar OR keep LNbits |
| Reverse proxy | Caddy | Caddy (unchanged) |
| TLS | cert-manager / Caddy | unchanged |

The LN-backend simplification (drop LNbits, run LDK Node embedded) saves a process but introduces the LDK Node operational risks documented in [[2026-05-28-ldk-node-issue-381-persistence-panic.md|issue #381]]. Most current operators keep LNbits + CLN/LND.
