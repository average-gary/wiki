---
title: "Switch-day runbook and failure-mode catalog"
category: concept
sources:
  - raw/articles/2026-06-01-dropinq7-switch-day-runbook-draft.md
  - raw/articles/2026-06-01-dropinq7-failure-mode-catalog-and-migrating-template.md
  - raw/articles/2026-06-01-dropinq7-c-gateway-keypair-and-version-handshake.md
  - raw/articles/2026-06-01-dropinq7-prior-art-survey-bitcoin-core-lnd-startos.md
created: 2026-06-01
updated: 2026-06-01
tags: [migration, runbook, operator, failure-modes, migrating-md]
confidence: high
---

# Switch-day runbook and failure-mode catalog

What an OCEAN operator running `datum_gateway` actually does to swap binaries. The C gateway ships zero migration docs (no `MIGRATING.md`, no `UPGRADING.md`, no `CHANGELOG.md`); the Rust drop-in shipping a real runbook is purely additive credibility.

From [[../../raw/articles/2026-06-01-dropinq7-switch-day-runbook-draft|Q7 runbook]], [[../../raw/articles/2026-06-01-dropinq7-failure-mode-catalog-and-migrating-template|Q7 failures + MIGRATING template]], [[../../raw/articles/2026-06-01-dropinq7-prior-art-survey-bitcoin-core-lnd-startos|Q7 prior art]].

## The headline finding

**The keypair-backup task does not exist.** `datum_protocol.c::datum_protocol_init()` calls `datum_encrypt_generate_keys()` each run. There is no on-disk keypair file. Drop-in keypair compatibility is automatic. Combined with TIDES attribution by Bitcoin payout address (not gateway pubkey) — see [[drop-in-surface-inventory#the-de-risking-finding|de-risking finding]] — switch-day rollback is a binary swap with zero state migration tooling.

## The runbook (5 phases)

### Phase 0 — decide

- Verify the Rust port targets the same DATUM Prime protocol version your OCEAN endpoint runs (`v0.4.1-beta` on master; production may be older).
- Pick all-SV1 mode (drop-in parity, zero risk) vs dual-protocol (SV1 default + SV2 opt-in on port 23335).
- Confirm one ASIC supports SV2 if you're enabling SV2 — otherwise the SV2 port serves nothing.

### Phase 1 — pre-switch

- `cp /usr/local/bin/datum_gateway /usr/local/bin/datum_gateway.bak`
- `cp datum_gateway_config.json datum_gateway_config.json.bak`
- Snapshot current state from the dashboard: visit `http://gateway:7152/clients` (or whichever port) and note miner count, share rate, OCEAN connection state.
- Identify monitoring touchpoints: grafana? `tail -f /var/log/datum/...`? cron grep? Document them so post-swap drift is detectable.
- `datum-gateway-rust --validate-config /etc/datum/config.json` (additive; the C gateway has no equivalent).
- `datum-gateway-rust --migrate-config --dry-run` if config schema additions are needed (additive).

### Phase 2 — the swap

systemd:
```
systemctl stop datum-gateway
mv /usr/local/bin/datum_gateway.bak /usr/local/bin/datum_gateway.c-prev
cp datum-gateway-rust /usr/local/bin/datum_gateway
systemctl start datum-gateway
```

Docker:
```
docker stop datum && docker rm datum
docker pull ghcr.io/<author>/datum-gateway:<version>
docker run -d --name datum -v /etc/datum:/app/config -p 23334:23334 -p 7152:7152 ghcr.io/<author>/datum-gateway:<version>
```

Direct kill:
```
kill -TERM $(pidof datum_gateway)
# wait for clean exit
./datum-gateway-rust -c datum_gateway_config.json &
```

### Phase 3 — verify (5 checks; any failure → rollback)

1. `datum_gateway --version` prints Rust version + commit hash.
2. Dashboard pool state: `http://gateway:7152/` shows OCEAN connection authenticated.
3. First share accepted: tail logs for `share accepted` line within 1-2 min.
4. Share-rate floor: matches pre-swap rate within 10%.
5. Log line health: existing grep alerts still fire (no false silence).

### Phase 4 — rollback (if any check fails)

```
systemctl stop datum-gateway
mv /usr/local/bin/datum_gateway /usr/local/bin/datum-gateway-rust.failed
mv /usr/local/bin/datum_gateway.c-prev /usr/local/bin/datum_gateway
systemctl start datum-gateway
```

Re-verify with the same 5 checks. File a GitHub issue with the Rust port. **Do not troubleshoot in production.**

### Phase 5 — post-switch (24h)

- TIDES attribution check: visit OCEAN dashboard, confirm shares attributed to the same payout address window.
- Log-format diff: spot-check that operator alerts didn't silently misfire.
- Adopt new endpoints: `/metrics` (Prometheus, additive in Rust port), structured JSON logs (gated, default off).

## Failure-mode catalog

| ID | Mode | Symptom | Mitigation |
|---|---|---|---|
| F1 | Config schema mismatch | Binary exits at start ("invalid config: unknown key") | `--migrate-config` + `--validate-config` subcommands; CHANGELOG section per added/changed key |
| F2 | Keypair format mismatch | "keypair not found" or silent regen on each restart | Preserve C's ephemeral in-memory model; no file. Drop-in inherits this property automatically. |
| F3 | SV1 `mining.subscribe` rejected | Zero subscribers; ASIC reconnect loops | Dual-port mode (SV1 23334, SV2 23335) for v0.x to isolate; preserve SV1 path bit-for-bit |
| F4 | DATUM Prime version mismatch | Reconnect cycles + legacy log line "Bad configuration version from server. Is this client up to date?" | Preserve legacy log string for grep-compat AND emit structured JSON event; configurable version string |
| F5 | TIDES attribution discontinuity | Local healthy, OCEAN dashboard shows new identity window | Byte-exact `coinbase_unique_id` in scriptSig + `username_modifiers` byte-for-byte |
| F6 | `blocknotify` SIGUSR1 missing | Stale shares ~30s post-block; mining performance drop | Keep SIGUSR1 handler (`tokio::signal::unix`) — non-negotiable per [[drop-in-surface-inventory#the-four-hard-surfaces]] |
| F7 | Log-format drift | Silent alert misfire — operator's grep pattern doesn't match new log line | Side-by-side log-string table in `MIGRATING.md`; custom `tracing` formatter that matches C's 44-char function-name padding + 5-char level prefix |
| F8 | HTTP API regression | Umbrel widget broken; polling scripts return 404 | Contract test suite vs full 14-endpoint list (Q3); CSRF token format must match |

## MIGRATING.md skeleton

The Rust port should ship `MIGRATING.md` with these sections:

1. **At a glance** — what changed, in one paragraph.
2. **Compatibility** — which platforms, which DATUM Prime versions, which Bitcoin Core/Knots versions.
3. **Pre-switch checklist** — backup, snapshot, monitoring identification.
4. **How to upgrade** — three subsections (systemd, Docker, package manager).
5. **Verification** — the 5-check post-swap procedure.
6. **Rollback** — explicit, tested procedure.
7. **What changed** — three subtables (config keys, log lines, new endpoints).
8. **Known issues** — pinned at top of each release.
9. **Telemetry differences** — what's new (Prometheus, JSON logs); what's identical.
10. **Getting help** — GitHub issues + OCEAN community channels.

Bitcoin Core's release-notes structure is the right template (terse, imperative, sectioned). LND's feature-driven structure is the wrong template (operators have to grep for migration content).

## Prior art for the migration pattern

Surveyed: Bitcoin Core release notes (right shape), LND release notes (wrong shape), `datum-gateway-startos` manifest update (eventual destination, not starting artifact). Conclusion: ship `MIGRATING.md` first; StartOS marketplace bump is downstream of having migration docs that operators trust.

## See also

- [[drop-in-surface-inventory]] — what the runbook actually has to verify
- [[dual-protocol-downstream]] — the SV1+SV2 design that makes Phase 0 decisions safe
- [[drop-in-distribution]] — the channels the swap actually flows through
