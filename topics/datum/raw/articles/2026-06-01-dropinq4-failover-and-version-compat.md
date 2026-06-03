# Failover Behavior + DATUM Version Compatibility

**Date:** 2026-06-01
**Sub-question:** Q4 / dual-protocol drop-in (sub-questions 4 and 7)
**Source:** `OCEAN-xyz/datum_gateway` source files `datum_protocol.c`, `datum_protocol.h`,
`datum_gateway.c` on master (v0.4.1-beta).

## Failover: what happens when OCEAN is unreachable

### C gateway behavior (current, observed in source)

From `src/datum_protocol.c` — three independent timeouts trigger a session teardown:

1. **No-data timeout**:

   ```c
   if ((datum_protocol_mainloop_tsms - latest_server_msg_tsms)
       >= datum_config.datum_protocol_global_timeout_ms) {
       DLOG_WARN("No data received from server in over %d seconds...");
       break;
   }
   ```

2. **Share-acceptance timeout** (30 s hardcoded):

   ```c
   if ((datum_last_accepted_share_local_tsms - datum_last_accepted_share_tsms)
       >= 30000) {
       DLOG_WARN("No share acceptance response for > 30 seconds...");
       break;
   }
   ```

3. **Reconnect spinwait**:

   ```c
   for (i = 2000; i; --i) {
       if (datum_protocol_client_active >= 3) break;
       usleep(2500);
   }
   datum_blocktemplates_notify_othercause();
   ```

   ~5 seconds (2000 × 2500µs) waiting for the protocol thread to come back up, then forces
   a fresh job notification to all downstream miners.

### Disconnection cascade to downstream

Per the README:

> "By default, if the connection with the pool is lost and fails to reconnect, the
> Gateway will disconnect all stratum clients" — allowing the miner's failover-pool config
> to take over.

This is a deliberate safety property: a stranded gateway should not let miners keep
hashing into the void. The disconnection cascade pushes miners onto their configured
backup pool. Operators rely on this. The Rust drop-in MUST replicate it.

### Behavior the Rust drop-in must match

| Behavior | Source mechanism | Rust drop-in requirement |
|----------|-----------------|--------------------------|
| 30s share-ack timeout | hardcoded in `datum_protocol.c` | Hardcode 30s, OR expose as `datum.share_ack_timeout_ms` (default 30000) |
| Configurable no-data timeout | `datum_protocol_global_timeout_ms` | Honor same config field name & default |
| ~5s reconnect spinwait | hardcoded | Match approximate magnitude; doesn't have to be exact |
| Force-notify on reconnect | `datum_blocktemplates_notify_othercause()` | Fan SV2 NewMiningJob + SV1 mining.notify out on reconnect |
| Disconnect-all-clients on prolonged outage | "Disconnect stratum clients" path | **Critical**: must close BOTH SV1 and SV2 listener-side sockets so miners trigger their failover |

The disconnect-all behavior is especially important on the SV2 side. SV2 does not have a
direct equivalent to "TCP close = pool down" because of channel state. The Rust drop-in
should send `CloseChannel` (mining_sv2) and then close the TCP connection so the SV2
miner's pool-failover logic activates correctly.

## Version compatibility with DATUM Prime

### What the C gateway sends in handshake

From `src/datum_protocol.c`:

```c
strncpy((char *)&hello_msg[i], DATUM_PROTOCOL_VERSION, 127);
```

`DATUM_PROTOCOL_VERSION` is defined in `src/datum_protocol.h` as the literal string:

```c
"v0.4.1-beta"
```

Plus the build commit hash and an optional build-tag string. The hello message is
`proto_cmd = 1` and includes:

- Client's Ed25519 signing pubkey
- Client's X25519 encryption pubkey
- Session subkeys
- Version string (above)

The server responds with `proto_cmd = 2` (handshake response) echoing client keys and
adding pool session keys + MOTD.

### Implications for the Rust drop-in

OCEAN's DATUM Prime accepts whatever version string the gateway sends — it does NOT
appear to enforce a strict version match (no version-mismatch rejection code path is
documented in the open gateway source, which we'd see in the response handler if
present). The version string is descriptive (logged/MOTD'd, not enforced).

Therefore the Rust drop-in can:

1. Send a string like `"sri-datum-rust v0.1.0 (compat: v0.4.1-beta)"` and OCEAN's Prime
   should accept it.
2. To be maximally safe in v1.0: **send the literal string** `"v0.4.1-beta"` plus the
   build hash, mimicking the C gateway exactly. If Prime later adds version-based
   feature gating, the drop-in inherits whatever feature set v0.4.1-beta gets.

But there's a real risk:

> **The DATUM protocol spec is "evolving, subject to change, and will be published
> elsewhere"** (from `doc/datum_gateway_config.md` per README).

i.e., OCEAN reserves the right to change the wire protocol. A Rust drop-in that pinned
itself to v0.4.1-beta semantics could break if OCEAN ships a v0.5 Prime that requires new
client behavior. **Mitigation: track the C gateway's `master` branch with high cadence.
Treat `datum_protocol.c` as the spec.**

### What's NOT documented (real risk)

The C gateway's handshake structure (`T_DATUM_PROTOCOL_HEADER`, the 5 protocol commands,
the libsodium-based encryption) is documented only in source. There is no published
`DATUM-protocol.md`. The Rust drop-in author must:

1. Treat `datum_protocol.c` and `datum_protocol.h` as the canonical spec.
2. Build a wire-format conformance test suite (capture C-gateway → Prime traffic in a
   test harness, replay against the Rust drop-in).
3. Avoid assuming any wire-format invariants that aren't byte-tested.

This is the single biggest engineering risk of the whole project: it is reverse-
engineering an evolving binary protocol from source. A protocol break by OCEAN at any
point invalidates the drop-in until updated.

## Risk matrix

| Risk | Likelihood | Severity | Mitigation |
|------|-----------|----------|------------|
| OCEAN ships DATUM v0.5 with breaking wire change | Med (it IS beta) | High | CI against C-gateway capture vectors; same-day update cadence; pin Prime version with operator opt-in upgrade |
| Disconnect-all behavior on outage not faithfully replicated → miners hash into the void | Low | High | Explicit conformance test: kill upstream, assert downstream sockets close within ~35 s |
| Version-string format unaccepted by Prime | Low | Med | Match the C string format byte-for-byte in v1.0 |
| Reconnect spinwait too aggressive → DDoS Prime | Very Low | Low | Match C timing; add jitter |
| SV2 channel-state outlives upstream disconnect → SV2 miners not failed over | Med | High | Emit `CloseChannel` + TCP close on outage (see SV2-failover note above) |
| Hardcoded 30s share-ack timeout differs across C versions | Low | Low | Make configurable but default 30000 |

## Switch-day operator runbook (skeleton — see consolidated runbook in next article)

Failover-relevant pre-checks for the operator BEFORE starting the Rust binary:

1. Confirm miners' failover pool config is set (so if the new binary has a bug and
   disconnect-cascade fires, miners go somewhere safe, not idle).
2. Have C binary on disk at known path for fast revert.
3. Watch logs for "No data received from server" warnings during the first hour — that's
   the canary for upstream-DATUM compatibility issues.
