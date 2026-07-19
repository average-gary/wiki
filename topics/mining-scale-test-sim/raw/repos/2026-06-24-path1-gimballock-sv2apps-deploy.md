---
title: "gimballock sv2-apps deploy branch — hardware-validation harness for the champion"
source_url: https://github.com/marafoundation/sv2-apps/tree/test/vardiff-simulation-framework
source_branch: test/vardiff-simulation-framework
type: repo
ingested: 2026-06-24
quality: 4
confidence: high
tags: [vardiff, simulation, gimballock, sv2-apps, hardware-validation, deploy-branch, antminer]
---

# `marafoundation/sv2-apps :: test/vardiff-simulation-framework`

A deploy branch that pins `stratum-core` (the parent stratum repo) to
gimballock's vardiff branch so a real pool/translator binary embedding
`channels_sv2::VardiffState` can be run against real testnet4 miners
(Antminer S21 at ~200 TH/s, per the `METRIC_DERIVATION.md` §9.4
hardware validation).

- Repo: `marafoundation/sv2-apps`
- Branch: `test/vardiff-simulation-framework`
- HEAD: `72335558` (latest)
- Role: NOT an algorithm-engineering branch. It carries no vardiff
  logic. It pins the right `stratum-core` git sha and adapts to
  upstream-API changes (accessor signatures, error code rename).

## Commit history (5 of 30, deploy-specific only)

```
72335558  2026-06-23  deploy: advance stratum-core to raw-count logging (20c03ad2)
213ae7da  2026-06-23  deploy: advance stratum-core to corrected vardiff logging (b73125dd)
14c55fba  2026-06-23  fix(logging): honor full RUST_LOG directive, not just a bare level
2dc5b152  2026-06-23  deploy: advance stratum-core to vardiff debug-logging tip
743030e3  2026-06-23  deploy: point stratum-core at the champion + adapt to upstream iterator API
```

Earlier commits (`baa89350`, `bca2e2a0`, `41923e25`, `0f3f70be`,
`c625de0f` etc) are routine `chore(deps): update stratum-core to <sha>`
keeping the deploy branch tracking the stratum work in progress.

The latest commit message tells the whole story:

> Bumps locked stratum-core b73125dd → 20c03ad2, which logs the raw
> per-window share count (raw_count + dt_secs) needed to test the
> Theorem-2 band-scaling lever on hardware — SD(raw_count) across a
> flat-belief window, expected ≈√(r*τ). The previously-logged
> e-band is EWMA-smoothed and silent on the lever. Pool builds green;
> champion algorithm unchanged.

This is the gimballock cycle at its tightest: a Theorem-2 prediction
needs a measurement that wasn't being logged, so the stratum branch
adds the log, the deploy branch bumps the pin, the pool gets
redeployed, and the next miner run produces data that can be
cross-checked against `1/√(r*τ)` from §3 of the white paper. The
"are we actually at the information floor?" question gets a clean
hardware answer.

## What changes between `main` and the deploy branch

`gh api 'repos/marafoundation/sv2-apps/compare/main...test%2Fvardiff-simulation-framework'`
shows 14 file changes, all of which are **mechanical adaptation to
upstream API churn**:

```
modified bitcoin-core-sv2/Cargo.toml                                                +1/-1
modified integration-tests/Cargo.lock                                               +18/-18
modified miner-apps/Cargo.lock                                                      +18/-18
modified miner-apps/jd-client/src/lib/channel_manager/template_message_handler.rs  +2/-2
modified miner-apps/jd-client/src/lib/monitoring.rs                                +18/-8
modified miner-apps/translator/src/lib/monitoring.rs                               +12/-4
modified miner-apps/translator/src/lib/sv2/channel_manager/mining_message_handler.rs +4/-3
modified miner-apps/translator/src/lib/sv2/channel_manager/mod.rs                   +2/-3
modified pool-apps/Cargo.lock                                                       +16/-16
modified pool-apps/pool/src/lib/channel_manager/template_distribution_message_handler.rs +2/-2
modified pool-apps/pool/src/lib/monitoring.rs                                       +12/-6
modified stratum-apps/Cargo.lock                                                    +18/-18
modified stratum-apps/Cargo.toml                                                    +1/-1
modified stratum-apps/src/config_helpers/logging.rs                                 +8/-5
```

## Categorized diff

### Lockfile bumps (5 files)

`Cargo.lock` updates in `integration-tests/`, `miner-apps/`,
`pool-apps/`, `stratum-apps/` to pick up the new `stratum-core` commit
(currently `20c03ad2`).

### Upstream accessor-API churn (`monitoring.rs`, 3 files)

`channels_sv2`'s `get_rejected_shares()` API changed from returning a
`HashMap<&str, u32>` to an iterator of `(reason, count)`. All three
monitoring modules (jd-client, translator, pool) get the same
transformation:

```rust
// before
let shares_rejected_by_reason = share_accounting.get_rejected_shares().clone();
let shares_rejected = share_accounting.get_rejected_shares_total();

// after
let shares_rejected_by_reason: HashMap<String, u32> =
    share_accounting
        .get_rejected_shares()
        .map(|(reason, count)| (reason.to_string(), count))
        .collect();
let shares_rejected = share_accounting.get_rejected_shares_count();
```

Also `user_identity.clone()` → `user_identity.to_string()` (the
accessor returned a different type after the refactor).

No new telemetry fields are added — the existing monitoring API
(`shares_accepted`, `shares_rejected`, `shares_rejected_by_reason`,
`share_work_sum`, `best_diff`, etc.) is reused unchanged.

### Channel-manager adapter tweaks (3 files)

`template_message_handler.rs`, `template_distribution_message_handler.rs`,
`mining_message_handler.rs`, `mod.rs`: small +2/-2 to +4/-3 changes
to consume the new accessor signatures or error code enum that gimballock
fixed upstream in `5a26fc9e fix(mining_sv2): add missing error code
constant for extended channel rejection` and `3262fc1b fix(mining_sv2):
remove duplicate error code constant after rebase`.

### Logging fix (`stratum-apps/src/config_helpers/logging.rs`)

`14c55fba fix(logging): honor full RUST_LOG directive, not just a
bare level`. Lets the operator pass `RUST_LOG=vardiff=debug,info`
without losing the namespacing — needed because gimballock's vardiff
work added `tracing::debug!` instrumentation at the
`channels_sv2::vardiff::composed::composed::Composed::try_vardiff`
level, and the existing logging config only forwarded a bare level.

## Hardware-validation telemetry path

Putting the pieces together, the actual hardware validation works as
follows:

1. **Champion algorithm change** lands in `stratum :: vardiff/simulation-framework`
   (e.g. `53924efb feat(vardiff): ship the champion as production VardiffState`)
2. **Debug logging added** in stratum so the algorithm's internal
   decision state is observable (`de3a2ff4 feat(vardiff):
   debug-log per-decision tracking error e and fire step s`,
   `20c03ad2 feat(vardiff): log raw per-window share count for the
   Theorem-2 lever test`)
3. **Deploy branch bumps `stratum-core`** to the new sha
   (`72335558 deploy: advance stratum-core to raw-count logging`)
4. **Pool/translator binaries are rebuilt** from the deploy branch
   and launched against a real testnet4 SRI pool instance
5. **An Antminer S21 (~200 TH/s)** is pointed at the pool via the
   `shape-proxy` tool (see `SLOW_DECLINE_TEST.md` §5 "Hardware version")
6. **Grafana dashboards** read the existing share-accounting telemetry
   (`shares_accepted`, `shares_rejected`, `share_work_sum`, `best_diff`)
   plus the new debug logs to confirm:
   - direction-of-change correct on a sustained decline
   - share-rejection rate stays flat at zero (the death-spiral tell)
   - raw per-window share count's SD ≈ `√(r*τ)` (the Theorem-2 lever)

The hardware test does NOT measure connection scaling, share validation
cost, or anything pool-side at scale. It validates one miner's vardiff
trajectory against the simulation prediction.

## Implications for scale testing

This deploy branch is **the existence proof that a sim-to-hardware
validation loop is operationally viable** for the SV2 ecosystem:

- The seam is clean: `stratum` carries algorithm + protocol; `sv2-apps`
  pins it and exercises it. A scale-test harness could follow the same
  pattern — `sv2/connection-scale-sim/` in stratum, then a deploy
  branch of `sv2-apps` (or its own deploy repo) that runs the
  pool/translator under synthetic-miner load.
- Validation needed: confirm that the deploy branch's pool/translator
  binaries embed the actual production `VardiffState` (not a mock).
  The deploy mechanism is unmodified — the pool builds against the
  pinned `stratum-core` sha. So the champion algorithm shipped on
  `2026-06-23` (`53924efb`) is running on every miner pointed at
  this deploy.
- Limitation: this branch validates ONE miner at a time. The
  multi-connection assumption from `METRIC_DERIVATION.md` §9.4
  ("multi-connection operation (the model assumes one worker per
  connection)") is explicitly flagged as an open hardware test. A
  connection-scale harness is the path to closing it.
- Missing: no `scale-test` or `load-test` instrumentation has been
  added to this branch. The validation telemetry is reused
  share-accounting metrics. For connection-scale, server-side
  metrics (handshake latency, fd count, async-runtime task queue
  depth, share-validation CPU per share) need to be added — likely
  in `pool-apps/pool/src/lib/monitoring.rs` and the equivalent
  translator file.
