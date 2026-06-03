---
title: "Drop-in surface inventory — what a Rust replacement must match"
category: concept
sources:
  - raw/articles/2026-06-01-dropinq1-cli-signals-exitcodes.md
  - raw/articles/2026-06-01-dropinq1-log-format-and-rotation.md
  - raw/articles/2026-06-01-dropinq1-network-ports-filesystem-docker.md
  - raw/articles/2026-06-01-dropinq1-ocean-keypair-tides-attribution.md
created: 2026-06-01
updated: 2026-06-01
tags: [drop-in, compatibility, datum_gateway, operator-surface]
confidence: high
---

# Drop-in surface inventory

The list of every operator-facing surface a Rust `datum_gateway` replacement must preserve to be binary-swappable. From [[../../raw/articles/2026-06-01-dropinq1-cli-signals-exitcodes|Q1 CLI/signals]], [[../../raw/articles/2026-06-01-dropinq1-log-format-and-rotation|Q1 logging]], [[../../raw/articles/2026-06-01-dropinq1-network-ports-filesystem-docker|Q1 ports/Docker]], [[../../raw/articles/2026-06-01-dropinq1-ocean-keypair-tides-attribution|Q1 keypair/TIDES]].

## The de-risking finding

**There is no on-disk state to migrate.** The C gateway:

- Generates Ed25519 + X25519 keypairs fresh on every startup (libsodium `crypto_sign_keypair` + `crypto_box_keypair`); zero disk persistence.
- Has no PID file, no lock file, no share log, no sequence-number checkpoint.
- TIDES attribution at OCEAN keys on **per-share Bitcoin payout address** (parsed from `mining.authorize` username), **not** on gateway pubkey. Confirmed by reading `datum_protocol.c` share-message construction.

Switch-day rollback to the C binary works automatically with no statefile compat tooling. **This single finding eliminates the largest hypothetical migration surface.**

## Inventory by surface

| Surface | Current behavior | Drop-in difficulty | Hazard |
|---|---|---|---|
| Default config path | `./datum_gateway_config.json` (cwd, no `/etc/`, no XDG) | trivial | preserve exact |
| Config schema (8 sections, ~70 keys) | JSON; documented in [[deployment-and-node-config]] | moderate | `stratum` section needs SV2 extension |
| CLI flags | `-?/--help`, `-c/--config FILE`, `--example-conf`, `--test`. **No `--version`.** | trivial | match exactly + ADD `--version` |
| Environment variables | **none** | trivial | clean slate |
| Stratum listen port | `23334/tcp` | trivial | preserve default |
| API/dashboard port | `7152/tcp`, configurable, 0=disabled | trivial | preserve default |
| Upstream destination | `datum-beta1.mine.ocean.xyz:28915` | trivial | preserve default |
| OCEAN pool pubkey | 128-hex hardcoded in `datum_conf.c` | trivial | preserve default; allow override |
| `SIGUSR1` | force GBT refresh (this IS the blocknotify mechanism) | trivial | **MUST preserve binary name = `datum_gateway` AND signal handler** |
| `SIGPIPE` | `SIG_IGN` | trivial | preserve |
| `SIGTERM`/`SIGINT`/`SIGHUP` | not handled (no clean shutdown, no SIGHUP-reload) | trivial | improve (additive) |
| Log timestamp | `%Y-%m-%d %H:%M:%S.%03d` local time | moderate | custom `tracing` formatter |
| Log level prefix | right-padded 5-char: `"  ALL"`, `"DEBUG"`, `" INFO"`, `" WARN"`, `"ERROR"`, `"FATAL"` | moderate | custom formatter |
| Log line shape | `TS.ms [func_name_padded_44] LEVEL: msg` (with `log_calling_function=true` default) | **hard** | operators have grep patterns on this; `tracing` doesn't pad function names by default |
| Log rotation | daily midnight; rename to `<file>.YYYY-MM-DD`; no compression, no size cap | trivial | `tracing-appender Rotation::DAILY` |
| Exit codes | `1` on init failure; otherwise infinite | trivial | richer codes are additive |
| HTTP API endpoints | 14 paths: `/`, `/clients`, `/threads`, `/coinbaser`, `/config`, `/cmd`, `/assets/*`, `/NOTIFY`, `/testnet_fastforward`, `/umbrel-api`, plus auth callbacks | **moderate-hard** | URL paths must match; Umbrel widget hits `/umbrel-api` |
| API auth | admin password + HTTP Digest (SHA-256 + MD5 fallback for Safari) + CSRF token | moderate | Digest auth is awkward in `axum` |
| OCEAN keypair (Ed25519+X25519) | regenerated every startup, ephemeral, no disk file | trivial | clean slate |
| TIDES attribution | per-share Bitcoin payout address | trivial | automatic continuity across swap |
| 8-job ring state | in-memory only, reset on every connection | trivial | stateless across restart |
| PID file | none | trivial | optional addition |
| Lock file | none | trivial | second instance fails to bind |
| Share log on disk | none | trivial | clean slate |
| `save_submitblocks_dir` | optional, one file per discovered block | trivial | preserve |
| bitcoind blocknotify | local: `killall -USR1 datum_gateway` (psmisc); networked: `wget http://gateway:7152/NOTIFY` | trivial | both paths preserved |
| Docker base image | `debian:bookworm-slim`, two-stage | trivial | Rust port can use `FROM scratch` if pure-Rust crypto |
| Docker entrypoint | `["/app/datum_gateway", "--config", "/app/config/config.json"]` | trivial | preserve |
| Docker user | non-root `datumuser` | trivial | preserve |
| Docker volume | `/app/config` | trivial | preserve |
| Docker EXPOSE | `23334/tcp 7152/tcp` | trivial | preserve |
| Docker healthcheck | `nc -zv localhost 23334` every 30s | trivial | preserve; can deepen as additive improvement |

## The four hard surfaces

1. **Log line shape** — operators have grep pipelines on the 44-char function-name padding. `tracing-subscriber` defaults are wrong on three axes (TZ, level alignment, function-name padding). Need a custom formatter.
2. **Binary name + SIGUSR1 handler** — `bitcoin.conf` `blocknotify=killall -USR1 datum_gateway` is in production at every operator. The Rust binary MUST be named `datum_gateway` AND must treat SIGUSR1 as a blocktemplate refresh trigger.
3. **HTTP API URL paths** — Umbrel widgets and operator polling scripts hit `/umbrel-api`, `/clients`, `/coinbaser`. URL paths and JSON shapes must match; HTML pages can be rewritten freely as long as the JSON contract holds.
4. **Default ports 23334, 7152, 28915** — every miner config, every Docker compose file references these. Cannot change.

## Negotiable surfaces (additive only)

- `--version` flag (none today)
- Clean SIGTERM/SIGINT shutdown (none today)
- `--validate-config` / `--migrate-config` subcommands
- Richer exit codes
- PID file (`--pid-file`)
- Prometheus `/metrics` endpoint
- Structured JSON log option (gated, default keeps C-format)
- `Type=notify` systemd integration

## See also

- [[datum-protocol]] — the wire format the drop-in must speak upstream
- [[gateway-internals-c-architecture]] — the C source the inventory was extracted from
- [[drop-in-rust-port-architecture]] — how the modules map to Rust crates
- [[switch-day-runbook]] — the operator-facing migration procedure
