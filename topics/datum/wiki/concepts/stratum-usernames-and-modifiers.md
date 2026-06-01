---
title: "Stratum usernames and modifiers"
category: concept
sources:
  - raw/articles/2026-05-28-datum-gateway-usernames.md
created: 2026-05-28
updated: 2026-05-28
tags: [datum, datum-gateway, stratum, usernames, worker-name, username-modifiers, asic, avalon, whatsminer, bitcoin-address]
aliases: ["DATUM username modifiers", "datum_gateway usernames", "DATUM revenue sharing"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "DATUM treats Stratum usernames as Bitcoin addresses with optional `.workername` and optional `~modifier-name` suffixes. The gateway has three pool-passthrough modes (full, worker-only, discard). Username modifiers split shares across addresses by hash-prefix range — a per-share revenue-sharing primitive built into the gateway. ASIC username-length quirks (Avalon 63, Whatsminer 127) are real footguns."
---

# Stratum usernames and modifiers

> In conventional pooled mining, the Stratum username is whatever the pool decides it means. In DATUM, it's structured: address, optional worker name, optional revenue-share modifier — and the gateway has opinions about what to do with all of it before forwarding to the pool.

## The three components

A Stratum username sent by an ASIC to the gateway can be:

```
<bitcoin-address>[.<worker-name>][~<modifier-name>]
```

All three pieces are optional in narrow ways:

| Form | Meaning |
|---|---|
| `bc1q…` | Address only. Default behavior — gateway uses this address. |
| `bc1q….rig01` | Address + worker name. Period is the only separator the gateway codebase understands; pools that accept `_` are not honored gateway-side. |
| `.rig01` | Leading period → worker name only. Gateway prepends its own configured `mining.pool_address`. |
| `bc1q….rig01~split-50-50` | Address + worker + modifier. See *Username modifiers* below. |

### Address rules (non-pooled mode and gateway default)

The gateway's configured default username — `mining.pool_address` — must always be a valid Bitcoin address, and the gateway will not fully start until it is. Supported encodings: **Base58 (Legacy), Bech32 (Segwit), Bech32m (Taproot)** — for Bitcoin mainnet and testnet only. The gateway does **not** detect mainnet/testnet mismatches; that's a real silent footgun.

In non-pooled (solo) mode, only `mining.pool_address` matters — Stratum usernames have no effect.

## The three pool-passthrough modes

When pooled, two config booleans determine what reaches DATUM Prime:

| `pool_pass_full_users` | `pool_pass_workers` | What pool sees |
|---|---|---|
| `true` (default) | _ignored_ | Full Stratum username, as-is. Web-UI label: "Override Bitcoin Address". |
| `false` | `true` | The whole Stratum username is appended after `mining.pool_address` as a worker. Web-UI label: "Send as worker names". |
| `false` | `false` | Stratum username discarded. Pool sees `mining.pool_address` with no worker. |

The default — `pool_pass_full_users: true` — is the only mode where username modifiers (below) take effect. This matters when wiring up revenue sharing.

## Username modifiers — per-share revenue split

A miner-firmware-level workaround for revenue-sharing arrangements. Defined in the `stratum.username_modifiers` config object as a JSON map of named splits:

```json
"username_modifiers": {
    "modifier name 1": {
        "bitcoin address A": 0.2,
        "": 0.8
    },
    "modifier name 2": {
        "bitcoin address B": 0.5,
        "": 0.5
    },
    "modifier name 3": {
        "bitcoin address C": 0.01,
        "bitcoin address D": 0.99
    }
}
```

A miner activates a modifier by suffixing its Stratum username with `~<modifier-name>`:

```
bc1q-MINER.rig01~modifier name 2
```

The empty-string key (`""`) means "the address from the Stratum username." So `modifier name 1` redirects 20% of shares to address A and 80% to whatever the miner submitted. `modifier name 3` ignores the miner's address entirely — 1% to C, 99% to D.

### How the split actually works

The gateway routes each share to an address based on the **proof-of-work hash prefix**. For an 80/20 split:

- Shares whose hash starts with `0000`–`cccc` go to address 1.
- Shares whose hash starts with `cccd`–`ffff` go to address 2.

Because PoW hashes are uniform-random, the split converges to the configured ratio over many shares but is not exact in any short window. Worker name (if any) is copied verbatim onto every redirected share.

### Sharp edges

- **Modifiers must sum to 100%.** If they don't, behavior is *currently* defined-but-not-promised:
  - **Less than 100%**: shares falling outside the defined ranges go to `mining.pool_address` *without* the worker name copied.
  - **More than 100%**: the over-allocated portion has no shares submitted, and address ordering may or may not be deterministic.
  Treat this as undefined — explicitly assign every percentage point.
- **Only works with `pool_pass_full_users: true`.** This is enforced by where the splitting logic lives (Stratum-server-side, before the DATUM Protocol forwarder).
- **Miner firmware would be the right place for this** (per the docs) — the gateway implements it because most ASIC firmware doesn't.

## ASIC-side length limits (real footguns)

The gateway tolerates Stratum usernames up to **191 characters** including all suffixes. ASICs are stricter, and per-vendor:

| ASIC family | Behavior at limit |
|---|---|
| Avalon | Truncates at 63 chars |
| Whatsminer | **Buffer overflow** at 127 chars — *may damage your miner* |
| Others | Various, generally lower than 191 |

Some firmwares URL-encode special characters (anything other than alphanumerics, `_`, `.`, `~`) — e.g. `%` → `%25` — which both eats into the length budget and can confuse parsers downstream.

Practical guidance: keep `address.workername~modifier` well under 63 characters if you need cross-vendor compatibility, and **never** push a Whatsminer past 127 — that's not a "config error," it's a hardware-hazard.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — where username handling sits
- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) — only `pool_pass_full_users: true` lets modifiers cross the DATUM boundary
- [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](gateway-data-flow.md)) — the modifier split happens on the Stratum-server leg, before pool submission
- [[deployment-and-node-config|Deployment and node config]] ([Deployment and node config](deployment-and-node-config.md)) — where to set `mining.pool_address`

## Sources

- [DATUM Gateway — Stratum username semantics (doc/usernames.md)](../../raw/articles/2026-05-28-datum-gateway-usernames.md)
