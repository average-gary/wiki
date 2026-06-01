---
title: "DATUM Gateway — overview"
category: topic
sources:
  - raw/repos/2026-05-28-datum-gateway-repo.md
  - raw/articles/2026-05-28-datum-gateway-readme.md
  - raw/articles/2026-05-28-datum-gateway-usernames.md
  - raw/articles/2026-05-28-ocean-datum-setup-guide.md
  - raw/articles/2026-05-28-ocean-origins-of-datum.md
created: 2026-05-28
updated: 2026-05-28
tags: [datum, ocean, datum-gateway, mining, decentralized-templates, beta]
aliases: ["DATUM Gateway", "datum_gateway", "DATUM client"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "DATUM Gateway is OCEAN's miner-side block-template construction client: it pulls templates from a local Bitcoin node via GBT, serves Stratum v1 work to mining hardware, and submits the resulting work to a DATUM Prime pool over an encrypted custom protocol — the pool never builds the template."
---

# DATUM Gateway — overview

> **Decentralized Alternative Templates for Universal Mining.** A C daemon that lives on the miner's network, between the miner's Bitcoin node and the miner's hashing hardware, and shifts block-template construction from pool to miner. Pool-side reward accounting still happens — but the pool no longer chooses which transactions go in the block.

## What problem it solves

In conventional pooled mining, the pool builds the block template and the miner just hashes whatever the pool sent. That gives the pool unilateral control over which transactions get confirmed and which don't — a centralizing force on Bitcoin's transaction-selection layer. DATUM inverts that: the **miner's local Bitcoin node** builds the template (via standard `getblocktemplate` RPC), the gateway distributes the work, and the pool's role is reduced to coordinating the generation transaction (payout split + coinbase tags) and accepting/rejecting submitted shares.

The README states it explicitly: *"The real miner is always whoever is running the Bitcoin node. With DATUM, that's not the pool."*

## Where it sits

```
mining hardware ──Stratum v1 + version-rolling──▶ DATUM Gateway ──GBT RPC──▶ local Bitcoin node
                                                       │
                                                       │ DATUM Protocol (encrypted)
                                                       ▼
                                                  DATUM Prime (pool)
```

The gateway speaks three different protocols at three different boundaries:

| Hop | Protocol | Direction |
|---|---|---|
| miner ↔ ASIC | Stratum v1 + ASICBoost (version rolling) | gateway is server |
| gateway ↔ node | GBT (`getblocktemplate`) RPC | gateway is client |
| gateway ↔ pool | DATUM Protocol (encrypted, custom) | gateway is client |

It is **Bitcoin-only** — the README says non-Bitcoin support is not straightforward because the optimizations are tied to Bitcoin-specific constraints.

## Component map

This wiki covers the gateway in concept articles plus a reference and this topic:

- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](../concepts/datum-protocol.md)) — the wire protocol between gateway and DATUM Prime, what it claims, and what trust still sits with the pool.
- [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](../concepts/gateway-data-flow.md)) — the runtime path of a template through the system, including `blocknotify` and the dual share-validation model.
- [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](../concepts/stratum-usernames-and-modifiers.md)) — Bitcoin-address-as-username, the three pool-passthrough modes, the `~modifier` per-share revenue split, and ASIC length quirks.
- [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](../concepts/deployment-and-node-config.md)) — Knots-vs-Core, the `blockmaxsize`/`blockmaxweight` reservation, build dependencies, and Docker networking patterns.
- [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](../concepts/datum-history-and-motivation.md)) — Hughes' framing essay; Eligius lineage; censorship thesis.
- [[tides-payout|TIDES payout]] ([TIDES payout](../concepts/tides-payout.md)) — the OCEAN payout layer that DATUM's coinbase reservation makes room for.
- [[lightning-payouts|Lightning payouts]] ([Lightning payouts](../concepts/lightning-payouts.md)) — optional BOLT12 payout rail (volatility: hot).
- [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — reference comparison of OCEAN's four documented template policies.

## OCEAN-side incentives

For DATUM users specifically on OCEAN (the only DATUM-supporting pool today), Hughes' "Origins of DATUM" essay names two operator-economics changes:

- **50% pool-fee discount** vs OCEAN's legacy non-DATUM endpoints.
- **Non-custodial coinbase payouts** via [[tides-payout|TIDES]] ([TIDES payout](../concepts/tides-payout.md)) — rewards land directly in the block being mined.

OCEAN previously offered a menu of four template policies via separate stratum endpoints (`mine.ocean.xyz:3334`, etc); those were **decommissioned 2025-12-21**. The DATUM Gateway is now the only path to a non-default template at OCEAN. The four policy docs survive as recipes — see [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)).

## Connecting miners

Per OCEAN's DATUM Setup Guide, miner config is straightforward:

| Field | Value |
|---|---|
| Username | Bitcoin payout address (optionally `address.workername`) |
| Password | `x`, blank, or any short value (ignored) |
| Stratum URL | `stratum+tcp://your_datum_node_ip:23334` |

Default Stratum port `23334` matches the in-tree config. See [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](../concepts/stratum-usernames-and-modifiers.md)) for the structured-username surface.

## Status (as of HEAD `a3da9e69`, 2026-04-06 merge)

- **Public BETA.** README warns the protocol may change with short or no notice.
- License: MIT.
- Linux-only, 64-bit AMD/Intel; "other systems may work, but at this time it is at your own risk."
- DATUM Protocol spec is **not yet published as an RFC** — README: *"evolving, subject to change, and will be published elsewhere."*

### Retraction (2026-06-01)

A previous revision of this article claimed an in-tree Rust port lived under `datum_gateway_rust/`. **This claim was incorrect.** Path 2 of the 2026-06-01 research session checked all branches (`master`, `0.2.x`, `0.3.x`), GitHub code search, all PRs and issues, and the top forks (BitcoinMechanic, luke-jr, GregTonoski, s0kil, privkeyio, plus ~20 zero-star forks). **There is no Rust code anywhere in the upstream `OCEAN-xyz/datum_gateway` repo or any visible fork.** The original commit anchor `a3da9e69` is a CI-workflow-only merge by luke-jr containing zero `.rs` files. The Rust-port claim has been removed.

## Where DATUM ends and TIDES begins

DATUM is the **template-construction layer**. It's orthogonal to **TIDES**, OCEAN's reward-distribution policy. The two layers can be combined (and, on OCEAN, are) but they answer different questions:

- DATUM: *who chooses which transactions go into the block I'm hashing on?*
- TIDES: *given that I submitted shares, what fraction of the block reward do I get?*

For the payout layer, see the sibling wiki: `bitcoin-mining-payout-schemas/wiki/concepts/datum.md` and `tides.md`.

## Where DATUM ends and SV2 begins

DATUM and Stratum V2 (SRI) overlap in motivation — both want miners to control templates — but they're different stacks. DATUM uses Stratum v1 for the miner-facing leg and a custom encrypted protocol upstream; SV2 uses a noise-encrypted binary protocol end-to-end with a formal Job Declaration Protocol. DATUM ships and is in production on OCEAN; SV2's Job Declaration is still being deployed across the ecosystem. See the `stratum-sri` and `sv2-p2pool-integration` sibling wikis for the SV2 side.

## Open questions

- Will DATUM Prime ever be open-sourced, or only the gateway? (Currently only the client side is public.)
- When does the protocol freeze? README implies a v1.0 stable release will end the breaking-change window, but no date is given.
- How does the future "pool blinded to template contents" mode (mentioned in the README) actually work cryptographically? The current version still has the pool validate blocks before submission.

## See Also

- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](../concepts/datum-protocol.md)) — wire-level details
- [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](../concepts/gateway-data-flow.md)) — runtime path
- [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](../concepts/stratum-usernames-and-modifiers.md)) — share addressing
- [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](../concepts/deployment-and-node-config.md)) — operator playbook
- [[datum-history-and-motivation|DATUM — history and motivation]] ([DATUM history and motivation](../concepts/datum-history-and-motivation.md)) — why DATUM exists
- [[tides-payout|TIDES payout]] ([TIDES payout](../concepts/tides-payout.md)) — OCEAN's payout layer
- [[lightning-payouts|Lightning payouts]] ([Lightning payouts](../concepts/lightning-payouts.md)) — optional BOLT12 rail
- [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — template policies reference

## Sources

- [Collection manifest — datum-gateway repo](../../raw/repos/2026-05-28-datum-gateway-repo.md) — pinning to commit `a3da9e69`, blob SHAs, license
- [DATUM Gateway — README](../../raw/articles/2026-05-28-datum-gateway-readme.md) — almost everything in this overview
- [DATUM Gateway — Stratum username semantics](../../raw/articles/2026-05-28-datum-gateway-usernames.md) — the username/modifier surface area
- [DATUM Setup Guide](../../raw/articles/2026-05-28-ocean-datum-setup-guide.md) — miner-config quickstart, stratum URL, support contacts
- [The Origins of DATUM](../../raw/articles/2026-05-28-ocean-origins-of-datum.md) — incentive structure, OCEAN positioning
