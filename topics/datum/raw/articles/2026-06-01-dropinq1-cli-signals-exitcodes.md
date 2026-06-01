---
title: "datum_gateway CLI flags, signals, exit codes, daemon model"
source: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_gateway.c
type: articles
tags: [datum-gateway, drop-in-replacement, cli, signals, exit-codes, daemon, operator-surface]
summary: "Every command-line flag, signal handler, exit code, and process-model fact about datum_gateway as of master. argp parses exactly four flags. Only two signals are handled (SIGUSR1=blocknotify, SIGPIPE=ignored). No PID file, no daemonization, no fork. Exits with 1 on any init failure; main loop is infinite (no graceful SIGTERM handler in this module)."
confidence: high
ingested: 2026-06-01
ingested_by: dropinq1
---

# datum_gateway CLI flags, signals, exit codes, daemon model

## Command-line flags (argp)

The full argp options table from `datum_gateway.c`:

| Short | Long | Argument | Description |
|---|---|---|---|
| `-?` | `--help` / `--usage` | none | Show custom help |
| `-c` | `--config` | `FILE` | Configuration JSON file |
| — | `--example-conf` | none | Print example config JSON to stdout |
| — | `--test` | none | Run tests only |

Default config path if `-c` not given: `datum_gateway_config.json` in the current working directory. **No XDG search**, no `~/.datum/`, no `/etc/datum/`. The README's reference to "the working directory" is literal.

There is **no `--version`** flag. Version is printed in the startup banner only, format: `datum_gateway <DATUM_PROTOCOL_VERSION>` plus a `GIT_COMMIT_HASH` macro.

## Environment variables

**None.** No `getenv()` calls in `datum_gateway.c`. The drop-in is free to add env-var overrides without colliding.

## Signal handlers

Only two signals are touched in `datum_gateway.c`:

| Signal | Handler | Behavior |
|---|---|---|
| `SIGUSR1` | `handle_sigusr1` → `datum_blocktemplates_notifynew_sighandler()` | Force GBT refresh — this is the documented `blocknotify` mechanism. `bitcoin.conf` blocknotify recipe is `killall -USR1 datum_gateway`. |
| `SIGPIPE` | `SIG_IGN` | Ignored; per-socket errors handled in `datum_sockets`. |

Notably **absent**: SIGTERM, SIGINT, SIGHUP. There is no clean shutdown path; the process exits when the OS kills it. There is no SIGHUP-reload of config (runtime config edits go through `/config` POST in `datum_api.c` and depend on `api.modify_conf=true`).

## Exit codes

Observed in `datum_gateway.c`:
- **0**: never reached in steady state (main loop is infinite)
- **1**: any init failure — argument parse, config load, protocol init, API init, coinbaser init, signal-handler install

There is no taxonomy of exit codes (e.g., 2=config-error, 3=ocean-disconnect). Operators alerting on exit code can only distinguish "ran" from "didn't init".

## Daemon / fork

- **No `fork()`**. Foreground only.
- **No PID file**. No `/run/datum_gateway.pid` or similar.
- **No lock file**. Two instances pointed at the same config will both try to bind `:23334` and the second will fail; nothing prevents a multi-instance accident at the gateway level.

This shapes how a production deployment must wrap it — typically systemd `Type=simple` + `Restart=on-failure`, or a Docker `restart: unless-stopped`.

## Drop-in implications

**Trivial to match**: `--config FILE`, `--example-conf`, exit code 1 on init failure, foreground-only process, no env vars (so the drop-in inherits a clean slate to add anything).

**Easy to improve**: add `--version`, add SIGTERM clean shutdown (drains channels, flushes shares to upstream), add structured exit codes.

**Cannot break**: `SIGUSR1=blocknotify`. The Knots `blocknotify=killall -USR1 datum_gateway` recipe is documented in OCEAN's setup guide and lives in operator `bitcoin.conf` files in production. The drop-in **must** retain SIGUSR1=GBT-refresh semantics, and the binary name must still be `datum_gateway` (or operators will need to edit blocknotify on every node).

## Justification

Defines the operator-process contract: invocation, signals, exit semantics. These are the surfaces a systemd unit and a `bitcoin.conf` blocknotify line touch. Bit-exact match here is cheap; missing SIGUSR1 would silently break new-block invalidation on every operator who copy-pasted the documented blocknotify recipe.
