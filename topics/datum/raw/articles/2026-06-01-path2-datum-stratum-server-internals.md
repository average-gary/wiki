---
title: "DATUM Gateway src/datum_stratum.c — SV1 Server Internals"
source_url: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/src/datum_stratum.c
source_type: source-file
upstream: OCEAN-xyz/datum_gateway
branch: master
date_fetched: 2026-06-01
ingested_by: path2
research_path: path2-sv1-asic-leg
quality_score: 9
tags: [datum, datum-gateway, stratum-v1, mining-server, c-source, replacement-target]
related_concepts: [sv2-downstream-replacement, mining-channel-server, channels-sv2]
---

# datum_stratum.c — the SV1-to-ASIC leg, in code

Single largest file in the gateway and the **module an SV2-downstream variant would
replace wholesale**. Implements: connection lifecycle, JSON-RPC method dispatch
(`mining.subscribe` / `authorize` / `submit` / `configure`), job broadcast
(`mining.notify` / `set_difficulty`), local share validation, vardiff control loop,
and block-discovery escape hatch. Not a thin wrapper — owns most of the
miner-facing semantics.

## Connection lifecycle

- `datum_stratum_v1_socket_thread_client_new()` (~lines 365-385): allocates a
  `T_DATUM_MINER_DATA`, assigns connection ID, records timestamp.
- `datum_stratum_v1_socket_thread_client_closed()` (~lines 350-362): teardown
  with descriptive reason string.
- `datum_stratum_v1_shutdown_all()` (~lines 282-300): graceful drain via
  `empty_request` flag broadcast to all worker threads.

## Method dispatch (lines 1596-1618 — switch statement)

| Method | Handler | Purpose |
|---|---|---|
| `mining.subscribe` | `client_mining_subscribe()` (1496-1556) | session ID alloc, miner fingerprint for coinbase variant, send extranonce1/2 + initial diff |
| `mining.authorize` | `client_mining_authorize()` (1354-1373) | store username, ack — no crypto check |
| `mining.submit` | `client_mining_submit()` (1033-1297) | 80-byte header reconstruct, dSHA-256, PoW + target + stale + dupe checks, then enqueue upstream |
| `mining.configure` | inline | version-rolling negotiation |
| outbound `mining.notify` | `send_mining_notify()` (1375-1495) | 'Q' prefix = quickdiff job, 'N' prefix = empty block |
| outbound `mining.set_difficulty` | `send_mining_set_difficulty()` (1533-1541) | sent before next notify when vardiff steps |

## Local share validation pipeline (in `client_mining_submit`)

Sequential, all checks must pass before upstream forward:

1. **PoW H-not-zero** (1228-1235): top 4 bytes of dSHA-256 must be 0
2. **Target** (1270-1288): hash ≤ per-job target (or quickdiff target if active)
3. **Stale prevblock** (1251-1257): reject if prior block invalidated
4. **ntime bounds** (1259-1267): `mintime ≤ ntime ≤ curtime + 7200s`
5. **Dupe** (1290-1295): `datum_stratum_check_for_dupe()` — see datum_stratum_dupes
6. **Stale job age** (1280-1286): reject if job timestamp > stale window

Notable: **block-beats-target** path goes through `assembleBlockAndSubmit()`
(1715-1824) → submitblock to bitcoind FIRST, then upstream notification via
`datum_protocol_pow_submit()`. Local-block-first is a load-bearing semantic that
an SV2 variant must preserve.

## Threading model snapshot

- **Hand-rolled pthread pool** with **fixed pre-allocation** (no heap fragmentation
  by design — quote line 405: *"We'll also never give up this memory, so no
  heap fragmentation risk."*)
- `T_DATUM_SOCKET_APP::datum_threads[max_threads]` (default 8), each runs
  `datum_stratum_v1_socket_thread_loop()` (629-815)
- **Thread-per-N-clients**, not per-connection: `max_clients_per_thread` default
  128, design ceiling at line 1006 documents 1024 threads × 4M clients/thread
- Socket I/O is via **epoll** (not libevent) — see datum_sockets.c findings
- Job-broadcast pacing: thread loop processes job updates and times
  `mining.notify` delivery across the work interval

## Extranonce1 layout

`get_new_session_id()` (~999-1015):

```
extranonce1 = (thread_id << 22 | client_id) ^ 0xB10CF00D
```

- 22 bits client (~4M per thread)
- 10 bits thread (~1024)
- XOR mask = `0xB10CF00D`

Trade-off explicitly called out (lines 999-1005): *"Downside ... it prevents
stratum v1 resume."* The miner-supplied **extranonce2 is 8 bytes** (16 hex);
combined into coinbase at line 1147. No allocation registry — collision
avoidance is solely the dupe filter's composite key.

## Job state machine (5 states, lines 1632-1722)

| State | Meaning |
|---|---|
| 1 | empty work, full to follow |
| 2 | empty+ (full on coinbaser-ready signal) |
| 3 | full, priority blast (no coinbase wait) |
| 4 | full, priority after coinbase ready |
| 5 | full, normal paced delivery |

`stratum_job_coinbaser_ready()` (591-609) gates 2/4 with a 5-second timeout
fallback.

## Replacement notes for SV2-downstream

A `channels-sv2`-backed mining-channel server replaces:

- **All five method handlers** — SV2 has `OpenStandardMiningChannel`,
  `OpenExtendedMiningChannel`, `SubmitSharesStandard/Extended`,
  `NewMiningJob`, `SetTarget`. Different framing (binary, not JSON-RPC),
  different identity model (channel IDs, not session IDs).
- **Vardiff loop** — SV2 push-based `SetTarget` replaces SV1 reactive
  `set_difficulty`; control loop math may largely survive.
- **Extranonce derivation** — SV2 extranonce_prefix per channel (extended)
  or implicit (standard). `0xB10CF00D` XOR + 22/10 split is gone.
- **Dupe filter composite key** — keep, but key on
  `(channel_id, sequence_number, extranonce, ntime, version)`.
- **Local share validation** — keep wholesale; pre-upstream PoW + target +
  stale + ntime checks are protocol-agnostic and a load-bearing trust
  boundary.
- **Block-discovery escape hatch** — keep `assembleBlockAndSubmit`
  unchanged; it's downstream-of-validation.

## Justification

This is THE file an SV2-downstream variant replaces. Every concrete number
above (line ranges, defaults, layouts) is what the replacement must
account for. Highest-priority artifact in the entire research path.
