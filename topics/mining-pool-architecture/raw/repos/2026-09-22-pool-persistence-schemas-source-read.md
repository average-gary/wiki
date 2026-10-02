---
title: "public-pool, ckpool and datum_gateway persistence — source read with transcribed schema"
source: "https://github.com/benjamin-wilson/public-pool"
related_sources:
  - "https://bitbucket.org/ckolivas/ckpool"
  - "https://github.com/OCEAN-xyz/datum_gateway"
type: repos
ingested: 2026-09-22
tags: [public-pool, sqlite, wal, typeorm, time-bucketed-aggregates, ckpool, sharelog, append-only, ckdb, datum-gateway, dupe-checking, write-amplification, retention, source-read]
summary: "Three implementations, three completely different answers, all read at source. public-pool uses SQLite in WAL mode and — crucially — stores NO per-share rows for internal mining: shares accumulate in memory in StratumV1ClientStatistics and land as 10-MINUTE TIME BUCKETS in ClientStatisticsEntity, one UPDATE per active session per minute regardless of share count, so writes scale with SESSIONS not with share rate. Its only per-share table (ExternalSharesEntity) is for shares POSTed from external pools and only accepts >= 1T difficulty. Retention 24 hours; schema managed by TypeORM synchronize:true with no migrations. ckpool writes an append-only JSON sharelog — one line per share, valid OR invalid — to {logdir}/{height:08x}/{workbase_id}.sharelog with a full field list including workinfoid/clientid/enonce1/nonce2/nonce/ntime/diff/sdiff/hash/result/reject-reason/workername/address/agent, via one fwrite per share from the stratifier, with no cleanup and no consumer in-tree. ckdb — ckpool's historical companion PostgreSQL daemon — has header references at ckpool.h:361-365 but was disabled by commit 4b655e1d (2017-05-13, 'Disable ckdb by default') and is not compiled or shipped. datum_gateway persists nothing; its memory is dominated by a pre-allocated duplicate-share table sized max_clients_per_thread * vardiff_target_shares_min * (share_stale_seconds/60) * 16, which is what the published ~1 GB per 1,000 clients guidance actually measures."
commits_read:
  - "public-pool: 01b31b6"
  - "ckpool: c38079a5"
  - "datum_gateway: a3da9e6"
credibility: high
credibility_score: 5
credibility_rationale: "Direct source read at named commits, with schemas transcribed verbatim from the entity definitions rather than summarised. Corrects one round-1 claim from the same repo."
confidence: high
research_round: 2
research_agent: "C1 (source read)"
corrects: "Round 1 said ckpool's optional share log is 'written by a dedicated logging thread'. The source shows the STRATIFIER writes it synchronously (fopen with mode 'ae', one fwrite per share) — i.e. it sits ON the share-submit path, not off it. Round 1 also left ckdb unmentioned; its history is recorded here."
extraction_note: "Subagent source read. public-pool entity definitions are transcribed verbatim. The datum_gateway dupe-item struct size was not read, so the memory figure is a formula rather than a byte count."
---

# Three answers to share persistence

## public-pool — SQLite, and no per-share rows

**SQLite with WAL mode** (`app.module.ts:44-53`).

### The accounting table is a 10-minute bucket

`src/ORM/client-statistics/client-statistics.entity.ts:5-35`:

```typescript
@Entity()
@Index(["address", "clientName", "sessionId"])
@Index(["address", "clientName", "sessionId", "time"])
export class ClientStatisticsEntity extends TrackedEntity {
    @PrimaryGeneratedColumn() id: number;
    @Column({ length: 62, type: 'varchar' }) address: string;
    @Column() clientName: string;
    @Column({ length: 8, type: 'varchar' }) sessionId: string;
    @Index() @Column({ type: 'integer' }) time: number;
    @Column({ type: 'real' }) shares: number;          // summed difficulty
    @Column({ default: 0, type: 'integer' }) acceptedCount: number;
}
```

**The write path is the finding.** Shares accumulate in memory in
`src/models/StratumV1ClientStatistics.ts:34-116`:

1. First share in a 10-minute slot → `INSERT` (lines 57-64)
2. Slot transition → `UPDATE` the old slot (69-76), `INSERT` the new one (84-91)
3. Every 60 s within a slot → `UPDATE` (97-104)
4. Otherwise → **increment `shares` and `acceptedCount` in memory only** (109-110)

Only accepted shares count — `StratumV1Client.ts:541` calls `statistics.addShares()` only when
`sdiff >= diff`.

**So DB writes per accepted share are 0 to 1, and typically one UPDATE per minute per active session
regardless of how many shares arrived in that minute.** Write load scales with **session count**, not
share rate.

That is the persistence-layer restatement of this topic's central sizing finding: the connection count
is the independent variable. Even the database agrees.

### The only per-share table is for external submissions

`src/ORM/external-shares/external-shares.entity.ts:4-30`:

```typescript
@Entity()
@Index(['address', 'time'])
export class ExternalSharesEntity extends TrackedEntity {
    @PrimaryGeneratedColumn() id: number;
    @Column({ length: 62, type: 'varchar' }) address: string;
    @Column() clientName: string;
    @Column({ type: 'integer' }) time: number;
    @Column({ type: 'real' }) difficulty: number;
    @Column({ length: 128, type: 'varchar', nullable: true }) userAgent: string;
    @Column({ length: 128, type: 'varchar', nullable: true }) externalPoolName: string;
    @Column() header: string;
}
```

Written **per share** via a direct `insert()` (`external-shares.service.ts:13-15`), for shares POSTed to
`/api/share` from external pools, and **only accepting ≥ 1T difficulty** (`MINIMUM_DIFFICULTY`). The
difficulty floor is what makes a per-share row affordable — it is a rate limiter expressed as a
threshold.

### Sessions and blocks

`ClientEntity` (`client/client.entity.ts:11-40`) — `@Entity({ withoutRowid: true })` with a unique
composite `[address, clientName, sessionId]` primary key, plus `userAgent`, `startTime`,
`bestDifficulty`, `hashRate`. `BlocksEntity` (`blocks/blocks.entity.ts:5-26`) stores `height`,
`minerAddress`, `worker`, `sessionId`, `blockData` (full hex). Base `TrackedEntity` adds soft-delete
`deletedAt` plus `createdAt`/`updatedAt`.

### Retention and schema management

`src/services/app.service.ts`: `deleteOldStatistics()` hourly, dropping `ClientStatisticsEntity` and
`ClientEntity` rows older than **24 hours**; `deleteOldBlocks()` daily, keeping the latest 1,000.
`deleteOldShares()` exists (`external-shares.service.ts:39-46`, 24 h) but **is not scheduled** in
`app.service.ts`.

**No migrations. TypeORM `synchronize: true`** — the schema is inferred from entities at boot. Convenient
in development and a known hazard in production: no schema history, and an entity change silently alters
a live table.

## ckpool — append-only JSON, on the hot path

**No database.** No `.sql`, no `libpq`/`postgres`/`mysql`/`sqlite` anywhere in the source.

### ckdb: existed, disabled 2017

Header references survive at `ckpool.h:361-365`, but the implementation is not in the tree and
`git log --grep=ckdb` shows **commit `4b655e1d` (2017-05-13) "Disable ckdb by default."** plus
`11fc1aca` "Disable ckdb." ckdb was a **companion PostgreSQL daemon** for share accounting. So the
accurate statement is not "ckpool never had a database" but **"ckpool had one and turned it off almost a
decade ago"** — which is a stronger data point for the in-memory design, not a weaker one.

### The sharelog

Path (`stratifier.c:1048-1078`): `{logdir}/{height:08x}/{workbase_id}.sharelog` — e.g.
`/var/log/ckpool/00875320/a1b2c3d4.sharelog`. Height as 8-hex (line 1071), workbase id as 16-hex
(line 1078), filename at line 6102.

**One JSON object per share, accepted *and* rejected** (`stratifier.c:6219-6243`):

```json
{"workinfoid":…, "clientid":…, "enonce1":"…", "nonce2":"…", "nonce":"…", "ntime":"…",
 "diff":…, "sdiff":…, "hash":"…", "result":<bool>, "reject-reason":"…", "error":{…}, "errn":…,
 "createdate":"<iso8601>", "createby":"code", "createcode":"<func>", "createinet":"<serverurl>",
 "workername":"…", "username":"…", "address":"<btc_addr>", "agent":"<useragent>"}
```

Note `diff` **and** `sdiff` — the target and the achieved difficulty — which is exactly what a
withholding-detection or best-share analysis needs, and `result` plus `reject-reason` for stale/reject
accounting.

**Correction to round 1**: the write is `fopen(fname, "ae")` (append + close-on-exec, line 6246) followed
by one `fwrite` per share (6248-6249), **performed by the single-threaded stratifier, synchronously**,
with the file closed after each write. Round 1 said a dedicated logging thread did this. It does not.
A synchronous open-write-close per share **is on the share-submit path**.

In practice this is survivable — at the corrected share rates (~2,300/sec at 23,000 connections) and with
the OS page cache absorbing appends, but it is a real coupling between the hot path and the filesystem,
and it is the one place ckpool's otherwise strict off-path discipline breaks. Rotation is implicit: a new
workbase means a new file. **No cleanup or TTL code exists** — logs grow forever, and external rotation
is assumed.

**And nothing in-tree reads them.** No consumer code. Either external tooling, the removed ckdb, or human
inspection.

## datum_gateway — nothing persisted, memory dominated by dupe-checking

No database, no share log. Only `submitblock` request dumps for debugging
(`datum_stratum.c:2217-2221`) and ordinary logging via `datum_logger.c`.

**Per-client memory** (`datum_sockets.h:65-85`): two `CLIENT_BUFFER` buffers at
`(16384*3)+1024 = 50,176` bytes each, so **~100 KB of buffers per client** before application state.

**The dominant allocation is duplicate-share detection** (`datum_stratum_dupes.c:64`):

```
(max_clients_per_thread * vardiff_target_shares_min * (share_stale_seconds/60) * 16)
    * sizeof(T_DATUM_STRATUM_DUPE_ITEM)
```

At 4,096 clients/thread, 10 shares/min target, 120 s stale window: `4096 × 10 × 2 × 16 = 1,310,720`
dupe items **per thread**, pre-allocated. Items expire when their job passes `share_stale_seconds`
(default 120), cleaned via sorted-array search (`datum_stratum_dupes.c:421`).

**This is what the published "~1 GB RAM per 1,000 concurrent clients" guidance actually measures** — not
session state, but a pre-sized replay-detection window. It also shows the design choice: bound the dupe
window by *time* (120 s) rather than by count, and pre-allocate for the worst case.

Compare the SRI pool, whose `seen_shares` is an unbounded `HashSet` flushed on chain-tip change. Same
problem, three answers: pre-allocated time-windowed array (datum), unbounded set flushed per block (SRI),
configured cap (SRI post-hardening, client side).

## Writes per accepted share

| Implementation | Storage | Writes/share | Record | Retention |
|---|---|---|---|---|
| **public-pool** | SQLite (WAL) | **0–1 UPDATE** (≈1/min/session) | 10-min aggregate | 24 h |
| **ckpool** | append-only JSON log | **1 `fwrite`** (+ open/close), synchronous | per-share, valid *and* invalid | **indefinite** |
| **datum_gateway** | none | **0** | memory only | ~120 s (dupes) |

## What the code did not answer

- **public-pool**: no benchmarks — how many concurrent sessions SQLite+WAL sustains is unknown. No
  partitioning; all data in one file. No backup/replication code. **No payout/PPLNS computation found**
  despite `shares` holding summed difficulty.
- **ckpool**: who consumes the sharelog.
- **datum_gateway**: the `T_DATUM_STRATUM_DUPE_ITEM` size, so the memory formula has no byte figure; and
  where upstream DATUM accounting happens, since shares are not persisted here.
- None of the three shards or partitions by address or user.
