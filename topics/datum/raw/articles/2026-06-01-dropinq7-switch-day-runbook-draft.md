---
title: "Switch-Day Runbook (Draft) — OCEAN Operator Migrating to the Rust DATUM Gateway"
source_url: synthesized
source_type: synthesis
date_fetched: 2026-06-01
ingested_by: dropinq7
research_path: dropinq7-switch-day-runbook
quality_score: 8
tags: [datum, datum-gateway, drop-in, migration, runbook, switch-day, operator]
related_concepts: [drop-in-replacement, rollback, failure-modes, migrating-md]
---

# Switch-Day Runbook (Draft)

A linear procedure an OCEAN operator follows when swapping a running
C `datum_gateway` for the Rust drop-in. Synthesized from:

- The C gateway README install/Docker sections (port 23334 stratum,
  port 7152 admin API, `blocknotify=killall -USR1 datum_gateway`).
- The C gateway config schema as parsed by `datum_conf.c`.
- Keypair / version-handshake findings from `datum_protocol.c`.
- Bitcoin Core's "How to Upgrade" template style.

## Phase 0 — Decide whether to switch today

- Confirm the Rust drop-in's release tag advertises the **same DATUM
  Protocol version byte** as your current C gateway. Mismatch is the
  single highest-risk failure mode; abort the switch if uncertain.
- Decide your downstream story:
  - **All-SV1 ASICs:** drop-in's SV1 listener replaces the C
    listener on port 23334. No ASIC-side changes required.
  - **Mixed SV1+SV2 ASICs:** confirm the drop-in supports
    dual-protocol downstream (separate SV2 port, e.g. 3334) before
    enabling SV2 firmware on any hashboard.
  - **Testing only:** stay all-SV1 for the first switch; add SV2 later
    when the SV1 leg is proven stable.

## Phase 1 — Pre-switch checklist

1. **Snapshot the config.** `cp datum_gateway_config.json
   datum_gateway_config.json.bak.YYYYMMDD`. The config contains
   `datum.pool_pubkey` (pool-side trust anchor), `bitcoind` RPC
   credentials, miner-routing rules, vardiff knobs.
2. **Snapshot the binary.** `cp /usr/local/bin/datum_gateway
   /usr/local/bin/datum_gateway.bak.YYYYMMDD` (bare metal). For
   package-managed installs, `apt-mark hold datum-gateway` or its
   `dnf` equivalent so the C version isn't auto-replaced
   mid-procedure. For Docker, note the exact image digest:
   `docker inspect datum-gateway | jq '.[0].Image'`.
3. **No keypair file to back up.** The C gateway generates ephemeral
   libsodium keypairs in memory each run; there is no on-disk
   keypair file. (See:
   `2026-06-01-dropinq7-c-gateway-keypair-and-version-handshake.md`.)
4. **Note current state.**
   - Pool connection status from `/` admin page (connected /
     initializing / error).
   - Recent share-rate floor from `/clients` (e.g. "12 miners,
     14.3 PH/s aggregate").
   - Last accepted-share timestamp for at least one canary miner.
5. **Identify monitoring touchpoints.** Common ones:
   - `tail -f` on `logger.log_file` (default unset; check config).
   - Cron grepping logs for `"share rejected"` / `"DATUM connection"`.
   - Custom HTML scraper of `/clients` (no Prometheus today).
   - Umbrel widget polling `/umbrel-api`.
   - `bitcoin.conf` `blocknotify=killall -USR1 datum_gateway`.
6. **Run the drop-in's config validator.** If the Rust binary ships
   `datum-gateway-rs --validate-config datum_gateway_config.json`,
   run it now. If it ships `--migrate-config`, run it with
   `--dry-run` first. Resolve any reported deltas before
   proceeding.
7. **Schedule a low-stakes window.** A few minutes of stratum
   downtime is normal; in TIDES, the share window is continuous,
   so a brief outage costs proportional reward, not categorical
   reward.

## Phase 2 — The actual swap (bare metal, systemd)

1. `sudo systemctl stop datum-gateway`. Wait for the unit to
   transition to `inactive (dead)`. ASICs will see the stratum
   socket close; their built-in failover should kick to the
   secondary stratum URL.
2. Replace the binary:
   - **Manual:** `sudo cp datum_gateway-rs /usr/local/bin/datum_gateway`
     (drop-in must keep the same path/name for the systemd unit).
   - **Package:** `sudo apt install datum-gateway=<rust-version>` /
     `sudo dnf install datum-gateway-<rust-version>`.
3. Update `bitcoin.conf` if the drop-in changes the signal name
   (e.g. SIGUSR1 → HTTP NOTIFY only). For the conservative case,
   the drop-in keeps `SIGUSR1` semantics.
4. `sudo systemctl start datum-gateway`.
5. Watch the unit log: `sudo journalctl -fu datum-gateway`.

## Phase 2 (alt) — Docker swap

1. `docker pull ocean-xyz/datum_gateway:rust-<tag>`.
2. `docker stop datum-gateway && docker rm datum-gateway`.
3. `docker run -d --name datum-gateway \
     -v /path/to/config:/app/config \
     -p 23334:23334 -p 7152:7152 \
     ocean-xyz/datum_gateway:rust-<tag>`.
4. Update `bitcoin.conf` `blocknotify=wget -q -O /dev/null
   http://datum-gateway:7152/NOTIFY` if not already set (Docker
   note from README).

## Phase 2 (alt) — `kill -TERM` (no init system)

1. `kill -TERM $(pgrep datum_gateway)`. Confirm the PID exits.
2. Replace binary in place.
3. Restart by your usual mechanism (tmux, supervisord, etc.).

## Phase 3 — Verification (must pass before walking away)

1. `datum_gateway --version` — output must include "Rust"
   identifier and the commit hash advertised in the release.
2. **Pool handshake:** `curl -s http://localhost:7152/ | grep -i
   "datum"` — homepage should show the pool connection state as
   "connected", not "initializing" or "error".
3. **First share accepted:** `curl -s http://localhost:7152/clients`
   — at least one miner should show `diff_accepted > 0` and a
   recent `last share` timestamp (within 2× target shares/min,
   default ~7.5s).
4. **Share-rate sanity:** the aggregate hashrate from `/clients`
   should be within ~10% of the pre-switch floor noted in Phase 1.
5. **Log-line health:** `journalctl -u datum-gateway | grep -iE
   "(error|version|reject)"` should be quiet. Specifically, no
   recurring `"Bad configuration version from server"` (the
   version-mismatch tell — see keypair/version article).
6. **Bitcoin node integration:** confirm `blocknotify` still fires.
   On the next block, the gateway should issue `getblocktemplate`
   within ~1s of the notify. Watch `journalctl` for the
   notify→template line.

If any of (2)–(5) fails, **roll back** (Phase 4). Don't troubleshoot
in production.

## Phase 4 — Rollback procedure

1. `sudo systemctl stop datum-gateway`.
2. Restore the C binary:
   - **Manual:** `sudo cp /usr/local/bin/datum_gateway.bak.YYYYMMDD
     /usr/local/bin/datum_gateway`.
   - **Package:** `sudo apt install datum-gateway=<previous-c-version>`
     / `sudo dnf downgrade datum-gateway`.
   - **Docker:** `docker run -d --name datum-gateway ...
     ocean-xyz/datum_gateway:<previous-c-image-digest>` (the digest
     you noted in Phase 1).
3. Restore the config if the drop-in mutated it in place
   (`--migrate-config` should write to a new file, not overwrite —
   if it overwrote, restore from `.bak`).
4. `sudo systemctl start datum-gateway`.
5. Re-run **Phase 3** verification with the C version. The same
   commands should pass.
6. File an issue against the Rust drop-in repo with: release tag,
   exact log lines from `journalctl`, the config file (with secrets
   redacted), and the pre-switch share-rate floor.

## Phase 5 — Post-switch (24 hours)

1. **Share-attribution check.** TIDES is a rolling window; over
   24h, the operator's share contribution from the Rust gateway
   should match the C gateway's pre-switch trajectory within
   noise (a few percent). If it diverges materially, suspect
   an upstream-side share-validation delta.
2. **Log-format diff.** If grep-based alerts use literal C-gateway
   log strings, port them now. The drop-in's structured logs (if
   any) are *additions*, but the unstructured tail likely uses
   different verb tense / capitalization. Update alert regexes.
3. **Adopt new endpoints.** If the drop-in ships `/metrics`
   (Prometheus), wire it into the operator's existing scrape
   target. This is the no-break improvement called out in
   `2026-06-01-path2-datum-api-operator-observability.md`.

## Justification

This is the linear sequence an OCEAN operator follows; previous
research articles enumerated *surfaces* (config, API, protocol),
not *time-ordered actions*. This article fills that gap and is
the direct draft input for `MIGRATING.md`.

## Sources

- `2026-05-28-datum-gateway-readme.md` (port numbers, install,
  Docker, blocknotify).
- `2026-06-01-path2-datum-config-surface.md` (config schema).
- `2026-06-01-path2-datum-api-operator-observability.md` (API
  endpoints used in verification).
- `2026-06-01-dropinq7-c-gateway-keypair-and-version-handshake.md`
  (no keypair file; version-mismatch is the top failure mode).
- `2026-06-01-dropinq7-prior-art-survey-bitcoin-core-lnd-startos.md`
  (template style).
