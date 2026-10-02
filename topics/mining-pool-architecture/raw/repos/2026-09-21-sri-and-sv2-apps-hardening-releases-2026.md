---
title: "SRI v1.12.0 and sv2-apps v0.8.0 — the 2026 hardening releases and the Loupe audit"
source: "https://github.com/stratum-mining/stratum/releases/tag/v1.12.0"
related_sources:
  - "https://github.com/stratum-mining/sv2-apps/releases/tag/v0.8.0"
  - "https://github.com/stratum-mining/stratum/pull/2243"
  - "https://github.com/stratum-mining/stratum/pull/2336"
  - "https://github.com/stratum-mining/stratum/pull/2261"
type: repos
ingested: 2026-09-21
tags: [stratum-v2, sri, sv2-apps, loupe-audit, share-replay, extranonce-lifecycle, coinbase-consensus-validity, scriptsig-budget, bip323, bip320, chacha20-poly1305, bounded-job-storage, dos-prevention, typestate, translator-proxy, production-hardening]
summary: "What production-hardening an SV2 stack actually consisted of. SRI v1.12.0 (2026-09-17): BIP323 support across the stack with EllSwiftPubKey; nTime/min_ntime bounds enforced on share validation in all channel types (upper bounds were previously missing); consensus-invalid coinbase construction fixed — undersized BIP141 witness commitment parts, scriptSig length off-by-one, scriptSig serialisation errors, and a 100-byte scriptSig budget check with BIP34 height allowance; job storage bounded on EVERY axis (future templates, past jobs, replaced group jobs, per-client future jobs, rejected_shares and seen_shares caches) explicitly to stop memory exhaustion; AES-256-GCM removed entirely leaving ChaCha20-Poly1305 as the only cipher; arithmetic overflow/underflow/div-by-zero replaced with saturating ops or validation; several production panics fixed including a use-after-free on ExtranoncePrefix released while jobs still referenced it. sv2-apps v0.8.0 (same day) implements third-party Loupe audit findings: job notifications only after BOTH mining.subscribe and mining.authorize (no unauthenticated mining), late SV1 shares validated against THEIR OWN job's target/extranonce rather than the current job (a direct revenue fix), channel opens rejected on extranonce/channel-ID space exhaustion with failure isolated to the one miner, typestate-based runtimes with no unwrap/expect, and DNS resilience via trying every A/AAAA record. The three named PRs give the mechanism for the two highest-severity bug classes: consensus-invalid coinbase (#2243) and share replay via dedup-cache and extranonce-prefix recycling (#2336, #2261)."
published: 2026-09-17
maintainer: plebhash
credibility: medium
credibility_score: 3
credibility_rationale: "Release notes are primary sources, but everything here is a subagent's summary of them rather than a direct read, and the same agent's timeline contained a year-duplication error (see dating_caveat). The technical content is detailed, internally coherent, and corroborated at the failure-class level by an independent agent's reading of the issue tracker."
confidence: medium
research_round: 1
research_agent: news
dating_caveat: "The reporting agent listed the SRI release series under BOTH 2025 and 2026 dates (v1.8.0 as 2025-03-19 and 2026-03-19; v1.12.0 as 2025-09-17 and 2026-09-17). The 2026 dates are almost certainly correct — v1.12.0 four days before ingestion, with v1.8.0 through v1.11.1 spanning March to July 2026. The 2025 duplicates are treated as an error. Verify against the releases page before citing any single date."
corroborates: "raw/repos/2026-09-21-sri-sv2-open-security-issues.md — the low-confidence issue list describes the same failure classes (share replay on prev_hash reset, accounting saturation, scriptSig budget, job collision). Where the two disagree on detail, prefer THIS file: release notes over paraphrased issue titles."
extraction_note: "Subagent summary of release notes. PR numbers and the Loupe attribution are as reported and unverified by this session."
---

# SRI v1.12.0 / sv2-apps v0.8.0 — the 2026 hardening pass

Both released **2026-09-17**. Read together they are the most useful document in this round about what
an SV2 pool stack needs beyond protocol correctness — because they are a list of what was *missing*.

## SRI v1.12.0 (protocol crates)

### BIP323 / Taproot

Full BIP323 adaptation across `subprotocol` crates, `sv1_api`, `stratum_translation`, and
`channels_sv2`. Added **`EllSwiftPubKey`** for compact public-key encoding. Enables Schnorr/Taproot-era
authentication and encryption.

### Share validation: time bounds

`min_ntime` and `nTime` bounds now enforced **across all channel types**. Previously **upper bounds
were missing**, so invalid timestamps were accepted. (Compare the decade-old `ntime out of range`
issue in slush0's original V1 implementation — the same validation gap, in a new codebase.)

### Consensus-invalid coinbase construction (the worst class)

Fixed in `channels_sv2`, detailed in **PR #2243**:

1. **Prefix/length mismatch** — scriptSig deserialisation used the wrong length during share
   validation.
2. **No budget enforcement** — nothing prevented building a scriptSig >100 bytes (a consensus limit).
3. **Extranonce config bypass** — configuration changes let budget validation be skipped.
4. **Custom job paths had no scriptSig budget checks at all.**
5. Undersized **BIP141 witness commitment** parts.

**Impact as reported**: a block found on an affected channel would be **rejected by every Bitcoin
node** — presenting as an orphan but actually consensus-invalid — meaning **total loss of the block
reward** rather than a degraded outcome. This is the highest-consequence failure mode found anywhere
in this research round: not downtime, not a share accounting error, but a found block worth ~3.125 BTC
plus fees that pays zero.

**Fix shape**: validate the scriptSig budget **at every trust boundary and at job creation time**,
with proper BIP34 height allowance (the height push consumes budget), and apply **identical validation
to custom and standard job paths**.

### Share replay (PRs #2336, #2261)

1. **Dedup cache invalidated on the wrong key.** The cache was flushed on **timestamp updates**, not
   only on block-header change — so resubmitting an identical share with a different timestamp got
   credited twice. **Fix: key invalidation to `prev_hash` only**, the actual work-uniqueness boundary.
2. **Extranonce prefix recycling → cross-channel replay.** Rotated prefixes were released
   immediately while jobs using them were still active. Attack: receive prefix A, submit shares, wait
   for A to be reassigned, receive A on a different channel, replay the same shares — which
   **per-channel duplicate detection structurally cannot catch**. **Fix: retain retired prefixes until
   all associated jobs are stale.**
3. **BIP141 witness flag not validated** — fixed-size witness sections were stripped blindly, so a
   non-witness transaction could be processed as a witness one (type confusion). Fix: only `0x01`
   accepted.
4. **Zero targets unvalidated** → infinite difficulty in accounting; a miner could request a zero
   target and poison work statistics. Fix: reject zero targets at channel boundaries.

**The general lesson the release states**: deduplication must be keyed to **actual work uniqueness**
(`prev_hash`), never to job metadata a client can vary; and **resource lifecycle must outlive the
resource's consumers** — an allocation token (extranonce prefix) cannot be recycled while jobs
referencing it are live.

### Bounded job storage (DoS)

Configured caps added on **every** axis: future templates, past jobs, replaced group jobs, per-client
future jobs, and the `rejected_shares` / `seen_shares` caches. Rationale as stated: prevent memory
exhaustion from a malicious upstream, bound share-validation history, limit job-churn memory, and stop
unbounded cache growth **on long-lived connections** — which every stratum connection is.

Note the tension with the replay fix: `seen_shares` must be **large enough to prevent replay** and
**bounded to prevent exhaustion**. Those two requirements are in direct conflict, and the release
resolves it with a configured cap — meaning the safe cap size is now an operator's problem.

### Crypto and codec

- **AES-256-GCM removed entirely**; **ChaCha20-Poly1305** is the sole cipher. Smaller attack surface
  and better performance on hardware without AES-NI.
- Broader `noise_sv2` hardening for timing and state-machine gaps.
- `Frame<T, B>` split into `MessageFrame<T>` and `SerializedFrame<B>`; `HandShakeFrame` →
  `HandshakeMessage`; new `SizeHint` enum for length prefixes.

### Panics fixed (production stability)

- Chain-tip transition: panic when `mark_past_jobs_as_stale` was called twice.
- Malformed upstream coinbases: deserialisation failures now return errors instead of panicking.
- **`ExtranoncePrefix` use-after-free** — prefixes released while jobs were still active.
- Arithmetic overflow / underflow / division-by-zero throughout, replaced with saturating operations
  or explicit validation.

### CI

Version bumps enforced against crates.io to prevent accidental non-semver changes; integration tests
accelerated.

**Breaking**: all published crates took incompatible version bumps; downstream pools, proxies and
miners must update and adapt.

## sv2-apps v0.8.0 (application layer)

Implements findings from a **third-party security audit by Loupe** across translator proxy, pool, and
job declarator.

### Translator Proxy — the highest-leverage component

It bridges SV1 miners (the majority of deployed hashrate) to SV2 infrastructure, so bugs here hit
revenue directly.

- **Handshake completion is now idempotent** (no duplicate setup).
- **Job notifications start only after BOTH `mining.subscribe` AND `mining.authorize`** — i.e.
  unauthenticated mining was previously possible.
- `mining.extranonce.subscribe` honoured; prefix changes applied **without recreating channels**, so
  a prefix rotation no longer disturbs the connection.
- Malformed notifications return errors instead of panicking.
- **Late SV1 shares validated against their own job's target/extranonce, not the current job's.**
  This is a pure revenue fix: valid stale shares were being rejected because they were checked with
  the wrong parameters. Any pool doing SV1↔SV2 translation should assume it has this bug until it
  checks.
- **Aggregated mode**: reject channel opens when extranonce space or channel-ID space is exhausted;
  **isolate the failure to the affected miner** rather than letting it affect others; explicit
  exhaustion checks to prevent downstream ID collisions.
- **BIP320/BIP323 version-rolling mask support**, rejecting non-rollable version bits with a proper
  error code.

### Runtime lifecycle

`JdcRuntime`, `TranslatorRuntime`, `PoolRuntime` built as **typestate state machines** handling
bootstrap, component lifecycle and graceful shutdown **without `unwrap`/`expect`** — eliminating panic
sources by construction. A notable architectural choice: the multi-component lifecycle is encoded in
the type system rather than in defensive runtime checks.

### Other

- Extranonce allocator exhaustion handled gracefully in both Pool and JDC (error, not panic or silent
  corruption).
- `SetupConnection` version ranges enforced; non-setup responses during handshake rejected (protocol
  confusion).
- **All configuration available via environment variables**, removing `envsubst` preprocessing from
  container deployments.
- **DNS resilience**: tProxy and JDC try **every** A/AAAA record for an upstream host, not just the
  first — handles round-robin and partial failure.

### Earlier in the series (v0.4.0)

New extranonce APIs from SRI v1.9.0; Bitcoin Core v31 compatibility in `bitcoin_core_sv2`; **static
shared state removed from the translator, enabling multi-instance deployment**; connection timeouts to
stop resource leaks from hung connections; rejected-share API and submit-share error-code visibility
for monitoring.

## Architectural reading

- **Every single class of bug here is a consequence of holding state per connection and per job.**
  Replay needs a seen-set; the seen-set needs bounds; bounds need eviction; eviction re-enables
  replay. Extranonce prefixes need allocation; allocation needs recycling; recycling races with job
  lifetime. This is the cost side of the SV2 ledger, stated concretely.
- **The audit findings are mostly *authorisation and lifecycle*, not cryptography.** Unauthenticated
  mining before `authorize`, wrong job used to validate a late share, resource exhaustion — none of it
  is about the Noise layer.
- **"Validate the late share against its own job" is the reusable rule.** A share is a claim about a
  *specific past job*; validating it against current state is wrong in every implementation that does
  it, and it silently costs miners money.
- **Bounded-everything is the maturity signal.** The difference between an alpha and a production pool
  component, per this release, is that every collection has a configured maximum.
