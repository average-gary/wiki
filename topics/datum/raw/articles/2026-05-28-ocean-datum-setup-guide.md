---
title: "DATUM Setup Guide"
source: "https://ocean.xyz/docs/datum-setup"
type: articles
ingested: 2026-05-28
tags: [ocean, datum, datum-gateway, setup, bitcoin-knots, stratum-v1]
summary: "OCEAN's official end-to-end setup guide for running a DATUM Gateway against a personal Bitcoin node. Covers prerequisites (synced node), the recommendation of Bitcoin Knots over Core for template controls, and the five install steps from node sync through pointing miners at stratum+tcp://datum:23334."
collection: "ocean-docs"
adapter: "wayback-cdx"
upstream_id: "datum-setup"
upstream_type: "wayback-snapshot"
canonical_url: "https://ocean.xyz/docs/datum-setup"
content_format: "html"
authors: ["OCEAN Team"]
fetched: 2026-05-28
extraction_tool: "WebFetch"
---

# DATUM Setup Guide

> DATUM is a decentralized mining protocol that lets individuals construct
> their own block templates using their own Bitcoin node. Users may either
> mine independently or participate in pools supporting DATUM. Currently in
> public beta, with source and binaries on GitHub.

## Prerequisites

A performant Bitcoin node — fast IBD and block validation. The Bitcoin node
is the most resource-intensive piece of the stack; the DATUM Gateway itself
is lightweight.

## Installation

### Step 1 — Bitcoin node

Stand up and fully sync a Bitcoin node (this is your "DATUM Host Node" / DHN).

> The guide recommends **Bitcoin Knots over Bitcoin Core** because of Knots'
> enhanced template controls.

### Step 2 — Configure templates

Configure the DHN to generate the kind of block template you want (policy
flags, mempool settings, etc).

### Step 3 — Network reachability

Ensure the DATUM Gateway machine can reach the DHN, and your mining hardware
can reach the gateway.

### Step 4 — Install datum_gateway

Download and install the DATUM Gateway from the GitHub releases page.

### Step 5 — Configure miners

| Field | Value |
|-------|-------|
| Username | Your Bitcoin payout address (in OCEAN's accepted format), optionally `address.workername` |
| Password | `x`, blank, or any short value (ignored) |
| Stratum URL | `stratum+tcp://your_datum_node_ip:23334` |

## Support Contacts

Reach the DATUM team via X / Nostr:

- Jason — `@wk057`
- Luke — `@LukeDashjr`
- Mechanic — `@GrassFedBitcoin`

## Cross-Reference

- The Stratum username format and worker-name semantics are documented in
  more depth in `raw/articles/2026-05-28-datum-gateway-usernames.md` (this
  topic) and in the `datum_gateway` README.
- Default DATUM Gateway stratum port `23334` matches the in-tree config and
  the Rust port.
