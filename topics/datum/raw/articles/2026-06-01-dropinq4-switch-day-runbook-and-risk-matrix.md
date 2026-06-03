# Switch-Day Operator Runbook + Consolidated Risk Matrix

**Date:** 2026-06-01
**Sub-question:** Q4 / dual-protocol drop-in (consolidated deliverable)
**Synthesizes:** the four other Q4 articles in this raw/articles set.

## Consolidated risk matrix

Risks are scored on the dual-protocol Rust drop-in replacing OCEAN's `datum_gateway` C
binary.

| # | Risk | Likelihood | Severity | Mitigation |
|---|------|-----------|----------|------------|
| 1 | SV1-only operator population larger than expected → SV2-only drop-in bricks fleet | High (estimated 75–90% SV1) | Catastrophic | **Mandatory: ship dual-protocol in v1.0.** SV2-only is not an option |
| 2 | OCEAN ships DATUM Prime wire-protocol break | Med (beta status) | High | Track C-gateway master; conformance capture/replay tests; version-pin with explicit upgrade |
| 3 | Disconnect-all-on-outage not replicated → miners hash into the void | Low | High | Replicate C behavior; SV2 must emit `CloseChannel` + TCP close on upstream loss; integration test |
| 4 | TIDES attribution discontinuity on switch | **None** (confirmed) | — | Attribution keyed on Bitcoin payout address (config field `mining.pool_address`), not on gateway identity |
| 5 | Keypair rollback statefile incompatibility | **None** (confirmed) | — | Keys are ephemeral; no on-disk keyfile to migrate |
| 6 | Config schema drift breaks operator's `datum_gateway_config.json` | Med | High (won't start) | Schema-compatible parser; `--check-config` flag; CI against real OCEAN configs; honor unknown fields with warnings, not errors |
| 7 | Log-format divergence breaks operator dashboards | Med | Low (cosmetic) | Match C log shapes by default; offer a `logger.format_compat` flag |
| 8 | CLI flag mismatch (`-c`, `--help`, `--version`) | Low | High (operator scripts break) | Mirror argp interface byte-for-byte for the common flags |
| 9 | Foreground vs daemon mode mismatch with operator's systemd unit | Low | Med | Run foreground (Type=simple); document the unit file template |
| 10 | SV2 channel state HOL-blocks SV1 share submission, or vice versa | Med | Med | Per-share mpsc with backpressure to a single DATUM upstream consumer; integration test under load |
| 11 | Coinbase-output divergence between SV1 `mining.notify` and SV2 `NewExtendedMiningJob` | Low | Catastrophic (operator pays self instead of OCEAN) | Single source-of-truth `available_coinbase_outputs[]` array; golden-vector tests for both encoders |
| 12 | Single-port sniffing complexity introduces protocol-confusion bugs | N/A (recommendation: avoid) | — | Recommend dual-port (23334 SV1, 23335 SV2). Keep sniffing as opt-in fallback only |
| 13 | StartOS / start9 packaging breaks (datum-gateway-startos) | Med | Med | Coordinate with start9 maintainers before swap; provide drop-in package update; test in start9 dev env |
| 14 | Rust drop-in panics under unanticipated input → crash loop | Med | High | Aggressive fuzzing of SV1/SV2 decoders + DATUM upstream parser; supervisor wraps process anyway |
| 15 | Performance regression vs C (latency, memory) under load | Low | Med | Benchmark vs C gateway with simulated 1k-miner load; enforce SLA in CI |

Risks 4 and 5 (TIDES discontinuity, keypair rollback) were the two highest-prior fears
going in. Both are eliminated by the source-code reading in the keypair article. This is a
genuine de-risking finding.

## Switch-day operator runbook (skeleton)

### T-7 days: pre-flight

1. Verify operator's miners have **failover pool configured** in their stratum URL list.
   Without failover, a Rust-binary crash strands hashrate. With failover, miners safely
   redirect to (e.g., a public OCEAN endpoint, or a backup pool of operator's choice).
2. Check that operator's `datum_gateway_config.json` is a known good version (operator
   knows which fields they have set). Save a copy off-machine.
3. Check that operator's bitcoind RPC credentials (`bitcoind.rpcuser` / `rpcpassword` /
   `rpcurl`) work — the new binary will read the same credentials.
4. Snapshot the current C binary at `/usr/local/bin/datum_gateway.c-backup` so revert is
   a single `mv`.
5. Note current OCEAN dashboard hashrate / share-rate / TIDES window position. Take a
   screenshot to compare post-switch.

### T-1 day: dry-run

1. On a non-production machine, run the Rust drop-in with the production config (with
   `pool_address` swapped to a test address). Confirm: it parses the config, connects to
   bitcoind, attempts handshake to DATUM Prime, opens stratum listeners on the configured
   ports.
2. Run `--check-config <production-config>` against the real production config (no
   network). Confirm: zero errors, only INFO-level "unknown field" warnings.
3. Pre-stage the new binary at `/usr/local/bin/datum_gateway.rust-staged`.

### T-0: switch

1. `systemctl stop datum-gateway` — miners disconnect, retry against failover pool.
2. `mv /usr/local/bin/datum_gateway /usr/local/bin/datum_gateway.c-backup`
   `mv /usr/local/bin/datum_gateway.rust-staged /usr/local/bin/datum_gateway`
3. `systemctl start datum-gateway` — Rust binary reads the same config, connects to
   DATUM Prime, opens both SV1 (port 23334) and SV2 (port 23335 if enabled) listeners.
4. Watch logs for the first 5 minutes:
   - INFO: "DATUM upstream connected, pool MOTD: ..."
   - INFO: "Stratum V1 listener bound on 0.0.0.0:23334"
   - INFO: "Stratum V2 listener bound on 0.0.0.0:23335" (if enabled)
   - INFO: "Miner subscribed: <ua-string>" (one per reconnect)
   - INFO: "Share accepted from <username>"
5. Watch OCEAN dashboard for 15–30 minutes:
   - Hashrate returns to within ~5% of pre-switch level.
   - TIDES window position unchanged or normally advancing.
   - No "user not found" or attribution-anomaly alerts.

### Rollback trigger

Revert if any of:

- Logs show repeated "No data received from server" or "No share acceptance response for
  > 30 seconds" — DATUM Prime not accepting the connection.
- Hashrate stays below 80% of pre-switch level after 15 minutes.
- TIDES dashboard shows unrecognized user / attribution lookup failure.
- Any panic / coredump from the Rust binary in the first 30 minutes.

### Rollback procedure

1. `systemctl stop datum-gateway`
2. `mv /usr/local/bin/datum_gateway /usr/local/bin/datum_gateway.rust-failed`
   `mv /usr/local/bin/datum_gateway.c-backup /usr/local/bin/datum_gateway`
3. `systemctl start datum-gateway` — C binary resumes, miners reconnect, TIDES continues.
4. **No statefile or keypair file to restore** (confirmed: the gateway has none).
5. File a bug against the Rust drop-in with the captured logs.

### T+7 days: confidence-build (if no rollback needed)

1. Enable SV2 listener (`stratum_v2.enabled = true`) on port 23335 if not yet enabled.
2. Configure ONE test miner running BraiinsOS+ to point at port 23335. Verify shares
   land on the same TIDES user as the SV1 miners.
3. Communicate to other operators via OCEAN forum / discord: "drop-in is stable, SV2
   path tested."

## What this runbook deliberately does NOT include

- Migrating share data: not needed (no share data lives on the gateway; OCEAN is
  authoritative).
- Migrating keypair: not needed (no keypair file).
- Updating systemd unit file: not needed (Type=simple, same `-c` flag).
- Updating firewall rules: not needed for SV1; only needed if operator opts into SV2 on a
  new port.
- Notifying every miner operator pre-switch: not needed for SV1 path; miners reconnect
  automatically. ONLY needed if operator changes ports or address.

The runbook's brevity is itself the validation that the drop-in is well-scoped: a true
drop-in should be a binary swap with no surrounding state migration.

## Single biggest unmitigated risk

**OCEAN's DATUM protocol is undocumented and beta** (their wording). A v0.5 Prime change
could break the Rust drop-in even after a clean v1.0 ship. Operating mitigation:

- The drop-in must auto-detect a protocol version mismatch (e.g., handshake response
  field it doesn't recognize) and **refuse to attribute shares** rather than silently
  misattribute. Better to fail loud than fail wrong.
- Establish a relationship with OCEAN engineering BEFORE shipping: agree on a notification
  channel for protocol changes. The C gateway is OCEAN's reference implementation and
  shipping a third-party reverse-engineered drop-in without coordination invites
  uncoordinated breakage.

This is a coordination risk, not a code risk. It is the load-bearing project risk.
