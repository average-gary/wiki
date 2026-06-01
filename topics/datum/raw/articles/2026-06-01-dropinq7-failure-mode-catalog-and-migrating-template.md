---
title: "Failure-Mode Catalog and MIGRATING.md Template — Rust DATUM Gateway Drop-In"
source_url: synthesized
source_type: synthesis
date_fetched: 2026-06-01
ingested_by: dropinq7
research_path: dropinq7-switch-day-runbook
quality_score: 8
tags: [datum, datum-gateway, drop-in, migration, failure-modes, migrating-md, template]
related_concepts: [drop-in-replacement, rollback, switch-day-runbook, observability]
---

# Failure-Mode Catalog and MIGRATING.md Template

Two artifacts the Rust drop-in's docs need on day one: a
failure-mode reference table and a `MIGRATING.md` skeleton.

## Failure-mode catalog

For each row: failure mode, observable symptom (what the operator
sees), recovery, and the design mitigation that would prevent the
failure entirely.

### F1 — Config schema mismatch

- **Cause:** the Rust drop-in rejects a key the C gateway
  accepted, or expects a renamed key.
- **Symptom:** binary exits immediately on start with a parser
  error. ASIC stratum sockets stay closed. `journalctl` shows a
  fatal "config error" log line.
- **Recovery:** roll back to C binary (Phase 4). File issue with
  the rejected key.
- **Mitigation:** ship `datum-gateway --migrate-config
  <old.json> -o <new.json>` and `--validate-config`
  subcommands. Document any renamed keys explicitly in
  `MIGRATING.md`'s "What changed" section.

### F2 — Keypair format mismatch

- **Cause:** Rust drop-in expects an on-disk keypair file the C
  gateway never wrote.
- **Symptom:** binary exits with "keypair file not found" or
  generates a new keypair silently.
- **Recovery:** if drop-in auto-generates, no action; the new
  keypair is functionally equivalent to the C ephemeral one. If
  drop-in halts, run an explicit `--init-keypair` subcommand.
- **Mitigation (preferred):** preserve the C gateway's ephemeral
  in-memory keypair model (no file). Generate fresh on every
  start. The C gateway already does this and DATUM Prime accepts
  it; bit-exact compatibility means continuing to do so.
  Persistence is a *new feature*, not a compatibility
  requirement.

### F3 — SV1 ASIC `mining.subscribe` rejected

- **Cause:** dual-protocol downstream listener has a regression
  in the SV1 leg, or port 23334 is bound only by SV2.
- **Symptom:** ASICs show "stratum disconnected" / "connection
  refused" or repeated subscribe→error cycles. `/clients` shows
  zero subscribers.
- **Recovery:** Phase 4 rollback. Optionally configure dual-port
  mode (SV1 23334, SV2 3334 per Issue #146 proposal) before
  retry — explicit isolation eliminates this class.
- **Mitigation:** dual-port mode is the safe default for the
  drop-in's first releases. Single-port multiplexing is an
  optimization for v1.x, not v0.1.

### F4 — DATUM Prime version mismatch

- **Cause:** Rust drop-in's protocol version byte differs from
  what DATUM Prime expects, or vice versa.
- **Symptom:** Connection cycles. Log line in C-style:
  `"Bad configuration version from server. Is this client up to
  date?"` (preserved verbatim by the drop-in for grep
  compatibility) followed by reconnect attempts. ASICs see
  intermittent disconnects.
- **Recovery:** Phase 4 rollback. The Rust drop-in is wedged
  until either DATUM Prime upgrades or the drop-in ships a
  build matching the deployed Prime version.
- **Mitigation:** ship a structured-error log line **alongside**
  (not replacing) the legacy string. Format:
  `{"event":"version_mismatch","our_version":N,
  "their_version":M,"docs":"..."}`. Operators get
  actionable context; existing grep alerts still match.
  This is documented in
  `2026-06-01-dropinq7-c-gateway-keypair-and-version-handshake.md`.

### F5 — TIDES share-attribution discontinuity

- **Cause:** the Rust drop-in submits shares with a different
  `coinbase_unique_id` or username-modifier mapping than the C
  gateway, causing OCEAN's TIDES bookkeeping to credit a
  different identity.
- **Symptom:** `/clients` looks healthy locally; OCEAN dashboard
  shows the operator's share window dropped and a new identity
  appeared.
- **Recovery:** restore exact `mining.coinbase_unique_id` and
  `stratum.username_modifiers` from the backup config. If still
  diverging, contact OCEAN support (Jason / Luke / Mechanic).
- **Mitigation:** drop-in must preserve `coinbase_unique_id` and
  the username-suffix mapping rules **byte-exact**.
  `MIGRATING.md` should explicitly call this out as a "do not
  change" surface.

### F6 — `blocknotify` SIGUSR1 handler missing

- **Cause:** the drop-in dropped SIGUSR1 in favor of HTTP
  `/NOTIFY` only.
- **Symptom:** template staleness on new blocks. Hashboards mine
  stale work for ~30s after each block until the gateway's
  internal poll picks up the new height. Stale-share rate jumps.
- **Recovery:** update `bitcoin.conf` to use HTTP NOTIFY
  (`blocknotify=wget -q -O /dev/null http://localhost:7152/NOTIFY`)
  and restart `bitcoind`.
- **Mitigation:** drop-in keeps SIGUSR1 handler. It's trivial in
  Tokio (`signal_hook` crate or `tokio::signal::unix`).

### F7 — Telemetry / log-format drift

- **Cause:** Rust log lines use different verbs/capitalization;
  operator's grep alerts stop matching.
- **Symptom:** silent — alerts don't fire when they should,
  or fire on wrong patterns.
- **Recovery:** update grep regexes to match drop-in's log
  format. Document the deltas.
- **Mitigation:** drop-in ships a `MIGRATING.md` "Log-format
  changes" section with a side-by-side table of legacy strings
  and new equivalents. Structured logs (JSON) ship as
  *additions*, not replacements, so grep continues to work
  unchanged.

### F8 — HTTP API endpoint regression

- **Cause:** drop-in's admin server (likely `axum` or `actix`)
  has a path/header difference from libmicrohttpd.
- **Symptom:** Umbrel widget shows "loading" forever, or custom
  HTML scrapers parse zero rows.
- **Recovery:** verify endpoint list in `MIGRATING.md` matches
  the C gateway endpoint list per
  `2026-06-01-path2-datum-api-operator-observability.md`. If a
  field disappeared, file an issue or restore.
- **Mitigation:** ship a contract test suite that exercises
  every endpoint listed in the API surface article and asserts
  byte-equal response shape (modulo whitespace). Run it in CI.

## MIGRATING.md template (skeleton)

The Rust drop-in repo should ship `MIGRATING.md` with this
structure. Section ordering and tone borrow from Bitcoin Core's
release notes (terse, imperative; see
`2026-06-01-dropinq7-prior-art-survey-bitcoin-core-lnd-startos.md`).

```markdown
# Migrating to the Rust DATUM Gateway

## At a glance

- Drop-in compatible with C `datum_gateway` v0.4.x against DATUM
  Prime protocol vN.
- Same default ports: stratum 23334, admin API 7152.
- Same config file path. New keys ignored by the C gateway can be
  added safely; renamed keys flagged below.
- No keypair file to back up (neither version persists keys).

## Compatibility

- **OS:** Linux x86_64 (kernel 4.18+). FreeBSD support pending.
- **Bitcoin node:** Bitcoin Knots ≥ 27.x recommended; Bitcoin
  Core ≥ 26.x supported.
- **Migrate from:** datum_gateway C v0.3.0+ tested. Older
  versions: upgrade C first, then migrate.
- **DATUM Prime:** protocol version N (current). If OCEAN bumps
  Prime to vN+1, both C and Rust gateways need matching
  releases.

## Pre-switch checklist

- [ ] Backup `datum_gateway_config.json` to `.bak.<date>`.
- [ ] Backup C binary to `.bak.<date>`.
- [ ] Run `datum-gateway --validate-config <config>`.
- [ ] Run `datum-gateway --migrate-config <old> -o <new>
      --dry-run` if any keys were renamed (see "What changed").
- [ ] Note current pool-connection state, share-rate floor, and
      last accepted-share timestamp from `/clients`.
- [ ] Confirm DATUM Prime is on a protocol version this release
      supports (see release notes).

## How to upgrade

### systemd (bare metal)

    sudo systemctl stop datum-gateway
    sudo cp datum-gateway-rs /usr/local/bin/datum_gateway
    sudo systemctl start datum-gateway
    sudo journalctl -fu datum-gateway

### Docker

    docker stop datum-gateway && docker rm datum-gateway
    docker pull ocean-xyz/datum_gateway:rust-<tag>
    docker run -d --name datum-gateway \
      -v /path/to/config:/app/config \
      -p 23334:23334 -p 7152:7152 \
      ocean-xyz/datum_gateway:rust-<tag>

### Package manager (apt / dnf)

    sudo apt install datum-gateway=<rust-version>
    # or
    sudo dnf install datum-gateway-<rust-version>

## Verification

Run within 60 seconds of start:

1. `datum_gateway --version` — must print Rust + commit.
2. `curl -s http://localhost:7152/` — pool state "connected".
3. `curl -s http://localhost:7152/clients` — at least one
   `diff_accepted > 0`.
4. `journalctl -u datum-gateway | grep -iE "(error|version)"` —
   quiet.
5. Aggregate hashrate within 10% of pre-switch floor.

If any check fails, **roll back** (next section). Do not
troubleshoot in production.

## Rollback

    sudo systemctl stop datum-gateway
    sudo cp /usr/local/bin/datum_gateway.bak.<date> \
            /usr/local/bin/datum_gateway
    sudo systemctl start datum-gateway

Re-run all five Verification checks. File an issue with logs.

## What changed

### Configuration

| C key | Rust key | Notes |
|---|---|---|
| `stratum.max_clients` | `mining_server.max_channels` | renamed |
| `stratum.vardiff_min` | `mining_server.min_target` | renamed; semantics differ |
| ... | ... | ... |

### Logging

| C log string | Rust log string | Grep impact |
|---|---|---|
| `Bad configuration version from server.` | (unchanged) | none |
| ... | ... | ... |

### New endpoints (additions, no break)

- `GET /metrics` — Prometheus exposition (new in Rust).
- `GET /channels` — per-channel target history (new in Rust).

## Known issues

(Limit-N list, with workarounds.)

## Telemetry differences

(Call out structured-log additions explicitly. Existing grep
alerts continue to work; structured fields are additive.)

## Getting help

- GitHub issues: github.com/OCEAN-xyz/datum_gateway/issues
- OCEAN support: Jason `@wk057`, Luke `@LukeDashjr`, Mechanic
  `@GrassFedBitcoin` (X / Nostr).
```

## Justification

The catalog enumerates the failure modes the drop-in must defend
against. The template is the on-disk artifact those mitigations
get documented in. Together they're the "what to ship" half of
the question; the runbook article is the "what to do" half.

## Sources

- `2026-06-01-dropinq7-c-gateway-keypair-and-version-handshake.md`
- `2026-06-01-dropinq7-prior-art-survey-bitcoin-core-lnd-startos.md`
- `2026-06-01-dropinq7-switch-day-runbook-draft.md`
- `2026-06-01-path2-datum-config-surface.md`
- `2026-06-01-path2-datum-api-operator-observability.md`
- `2026-06-01-path1-issue-146-sv2-support.md` (dual-port SV1/SV2
  proposal).
