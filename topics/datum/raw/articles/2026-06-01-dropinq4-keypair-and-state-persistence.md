# DATUM Gateway: Keypair, State Persistence, and Rollback Surface

**Date:** 2026-06-01
**Sub-question:** Q4 / risks of dual-protocol drop-in
**Source repo:** https://github.com/OCEAN-xyz/datum_gateway (master, v0.4.1-beta as of 2026-01-06)

## TL;DR — the rollback surface is much smaller than feared

Reading `src/datum_protocol.c`, `src/datum_protocol.h`, `src/datum_gateway.c`, and the example
config (`doc/example_datum_gateway_config.json`), DATUM Gateway has **NO persistent on-disk
state required for share attribution or pool identity**. The keypair is generated fresh per
session via libsodium (`crypto_sign_keypair`, `crypto_box_keypair`) and is not written to
disk. Pool identity is just the `mining.pool_address` field in the JSON config (a Bitcoin
payout address). This means:

- A drop-in replacement does **not** need to read or write a keypair file.
- TIDES attribution does **not** break across binary swaps as long as the new binary keeps
  the same `mining.pool_address` in its config (which the operator already has on disk).
- The only on-disk state the C gateway uses are: (a) the JSON config file itself, and
  (b) optional rotating logs at `logger.log_file` (default `/var/log/datum.log`).

This dramatically de-risks switch day. The Rust drop-in is responsible only for protocol
behavior and binary compatibility with existing CLI flags / config schema — there is no
persistent statefile to corrupt or fail to migrate.

## Evidence: keypair generation

From `src/datum_protocol.c`:

```c
int datum_encrypt_generate_keys(DATUM_ENC_KEYS *keys) {
    crypto_sign_keypair(keys->pk_ed25519, keys->sk_ed25519);
    crypto_box_keypair(keys->pk_x25519, keys->sk_x25519);
}
```

No `fopen`, no `read`, no path constant for a keyfile is referenced anywhere in
`datum_protocol.c`. Keys are ephemeral per process lifetime. The pool's pubkey is the only
long-lived crypto identity, and it is supplied via the config field:

```c
if (datum_pubkey_to_struct(datum_config.datum_pool_pubkey, &pool_keys) != 0)
```

128 hex characters: 32-byte Ed25519 + 32-byte X25519, concatenated.

## Evidence: TIDES attribution is by Bitcoin payout address, not gateway pubkey

From `src/datum_protocol.c` username construction:

```c
if (((!datum_config.datum_pool_pass_full_users)
    && (!datum_config.datum_pool_pass_workers))
    || pow->username[0] == '\0') {
    snprintf(username, 385, "%s", datum_config.mining_pool_address);
} else if (datum_config.datum_pool_pass_full_users && pow->username[0] != '.') {
    snprintf(username, 385, "%s", pow->username);
} else {
    snprintf(username, 385, "%s%s%s",
             datum_config.mining_pool_address, ".", pow->username);
}
```

Shares are submitted upstream tagged with the configured Bitcoin address (or
`<address>.<worker>`). OCEAN's TIDES docs confirm: "Rewards are calculated per user, not
per worker. The sum of all work submitted by a user's workers is what is used for reward
calculations" — and that "user" is the Bitcoin payout address, not a per-gateway crypto
identity. The session keypair is for transport encryption only, not for attribution.

## Evidence: no PID file, no systemd-notify, no daemonization

From `src/datum_gateway.c`:

- `main()` reads the config file (default `datum_gateway_config.json` cwd, override `-c`).
- Signal handlers: `SIGUSR1` (template-notify trigger), `SIGPIPE` (ignored). **No SIGTERM,
  SIGHUP, no PID file, no `sd_notify`.**
- Process runs in the foreground; the `Dockerfile` and OCEAN-supplied `datum-gateway-startos`
  package are responsible for supervision (start9 packaging wraps the foreground process).

Implication: a Rust drop-in must also run in the foreground and must accept the same
`-c <path>` flag at minimum. Any operator-side systemd unit will treat both binaries
identically (Type=simple), so binary swap is a `systemctl stop` + replace + `systemctl
start` with no statefile concerns.

## Config schema the Rust drop-in must accept verbatim

From `doc/example_datum_gateway_config.json`:

```json
{
  "bitcoind":  { "rpcuser", "rpcpassword", "rpcurl", "notify_fallback" },
  "stratum":   { "listen_port" /* 23334 */ },
  "mining":    { "pool_address", "coinbase_tag_primary", "coinbase_tag_secondary" },
  "api":       { "admin_password", "listen_port" /* 7152 */, "modify_conf" },
  "logger":    { "log_to_console", "log_to_file", "log_file",
                 "log_rotate_daily", "log_level_console", "log_level_file" },
  "datum":     { "pool_pass_workers", "pool_pass_full_users", "pooled_mining_only" }
}
```

Notably absent and confirmed not in the source: any field for SV2 listen port, any field
for keypair file, any field for systemd / PID. The Rust drop-in must extend this schema
(e.g., add `stratum_v2: { listen_port: 23335 }`) but ALL existing fields must continue to
work or operators will reject the drop-in.

## Rollback story is trivial

If the Rust drop-in misbehaves and the operator reverts to the C binary:

1. `systemctl stop` the Rust process. Connections drop. Miners reconnect to whatever
   failover the miner has configured (or sit retrying).
2. Restore the old C binary on PATH.
3. `systemctl start`. The C binary reads the same `datum_gateway_config.json` it always
   read. Generates a fresh transport keypair (lost nothing, since keys were ephemeral).
   Reconnects to OCEAN. Reopens stratum listener on port 23334.
4. Miners reconnect, share submission resumes, TIDES attribution continues seamlessly
   because `mining.pool_address` is unchanged.

There is no statefile incompatibility because there is no statefile.

## Caveat: log file format

The one place a Rust drop-in could break a downstream tool is the log file format.
Operators may have grep / journald parsing pipelines keyed to specific log line formats
(e.g., "share accepted from %s diff %f"). The Rust drop-in should match the C log line
shapes by default and offer a `logger.format_compat: true` flag if it diverges.

## Ranked rollback risks (from this source)

| Risk | Likelihood | Severity | Mitigation |
|------|-----------|----------|------------|
| Operator's config has fields the Rust drop-in fails to parse | Med | High (won't start) | Schema-compatible parser; `--check-config` flag; CI test against real OCEAN configs |
| Log format divergence breaks operator dashboards | Med | Low (cosmetic) | Match C log line shapes; offer `format_compat` flag |
| `-c <path>` CLI flag absent | Low | High | Mirror argp interface |
| Foreground vs daemon mode mismatch with systemd unit | Low | Med | Run foreground (same as C); document `Type=simple` |
| TIDES attribution discontinuity | **None** | — | Confirmed: keyed on Bitcoin address, not gateway crypto identity |
| Keypair file format incompatibility | **None** | — | Confirmed: no keypair file exists |
