---
title: "Tokio CHANGELOG.md 2024-2026: perf-relevant entries"
source_url: https://raw.githubusercontent.com/tokio-rs/tokio/master/tokio/CHANGELOG.md
type: article
ingested: 2026-06-24
quality: 5
confidence: high
tags: [scale, tokio, rust, changelog, primary-source, 2024+]
---

# Tokio CHANGELOG.md performance-relevant entries (2024-2026)

Pulled from the master-branch CHANGELOG.md on 2026-06-24. Filtered for
runtime/scheduler/io performance items and io_uring work. Release dates
are as listed in the changelog.

## 2026 cycle

### 1.52.3 (May 8 2026) — bugfixes only

### 1.52.2 (May 4 2026)
- **Reverts LIFO slot stealing** (PR #7431) "due to its performance
  impact" (#8100). See `2026-06-24-r2-pathC-tokio-lifo-regression.md`.

### 1.52.1 (April 16 2026)
- Reverts PR #7757 (sharded spawn_blocking) due to hang regression
  (#8056, #8057).

### 1.52.0 (April 14 2026)
- runtime: improve `spawn_blocking` scalability with sharded queue
  (#7757) — see PR for benchmark numbers (16-thread: -91% latency).
- runtime: use `compare_exchange_weak()` in worker queue (#8028).
- runtime: `Builder::enable_eager_driver_handoff` setting (#8010) —
  unstable; prevents I/O starvation when a worker holds the driver.
- fs: support io_uring in `AsyncRead` for `File` (#7907).

### 1.51.0 (April 3 2026)
- runtime: steal tasks from the LIFO slot (#7431) — introduces the
  regression later reverted in 1.52.2.

### 1.50.0 (March 3 2026)
- io: implement vectored writes for `write_buf` (#7871).
- io: add optimizer hint that `memchr` returns in-bounds pointer (#7792).
- runtime: avoid redundant unpark in current_thread scheduler (#7834).
- runtime: don't park in current_thread if before_park defers waker (#7835).
- runtime: wake deferred tasks before entering block_in_place (#7879).
- runtime: avoid lock acquisition after uring init (#7850).
- fs: check for io-uring opcode support (#7815) — unstable.

### 1.49.0 (January 3 2026)
- time: **add alternative timer for better multicore scalability (#7467)**
  — unstable. Sharded per-worker timer wheels. ScyllaDB's Latte upgraded
  to this to work around the 1.45+ timer contention regression.
- fs: support io-uring with `tokio::fs::read` (#7696) — unstable.
- runtime: disable io-uring on EPERM (#7724) — unstable.
- runtime: revert "replace manual vtable definitions with Wake" (#7699).

## 2025 cycle

### 1.48.0 (October 14 2025)
- MSRV increased to 1.71.
- net: add `TcpStream::quickack` / `set_quickack` (#7490).
- net: add `SocketAddr::as_abstract_name` (#7491).
- runtime: use release ordering in `wake_by_ref()` even if already woken
  (#7622).
- time: reduce generated code size of `Timeout<T>::poll` (#7535).
- sync: remove inner mutex in `SetOnce` (#7554).

### 1.47.0 (July 25 2025)
- sync: improve `AtomicWaker::wake` performance (#7450) — swap instead
  of compare-and-swap loop.
- runtime: eliminate unnecessary lfence while operating on
  `queue::Local<T>` (#7340).
- runtime: add `TaskMeta::spawn_location` tracking (#7417) — unstable.

### 1.46.0 (July 2 2025)
- (per CHANGELOG section starting line 507, mostly fix/maint)

### 1.45.0 (May 5 2025)
- (per CHANGELOG section starting line 575, mostly fix/maint;
  this is the version users noted timer-wheel contention regression
  starting from — see ScyllaDB Latte upgrade note for PR #7467)

### 1.44.0 (March 7 2025)
- (entry starts line 624, mostly fix/maint)

### 1.43.0 (Jan 8 2025)
- (entry starts line 745)

## 2024 cycle (1.36 - 1.42, dates earlier in changelog)

The "alt multi-threaded runtime" was removed in 1.46-era (#7275). Prior
to 2024 it had been an unstable opt-in for an experimental scheduler
variant; this is now gone.

## Big-picture observations

- **No public per-wake nanosecond benchmark accompanies any of the
  2024-2026 perf PRs.** The 2019 tokio.rs scheduler post remains the
  most-cited primary reference for absolute scheduler latency numbers.
- The 2026 cycle is dominated by a regression-and-rollback pattern:
  LIFO stealing (added 1.51, reverted 1.52.2), sharded spawn_blocking
  (added 1.52.0, reverted 1.52.1, presumably re-landed). This implies
  the work-stealing scheduler is near a local optimum and further
  improvements have non-trivial tradeoffs.
- io_uring support in tokio remains **fs-only.** TCP/net io_uring
  requires a different runtime (monoio, glommio, compio) or
  tokio-uring (which is fs-focused too).
