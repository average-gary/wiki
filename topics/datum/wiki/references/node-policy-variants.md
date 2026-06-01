---
title: "Node policy variants"
category: reference
sources:
  - raw/articles/2026-05-28-ocean-node-policy.md
  - raw/articles/2026-05-28-ocean-core-policy.md
  - raw/articles/2026-05-28-ocean-core-antispam-policy.md
  - raw/articles/2026-05-28-ocean-data-free-policy.md
  - raw/articles/2026-05-28-ocean-alternate-templates.md
created: 2026-05-28
updated: 2026-05-28
tags: [ocean, datum, bitcoin-knots, bitcoin-core, node-policy, block-template, blockmaxweight, blockmaxsize, datacarriersize]
aliases: ["OCEAN node policies", "DATUM template variants", "OCEAN templates"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "Reference comparison of OCEAN's four documented block-template node policies — OCEAN-recommended (Knots), Core, Core+Antispam, Data-Free. The legacy alternate-template stratum endpoints serving these were decommissioned 2025-12-21; the policy docs now serve as recipes for DATUM Gateway operators reproducing each template against their own node."
---

# Node policy variants

> A side-by-side reference for the four block-template node policies OCEAN documents. Useful for picking which one to mirror on a DATUM Gateway's local Bitcoin node — see [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](../concepts/deployment-and-node-config.md)) for how to apply these settings in practice.

## Status

OCEAN previously served all four templates via dedicated stratum endpoints (a non-DATUM way of letting miners pick a template policy). Those endpoints were **decommissioned on December 21, 2025**. The policies still exist as documentation; their job now is to give DATUM Gateway operators a recipe for reproducing each behavior against their own Bitcoin node.

The four-policy menu also has historical relevance — it's the surface area DATUM Gateway replaced. Miners no longer choose from OCEAN's curated templates; they configure their own. See [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](../concepts/datum-history-and-motivation.md)) for the framing.

## At a glance

| Policy | Node implementation | Distinguishing feature |
|---|---|---|
| **OCEAN Recommended** | Bitcoin Knots v29.2 | Knots-style parasitic-protocol rejection enabled by Knots defaults; data-carrier left on |
| **Core** | Bitcoin Core v29.0 | Vanilla Core, only the coinbase-room reservation deviates |
| **Core + Antispam** | Bitcoin Core v25.0 + antispam patch | Older Core base + an antispam patch (older snapshot, not maintained) |
| **Data-Free** | Bitcoin Knots v28.1 (20250305) | `datacarriersize=0` — no OP_RETURN data-carrier transactions in the template |

All four set `blockmaxweight=3985000` to reserve coinbase room for [[tides-payout|TIDES]] ([TIDES payout](../concepts/tides-payout.md)) generation-transaction outputs.

## OCEAN Recommended (default)

Source: `https://ocean.xyz/docs/nodepolicy` — Bitcoin Knots v29.2.

| Parameter | Knots default | OCEAN setting | Why |
|---|---|---|---|
| `blockmaxsize` | 300000 | **3985000** | bytes; large coinbase room |
| `blockmaxweight` | 1500000 | **3985000** | weight; large coinbase room |
| `blockprioritysize` | 100000 | **0** | no high-priority/low-fee reserve |

Knots defaults preserved elsewhere — transaction-relay standards, data-carrier handling (relayed but bounded), full RBF, parasitic-protocol rejection, `maxscriptsize=1650`, `minrelaytxfee=0.00001 BTC/kvB`.

This is what `mine.ocean.xyz:3334` matches today (post-decommission) and the recommended target for new DATUM Gateway operators unless they have a specific reason to pick another variant.

## Core

Source: `https://ocean.xyz/docs/corepolicy` — Bitcoin Core v29.0.

| Parameter | Core default | OCEAN setting |
|---|---|---|
| `blockmaxweight` | 3996000 | **3985000** |

Single deviation. Everything else tracks Core v29.0 defaults — including Core's permissive data-carrier handling (no `datacarriersize=0`) and its lack of Knots' parasitic-protocol rejection. Use this if you specifically want a "Bitcoin Core ships with this" template; you'll get the policy choices that come with that, including weaker template controls per the [DATUM Setup Guide's recommendation against Core](../../raw/articles/2026-05-28-ocean-datum-setup-guide.md).

## Core + Antispam

Source: `https://ocean.xyz/docs/ordispolicy` — Bitcoin Core v25.0 + antispam patch.

| Parameter | Core default | OCEAN setting |
|---|---|---|
| `blockmaxweight` | 3996000 | **3985000** |

Same single deviation, but with two non-trivial differences from "Core":

1. **Older base** — Core v25.0, not v29.0. Several releases behind.
2. **Antispam patch** — referenced via GitHub in the upstream doc. Targets ordinals/inscription-style transactions for filtering.

Operationally this template is harder to reproduce on a fresh DATUM Gateway install because v25.0 is no longer the current release; you'd be running an older Core (with whatever security implications that carries) plus a third-party patch. This is the variant least likely to be worth replicating today; included for completeness.

## Data-Free

Source: `https://ocean.xyz/docs/datafreepolicy` — Bitcoin Knots v28.1 (20250305).

| Parameter | Default | OCEAN setting | Notes |
|---|---|---|---|
| `acceptnonstdtxn` | 0 | 0 | tracks default (no non-standard relay) |
| `datacarrier` | 1 | 1 | data-carrier txs still relayed |
| `datacarriercost` | 1 | 1 | data costed at ≥1 vbyte/byte |
| `datacarriersize` | 42 | **0** | **no data-carrier data in template/relay** |
| `blockmaxsize` | 300000 | **3985000** | |
| `blockmaxweight` | 1500000 | **3985000** | |
| `blockprioritysize` | 100000 | **0** | |

Defaults preserved: `bytespersigop=20`, `maxscriptsize=1650`, `minrelaytxfee=0.00001 BTC/kvB`, `mempoolreplacement=fee,-optin` (full RBF), `mempoolmultisig=0` (no non-P2SH multisig relay).

The signature setting is `datacarriersize=0`: OP_RETURN-bearing transactions are not relayed and not included in templates. Useful if you specifically want a template that excludes data-carrier-style transactions. Note: the underlying Knots version is older (v28.1) than the OCEAN-recommended policy's v29.2 — bringing this forward to v29.x while preserving the `datacarriersize=0` setting is straightforward.

## What `blockmaxweight=3985000` is doing

All four policies share this number. The full block weight is 4,000,000 (per BIP141). Reserving 15,000 weight units leaves room for the pool's TIDES coinbase output set — which can be large because OCEAN pays many miners directly in the generation transaction. See [[tides-payout|TIDES payout]] ([TIDES payout](../concepts/tides-payout.md)) for why the coinbase output set is unusually wide; see [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](../concepts/deployment-and-node-config.md)) for the practical config flags. The DATUM Gateway README also recommends `blockmaxsize=3985000` for the same reason (covers both pre-segwit and post-segwit accounting).

## Choosing one

| If you want… | Pick |
|---|---|
| The OCEAN-default template behavior | OCEAN Recommended (Knots v29.2) |
| Vanilla Core defaults, only the coinbase reservation | Core (Core v29.0) |
| A template excluding OP_RETURN/data-carrier data | Data-Free (Knots v28.1; consider upgrading to v29.x) |
| The legacy "Core+Antispam" behavior verbatim | Core + Antispam (Core v25.0 + patch) — not recommended unless you have a specific reason |

A future DATUM Gateway version is expected to support per-template `blockmax*` overrides via Knots, removing the `bitcoin.conf` reservation requirement (see the [DATUM Gateway README](../../raw/articles/2026-05-28-datum-gateway-readme.md) Node Configuration section). Until then, set the values explicitly in your `bitcoin.conf`.

## See Also

- [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](../concepts/deployment-and-node-config.md)) — how to apply these settings on a DATUM Gateway host
- [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](../concepts/datum-history-and-motivation.md)) — why the four-template menu was decommissioned
- [[tides-payout|TIDES payout]] ([TIDES payout](../concepts/tides-payout.md)) — what the coinbase reservation is for
- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — where node policy fits in the larger stack

## Sources

- [OCEAN Node Policy](../../raw/articles/2026-05-28-ocean-node-policy.md) — Knots v29.2 recommended
- [Core Node Policy](../../raw/articles/2026-05-28-ocean-core-policy.md) — Core v29.0
- [Core Antispam Node Policy](../../raw/articles/2026-05-28-ocean-core-antispam-policy.md) — Core v25.0 + patch
- [Data-Free Node Policy](../../raw/articles/2026-05-28-ocean-data-free-policy.md) — Knots v28.1, `datacarriersize=0`
- [Alternate Templates](../../raw/articles/2026-05-28-ocean-alternate-templates.md) — decommissioning notice (2025-12-21)
