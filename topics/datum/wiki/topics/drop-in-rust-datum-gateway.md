---
title: "Drop-in Rust DATUM gateway — synthesis"
category: topic
created: 2026-06-01
updated: 2026-06-01
tags: [drop-in, rust, datum_gateway, sv2, sv1, ocean, synthesis]
confidence: high
---

# Drop-in Rust DATUM gateway — synthesis

The synthesized answer to: *"How can we use SV2 for a DATUM gateway? Miners SV2 downstream, DATUM upstream, drop-in replacement for `datum_gateway`."*

This topic is the one-stop answer. Read this article and you should know whether the project is feasible, what it ships, what it doesn't, and what to build in what order.

## TL;DR

**Feasible. ~4,000-5,500 Rust LOC over 6 months for a single dev.** The drop-in is genuinely binary-swappable because `datum_gateway` has no on-disk state to migrate. The Rust port replaces the C codebase 1:1 on operator-facing surfaces, adds SV2 as an opt-in downstream protocol on a new port, fixes several latent C bugs (no GBT longpoll, hardcoded `["segwit"]` rules, dupe-table sizing breaks under SV2), and ships migration tooling the C gateway never had.

The single biggest engineering risk is **DATUM Prime wire-protocol drift**: the protocol spec is the C source, OCEAN's pool side is closed, and protocol stability requires OCEAN-engineering coordination.

## The four de-risking findings

These are the discoveries that turn "drop-in replacement" from a slogan into a tractable project:

1. **No on-disk state to migrate.** `datum_gateway` regenerates its OCEAN keypair on every startup; TIDES at OCEAN attributes shares by Bitcoin payout address (not gateway pubkey). Switch-day rollback is a binary swap. No statefile-compat tooling required. (See [[../concepts/drop-in-surface-inventory#the-de-risking-finding]].)
2. **Cipher correction**: steady-state encryption is XSalsa20Poly1305 (libsodium default), **not ChaCha20-Poly1305**. The pure-Rust `dryoc` crate matches this default; coordination with build (Q5) gives static-musl artifacts that the C upstream cannot ship. (See [[../concepts/datum-protocol-rust-implementation]].)
3. **CLI surface is minimal**: 4 flags (`-c`, `--example-conf`, `--test`, `-?`), one signal handler (SIGUSR1), no env vars, no PID file. Replication is hours, not days. (See [[../concepts/drop-in-surface-inventory]].)
4. **`bitcoincore-rpc` is archived as of 2025-11-25.** Hand-rolled `reqwest + corepc-types` (~200 LOC) is the rust-bitcoin org's official recommendation. Free upgrade: replace the C gateway's signal+1Hz-poll dance with bitcoind native GBT long-polling (75s timeout). (See [[../concepts/drop-in-rust-port-architecture#bitcoind-rpc--hand-rolled-reqwest--corepc-types]].)

## Architecture at a glance

```
┌────────────────────────────────────────────────────────────────────────┐
│                       Operator's farm                                  │
│                                                                        │
│   ┌────────────┐    GBT longpoll    ┌────────────────────────────┐    │
│   │ bitcoind   │ ◀───────────────▶  │      datum-rs binary       │    │
│   │ (Knots)    │                    │      (single process)      │    │
│   └────────────┘                    │                            │    │
│                                     │  ┌────────────────────┐    │    │
│                                     │  │ datum-blocktemplates│    │    │
│                                     │  │ datum-coinbaser     │    │    │
│                                     │  │ datum-protocol      │    │    │
│                                     │  │ datum-stratum-sv1   │    │    │
│                                     │  │ datum-stratum-sv2   │    │    │
│                                     │  │ datum-api (axum)    │    │    │
│                                     │  │ datum-submitblock   │    │    │
│                                     │  └────────────────────┘    │    │
│                                     │       :23334 (SV1)         │    │
│                                     │       :23335 (SV2, opt-in) │    │
│                                     │       :7152  (HTTP API)    │    │
│                                     └─────────┬──────────────────┘    │
│                  ┌──────────────────────┬─────┴─────┬─────────────┐   │
│                  │                      │           │             │   │
│             SV1 ASIC             SV1 ASIC      SV2 ASIC     SV2 ASIC  │
│           (Antminer S19)       (Antminer S21)  (BraiinsOS+)(BraiinsOS+)│
└─────────────────┬──────────────────────────────────────────────────────┘
                  │
                  │ DATUM Protocol over libsodium box
                  │ (XSalsa20Poly1305, port 28915)
                  ▼
            ┌────────────┐
            │   OCEAN    │
            │   pool     │
            │  (TIDES)   │
            └────────────┘
```

The previously-researched [[sv2-downstream-architecture|sidecar proxy]] (Phase 1) is **still a valid intermediate option** for operators who don't want a new daemon — but the drop-in is the project endgame.

## What ships in v1.0

### Compatibility (must match the C gateway exactly)

- Binary name `datum_gateway` (underscore — `bitcoin.conf` blocknotify recipes depend on it).
- Default config path `./datum_gateway_config.json` (cwd, no `/etc/`, no XDG).
- Default ports: `23334` SV1 stratum, `7152` HTTP dashboard, `28915` DATUM upstream.
- CLI flags: `-?/--help`, `-c/--config FILE`, `--example-conf`, `--test`.
- Signal handlers: SIGUSR1 (force GBT refresh), SIGPIPE (ignore).
- Log format: `TS.ms [func_name_padded_44] LEVEL: msg`, daily rotation, 6 levels with right-padded 5-char prefix.
- HTTP API: 14 endpoints with same URL paths and JSON shapes (`/clients`, `/threads`, `/coinbaser`, `/config`, `/cmd`, `/assets/*`, `/NOTIFY`, `/testnet_fastforward`, `/umbrel-api`, plus auth callbacks). HTTP Digest SHA-256 + MD5 fallback. CSRF token format: `SHA256("DATUM Anti-CSRF Token" + port + admin_password)`.
- Config schema: 8 sections, ~70 keys, `vardiff_min` rounded down to power of 2, `work_update_seconds` clamped [5,120], `coinbase_tag_*` combined ≤88B.
- DATUM upstream wire format: bit-exact frame layout, libsodium handshake, MurmurHash3 obfuscation chain, version string `"v0.4.1-beta"`.
- Failover behavior: disconnect-all-stratum on prolonged DATUM outage.
- Docker contract: `EXPOSE 23334 7152`, `VOLUME /app/config`, ENTRYPOINT `["datum_gateway", "--config", "/app/config/config.json"]`, non-root `datumuser`.

### Additive (new in Rust port; opt-in or default-off)

- **SV2 downstream on port 23335** (default off) using SRI's `channels_sv2` + `handlers_sv2` crates.
- `--version` flag.
- Clean SIGTERM/SIGINT shutdown.
- `--validate-config` and `--migrate-config --dry-run` subcommands.
- Richer exit codes (config-error, ocean-disconnect, bitcoind-unreachable).
- Optional PID file (`--pid-file PATH`).
- Prometheus `/metrics` endpoint.
- Structured JSON log option (gated, default keeps C-format).
- `Type=notify` systemd integration.
- GBT native long-polling (replaces C's signal+1Hz fallback).
- Static-musl release artifacts.
- `MIGRATING.md`, `CHANGELOG.md`, reproducible builds.

## Build path of least resistance

Ordered by dependency:

1. **`datum-config`** — JSON schema parse + validate; minimal dependencies (~300-400 LOC).
2. **`datum-rpc`** — hand-rolled `reqwest + corepc-types` for bitcoind (~100-150 LOC). Mock bitcoind for tests.
3. **`datum-blocktemplates`** + **`datum-coinbaser`** in parallel (~500-700 LOC together). Test against regtest bitcoind.
4. **`datum-protocol`** — the gating engineering problem. Mock pool first (in-tree), then live OCEAN integration. ~800-1200 LOC.
5. **`datum-dupes`** + **`datum-submitblock`** (~230-320 LOC together).
6. **`datum-stratum-sv2`** — SRI crates + custom `JobStore` (~500-800 LOC).
7. **`datum-stratum-sv1`** — direct serve, parity with C (~600-900 LOC). Or skip if shipping SV2-only first.
8. **`datum-api`** — the largest remaining crate (~800-1200 LOC). Iterative against the 14-endpoint contract.
9. **`datum-bin`** — main binary; produces `target/release/datum_gateway`.
10. **Distribution** — GitHub Actions for static-musl artifacts, multi-arch Docker, `.deb` via `cargo-deb`, StartOS submodule swap.

## Risks & open questions

| Risk | Likelihood | Severity | Mitigation |
|---|---|---|---|
| DATUM Prime wire-protocol drift mid-development | Med | High | Mock pool + live integration tests; coordinate with OCEAN engineering; pin a version string |
| OCEAN production server runs older protocol than master | Med | Med | Configurable version string; literal `"v0.4.1-beta"` for v1.0; fall-back if rejected |
| Coinbase output divergence SV1↔SV2 (operator could pay self instead of OCEAN) | Low | **Catastrophic** | Single source-of-truth array + golden vectors against C output |
| Log format drift breaks operator alerts | Med | Med | Custom `tracing` formatter; side-by-side log-string table in `MIGRATING.md` |
| Disconnect-all-on-outage cascade misimplemented | Low | High | Replicate C behavior for both protocols; SV2 needs explicit `CloseChannel` |
| `datum_api.c` rewrite underestimated (it's 40% of port) | Med | Med | Iterative; ship without operator-asset polish first |
| OCEAN hostility to upstream contribution | known | Med | Build externally; cite [[ocean-sv2-stance-and-prior-art|issue #146]] in any community announcement |

### Open questions for follow-up research

1. Header bitfield byte ordering — capture-and-pin from a real C-emitted PING frame.
2. OCEAN production server protocol version (vs master `v0.4.1-beta`).
3. Per-miner unique-identifier delivery semantics (16-bit ID; one per gateway or per downstream miner?).
4. Coinbaser refresh trigger — block-notify? timer? per-share? Read `datum_coinbaser.c`.
5. SV1 pure-direct-serve vs internally-translate-to-SV2 — Q4 recommends direct-serve; revisit once SV2 path is stable.

## What this project is NOT

- **Not a fork of `datum_gateway`**. Greenfield Rust workspace; consumes upstream as a reference point.
- **Not a fork of `OCEAN-xyz/datum_gateway-startos`** until the Rust port is at v1. Then we fork the StartOS package and swap the submodule.
- **Not an OCEAN endorsement**. OCEAN has explicitly rejected SV2 ([[ocean-sv2-stance-and-prior-art]]); the project ships independently and integrates with whatever OCEAN's pool side accepts.
- **Not a DATUM-Prime reimplementation**. Pool-side stays closed-source; the gateway is what we own.
- **Not a Job Declaration server**. Operators on this gateway use OCEAN's coinbase outputs in order — same as the C gateway. SV2 JD is for a different topology.

## See also

- [[../concepts/drop-in-surface-inventory]] — operator-facing surface compatibility list
- [[../concepts/datum-protocol-rust-implementation]] — encrypted upstream Rust design
- [[../concepts/drop-in-rust-port-architecture]] — Cargo workspace + LOC budget
- [[../concepts/dual-protocol-downstream]] — SV1+SV2 in one binary
- [[../concepts/drop-in-distribution]] — packaging + binary swap mechanics
- [[../concepts/switch-day-runbook]] — operator migration procedure
- [[datum-sv2-proxy-playbook]] — the **sidecar proxy** alternative (Phase 1, no daemon replacement)
- [[../../sv1-upstream-reverse-translator/_index|sv1-upstream-reverse-translator]] — generic SV2-downstream / SV1-upstream pattern
- [[../../bitcoin-mining-payout-schemas/wiki/concepts/datum]] — DATUM in payout-schema context
