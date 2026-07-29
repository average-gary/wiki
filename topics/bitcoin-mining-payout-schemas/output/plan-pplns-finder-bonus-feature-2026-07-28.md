---
title: "Build plan: PPLNS finder-bonus feature on Blitzpool"
type: plan
format: roadmap
generated: 2026-07-28
supersedes: "plan-lottery-pplns-0.1776-build-2026-07-28.md"
base_commit: 7815884c7c531561e1302ca311070d09f97c1c3c
branch_head: 059d7b0
fork: average-gary/blitzpool-server-rust
branch: lottery-pplns
upstream: warioishere/blitzpool-server-rust (AGPL-3.0-or-later)
sources:
  - "output/plan-lottery-pplns-0.1776-build-2026-07-28.md"
  - "raw/repos/2026-07-27-blitzpool-finder-bonus-code-read.md"
summary: "Scope-trimmed build plan: enable the existing finder-bonus mechanism on the PPLNS path with a configurable bonus (0.1776 BTC to start). Five phases, ~6 days. Halving-drift guards, percent mode, the JDP validation gap, and the disclosure phase are all cut per operator direction. What remains is the mechanism plus the one ledger fix without which a found block cannot be booked."
---

# Build plan: PPLNS finder-bonus feature

> **Scope:** turn on the finder bonus for PPLNS. Configurable amount, `0.1776 BTC` (`17_760_000` sats) to start. Nothing else.

**Fork:** https://github.com/average-gary/blitzpool-server-rust
**Branch:** `lottery-pplns` @ `059d7b0` (8 spike tests committed, no production code touched)
**Effort:** ~6 days · one gate (Phase 2)

## Scope

**In:** a `[pplns]` config key for the bonus amount, the bonus flowing through the PPLNS distribution path, the per-address ledger merge that makes a found block bookable, and regtest verification that it works end to end.

**Out** (cut from the prior plan per operator direction):

| Cut | Was |
|---|---|
| Halving-drift warn / boot-time rejection / clamp logging | Phase 1 "drift guard" (3 items) |
| `block_subsidy_sats` cross-crate relocation | Phase 1 commit 1 — only existed to feed the drift guard |
| Percent-of-cut mode | Already dropped |
| JDP consensus-validation gap | Unrelated pre-existing gap in a different protocol path |
| Disclosure / marketing copy phase | Phase 6 |
| Dust-suppression warn | Unreachable at this bonus size anyway |

Dropping the drift guard removes the only item that needed a cross-crate move, so the config work is now genuinely small: one `Option<u64>`, validated where the existing `[pplns]` fields already are.

**One thing I kept that looks like scope:** the Phase 2 ledger merge. It is not future-proofing — without it the coinbase pays correctly on-chain and the pool *cannot book the block at all* (reproduced against a live Postgres). It is the difference between the feature working and not working.

## How it works

The mechanism already exists in the shared distribution math that both PPLNS and Group-Solo call — `crates/bp-pplns/src/distribution.rs`: carve-out at `:166-175`, weight accounting at `:233-241`, dedicated coinbase output at `:648-657`, plus a 95%-of-miner-cut safety clamp and dust suppression.

PPLNS declines it in exactly one line — `crates/bp-pplns-engine/src/distribution.rs:340`:

```rust
finder_bonus_sats: None, // finder-bonus is a Group-Solo feature
```

The bonus is carved out **before** the proportional split, so every non-finder's payout shrinks identically regardless of who finds the block. That is why exactly one payout-list position differs between any two per-finder distributions (measured: 1 differing position out of 202, index 1). The finder appears **twice** — once for the bonus, once for their proportional share — which is legal on-chain (two `TxOut`s) and is the direct cause of the Phase 2 ledger problem.

Per-connection coinbase construction is already the architecture for Solo, Group-Solo, and Blockparty: `payout_resolver` runs per `(template × connection)` and already receives the miner address, and `payouts_fingerprint` has no session component by design, so varying the payout list per finder makes the existing fingerprint carry finder identity for free. **PPLNS is the only mode sharing one pool-wide coinbase.** This is turning off a special case, not a redesign.

At `0.1776 BTC` on today's subsidy with 8 equal miners: a non-finder goes **39,092,187 → 36,872,187 sats**, a 5.68% haircut. On-chain reach is unchanged from baseline at every pool size tested (10/100/500/2000 miners) — the bonus costs exactly one extra output and pushes nobody into pending credit.

## Verified seams (read at `059d7b0`)

- **Config struct:** `PplnsConfig` (`crates/bp-config/src/lib.rs:557-618`), `#[serde(deny_unknown_fields)]`, no `validate()` of its own — per-field invariants live downstream.
- **Validation seam:** `PplnsEngineConfig::try_new` (`crates/bp-pplns-engine/src/config.rs:132-172`), reached from `to_pplns_engine_config` (`bin/blitzpool/src/engines.rs:247-270`) at spawn. This is where the range check goes.
- **Existing ceiling:** `MAX_FINDER_BONUS_SATS = 100_000_000` (`crates/bp-group-mgmt/src/constants.rs:21-25`). `17_760_000` is well under it — **no change needed**, and its "1 BTC is already absurd" doc comment stays accurate.
- **Config docs:** the commented `[pplns]` block at `blitzpool.example.toml:245-263`; the new key goes after `min_payout_sats` (`:255`).
- **The merge to port:** `crates/bp-group-solo-engine/src/engine.rs:912-936` — sums sats *and* percent per address with deterministic insertion order. Its own comment documents the exact hazard.
- **The write path to fix:** `build_writes_from_snapshot` (`crates/bp-pplns-engine/src/engine.rs:611-700`) emits one `AuditRow` + one `BalanceWrite` per distribution entry with no per-address merge.

## Phases

### Phase 0 — Failing test first (0.5 d)

Fork, branch, worktree, and measurement spikes are **done**. Baseline `cargo test -p bp-pplns --release` = **53 passing**, no production code modified.

- [x] Fork, branch `lottery-pplns` @ `059d7b0`, worktree at `REPOS/blitzpool-lottery-pplns`
- [ ] Write the **failing** duplicate-finder ledger test: a PPLNS distribution where the finder appears twice, asserting `apply_distribution` succeeds. Fails today on `ON CONFLICT DO UPDATE command cannot affect row a second time`. Needs a real Postgres, so it belongs with the DB-backed integration tests
- [ ] Add the audit-conservation assertion in the same test: `Σ(audit rows) == Σ(coinbase outputs)`. Fails separately, on the `DO NOTHING` silent drop
- [ ] **Pin it to ≤400 addresses at the 50,000 WU budget floor.** Measured: the duplicate forms for every pool from 5 to 400 addresses and vanishes at ~500+, where the trim eats the finder's proportional share. A test at 1000 miners passes for the wrong reason

**Validation.** Baseline green; the new test red for both reasons.

### Phase 1 — Config key (0.5 d)

- [ ] Add `finder_bonus_sats: Option<u64>` to `PplnsConfig` (`crates/bp-config/src/lib.rs:557-618`), `#[serde(default)]`, `None` = feature off
- [ ] Thread it through `to_pplns_engine_config` (`bin/blitzpool/src/engines.rs:247-270`) into `PplnsEngineConfig`
- [ ] Range check in `PplnsEngineConfig::try_new` (`crates/bp-pplns-engine/src/config.rs:132`): reject `0` (use `None` to disable) and reject above `MAX_FINDER_BONUS_SATS`, with a `ConfigError` variant matching the existing style
- [ ] Document the key in `blitzpool.example.toml` after `min_payout_sats` (`:255`), commented out, with `17760000` as the example value

**Validation.** Config round-trip tests: absent, zero, valid, over-ceiling.

### Phase 2 — Per-address merge in the PPLNS ledger (2 d) ⚠️ gate

**Without this the feature does not work.** Reproduced against a live Postgres mirroring both schemas:

- `pplns_balance` is `ON CONFLICT (address) DO UPDATE` (`crates/bp-db/src/pplns.rs:319-323`) → `ERROR: ON CONFLICT DO UPDATE command cannot affect row a second time`, zero rows.
- `pplns_payout_history` is `ON CONFLICT ("blockHeight", address) DO NOTHING` (`:416`) → the duplicate row is silently dropped; 20,000,000 sats vanished from a 217,600,000-sat audit trail.

Both writes share one transaction (`crates/bp-pplns-engine/src/ledger/mod.rs:92-137`), so the abort rolls back the whole booking: **the block pays correctly on-chain and the pool can never book it**, with `bin/blitzpool/src/block_confirmation.rs:234-249` retrying a deterministic error every tick forever. This is the default outcome for any pool under ~400 addresses, and it is independent of bonus size — a property of the trim, not the bounty.

- [ ] Port the Group-Solo merge (`crates/bp-group-solo-engine/src/engine.rs:912-936`) into `build_writes_from_snapshot` (`crates/bp-pplns-engine/src/engine.rs:611-700`)
- [ ] Merge **both** output lists — the `AuditRow` list *and* the `BalanceWrite` list. The abort is on the balance side, the silent drop on the audit side; fixing one leaves the other broken
- [ ] Turn the Phase 0 test green, both assertions

**Validation.** Phase 0 test green; a regtest block-found books a real bonus and reconciles against the chain.

### Phase 3 — Thread the finder through the engine (1 d)

- [ ] Widen `PplnsEngine::build_distribution` (`crates/bp-pplns-engine/src/engine.rs:388`) to take the prospective finder
- [ ] Change the inflight cache key from `u64` to `(u64, AddressId)` (`crates/bp-pplns-engine/src/distribution.rs:175`), mirroring Group-Solo's existing `CacheKey` (`crates/bp-group-solo-engine/src/distribution.rs:130`)
- [ ] Replace `finder_bonus_sats: None` (`crates/bp-pplns-engine/src/distribution.rs:340`) with the configured bonus + finder address
- [ ] Pass `miner_address` as the prospective finder in `pplns_payouts` (`bin/blitzpool/src/payout_resolver.rs:236-254`)
- [ ] **A lost snapshot write must never fail a build.** The fallback (`bin/blitzpool/src/payout_resolver.rs:270-276`) hands one miner the entire block via `solo_payouts`; per-finder fan-out multiplies how often that path is reachable. Explicit test

**Validation.** Regtest: two connections from different addresses get coinbases differing in exactly one output (index 1); a found block on either books correctly.

**Note.** `inputs_cache` keyed by `()` (`crates/bp-pplns-engine/src/distribution.rs:180`) already shares the Redis window read and Postgres ledger query across concurrent builds, so this does not multiply DB load. Only the pure math fans out.

### Phase 4 — Regtest verification (2 d)

The feature changes PPLNS from one shared coinbase per template to one per distinct address. That needs checking before it runs anywhere real.

- [ ] End-to-end regtest: multiple addresses mining, bonus paid to the finder on a found block, ledger booked, balances correct
- [ ] Sweep N ∈ {50, 200, 500} distinct addresses at a 30 s template cadence and **measure resident memory.** Per-finder jobs turn ~4 cache entries into ~4 × N, each holding `coinbase_prefix`, `coinbase_suffix`, and both pre-rendered SV1 hex strings, against a TTL-only cache with **no size cap** (`crates/bp-mining-job/src/cache.rs:79-83`). Add a size cap if the profile is bad
- [ ] Measure `mining.notify` build latency at each N — `crates/bp-stratum-v1/src/client.rs:840-842` documents that every PPLNS connection currently shares exactly one `MiningJob` per template, and that optimization is gone by design
- [ ] Include a run at ≤400 addresses so the Phase 2 fix is exercised where the duplicate actually forms

**Validation.** Numbers at each N and a recommended maximum pool size. If memory is bad, add the cap and re-measure.

## Optional follow-ups (not scheduled)

Cheap, independent, skip freely:

- **Address-keyed script memo (~1 d).** `address_to_script` is a pure function of `(network, address)` but the current memo key includes sats, so it re-parses for every finder. Re-keying on the address alone measured 442× / 532× / 507× faster at 100 / 400 / 1000 outputs. Worth noting it is only ~16% of the distribution math (0.300 vs 1.905 ms/finder) — a cheap win, not a bottleneck.
- **Bound the `apply_prepared` retry.** `bin/blitzpool/src/block_confirmation.rs:234-249` retries deterministic errors forever. Pre-existing weakness, unrelated to this feature once Phase 2 lands. Possibly a cleaner contribution upstream on its own.

## Risks

| Risk | Source | Severity | Mitigation |
|---|---|---|---|
| Block pays on-chain but can never be booked | `crates/bp-db/src/pplns.rs:319-323` | **High** — default case for pools <400 addrs | Phase 2 (gate) |
| Audit trail under-counts vs chain | `crates/bp-db/src/pplns.rs:416` `DO NOTHING` | **High** — silent | Phase 2, both lists |
| Duplicate vanishes at 500+ addresses — a large-scale test passes falsely | Measured | Medium — false confidence | Phase 0 pinned ≤400 |
| Solo-fallback hands one miner a whole block | `bin/blitzpool/src/payout_resolver.rs:270-276` | **High** | Explicit test, Phase 3 |
| Job-cache memory growth (~4 × N, no size cap) | `crates/bp-mining-job/src/cache.rs:79-83` | Medium | Phase 4; add a cap |
| Loss of SV1 shared-job optimization | `crates/bp-stratum-v1/src/client.rs:840-842` | Low-Medium | Phase 4 latency measurement |
| Typo'd address paid the bonus irreversibly | Accepted policy — consensus validation only | Low — accepted | None; operator decision |
| Upstream immaturity | Created 2026-06-23, unaudited, single primary author | Medium | Pinned to `7815884`; AGPL-3.0-or-later applies to any deployment |

## Effort

| Phase | Days | Gate |
|---|---|---|
| 0 — failing test | 0.5 | |
| 1 — config key | 0.5 | |
| 2 — per-address ledger merge | 2 | ⚠️ |
| 3 — thread the finder through | 1 | |
| 4 — regtest verification | 2 | |
| **Total** | **6** | |

Phases 1 and 2 are independent and parallelizable. Phase 3 depends on 1; Phase 4 depends on 2 and 3.

## Verification record

All measurements at `7815884`, branch `lottery-pplns`, head `059d7b0`, worktree `REPOS/blitzpool-lottery-pplns`. `cargo test -p bp-pplns --release` = **53 passing**, no production code modified.

- `crates/bp-pplns/tests/spike_bonus_sizing_modes.rs` (`059d7b0`) — duplicate-entry frequency by pool size (the ≤400 figure), bonus-size independence, dust reachability. 4 tests
- `crates/bp-pplns/tests/spike_bonus_1776.rs` (`8235dac`) — positional divergence (1 differing output), clamp behaviour. 3 tests
- `crates/bp-pplns/tests/spike_dust_cliff_1776.rs` (`8235dac`) — on-chain reach vs baseline by pool size. 1 test
- Ledger failure — Postgres schema mirror of `pplns_balance` + `pplns_payout_history` against a local instance; both the `DO UPDATE` abort and the `DO NOTHING` drop reproduced. Scratch schema dropped afterward
- Haircut figures (39,092,187 → 36,872,187 sats, 5.68%) derived through the distribution code, not by hand
- Seams in "Verified seams" each confirmed by reading the cited lines at `059d7b0`
- Prior spikes preserved at `.buzz/.scratch/blitzpool-spikes/` (5 files)
