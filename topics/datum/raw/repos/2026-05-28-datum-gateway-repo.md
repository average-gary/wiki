---
title: "Collection: datum-gateway (OCEAN-xyz/datum_gateway)"
source: "https://github.com/OCEAN-xyz/datum_gateway"
type: repos
ingested: 2026-05-28
tags: [collection, collection-manifest, git, datum, ocean, mining, stratum, gbt]
summary: "Manifest for a collection ingest of OCEAN's DATUM Gateway repository: 2 child sources (README, Stratum username doc) captured from git HEAD a3da9e69 (Merge branch '0.3.x' (hidden CI conflict), 2026-04-06)."
collection: "datum-gateway"
adapter: git
revision: "a3da9e6975984fd0ae584f37d76fe4afe2c75bac"
canonical_url: "https://github.com/OCEAN-xyz/datum_gateway/tree/a3da9e6975984fd0ae584f37d76fe4afe2c75bac"
license: "MIT"
---

# Collection: datum-gateway

OCEAN-xyz/datum_gateway — DATUM Gateway, OCEAN's miner-side block-template construction client.

## Provenance

- Local clone path: `/Users/garykrause/repos/datum_gateway`
- Origin: `git@github.com:OCEAN-xyz/datum_gateway.git`
- HEAD commit: `a3da9e6975984fd0ae584f37d76fe4afe2c75bac` — `Merge branch '0.3.x' (hidden CI conflict)` (2026-04-06)
- License: MIT (Bitcoin Ocean, LLC, Jason Hughes, and individual contributors, 2024–2025)
- Tracked text-like files in repo at HEAD: 3 (`README.md`, `doc/usernames.md`, `CMakeLists.txt`); only `.md` files were captured per the git-collection adapter rule (build scripts excluded).

## Adapter and filters

- Adapter: `git` (auto-detected: directory contains `.git/`).
- Include set: `.md`, `.mediawiki`, `.wiki`, `.rst`, `.txt`, `.adoc`.
- Excluded by default: `.git/`, `.github/`, `src/`, `www/`, `cmake/`, `debian/`, `build/`, `datum_gateway_rust/` (source trees), the SVG diagram in `doc/`, the `LICENSE` file, the `Dockerfile`, and the `example_datum_gateway_config.json` example file.

## Children

| Path | Blob SHA | Captured to |
|---|---|---|
| `README.md` | `fb052939e2759ac7899684306454b92ad926eae7` | [[2026-05-28-datum-gateway-readme.md\|README]] (raw/articles/) |
| `doc/usernames.md` | `a788317231aa5cb1b84388bf13fa96407064aa4e` | [[2026-05-28-datum-gateway-usernames.md\|Stratum username semantics]] (raw/articles/) |

## Why a collection (not 2 single ingests)

Capturing as a collection preserves:
- Pinned `revision: a3da9e69…` so future re-ingests against a newer HEAD dedupe via `(collection, upstream_id, revision/sha)`.
- Per-blob `sha` for content-level change detection independent of the surrounding commit graph.
- A single manifest row in `raw/repos/` to anchor compile-time provenance and dataset-level claims (e.g. "as of 0.3.x merge").

## Compile guidance (deferred)

When compiling, prefer synthesized concept articles over per-file articles:
- `datum-protocol-surface` — what the DATUM wire protocol claims, what's still pool-side trust.
- `gateway-data-flow` — node ↔ Gateway ↔ miner ↔ pool, including blocknotify/`SIGUSR1`.
- `stratum-usernames-and-modifiers` — Bitcoin-address-as-username, worker name semantics, `~modifier` revenue split.
- `node-and-build-config` — Knots vs Core, blockmaxsize/weight reservation, libsodium/libcurl/libjansson/libmicrohttpd.
- `docker-deployment` — host.docker.internal vs container networking, blocknotify over HTTP NOTIFY.
- Reference to `bitcoin-mining-payout-schemas` for TIDES (orthogonal layer); reference to `stratum-sri` for the SV2 alternative.
