---
title: "Blitzpool (server + rental proxy): source read, with emphasis on how shares are stored"
source: "https://github.com/warioishere/blitzpool-server-rust"
related_sources:
  - "https://github.com/warioishere/blitzpool-rental-proxy"
type: repos
ingested: 2026-09-23
tags: [blitzpool, rust, tokio, postgres, redis, redis-streams, lua, pplns, group-solo, non-custodial, coinbase-payout, time-bucketed-aggregates, fillfactor, hot-updates, vardiff, silence-easing, sv1, sv2, tdp-ipc, rental-proxy, sqlite, upstream-swap, source-read]
summary: "Blitzpool is a Rust port of public-pool (its Postgres schema is public-pool's TypeORM schema, carried over), grown into a split deployment. A 'front' (core) process holds the unified SV1+SV2 listeners and gets templates from Bitcoin Core over the SV2 Template Distribution Protocol via Cap'n Proto IPC (no GBT, no ZMQ). It publishes every accepted share as one JSON entry onto a Redis stream (shares:accepted, MAXLEN ~1,000,000). A separate 'satellite' process consumes that stream at-least-once. There is NO durable per-share row. Payout state lives in Redis: an atomic Lua script folds each share into per-address count buckets of 10,000 shares, with a share_id dedup zset, so storage is O(buckets x miners). Statistics go to Postgres as increment-semantic UNNEST bulk upserts every 60 s into 10-minute slot rows, which are pruned after 14 days. Lifetime per-address and per-worker cumulative totals (no time dimension) are never pruned. Writes are off the share hot path in both routes: a bounded mpsc of 8,192 that drops on overflow, and an in-memory accumulator using a drain/confirm contract. Miner duplicate-share detection is a per-connection in-memory HashSet, cleared on clean_jobs (SV1) or SetNewPrevHash (SV2). The rental proxy uses SQLite, stores no per-share data, and has a working live upstream-swap mechanism (SV1 set_extranonce; SV2 SetExtranoncePrefix with channel-id remapping). However, the production order paths deliberately force a reconnect instead."
commits_read:
  - "blitzpool-server-rust: c295ae0 (origin/main, 2026-09-18, workspace version 2.3.5)"
  - "blitzpool-rental-proxy: f25a87d (upstream/master, 2026-09-16, crate version 0.3.8)"
skipped:
  - "Feature-branch checkouts blitzpool-lottery-pplns (finder-bonus-ppm @ 259668a) and blitzpool-server-rust-xpubs (feat/xpub-identity @ 338c8d1). Their HEADs are not contained in any remote branch (`git branch -r --contains HEAD` is empty), so they are unpublished and were not read."
credibility: high
credibility_score: 5
credibility_rationale: "Direct source read at named upstream commits. SQL is transcribed from db/schema.sql and the sqlx migrations. Behavioural claims are cited to file:line. The proxy and payout sections come from delegated sub-reads of the same commits and carry the same citation standard."
confidence: high
confidence_notes: "High for the schema, write path, retention, dedup, listeners, template source and proxy switching; all were read. Medium for payout-math details where noted [I]. Nothing was run: no throughput figures come from execution. The prod numbers quoted in migration 0015 are the authors' own measurements, recorded in a comment."
research_round: 2
research_agent: "C1 (source read)"
extraction_note: "[R] means read in code, [I] means inferred. Server paths are relative to the blitzpool-server-rust repo root. Proxy paths are relative to the proxy repo root. The server's Postgres schema is a pg_dump snapshot (db/schema.sql) plus incremental sqlx migrations (crates/bp-db/migrations/). Where the two differ, the migration is the newer state."
---

# Blitzpool: source read

**Lineage.** This is a Rust port of the TypeScript public-pool. The Postgres tables keep public-pool's
TypeORM names and camelCase columns (`client_statistics_entity`, `"clientName"`, `"sessionId"`).
Comments throughout refer to "the TS pool" (e.g. migration 0003). Compare the public-pool section of
`2026-09-22-pool-persistence-schemas-source-read.md`: the 10-minute slot bucket survived the port.
Retention went from 24 h to 14 days, and SQLite became Postgres 18 plus Redis. License AGPL-3.0-or-later
(`Cargo.toml`).

## 1. Server architecture

**Workspace.** 35 library crates plus one binary, `bin/blitzpool` (`Cargo.toml` members list). Main crates:
`bp-stratum-v1`, `bp-stratum-v2` (includes a JDP server/client), `bp-template-distribution`, `bp-vardiff`,
`bp-share`, `bp-share-hook`, `bp-share-stream`, `bp-stats`, `bp-share-stats-sink`, `bp-session-persistence`,
`bp-pplns(-engine)`, `bp-group-solo-engine`, `bp-blockparty(-engine)`, `bp-mining-job`,
`bp-coinbase-snapshot`, `bp-db`, `bp-api`, `bp-notifications`, `bp-regtest-harness`.

**Runtime.** tokio multi-thread (`tokio = { features = ["full"] }`). jemalloc on Linux, adopted because
"the TS port hit unbounded RSS growth on glibc" (`Cargo.toml` workspace deps comment).

**Process roles** [R] (`crates/bp-config/src/lib.rs:150-190`). One binary runs one or more roles:
`front`, `api`, `payout`, `stats`, `notify`.
- **front** ("core"): Stratum listeners, share producer, block submit, JDP. It *produces* Redis streams
  (accepted, rejected, block-found, device-status).
- Any non-front process is a **satellite** and *consumes* those streams.
- `front` and `payout` in one process is refused at boot with exit code 2 (`bin/blitzpool/src/main.rs:314-330`).
  The reason given: the front always produces to the stream, so a combined process would produce shares
  that no one consumes.
- Rationale (`bp-config/src/lib.rs:168-170`): "the back-office can redeploy/restart without dropping miners".

**Connection accept** [R] (`bin/blitzpool/src/stratum.rs`).
- One `TcpListener` per configured port (solo, solo-high-diff, pplns, pplns-high-diff). Each port serves
  **both SV1 and SV2** (`:1-35`, bind at `:240-248`).
- `accept_loop` spawns **one tokio task per accepted socket** (`:291-313`).
- `dispatch_connection` then:
  - sets TCP_NODELAY (to avoid the ~40 ms Nagle/delayed-ACK stall);
  - sets TCP keepalive at 60 s idle, 20 s interval, 4 probes;
  - **peeks one byte** under a 30 s timeout, classified by `bp_protocol_detect::detect`: `{`/whitespace → SV1,
    HTTP, TLS, else SV2 (`:320-398`).
- SV1 is handed to `StratumV1Server::accept_connection`, which `tokio::spawn`s `run_connection`
  (`crates/bp-stratum-v1/src/server.rs:352-406`). SV2 goes through a Noise XK handshake
  (`crates/bp-stratum-v2/src/server.rs:570-585`).
- **No connection cap and no per-IP limit** were found in the accept loop. A comment at
  `bp-stratum-v2/src/server.rs:576-578` says "fail-ban lives there". [I] No fail-ban implementation exists
  in `bin/blitzpool/src/stratum*.rs` or `boot.rs` (grep for ban/banned/fail_ban is empty), so that comment
  looks stale or aspirational.

**Template source** [R]. SV2 **Template Distribution Protocol over Bitcoin Core's IPC**, Cap'n Proto on a
UNIX socket (bitcoin-core v31).
- Runs on a dedicated OS thread with its own runtime and `LocalSet`, because `capnp-rpc` is `!Send`.
- Fans out to the pool via `broadcast` (templates) and `mpsc` (solutions) (`crates/bp-template-distribution/src/lib.rs:1-35`).
- **No `getblocktemplate` and no ZMQ**: "ZMQ block notifications — replaced by TDP `SetNewPrevHash`"
  (`crates/bp-bitcoin/src/lib.rs:9-13`).
- JSON-RPC is kept only for metadata and one exception: `submitblock` for JDP-declared jobs, which the
  node has no `template_id` for (`:15-23`).
- Each SV1 port runs a translator task that turns templates into `mining.notify` (`bp-stratum-v1/src/server.rs:280-298`).

**Vardiff** [R]. One engine, `crates/bp-vardiff` (std-only), shared by SV1, SV2 Standard/Extended and JD
channels (`lib.rs:1-26`).
- **Arrival side:** the rate estimate is updated on each accepted share (`update_hash_rate`).
- **Timer side:** each connection's select-loop has its own `tokio::time::interval` tick, 60 s default
  `difficulty_check_interval_ms` (`bp-stratum-v1/src/server.rs:618-619`, `config.rs:46,144`). The tick polls
  `suggested_difficulty`.
- **Answer to "timer or arrival?": both, but by default a silent session does not come down.**
  Historically the estimator's window ended at the last share, so a session that went quiet "kept being
  evaluated against a frozen window" (`lib.rs:36-44`).
- The fix is opt-in **silence easing**:
  - The window ends at *now*, so silence lowers the estimate.
  - Descent is bounded at 16x below the pre-silence rate; any up-step is capped at 8x.
  - Rejected shares count as "alive".
  - Before the first share there is a Poisson upper-bound descent, `D = k·τ / ∫dt/D(t)` with k = 3,
    floored at 256x below the opening difficulty (`lib.rs:34-94`, constants `:162-190`).
- Easing is **off by default**: `vardiff_silence_easing_enabled: bool` under `#[serde(default)]` ("Off by
  default — switch it on deliberately (staging first)", `bp-config/src/lib.rs:505-512`). The example config
  also sets it to `false` (`blitzpool.example.toml:200`).
- The timer tick does nothing before the handshake completes or while no template exists, so a template
  outage can't walk every session to the floor (`bp-stratum-v1/src/client.rs:760-776`).
- A ckpool-style race clamp credits in-flight shares at `min(old, new)` difficulty across a ratchet
  (`bp-vardiff/src/lib.rs:27-31`).

## 2. Share persistence (the main question)

**Stores:** **PostgreSQL 18** (sqlx, compile-time-checked queries with an offline cache, `db/README.md`)
**plus Redis** (streams, PPLNS and group-solo window state, live session hashes). There are no
per-share rows in Postgres.

### 2a. Hot path → Redis stream (one entry per share, capped, not durable history)

The front's accepted-share sink is a `ProducingSink` (`bin/blitzpool/src/engines.rs:145-190, 742-750`).
It stamps `share_id`, `mode` and `group_id`, then offers the share to a `BufferedPublisher`
(`crates/bp-share-stream/src/lib.rs:160-240`):

- A bounded `mpsc::channel(PUBLISH_BUFFER = 8192)` feeds a drain task that owns the `XADD`.
  The stratum loop does only `try_send`: "the loop already acked the share in ~40µs" (`:193-197`).
- **On overflow the share is dropped** ("best-effort — the miner already got its accept"), with a counter
  logged at power-of-two crossings (`:164-168, 226-240`).
- [R] On publish error the drain task only `warn!`s and continues (`:208-214`); there is no retry.
  [I] So a Redis outage longer than the buffer loses accounting for those shares.
- Stream `shares:accepted`, `XADD … MAXLEN ~ 1_000_000` (`:47-57, 147-156`).
  The comment calls a breach "a fairness delle (the coinbase already paid the window), not fund loss".
- Entry = one JSON field `d` holding `SharedAcceptedShareOwned` (`crates/bp-share-hook/src/lib.rs:216-235`).
  Fields: `address, worker, session_id, effective_difficulty, submission_difficulty, user_agent,
  is_block_candidate, hash_rate, channel_count, ts_ms, share_id, mode, group_id`.
  - **There is no nonce, header, job id or hash**, so the record cannot be re-verified. It is an
    accounting event, not a proof.
- `share_id` = `<core_epoch>:<counter>` (e.g. `"ep7:42"`, `bp-share-hook/src/lib.rs:486-510`). `core:epoch`
  is INCR'd at front boot (`engines.rs:176-180`).

**Consumer** (`bin/blitzpool/src/satellite_consumer.rs:1-30`, `crates/bp-share-stream/src/runner.rs`).
- Redis consumer groups, **at-least-once**, `block_ms` 1000 (`runner.rs:41-63`).
- At start it replays the pending (delivered-but-unacked) backlog, then tails new entries (`runner.rs:82-140`).
- Two groups:
  - **money** (PPLNS and group-solo): single ordered consumer, because window order equals consume order;
  - **stats-session**: order-insensitive.

### 2b. Payout state → Redis, aggregated per share by atomic Lua

`crates/bp-pplns-engine/src/window/mod.rs`. "Storage is O(buckets × miners), not O(shares)" (`:13-17`).

Keys (`:60-102`):
- `pplns:counter`: monotonic, never reset.
- `pplns:buckets`: index zset; score = epoch-ms of the bucket's first share.
- `pplns:bucket:<id>`: hash, address → Σdiff.
- `pplns:window:total`: float.
- `pplns:window:by-address`: the authoritative aggregate.
- `pplns:snapshot`: coinbase distribution snapshot.
- `pplns:applied`: dedup zset, share_id → counter.

`DEFAULT_BUCKET_SHARES = 10_000` (`:109`). The window is sized by **weight**, `window_factor ×
network_difficulty` (`:27-36`); the engine header gives the factor as `4 * net_diff`
(`bin/blitzpool/src/engines.rs` module doc).

The per-share write, verbatim (`window/mod.rs:292-307`):

```lua
local has_dedup = ARGV[3] ~= ''
if has_dedup and redis.call('ZSCORE', KEYS[4], ARGV[3]) then
    return 0
end
local counter = redis.call('INCR', KEYS[1])
local bucket = math.floor(counter / tonumber(ARGV[5]))
redis.call('HINCRBYFLOAT', 'pplns:bucket:' .. bucket, ARGV[2], ARGV[1])
redis.call('ZADD', KEYS[5], 'NX', ARGV[6], tostring(bucket))
redis.call('INCRBYFLOAT', KEYS[2], ARGV[1])
redis.call('HINCRBYFLOAT', KEYS[3], ARGV[2], ARGV[1])
if has_dedup then
    redis.call('ZADD', KEYS[4], counter, ARGV[3])
    redis.call('ZREMRANGEBYRANK', KEYS[4], 0, -tonumber(ARGV[4]) - 1)
end
return 1
```

- That is about 7 Redis ops per share, atomic.
- Dedup keeps the newest `DEDUP_KEEP = 100_000` ids, about 3 MB (`:139-143`). It guards **transport
  redelivery**, not miner replay.
- Trim drops whole oldest buckets, at most `MAX_DROPS_PER_TRIM = 64` per call, **on the share-append path**.
  The authors accept that the window can briefly exceed its target size (`:118-137`).
- Group-solo uses a separate, time-bucketed Redis `RoundStore` (`:19-46`); see §3.

**Durability of the Redis money state** [R]: `redis_state_backup` (migration 0003, verbatim below).
Every 10 min (`DEFAULT_INTERVAL = 600 s`) it writes one row per Redis key holding the `DUMP` payload,
keeping 48 h (`bin/blitzpool/src/redis_backup.rs:41-43`). **Restore is manual only**
(`blitzpool --restore-redis-state`), "never automatic — there is no fail-state detection".

```sql
CREATE TABLE IF NOT EXISTS redis_state_backup (
    id          bigserial PRIMARY KEY,
    captured_at bigint    NOT NULL,   -- epoch ms, one shared value per backup run
    scope       text      NOT NULL,   -- 'pplns' | 'groupsolo'
    redis_key   text      NOT NULL,
    dump        bytea     NOT NULL     -- Redis DUMP payload (RESTORE-able verbatim)
);
CREATE INDEX IF NOT EXISTS redis_state_backup_captured_at_idx
    ON redis_state_backup (captured_at DESC);
```

### 2c. Statistics → Postgres, 60 s bulk flush into 10-minute slots

`bp-stats` holds six in-memory accumulators behind `Mutex`es; `add_*` is called from the share path
(`crates/bp-stats/src/lib.rs`). `bp-share-stats-sink` flushes them to **7 tables** on a 60 s tick, with a
spot flush when the slot changes (`crates/bp-share-stats-sink/src/lib.rs:1-30`, `engine.rs:147-153`).
Config (`config.rs:38-39`): `flush_interval = 60 s`, `client_stats_batch_size = 1000` rows per statement.
`SLOT_DURATION_MS = 10 min`, keyed by slot end (`crates/bp-stats/src/constants.rs`).
`MAX_REASONABLE_DIFFICULTY = 1e15`: anything above is silently dropped as corruption.

**Write pattern** (`crates/bp-db/src/stats_writes.rs:1-26`):
- Every write is `INSERT … SELECT FROM UNNEST($1::varchar[], …) ON CONFLICT (…) DO UPDATE SET col =
  table.col + EXCLUDED.col`, i.e. increment-semantic.
- **Drain/confirm contract** (`crates/bp-stats/src/buffer.rs:151-184`): `drain` snapshots without clearing,
  and `confirm` subtracts the snapshot only after the PG write succeeds. A failed flush therefore just
  rolls into the next tick.
- Failures are isolated per flusher and per batch (`crates/bp-share-stats-sink/src/flush.rs:74-77, 236-277`).
- [I] If a statement commits in PG but the client sees an error (e.g. a timeout after commit), the next tick
  re-adds the same delta. The module doc calls totals "eventually consistent", but that case is a double
  count, not a convergence. It is tolerable for stats, and money does not flow through here.

**Per-session detail table** (baseline `db/schema.sql:187-208`, plus migration 0011):

```sql
CREATE TABLE public.client_statistics_entity (
    "deletedAt" bigint,
    "createdAt" bigint DEFAULT ((EXTRACT(epoch FROM now()) * (1000)::numeric))::bigint NOT NULL,
    "updatedAt" bigint DEFAULT ((EXTRACT(epoch FROM now()) * (1000)::numeric))::bigint NOT NULL,
    id integer NOT NULL,                          -- PK (serial)
    address character varying(62) NOT NULL,
    "clientName" character varying NOT NULL,
    "sessionId" character varying(8) NOT NULL,
    "time" bigint NOT NULL,                       -- 10-min slot end, epoch ms
    shares real NOT NULL,                         -- Σ difficulty, not a count
    "acceptedCount" integer DEFAULT 0 NOT NULL,
    "rejectedCount" integer DEFAULT 0 NOT NULL,
    "rejectedJobNotFoundCount" integer DEFAULT 0 NOT NULL,
    "rejectedJobNotFoundDiff1" real DEFAULT '0'::real NOT NULL,
    "rejectedDuplicateShareCount" integer DEFAULT 0 NOT NULL,
    "rejectedDuplicateShareDiff1" real DEFAULT '0'::real NOT NULL,
    "rejectedLowDifficultyShareCount" integer DEFAULT 0 NOT NULL,
    "rejectedLowDifficultyShareDiff1" real DEFAULT '0'::real NOT NULL,
    "rejectedVersionRollingCount" integer DEFAULT 0 NOT NULL,
    "rejectedVersionRollingDiff1" real DEFAULT '0'::real NOT NULL
);
-- migration 0011:
ALTER TABLE client_statistics_entity
  ADD COLUMN IF NOT EXISTS "rejectedStaleCount" INTEGER DEFAULT 0 NOT NULL,
  ADD COLUMN IF NOT EXISTS "rejectedStaleDiff1" REAL DEFAULT '0'::real NOT NULL;
-- migration 0015:
ALTER TABLE client_statistics_entity SET (fillfactor = 80);
-- constraints / indexes (schema.sql:1186, 1238, 1301, 1308):
--   UNIQUE (address, "clientName", "sessionId", "time")        -- the ON CONFLICT target
--   INDEX ("time");  INDEX (address, "time");
--   INDEX ("time", address, "clientName") WHERE "sessionId" <> 'AGG' AND address <> 'POOL'
```

**Other share-derived tables** (`db/schema.sql`):

| Table | Grain | Key | Pruned? |
|---|---|---|---|
| `client_statistics_entity` | address × worker × session × 10-min slot | UNIQUE(address, clientName, sessionId, time) | **14 d** |
| `client_rejected_statistics_entity` (:150) | address × 10-min slot × reason; `count real, shares real` | UNIQUE(address, time, reason) :1170 | 14 d |
| `client_difficulty_statistics_entity` (:97) | address × worker × hour slot; `maxDifficulty real` | UNIQUE(address, clientName, slotTime) :1287 | 14 d (hour-aligned) |
| `pool_mode_hashrate` (:359) | mode × slot; `diff real` | UNIQUE(mode, time) :1202 | 14 d |
| `pool_share_statistics_entity` (:426) | pool × 10-min slot; `accepted real, rejected real` (diff sums) | UNIQUE(time) :1146 | **never** [R: no DELETE outside tests] |
| `pool_rejected_statistics_entity` (:391) | pool × slot × reason | UNIQUE(time, reason) :1178 | **never** |
| `address_settings_entity` (:30) | address, lifetime; `shares double precision`, `bestDifficulty` | PK(address) | **never** |
| `worker_shares_entity` (:804) | address × worker, **lifetime cumulative**; `shares, rejectedShares double precision` | PK(address, clientName) :1138, INDEX(address) :1441 | **never** |
| `client_entity` (:133) | session birth row | PK(address, clientName, sessionId) :986 | soft-delete, hard-delete after 2 h |
| `external_shares_entity` (:234) | one row per *externally POSTed* share (public-pool heritage) | INDEX(address, time) :1322 | not seen pruned |

Retention cron (`bin/blitzpool/src/crons.rs:655-720`): runs hourly. `STATS_RETENTION = 14 days`, with the
note "UI charts only render 1d/3d/7d windows". `CLIENT_HARD_DELETE_RETENTION = 2 h` (was 24 h; the reason
given is "~71k retained rows against ~740 live ones" on 2026-08-06). Deletes use
`DELETE FROM client_statistics_entity WHERE "time" < $1` etc. (`crates/bp-db/src/client.rs:861-906`).

**Operational evidence in migrations** (authors' prod measurements, quoted in SQL comments):
- **0015** measured HOT-update ratios on 2026-09-02:
  - `client_statistics_entity`: **106.7 M updates, only 16.7 % HOT**, with 794 MB of index on 274 MB of table.
  - Narrow tables: 78–99 % HOT.
  - The stated cause is page space, not indexed columns changing: "~20 counter columns wide, a slot row is
    updated ~10× (60 s stats flush into a 10 min slot)". The fix is `fillfactor = 80`.
- **0013** moved the live per-session fields (`hashRate`, `currentDifficulty`, `channelCount`,
  `bestDifficulty`) out of Postgres into Redis `client:live:*` hashes. Those fields were "rewritten ~3×/minute
  per active session and were the load behind the payout slow-statement bursts".

This is a measured instance of the write-amplification cost of the 10-min-bucket pattern: each flush is one
UPDATE per active session per minute, and a wide row plus 5 indexes turns that into index churn.

### 2d. Replay / duplicate-share detection

- **SV1** [R] (`crates/bp-stratum-v1/src/submit.rs:221-330`): a per-session `SessionShareCache { seen:
  HashSet<DedupKey> }`, keyed `(job_id u64, nonce, ntime, version_mask, extranonce2 [u8;8])` with zero
  heap allocations. It is **cleared on every `clean_jobs=true` notify**, so it is bounded by the block
  interval, not by a cap. It is the first check, run before any hashing (`:333-357`).
- **SV2** [R] (`crates/bp-stratum-v2/src/mining/submit.rs:354-421`, `mining/channel.rs:234-244`): a
  per-channel `SubmissionCache` (Standard/Extended keys). It checks before inserting and inserts only on
  accept, so a duplicate of a bad share is not logged as a duplicate. It is **cleared on `SetNewPrevHash`**.
- **Restart:** both are in-memory and per-connection, so neither survives. [I] That is harmless, because a
  restart drops the connections and the jobs they referenced.
- The Redis `pplns:applied` zset is a different thing: consumer-redelivery idempotence, not miner-replay
  detection.

## 3. Payout accounting

**Shared model: non-custodial, paid in the coinbase.**
- Every mode computes SV2-extension-style weights, `amount_i = floor(w_i·T/W)`
  (`crates/bp-share/src/lib.rs:210-213, 253-285`).
- **The pool output takes the residual `T − Σpay`**, which absorbs rounding and pruned dust.
- Pool weight is `P·f/(1−f)` (`crates/bp-pplns/src/weights.rs:295-301`).
- The coinbase builder places the distributor's exact sats with no re-derivation. Order: payout outputs, then
  TDP extra outputs, then the witness-commitment OP_RETURN last. A shortfall is added to `outputs[0]` (the
  pool/fee output) and an overshoot is trimmed from trailing outputs
  (`crates/bp-mining-job/src/coinbase.rs:25-37, 541-637`).

**Output limits** (`crates/bp-pplns/src/weight.rs`):
- `DUST = 546`, `min_payout` default 5,000 sats (clamped ≥ 546), and a coinbase weight budget of 50,000 WU.
- Fixed overhead: base 328, witness commitment 188, safety 200. Per-output weights: P2WPKH 124, P2SH 128,
  P2PKH 136, P2WSH/P2TR 172 (`:13-59, 111-129`).
- `max_coinbase_outputs(budget) = (budget − 888)/172`. [I] That is about 285 worst-case outputs at 50k; the
  docs say about 400 for P2WPKH.
- Entries are admitted greedily by weight into the budget (`weights.rs:573-596`).
- The budget **autoscales** between configured bounds, with hysteresis: up at 0.85 utilization, down at 0.50,
  step ×1.15, cooldown 300 s (`crates/bp-pplns-engine/src/autoscale.rs:47-247`, defaults
  `bp-config/src/lib.rs:661-730`).

**PPLNS: difficulty-sized, count-bucketed, with a balance ledger.**
- **Window** = Σ share difficulty ≤ `window_factor × network_difficulty`. `window_factor` defaults to **4.0**
  with no TOML knob (`bp-pplns-engine/src/config.rs:60-62`, `window/mod.rs:531-537`,
  `bin/blitzpool/src/engines.rs:273-285`).
- A second, **age** rule drops buckets older than `abandoned_balance_days` (default 90).
- Storage is the Redis bucket scheme in §2b. **The window is not reset on a block** (`engine.rs:530`).
- **Distribution is precomputed per job, not at block time** (`distribution.rs:339-373`):
  - Inputs are the Redis `by-address` aggregate plus open PG balances.
  - The weight build (`weights.rs:317-690`) projects scores to integers, adds open balances as candidates
    (a 95 % solvency cap and a repayment floor for debts), sorts by weight, and drops sub-`min_payout`
    entries smallest-first.
  - It then applies the blockspace cut.
  - Withheld value goes `ToOtherMiners`, so the pool output carries only the fee.
  - The build is snapshotted to `pplns:snapshot:<fingerprint>` with a 1,200 s TTL (`window/mod.rs:814-823`).
- **At block found** (`engine.rs:396-723`):
  1. Resolve the snapshot by fingerprint, and refuse if T < subsidy.
  2. Lock the `pplns_balance` rows `FOR UPDATE` in address order.
  3. Compute `claim = floor(score·(pot − X)/S)`, then `delta = claim − paid`, and add `delta` to `balanceSats`
     (signed: credit or debt).
  4. Write `pplns_payout_history` rows: `rowType` `coinbase` when paid > 0, otherwise `pending`.
- Booking the same height twice with identical rows is a no-op; different rows are refused
  (`ledger/mod.rs:125-202`).
- **Sub-dust miners are therefore carried as ledger credit** and paid in a later coinbase, not dropped.
- A daily 03:00 UTC **dust sweep** cancels *abandoned* credits against debits, writing paired `dust-sweep`
  rows at a synthetic negative height (`sweep.rs:28-359`).
- **Finder bonus: 0 under PPLNS** ("a Group-Solo feature", `distribution.rs:401`).

**Solo** (`coinbase.rs:677-760`). 100 % to the miner, minus an optional dev-fee output
(`floor(percent·T)`). No ledger and no snapshot.

**Group-solo** (Redis `groupsolo:{groupId}:*`, `crates/bp-group-solo-engine/src/round/mod.rs:3-93`).
- Two `payoutMode`s:
  - **prop** (default): a cumulative round with no trim. It resets on a calendar schedule
    (daily/weekly/monthly/custom at 00:00 in the group's TZ, `reset.rs`) or optionally on block
    (`resetRoundOnBlock`).
  - **window**: 1-hour time buckets trimmed to N days (`:180, 257-277`).
- **Finder bonus**: `b = S·f/(1−f)` is added to the finder's score, capped at 500,000 ppm, from
  `pplns_group."finderBonusPpm"` (migration 0009; `weights.rs:451-474`).
- Sub-minimum members **forfeit to the pool** (`ToPool`), with no carry-forward.
- History rows are written **from the actual coinbase** into `pplns_group_block_history`
  (`engine.rs:866-925`).
- The member cap is derived from `max_coinbase_outputs`.
- `pplns_group_balance` is a legacy table; only tests reference it.

**Blockparty** (`crates/bp-blockparty`). *Not a lottery*: an admin-set fixed basis-point split of the miner
cut, "for pooled hashpower rentals". No shares and no ledger. Nominals below max(min_payout, 546) are folded
into the pool fee. One `blockparty_block_history` row per block holds a `splits jsonb`, with `ON CONFLICT
("groupId","blockHash") DO NOTHING`.

**Lottery-PPLNS** is not on upstream main. The local `lottery-pplns` / `finder-bonus-ppm` work is on
unpublished checkouts and was skipped (see frontmatter).

**Payout tables** (`db/schema.sql`):

```sql
CREATE TABLE public.pplns_balance (                 -- :474, PK(address)
    address character varying(62) NOT NULL,
    "balanceSats" bigint DEFAULT 0 NOT NULL,       -- signed; renamed from pendingSats
    "totalPaidSats" bigint DEFAULT 0 NOT NULL,
    "updatedAt" bigint NOT NULL,
    "lastAcceptedShareAt" bigint
);
CREATE TABLE public.pplns_payout_history (          -- :678, PK(id)
    id integer NOT NULL,
    "blockHeight" integer NOT NULL,
    address character varying(62) NOT NULL,
    "paidSats" bigint DEFAULT 0 NOT NULL,
    percent real DEFAULT 0 NOT NULL,
    "createdAt" bigint NOT NULL,
    "rowType" character varying(16) DEFAULT 'coinbase' NOT NULL   -- coinbase | pending | dust-sweep
);
-- UNIQUE ("blockHeight", address) :1462; INDEX ("blockHeight") :1336; INDEX (address) :1343
CREATE TABLE public.pplns_group_block_history (     -- :572, PK(id)
    id integer NOT NULL, "groupId" uuid NOT NULL, "blockHeight" integer NOT NULL,
    address character varying(62) NOT NULL, "paidSats" bigint DEFAULT 0 NOT NULL,
    percent real DEFAULT 0 NOT NULL, "sharesInRound" bigint DEFAULT 0 NOT NULL,
    "totalSharesInRound" bigint DEFAULT 0 NOT NULL, "createdAt" bigint NOT NULL,
    "rowType" character varying(16) DEFAULT 'coinbase' NOT NULL
);
-- UNIQUE ("groupId","blockHeight",address) :1448; FK groupId → pplns_group ON DELETE CASCADE
CREATE TABLE public.blockparty_block_history (      -- :1558, PK(id), UNIQUE("groupId","blockHash")
    id bigint NOT NULL, "groupId" uuid NOT NULL, "blockHeight" integer NOT NULL,
    "blockHash" character varying(64) NOT NULL, "foundAt" bigint NOT NULL,
    "coinbaseValueSats" bigint NOT NULL, "poolFeeSats" bigint NOT NULL,
    splits jsonb NOT NULL, "createdAt" bigint NOT NULL
);
```

(`percent` and `pplns_group` columns: see `db/schema.sql:531-551`. `"createdAt"`/`"updatedAt"` defaults are
the epoch-ms expression shown in §2c.)

## 4. Rental proxy (`blitzpool-rental-proxy` @ f25a87d)

**Shape** [R]:
- One crate, `stratum-rental-proxy` v0.3.8, on tokio multi-thread with an axum 0.8 API (`src/main.rs:11-32`).
- SV2 and the translator sit behind the `sv2` cargo feature (`src/proto/mod.rs:17-19`).
- Miner port defaults to `0.0.0.0:3333`. `RENTAL_PROXY_PROTOCOL` is `sv1|sv2|both`; `both` peeks the first
  byte (`src/main.rs:158-197`, `src/proto/detect.rs:24-29`).
- One task per socket (`main.rs:146,176`).
- Upstream protocol is **probed**: SV1 first with a 3 s timeout, then SV2 (`src/proto/relay.rs:488-518`,
  `translate.rs:44`).
- Model: `rigs` (seller worker → idle pool) and `orders` (buyer target, optional fallback, `until_ms`,
  budget). Only registered workers are admitted (`relay.rs:1336-1349`).
- SV2 "rig bundling": several same-worker miners share one upstream, kept warm for 30 s after the last
  member leaves (`src/proto/sv2/relay.rs:89, 2098-2130`).

**The live-swap mechanism exists and works** [R]:
- **SV1** `swap_upstream` (`relay.rs:244-305`):
  1. Connect and handshake the new upstream *before* tearing down the old one. On failure the miner stays
     where it is (`:265-270`).
  2. Swap under a lock with a generation bump; stale-generation lines are dropped (`:309-315, 573-574`).
  3. Send `mining.set_extranonce(en1, en2)` if the miner subscribed to extranonce (`:282-285`).
  4. Forward the new pool's `set_difficulty` and `notify` prelude verbatim (`:299-302`).
  - It does not synthesize `clean_jobs=true` [R: nothing does].
- **SV2** `swap_upstream` (`sv2/relay.rs:889-1041`):
  1. Open a fresh channel per existing channel on the new pool. Early frames are deferred and replayed
     (`:282-373`).
  2. **Downstream channel ids and group ids stay the same**; upstream ids are remapped (`:962-977`).
  3. Send each owner `SetExtranoncePrefix` + `SetTarget` (`:1026-1031`).
  4. The new pool's jobs and prevhash stream through. Pending opens get `OpenMiningChannelError "upstream
     switched; please reopen"` (`:1004-1008`).
  - Admitted gap: `SetExtranoncePrefix` cannot change the extranonce *size* (`:417-420`).
- **SV1↔SV2 translation in both directions** (`src/proto/translate.rs:3-23`).
  - SV1 miner → SV2 pool: one Extended channel; `extranonce_prefix` → en1; future jobs are buffered until
    `SetNewPrevHash`, then sent as `clean=true`. The proxy answers `mining.configure` itself with mask
    `1fffe000` (`relay.rs:520-766, 1262-1277`).
  - SV2 miner → SV1 pool: `mining.notify` → `NewExtendedMiningJob`. For Standard channels the proxy builds
    the coinbase itself, with its own extranonce2, and folds the merkle root (`sv2/relay.rs:1347-2031`,
    `translate.rs:180-325`).
  - Job maps are capped at 64 entries, cleared when full.

**What production actually does on a rental switch** [R]: **it forces a reconnect.**
- Order create, cancel and idle-pool edit all call `reconnect_all` → `force_reconnect` (`src/api.rs:231-236,
  369-376, 571-576, 591-605`).
- Expiry is a 5 s poll that ends orders and force-reconnects (`src/orders.rs:472-492`).
- SV1 `force_reconnect` is a bare socket close. `client.reconnect` would "race the writer teardown"
  (`relay.rs:1240-1248`).
- `switch_to` / `switch_to_order` are `#[cfg(all(test, feature="sv2"))]` only: "The production path forces a
  reconnect" (`src/control.rs:75-91`).
- After the reconnect:
  - **SV1:** at `authorize` the proxy finds the active order. It waits ≤ 250 ms for
    `mining.extranonce.subscribe`, then either live-swaps (capable miner) or stores an IP→pool hint (120 s),
    sends `client.reconnect`, and closes. The second connect handshakes directly on the buyer pool
    (`relay.rs:71, 1154-1161, 1393-1455`). [I] A non-capable miner therefore reconnects twice.
  - **SV2:** the first channel opens directly on the order target (`sv2/relay.rs:2080-2210`).
- **Upstream failure:**
  - SV1: truly re-points in place via `swap_upstream` (`relay.rs:1076-1113`).
  - SV2: re-establishes, then calls `force_reconnect` anyway, citing prod 2026-08-13 ("~200 rejects/min after
    a re-point") (`sv2/relay.rs:405-428, 867-875`).
  - Header comments that still describe a no-reconnect design (`relay.rs:9-10`, `sv2/relay.rs:13-16`) are
    stale.
- **In-flight shares on a swap:** SV1 `pending.clear()`, so they are not credited and the miner gets no
  reply (`relay.rs:634-636`). SV2 old-generation results are dropped (`sv2/relay.rs:1051-1053`).
- **Fallback:** a per-order fallback pool (migration 0005). Retry backoff runs 0.5 s → 30 s. [I] There is no
  automatic return from fallback to the primary.

**Persistence** [R]: SQLite via sqlx, WAL, pool of 5 (`src/db.rs:16-34`). **No per-share rows.** Order
counters (`delivered_work` in diff-1 units, accepted, submitted) are buffered in memory and flushed as one
UPDATE per order every 5 s (`orders.rs:212-219, 390-413`). [I] A crash loses up to 5 s of billing.
Credit is counted on the *upstream pool's* accept.

```sql
-- 0001_init.sql
CREATE TABLE IF NOT EXISTS rigs (
    worker TEXT PRIMARY KEY NOT NULL, pool_url TEXT NOT NULL, pool_user TEXT NOT NULL,
    pool_password TEXT NOT NULL DEFAULT '', pool_authority TEXT,
    advertised_ths REAL NOT NULL DEFAULT 0, price_per_th_day REAL NOT NULL DEFAULT 0,
    price_min_per_th_day REAL NOT NULL DEFAULT 0, price_max_per_th_day REAL NOT NULL DEFAULT 0,
    payout_address TEXT);
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY NOT NULL, worker TEXT NOT NULL, target_url TEXT NOT NULL,
    target_user TEXT NOT NULL, target_password TEXT NOT NULL DEFAULT '', target_authority TEXT,
    created_ms INTEGER NOT NULL, until_ms INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL,
    delivered_work REAL NOT NULL DEFAULT 0, accepted_shares INTEGER NOT NULL DEFAULT 0,
    submitted_shares INTEGER NOT NULL DEFAULT 0, price_per_th_day REAL NOT NULL DEFAULT 0,
    budget REAL NOT NULL DEFAULT 0);
CREATE INDEX IF NOT EXISTS idx_orders_worker ON orders (worker);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders (status);
-- 0002: ALTER TABLE rigs ADD COLUMN rentable INTEGER NOT NULL DEFAULT 1;
-- 0003: ALTER TABLE rigs ADD COLUMN max_rental_secs INTEGER NOT NULL DEFAULT 0;
-- 0004: (ends duplicate actives, then)
CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_one_active_per_worker ON orders (worker) WHERE status = 'active';
-- 0005: ALTER TABLE orders ADD COLUMN fallback_url/fallback_user/fallback_password/fallback_authority TEXT;
-- 0006:
ALTER TABLE orders ADD COLUMN ended_ms INTEGER NOT NULL DEFAULT 0;
CREATE TABLE IF NOT EXISTS rig_hashrate_samples (
    worker TEXT NOT NULL, slot_ms INTEGER NOT NULL, hashrate_ths REAL NOT NULL, online INTEGER NOT NULL,
    PRIMARY KEY (worker, slot_ms));
CREATE INDEX IF NOT EXISTS idx_hashrate_samples_slot ON rig_hashrate_samples (slot_ms);
```

`rig_hashrate_samples`: one upsert per rig per 10-min slot, pruned after 7 days (`src/hashrate.rs:23, 48-62,
98-125`). The migration-0005 comment says "the proxy doesn't translate", which is wrong: `connect_raw` /
`probe_sv2` auto-translate.

## 5. Robustness notes

**Server**
- [R] Bounded:
  - the publish mpsc (8,192, drop on full);
  - the stream (MAXLEN ~1 M);
  - the dedup zset (100 k);
  - trim steps (64 per call);
  - vardiff steps (8x up, 16x/256x down).
- [R] Dupe sets are bounded by clean-job/prevhash clears, not by size.
- [I] No connection or per-IP cap; the "fail-ban" comment has no implementation.
- Restart:
  - The satellite resumes from the stream PEL, which is the design goal.
  - Front restart drops miners.
  - Redis money state has a 10-min manual-restore backup.
- A PPLNS cold-start rebuild uses a temp key and an atomic `RENAME` (`window/mod.rs:72-73`).
- Tests:
  - 2,255 `#[test]`/`#[tokio::test]` attributes across `crates/` and `bin/` (grep count);
  - integration tests against docker Postgres/Redis;
  - a `bp-regtest-harness` crate driving bitcoin-core regtest (`*/tests/regtest_*.rs`);
  - criterion benches `bp-stratum-v1/benches/{notify,parse}.rs` and `bp-stratum-v2/benches/submit.rs`.
- CI: `.github/workflows/ci.yml` with `SQLX_OFFLINE=true`.

**Proxy** [R/I]
- 112 tests (39 `#[test]`, 73 `#[tokio::test]`; 39 of them in `src/proto/sv2/relay/tests.rs`).
- Not bounded:
  - no rate limiting or body limits;
  - all mpsc channels are `unbounded_channel`;
  - SV1 lines are read without a length cap;
  - no miner-side handshake/read timeout found;
  - reconnect hints are only removed when used [I].
- API: a bearer token is required, and every protected route refuses if it is unset. Comparison is
  constant-time (`src/api.rs:106`, `main.rs:74-82`).
- The SV2 Noise key is ephemeral unless configured (`src/proto/sv2/keys.rs:40-70`).
- Rentals resume after a restart only when miners reconnect.

## Against the working claims

- **"Nobody writes one durable row per share"**: **holds, with a qualification.** Blitzpool writes one
  *Redis stream entry* per accepted share, but it is capped (MAXLEN ~1 M, trimmed oldest), is dropped under
  backpressure, and carries no nonce/hash. It is a transport, not a ledger. Postgres gets aggregates only;
  Redis money state is aggregates only. The proxy writes nothing per share.
- **"No pool retains long-horizon per-worker history"**: **partly contradicted.**
  - Per-worker *time series* are kept 14 days (per-session 10-min slots), not long-horizon.
  - But `worker_shares_entity` keeps **lifetime cumulative per-worker totals** (Σdiff accepted/rejected) and
    is never pruned. `address_settings_entity.shares` does the same per address, and
    `pool_share_statistics_entity` keeps **pool-wide** 10-min rows indefinitely.
  - `pplns_payout_history` (one row per address per block) and `pplns_group_block_history` hold per-address
    *payout* history with no pruning [R: no DELETE for `pplns_payout_history` in `crates/bp-db/src`; the
    group table is deleted only on group dissolve, `group.rs:339`].
  - So: long-horizon per-worker *totals*, yes; per-address *payout* history, yes; per-worker *share-rate
    history*, no (14 days).
- **"Migrating an established connection is unsolved"**: **the proxy is a partial counterexample at the
  proxy layer.**
  - It keeps the downstream TCP open and swaps the upstream, handling the extranonce change via SV1
    `mining.set_extranonce` or SV2 `SetExtranoncePrefix` with channel-id remapping. SV1 failover uses this in
    production.
  - But for rental switches the authors **chose forced reconnects**. The swap only works for miners that
    opted into extranonce subscribe, cannot change the extranonce size, loses in-flight shares, and on SV2
    produced ~200 rejects/min in prod (their comment).
  - Net: mechanically demonstrated at a proxy; operationally retreated from. It does not migrate a
    *pool-side* session, since both upstreams see a fresh connection.
