---
title: "block/buzz — open issues: upgrade/partition/agent-identity risks"
source: https://github.com/block/buzz/issues
type: data
tags: [buzz, issues, ops-risk, migrations, agents, bugs, contrarian]
confidence: high
ingested: 2026-07-23
summary: "Specific, dated operational time-bombs and agent bugs from the tracker: migration-checksum upgrade bricking (#2472), partition time-bomb recurring 2027-01-01 (#2396), agent persona-drift/self-misidentification (#2287), production panics."
---

# block/buzz — open issues (operational & security risk evidence)

- **#2472 — upgrades can brick a long-lived DB:** shipped migration files were edited in place, breaking sqlx checksums; the newer relay **refuses to start** (`migration 1 … has been modified`) with "no forward path" short of hand-editing `_sqlx_migrations` or dropping the schema. Confirmed against real Cloud SQL. "A production tenant DB could not do this."
- **#2396 — partition time-bomb:** `events` partitions end at 2026-06 + a catch-all; nothing rolls them forward (recurs 2027-01-01). **#2474:** `ensure_future_partitions` logs ERROR on a freshly migrated schema.
- **#2287 — prompt-injection / persona-drift:** ACP harness never injects the agent's own name/pubkey into the system prompt, so in a multi-agent thread an agent can misidentify as another agent and adopt its framing (author pubkey correct; only self-identity wrong). Directly relevant to agent blast radius in a shared room.
- **#2282 — capabilities are cosmetic:** "Buzz agents can be granted a scoped capability today — but nothing lets them consume one." Confirms authz = channel membership only.
- **#2320 / #2423 — agent key-handling bugs:** imported private key cleared when leaving harness setup; renaming/re-adding personal agents desyncs identity and breaks @mentions.
- **#2348 / #2552 — production crashes:** relay panic in reaction ingest (`.expect()`); `buzz agents draft-create` panics ("rustls CryptoProvider not installed").
- **#2600 — per-owner community cap hardcoded to 3.**
- Repo stats (2026-07-23): created 2026-03-06 (~4.5 mo old), Apache-2.0, ~6.3k stars, ~507 forks; API `open_issues_count: 475` folds in ~321 PRs (≈154 true issues). Latest release ~v0.4.23, no v1.0.
