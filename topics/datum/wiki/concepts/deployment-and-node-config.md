---
title: "Deployment and node config"
category: concept
sources:
  - raw/articles/2026-05-28-datum-gateway-readme.md
  - raw/articles/2026-05-28-ocean-datum-setup-guide.md
  - raw/articles/2026-05-28-ocean-node-policy.md
created: 2026-05-28
updated: 2026-05-28
tags: [datum, datum-gateway, deployment, bitcoin-knots, bitcoin-core, gbt, blockmaxsize, docker, libsodium, libcurl, libjansson, libmicrohttpd]
aliases: ["DATUM Gateway deployment", "datum_gateway install", "DATUM Gateway Docker"]
confidence: high
volatility: warm
verified: 2026-05-28
summary: "Operator playbook for DATUM Gateway: Bitcoin Knots is strongly preferred over Core (template-control surface area); reserve coinbase room with blockmaxsize/blockmaxweight=3985000; build deps are libcurl + libjansson + libmicrohttpd + libsodium; Docker requires either host.docker.internal, host networking, or container DNS plus an HTTP /NOTIFY blocknotify."
---

# Deployment and node config

> What the gateway needs from the Bitcoin node beneath it, what the host system needs to build and run it, and how Docker changes the topology. The non-obvious bits are the coinbase reservation and the Docker `/NOTIFY` configuration.

## OCEAN's official 5-step setup

The DATUM Gateway README is the canonical build/install reference; OCEAN's [DATUM Setup Guide](../../raw/articles/2026-05-28-ocean-datum-setup-guide.md) compresses it to five steps:

1. **Bitcoin node.** Stand up and fully sync a Bitcoin node ("DATUM Host Node" / DHN). Knots recommended.
2. **Configure templates.** Set the policy flags and mempool settings you want.
3. **Network reachability.** Ensure the gateway machine can reach the DHN, and miners can reach the gateway.
4. **Install `datum_gateway`** from the GitHub releases page.
5. **Configure miners**: username = Bitcoin payout address (optionally `address.workername`), password = `x` or any short ignored value, Stratum URL = `stratum+tcp://your_datum_node_ip:23334`.

The setup guide also names support contacts (X / Nostr): Jason `@wk057`, Luke `@LukeDashjr`, Mechanic `@GrassFedBitcoin`.

For the policy choices in step 2, see [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — that reference compares OCEAN's four documented templates and what each `bitcoin.conf` stanza needs.

## Bitcoin Knots vs Bitcoin Core

The README is unambiguous: **Bitcoin Knots is highly recommended**. Reason: Knots exposes fine-grained block-template controls; Core does not. Quote:

> "Bitcoin Core is severely lacking in template control options. That is unfortunately a centralizing force which partly defeats the purpose of decentralizing block template creation in the first place."

DATUM is supposed to give the miner template control. If the miner runs Core, the miner ends up with whichever transaction-selection policy Core ships with — a downstream policy decision baked into Core. Knots restores actual policy choice to the miner.

That said: Core works, no source patches required, just standard GBT.

## Coinbase-room reservation (current requirement)

DATUM templates must leave room in the coinbase for the pool's generation-transaction outputs. Today this is done with two `bitcoin.conf` settings:

```
blockmaxsize=3985000
blockmaxweight=3985000
```

The full block weight is 4,000,000 weight units; reserving ~15,000 leaves space for the pool's coinbase outputs without overflowing. The README says this requirement will be removed for Knots users in a future gateway version — Knots will let the gateway specify these reservations on the fly per template. Until then, set both.

## `blocknotify` — local vs network

The gateway needs to know when a new block has arrived so it can invalidate stale work. Two configurations.

### Local (recommended)

Run the gateway as the same user as the node and add to `bitcoin.conf`:

```
blocknotify=killall -USR1 datum_gateway
```

This requires `killall` (`psmisc` package on most distros). The signal forces the gateway to re-fetch a template and push new jobs.

### Network/HTTP fallback

Different host (or different container) → use the gateway's HTTP NOTIFY endpoint instead:

```
blocknotify=wget -q -O /dev/null http://datum-gateway:7152/NOTIFY
```

The gateway's API/dashboard listens on **port 7152** by default (Stratum is on **23334**).

## RPC access

The gateway needs RPC access to the local node. Add a dedicated RPC user and (if not on the same host) whitelist the gateway's IP via `rpcallowip`/`rpcbind` in `bitcoin.conf`. Use strong credentials — these aren't read-only, the gateway issues GBT.

## Recommended supporting node config

Beyond the coinbase reservation, two settings give the local template builder a richer mempool to draw from:

```
maxmempool=1000
blockreconstructionextratxn=1000000
```

The README's editorial framing: *"As a true miner, you'll most likely want as many valid transactions as possible in your mempool which meet your node's policies."*

## Build dependencies

Everything needed to build the C gateway:

- `cmake`
- `pkgconf`
- `libcurl` (e.g. `libcurl4-openssl-dev`)
- `libjansson` (`libjansson-dev`)
- `libsodium` (`libsodium-dev`)
- `libmicrohttpd` (`libmicrohttpd-dev`)
- `psmisc` (for `killall`, used by `blocknotify`)

Build:

```sh
cmake . && make
```

Per-distro install commands are in the README; a few notable variants:

- **Alpine**: also needs `argp-standalone` (Alpine's musl doesn't ship glibc's `argp.h`).
- **FreeBSD**: needs `argp-standalone` and `libepoll-shim` (no native epoll).
- **Alma/Oracle Linux**: enable EPEL plus `crb`/`ol9_codeready_builder`.

## Configuration entry points

- Default config file: `datum_gateway_config.json` in the working directory.
- An example lives at `doc/example_datum_gateway_config.json` in the repo.
- Run `datum_gateway -?` for the full option/flag listing.
- Required: `mining.pool_address` (must be a valid Bitcoin address; gateway won't fully start otherwise — see [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](stratum-usernames-and-modifiers.md))).
- Set the **secondary coinbase tag** — it's what shows up on block explorers when *you* mine a block. The primary tag is unused in pooled mining.
- The web admin password is **also the CSRF token** — set it to something real or disable the API/web interface entirely. Don't leave it default.

## Docker deployment

Image build:

```sh
docker build -t datum_gateway .
```

Run:

```sh
docker run -p 23334:23334 -p 7152:7152 \
  -v /path/to/your/config/directory:/app/config \
  --name datum-gateway \
  datum_gateway
```

The container expects `/app/config/config.json`.

### The three node-connectivity topologies

How the gateway reaches `bitcoind` depends on where `bitcoind` lives.

#### 1. Both in Docker, same network

Use the container name as hostname:

```json
{ "rpc_host": "bitcoin-node", "rpc_port": 8332, ... }
```

In `bitcoin.conf`:

```
blocknotify=wget -q -O /dev/null http://datum-gateway:7152/NOTIFY
```

#### 2. Node on host, gateway in container

Two sub-options:

**Option A — `host.docker.internal` (recommended).**

```json
{ "rpc_host": "host.docker.internal", "rpc_port": 8332, ... }
```

**Option B — host networking mode** (`docker run --network host …`).

```json
{ "rpc_host": "localhost", "rpc_port": 8332, ... }
```

`bitcoin.conf` for option B:

```
blocknotify=wget -q -O /dev/null http://localhost:7152/NOTIFY
```

#### 3. Remote node

```json
{ "rpc_host": "192.168.1.100", "rpc_port": 8332, ... }
```

Remote `bitcoin.conf` then needs `rpcbind` and `rpcallowip` configured for the gateway host's IP, and the `blocknotify` command needs the gateway host's reachable IP/hostname.

### Disable the notify fallback in Docker

The Docker section is explicit: when running in Docker, **disable the `notify` fallback** in the gateway's config. The HTTP NOTIFY path is the right one in container topologies; running the in-process fallback in parallel races against it.

## Operator footguns

- Never expose the gateway's RPC connection to `bitcoind` over the public internet without TLS/auth — `rpcallowip` is not a security boundary on its own.
- Don't leave the API/web admin password default — it doubles as CSRF.
- Set Stratum failover on every miner. README: *"As a best practice, when mining on a DATUM pool, set your miner's failover to use that pool's Stratum endpoint."* The gateway disconnects all clients when DATUM Prime is unreachable (see [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](gateway-data-flow.md))) — without failover, your miners go dark.
- This is **public BETA**. Protocol changes may force gateway upgrades with short or no notice. Watch the upstream repo.

## See Also

- [[datum-gateway-overview|DATUM Gateway — overview]] ([DATUM Gateway — overview](../topics/datum-gateway-overview.md)) — what you're deploying
- [[gateway-data-flow|Gateway data flow]] ([Gateway data flow](gateway-data-flow.md)) — why `blocknotify` exists
- [[datum-protocol|DATUM Protocol]] ([DATUM Protocol](datum-protocol.md)) — the upstream side this gateway speaks
- [[stratum-usernames-and-modifiers|Stratum usernames and modifiers]] ([Stratum usernames and modifiers](stratum-usernames-and-modifiers.md)) — `mining.pool_address` is configured here
- [[node-policy-variants|Node policy variants]] ([Node policy variants](../references/node-policy-variants.md)) — recipes for the four OCEAN-documented templates

## Sources

- [DATUM Gateway — README](../../raw/articles/2026-05-28-datum-gateway-readme.md) — *Requirements*, *Node Configuration*, *Installation*, *Usage*, *Docker* sections
- [DATUM Setup Guide](../../raw/articles/2026-05-28-ocean-datum-setup-guide.md) — 5-step install flow and miner-config quickstart
- [OCEAN Node Policy](../../raw/articles/2026-05-28-ocean-node-policy.md) — Knots-recommended template parameters confirming `blockmaxweight=3985000`
