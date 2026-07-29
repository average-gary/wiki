---
title: "Build plan: 0.1776 BTC coinbase-direct lottery-PPLNS on Blitzpool"
type: plan
format: roadmap
generated: 2026-07-28
status: superseded
superseded_by: "plan-pplns-finder-bonus-feature-2026-07-28.md"
supersedes: "plan-lottery-pplns-1776-rewiring-2026-07-28.md"
base_commit: 7815884c7c531561e1302ca311070d09f97c1c3c
branch_head: 059d7b0
fork: average-gary/blitzpool-server-rust
branch: lottery-pplns
upstream: warioishere/blitzpool-server-rust (AGPL-3.0-or-later)
sources:
  - "output/plan-lottery-pplns-1776-rewiring-2026-07-28.md"
  - "output/plan-coinbase-direct-lottery-pplns-2026-07-27.md"
  - "wiki/concepts/lottery-pplns.md"
  - "raw/repos/2026-07-27-blitzpool-finder-bonus-code-read.md"
  - "wiki/concepts/variance-and-risk-shifting.md"
summary: "Locked build plan for a 0.1776 BTC absolute finder bonus, chosen for thematic reasons. Absolute mode is decided, so the percent-resolution work drops and the halving-drift guard becomes load-bearing instead. Seven phases, ~9.5 days, two of them gates. Config seam confirmed at PplnsEngineConfig::try_new; the subsidy helper the drift guard needs is pub(crate) in bp-api and must be relocated."
---

# Build plan: 0.1776 BTC coinbase-direct lottery-PPLNS

> **⚠️ SUPERSEDED — over-scoped.** The operator's direction: *"you're worrying too much about the maths in the future. I just want a plan that will update blitzpool so we can have a PPLNS pool with bonus structure."* This plan made the halving-drift guard load-bearing, relocated a subsidy helper across crates solely to serve it, and published multi-halving drift tables. All of that is cut. Build from **[the trimmed feature plan](plan-pplns-finder-bonus-feature-2026-07-28.md)** — 5 phases, ~6 days. This document is retained for its measurements (M1–M5, drift and fee-sensitivity tables), which remain accurate and are the reference if the sizing is ever revisited.

> **Decision locked.** The finder bonus is **0.1776 BTC absolute** (`17_760_000` sats), chosen for the pool's thematic identity. Percent mode is **not** being built. This supersedes [the rev-2 plan](plan-lottery-pplns-1776-rewiring-2026-07-28.md), which left the choice open.

**Fork:** https://github.com/average-gary/blitzpool-server-rust
**Branch:** `lottery-pplns` @ `059d7b0` (cut from `7815884`; 8 spike tests committed, no production code touched)
**Effort:** ~9.5 days · Phases 2 and 5 are gates

## What the decision changes

Absolute mode is the *simpler* build — one `u64` config key, no runtime subsidy resolution, no fee-spike interaction with the existing ceiling. Three items from the rev-2 plan disappear entirely:

| Dropped | Why |
|---|---|
| `finder_bonus_percent` config key + `(0, 95]` range check | Not building percent mode |
| Percent → sats resolution against live `block_reward_sats` | The value is a constant |
| Check whether resolved sats trip `MAX_FINDER_BONUS_SATS` on a fee spike | Only percent mode could grow into the ceiling |
| Raise `MAX_FINDER_BONUS_SATS` | 17,760,000 is already well under the existing `100_000_000` |

**But one item is promoted to load-bearing.** Percent mode was the structural answer to halving drift; absolute mode has no structural answer, so the guard has to be operational. Measured drift at 0.1776 BTC (M5a, `spike_bonus_sizing_modes.rs`):

| Halving | Bonus as % of miner cut | Non-finder haircut |
|---|---|---|
| +0 (now) | 5.68% | 5.7% |
| +1 | 11.18% | 11.2% |
| +2 | 21.69% | 21.7% |
| +3 | 40.92% | 40.9% |
| +4 | 73.50% | 73.5% |
| +5 | clamped to 0.138169 | 95.0% |

Nothing in the current code logs any of this. The pool becomes materially more lottery-like every four years, and the first *visible* symptom is the 95% clamp at halving +5 — roughly 20 years out. **Phase 1's drift guard is what converts that from a silent mutation into a decision the operator has to make.** It is the single most important thing this plan adds beyond the mechanism itself.

## Design decisions

Carried forward unchanged: **D1** bonus-on-top (finder gets the bounty *and* their proportional share — exactly EV-neutral at every miner size), **D3** address-keyed script memo, **D4** no CTV fanout, **D5** leave `payouts_fingerprint` untouched (it has no session component by design, so a per-finder payout list makes the existing fingerprint carry finder identity for free), **D7** no ownership proof.

### D2 (resolved): Absolute sats, with a mandatory drift guard

**Decision.** One key, `finder_bonus_sats: Option<u64>`, default `None` (feature off). No percent knob. The operator's chosen value is `17_760_000`.

**The tradeoff being accepted, stated plainly:** the bonus's *share* of the block grows at every halving without anyone changing a setting. That is the cost of a fixed headline number, and it is a real cost, not a rounding error — 5.7% today becomes 40.9% three halvings out. It is accepted because the number is the product's identity, and because the guard below makes each step visible.

**Guard (Phase 1), three parts:**
1. **Boot-time drift warn.** At engine spawn, compute the bonus as a fraction of the expected miner cut at the current subsidy. Log at `info` under 15%, `warn` from 15%, and `error` from 50%, naming the percentage. An operator restarting after a halving sees the deal change in their logs.
2. **Boot-time rejection** when the bonus would exceed 95% of the miner cut at the current subsidy — refuse to start rather than silently clamp. This is the halving-+5 case; failing loudly forces a conscious re-set.
3. **Runtime warn when the 95% clamp actually binds** at distribution-build time, rate-limited so it can't flood. Covers the case where a halving happens under a long-running process that never restarts.

**Not building:** any automatic reduction of the bonus at a halving. Silently changing the advertised number is worse than warning about it. The operator decides.

### D6 (revised): No ceiling change; make three silent paths loud

`MAX_FINDER_BONUS_SATS = 100_000_000` (`crates/bp-group-mgmt/src/constants.rs:21-25`) stays exactly as it is. 17,760,000 sats is comfortably under it, and its doc comment — *"1 BTC is already absurd as a per-block bonus… anything bigger is almost certainly a config typo"* — is now consistent with the design rather than in conflict with it. **Leave the constant, `validate_round_reset` (`crates/bp-group-mgmt/src/group.rs:318`), and its cap tests (`:541-551`) untouched.**

What does get built is diagnostics for paths that currently fail silently:

- The **95% clamp** (`crates/bp-pplns/src/distribution.rs:172`) — silent today.
- The **dust suppression** at `crates/bp-pplns/src/distribution.rs:175`: `bonus_emitted = capped_bonus >= min_payout`. Unreachable by the chosen value (17,760,000 sats vs a 546-sat floor, at every subsidy), but reachable by a config typo, and confirmed silent — M5e showed a 100-sat request emits no bonus output, no warning, and still conserves the reward. The finder simply doesn't get paid.
- The **halving drift** itself (D2).

Because the operator's policy is that miners own their address inputs, the pool's *own* config is the one place a typo is the operator's responsibility. Guard it there.

### D7 (unchanged): No ownership proof

The pool validates against consensus rules via `address_to_script` (`crates/bp-mining-job/src/address.rs:39-45`) and pays what the miner asked for. No signature gate, no confirmation step, no recovery. This matches every SV1/SV2 mining path today.

**One gap does get closed, and it is not an ownership feature.** The Job Declaration path validates *less* than the mining paths: `parse_user_identifier_as_address` (`crates/bp-stratum-v2/src/jdp/client.rs:656-677`) calls `AddressId::new` but **not** `address_to_script`, so a shape-valid-but-consensus-invalid address is issued a job token and fails later at `jdp/dynamic_outputs.rs:174`, whose production hook degrades to `coinbase_outputs: vec![0u8]` (`bin/blitzpool/src/jdp_hooks.rs:210-226`). That is a consensus-validation gap — precisely the one check the operator does want enforced.

**Consequence, accepted:** a typo sends 0.1776 BTC to a valid address that isn't the miner's, irreversibly, on a block they may have waited years for. Phase 6 discloses it at the point of configuration.

## Implementation seams (verified at `059d7b0`)

Confirmed by reading, not assumed:

- **Config struct:** `PplnsConfig` (`crates/bp-config/src/lib.rs:557-618`) has `#[serde(deny_unknown_fields)]` and **no `validate()` of its own** — per-field invariants are enforced downstream, so a new key needs no new validation hook in `bp-config`.
- **Validation seam:** `PplnsEngineConfig::try_new` (`crates/bp-pplns-engine/src/config.rs:132-172`) is where fee/payout/budget invariants are checked, reached from `to_pplns_engine_config` (`bin/blitzpool/src/engines.rs:247-270`) at spawn. This is where the bonus range check belongs. It is a **pure function with no subsidy access** — see the next point.
- **⚠️ The subsidy helper is in the wrong crate.** `block_subsidy_sats(height, network)` is `pub(crate)` inside `bp-api` (`crates/bp-api/src/controllers/groups.rs:408`), with callers only in `bp-api` (`groups.rs:430,459`, `info.rs:356`). The drift guard needs it at **engine boot**, which is `bin/blitzpool` + `bp-pplns-engine`. It must be relocated to a shared crate (`bp-common` alongside `Sats`, or `bp-pplns`) and re-exported, keeping its existing tests (`groups.rs:2262-2275`, which cover halvings, regtest's 150-block interval, and the height-64×210k zero case). **Do this as its own commit** — a pure move plus visibility change, no behaviour — so the diff stays reviewable.
- **Drift-guard placement:** because `try_new` is pure and the subsidy needs an RPC height, the *range* check goes in `try_new` and the *drift* warn goes in `spawn_pplns` (`bin/blitzpool/src/engines.rs:218-245`), which already awaits `bootstrap_network_difficulty` and so already has RPC in hand. Follow that function's existing best-effort pattern: a failed height fetch must **warn and continue**, never block startup.
- **Config docs:** `blitzpool.example.toml:245-263` is the commented `[pplns]` block; the new key goes after `min_payout_sats` (`:255`).

## Phases

### Phase 0 — Harness and two failing tests (0.5 d)

Fork, branch, worktree, and the measurement spikes are **done**. Baseline `cargo test -p bp-pplns --release` = **53 passing** (45 baseline + 8 spike tests), no production code modified.

- [x] Fork, branch `lottery-pplns` @ `059d7b0`, worktree at `REPOS/blitzpool-lottery-pplns`
- [x] Sizing spikes committed (`spike_bonus_sizing_modes.rs` 4 tests, `spike_bonus_1776.rs` 3, `spike_dust_cliff_1776.rs` 1)
- [ ] Promote the five prior spikes from `.buzz/.scratch/blitzpool-spikes/` into `crates/bp-pplns/tests/`
- [ ] Write the **two currently-failing** ledger tests, before any fix exists:
  - **(a) the abort** — a PPLNS distribution with a duplicated finder, asserting `apply_distribution` succeeds. Fails on `ON CONFLICT DO UPDATE command cannot affect row a second time`. Needs a real Postgres, so it belongs with the DB-backed integration tests, not the pure-math suite.
  - **(b) the drift** — assert `Σ(audit rows) == Σ(coinbase outputs)`. Fails on the `DO NOTHING` silent drop.
- [ ] **Pin test (a) to ≤400 addresses at the 50,000 WU floor.** Per M5d the duplicate forms for every pool from 5 to 400 addresses and vanishes at ~500+ where the trim eats the finder's proportional share. A test at 1000 miners passes for the wrong reason.

**Validation.** Baseline green; both new tests red, each for its own distinct reason.

### Phase 1 — Config key, drift guard, JDP gap (1.5 d)

Larger than rev-2's estimate despite the dropped percent work, because the subsidy-helper relocation and the three-part drift guard are both real.

- [ ] **Commit 1 — relocate `block_subsidy_sats`** out of `bp-api` into a shared crate, make it `pub`, move its tests with it, update the three `bp-api` call sites. Pure move; no behaviour change
- [ ] **Commit 2 — config key.** Add `finder_bonus_sats: Option<u64>` to `PplnsConfig` (`crates/bp-config/src/lib.rs:557-618`), `#[serde(default)]`, default `None` = feature off. Thread through `to_pplns_engine_config` (`bin/blitzpool/src/engines.rs:247-270`) into `PplnsEngineConfig`
- [ ] Range check in `PplnsEngineConfig::try_new` (`crates/bp-pplns-engine/src/config.rs:132`): reject `0` (use `None` to disable) and reject above `MAX_FINDER_BONUS_SATS`, with a new `ConfigError` variant matching the existing style
- [ ] **Commit 3 — the drift guard (D2).** In `spawn_pplns` (`bin/blitzpool/src/engines.rs:218-245`): fetch height, compute bonus-as-fraction-of-miner-cut at the current subsidy, log `info`/`warn`/`error` by the 15%/50% thresholds, and **refuse to start above 95%**. RPC failure warns and continues, matching `bootstrap_network_difficulty`
- [ ] Runtime warn when the 95% clamp binds in `build_coinbase_distribution`, rate-limited
- [ ] Runtime warn when the bonus is suppressed under `min_payout_sats` — today it vanishes with no diagnostic at all
- [ ] Document the key in `blitzpool.example.toml` after `min_payout_sats` (`:255`), commented out, **with the drift table** so the halving behaviour is visible where it's configured
- [ ] **Commit 4 — close the JDP consensus gap (D7):** call `address_to_script` in `parse_user_identifier_as_address` (`crates/bp-stratum-v2/src/jdp/client.rs:656-677`) so an invalid address is refused at token issue as SV1/SV2 mining already do, instead of degrading to an empty coinbase output set
- [ ] ~~Percent key, percent range check, percent→sats resolution, ceiling raise, fee-spike ceiling check~~ — **not building** (absolute mode)

**Validation.** Config round-trip tests including absent/zero/over-ceiling; a subsidy that would clamp fails startup with a message naming the percentage; RPC-down still boots with a warn; a JDP client with a consensus-invalid address is refused a token rather than getting one that fails later. Unit-test the drift thresholds at all six subsidies from the table.

### Phase 2 — Per-address merge in the PPLNS ledger (2.5 d) ⚠️ gate

**The correctness-critical phase, and per M5d the failure is the default outcome for any pool under ~400 addresses, not an edge case.** It is also completely independent of bonus size — 0.1776, 17.76%, and 1.776 BTC produce identical `finder_entries` at every budget from 6k to 200k WU. It is a property of the greedy trim, not the bounty. Shrinking the bonus mitigates nothing.

- [ ] Port the Group-Solo merge (`crates/bp-group-solo-engine/src/engine.rs:912-936` — sums sats *and* percent per address, deterministic insertion order) into `build_writes_from_snapshot` (`crates/bp-pplns-engine/src/engine.rs:611-700`)
- [ ] Merge must cover **both** outputs: the `AuditRow` list *and* the `BalanceWrite` list. The abort is on the balance side (`DO UPDATE`, `crates/bp-db/src/pplns.rs:319-323`), the silent drop on the audit side (`DO NOTHING`, `:416`). Fixing one leaves the other broken
- [ ] Turn both Phase 0 tests green
- [ ] Add the invariant test: `Σ(audit rows) == Σ(coinbase outputs)` with a duplicated finder
- [ ] **Bound the retry.** `bin/blitzpool/src/block_confirmation.rs:234-249` retries `apply_prepared` failures every tick forever against a deterministic error. Add a retry ceiling or escalating alert — a pre-existing weakness the finder bonus makes reachable

**Failure mode if skipped.** The coinbase pays 0.1776 BTC correctly on-chain. `apply_prepared` aborts on every attempt, the block is never booked, `pplns_balance` never updates, every miner's pending credit goes stale, and `block_confirmation` logs `will retry next tick` indefinitely. Verified against a live Postgres (M4): the balance upsert raises `cannot affect row a second time` and the history insert silently dropped 20,000,000 sats from a 217,600,000-sat audit trail.

**Validation.** Both tests green, plus a regtest block-found that books a real bonus and reconciles against the chain.

### Phase 3 — Thread the finder through the PPLNS engine (1 d)

- [ ] Widen `PplnsEngine::build_distribution` (`crates/bp-pplns-engine/src/engine.rs:388`) to take the prospective finder
- [ ] Change the inflight cache key from `u64` to `(u64, AddressId)` (`crates/bp-pplns-engine/src/distribution.rs:175`), mirroring Group-Solo's existing `CacheKey` (`crates/bp-group-solo-engine/src/distribution.rs:130`)
- [ ] Replace `finder_bonus_sats: None, // finder-bonus is a Group-Solo feature` (`crates/bp-pplns-engine/src/distribution.rs:340`) with the configured bonus + finder address
- [ ] Pass `miner_address` as the prospective finder in `pplns_payouts` (`bin/blitzpool/src/payout_resolver.rs:236-254`)
- [ ] **Preserve the invariant that a build never fails over a lost snapshot** — the fallback (`bin/blitzpool/src/payout_resolver.rs:270-276`) hands one miner the entire block via `solo_payouts`. Per-finder fan-out multiplies how often that path is reachable. Explicit test, not just care

**Validation.** Regtest: two connections from different addresses get coinbases differing in exactly one output (M2 predicts index 1); a found block on either books correctly.

**Note.** `inputs_cache` keyed by `()` (`crates/bp-pplns-engine/src/distribution.rs:180`) already shares the Redis window read and Postgres ledger query across concurrent builds, so this does not multiply DB load. Only the pure math fans out.

### Phase 4 — Address-keyed script cache (1 d)

M2 confirms the premise: the payout tail is byte-identical across finders, so `address_to_script` is a pure function of `(network, address)` that never reads sats. Putting sats in the memo key is what defeats it today. Worth doing, but note the measured baseline is ~16% of the distribution math (0.300 vs 1.905 ms/finder), not a dominant term — this is a cheap win, not the bottleneck.

- [ ] Add a `(Network, address) → ScriptBuf` memo beneath the existing outputs cache (`crates/bp-mining-job/src/cache.rs:129`)
- [ ] Route `build_payout_outputs` (`crates/bp-mining-job/src/coinbase.rs:516`) through it
- [ ] **Bound it explicitly** — the existing job cache is TTL-only with no size cap (`ENTRY_TTL = 120s`, `PRUNE_INTERVAL = 10s`); do not add a second unbounded map
- [ ] Assert the improvement as a test, not a claim (measured 442× / 532× / 507× at 100 / 400 / 1000 outputs)

### Phase 5 — Regtest load-test the fan-out (3 d) ⚠️ gate

Still the phase whose answer I do not know. M3 removes the on-chain-reach worry but says nothing about memory.

- [ ] Sweep N ∈ {50, 200, 500, 1000} distinct addresses at a 30 s template cadence
- [ ] **Job cache growth** — per-finder jobs turn ~4 resident entries into ~4 × N, each holding `coinbase_prefix`, `coinbase_suffix`, and both pre-rendered SV1 hex strings (~3× raw coinbase size) on a coinbase carrying the full PPLNS payout list. TTL-only eviction, no size cap. Measure resident memory; add a cap if needed
- [ ] **Redis snapshot keyspace** — one write per template becomes one per distinct address (`snapshot_ttl_secs` default 1200); `delete_all_fingerprinted_snapshots` has more keys to SCAN per apply
- [ ] **SV1 shared-job loss** — `crates/bp-stratum-v1/src/client.rs:840-842` documents that every PPLNS connection currently shares exactly one `MiningJob` per template. That optimization is gone by design. Measure notify-build latency at each N
- [ ] Confirm the autoscaler behaves: `[pplns].coinbase_weight_budget` floor 50,000 WU, stepping on 0.85/0.50 utilization × 1.15
- [ ] **Include a run at ≤400 addresses** so the Phase 2 fix is exercised where the duplicate actually forms (M5d)

**Validation.** A written report with numbers at each N, a recommended maximum, and a go/no-go. **If the memory profile is bad, the correct outcome is "don't ship it" — say so.**

### Phase 6 — Disclosure (1 d)

- [ ] **Publish the haircut arithmetic.** 8 equal miners at the current subsidy (3.125 + 0.05 fees, 1.5% pool fee): a non-finder goes **39,092,187 → 36,872,187 sats, a 5.7% haircut**. Verified against the distribution code, not derived on paper
- [ ] **Publish the drift schedule** (D2 table) — 5.7% now → 11.2% → 21.7% → 40.9% → 73.5%, clamping at halving +5. Miners are entitled to know the deal degrades on a known schedule, and this is the honest cost of a fixed headline number
- [ ] State the EV result plainly: **expectation-neutral for every miner at every size.** It sells variance, not yield
- [ ] State what the expectation math hides: a 30%-of-pool miner collects the bounty often enough to feel it as income; a 0.1% miner experiences it as a per-block haircut against a bounty they will likely never collect. **The scheme is most attractive to the participants it treats worst.** That is the ordinary structure of a lottery, and it should be disclosed rather than marketed
- [ ] Disclose the trim interaction: the bonus output is never trimmed; small miners are. Under a starved budget even the *finder's own* proportional share is trimmed before the bonus (M5d)
- [ ] **Disclose the address policy (D7):** the pool pays the address in the stratum username, validated against consensus rules only. No ownership check, no recovery. A typo sends 0.1776 BTC somewhere unrecoverable. State it **where a miner configures their worker**, not buried in terms
- [ ] Show live expected-time-to-block. Blitzpool's own pool states **42.4 years** at ~3.2 PH/s with zero blocks found — the number a prospective miner needs most

**Validation.** A miner reading the page can state unprompted that their expected earnings are unchanged, their variance is higher, and a typo'd address is unrecoverable.

## Risks

| Risk | Source | Severity | Mitigation |
|---|---|---|---|
| Block pays on-chain but can never be booked; infinite retry | `crates/bp-db/src/pplns.rs:319-323` + `bin/blitzpool/src/block_confirmation.rs:234-249` | **High** — default case for pools <400 addrs (M5d) | Phase 2 merge **and** retry bound |
| Audit trail under-counts vs chain | `crates/bp-db/src/pplns.rs:416` `DO NOTHING` | **High** — silent | Phase 2, both output lists |
| Haircut drifts 5.7% → 73.5% across four halvings, silently | M5a; inherent to absolute mode | **High** — slow, invisible | D2 three-part guard (Phase 1); Phase 6 discloses the schedule |
| Duplicate vanishes at 500+ addresses — a large-scale test passes falsely | M5d | Medium — false confidence | Phase 0 test pinned ≤400; Phase 5 runs both |
| Solo-fallback hands one miner a whole block | `bin/blitzpool/src/payout_resolver.rs:270-276`; fan-out multiplies reachability | **High** | Explicit test in Phase 3 |
| Job-cache memory growth (~4 × N, no size cap) | `crates/bp-mining-job/src/cache.rs:79-83` | Medium | Phase 5; add a cap |
| Subsidy helper relocation touches `bp-api` call sites | `pub(crate)` at `crates/bp-api/src/controllers/groups.rs:408` | Low | Its own commit, pure move, existing tests travel with it |
| Bonus silently dropped under the dust floor | `crates/bp-pplns/src/distribution.rs:175`, M5e | Low — unreachable by 0.1776, reachable by typo | Phase 1 warn |
| Typo'd address paid 0.1776 BTC irreversibly | Accepted policy (D7) | Medium — accepted | Phase 6 disclosure at point of configuration |
| JDP issues tokens for consensus-invalid addresses | `crates/bp-stratum-v2/src/jdp/client.rs:656-677` | Medium | Phase 1 |
| Redis snapshot keyspace + SCAN cost | `crates/bp-pplns-engine/src/window/mod.rs:485-500` | Medium | Phase 5 sizing |
| Small miners bear the variance | [[../wiki/concepts/variance-and-risk-shifting\|Variance & Risk-Shifting]] | Medium — reputational | Phase 6; property, not bug |
| Loss of SV1 shared-job optimization | `crates/bp-stratum-v1/src/client.rs:840-842` | Low-Medium | Phase 5 latency |
| Upstream immaturity | Created 2026-06-23, 1 star, unaudited, single primary author | Medium | Pinned to `7815884`; AGPL-3.0-or-later applies to any deployment |

## Effort

| Phase | Days | Gate |
|---|---|---|
| 0 — harness + 2 failing tests | 0.5 | |
| 1 — config key, drift guard, JDP gap | 1.5 | |
| 2 — per-address merge + retry bound | 2.5 | ⚠️ correctness |
| 3 — thread the finder through | 1 | |
| 4 — address-keyed script cache | 1 | |
| 5 — regtest load-test | 3 | ⚠️ go/no-go |
| 6 — disclosure | 1 | |
| **Total** | **9.5** | |

Phases 1, 2, and 4 are independent and parallelizable. Phase 3 depends on 1; Phase 5 depends on 3 and 4.

## Open questions

1. **Does the operator want a halving playbook?** The D2 guard warns and (at 95%) refuses to start, but someone still has to decide what the number becomes. Worth writing down before the first halving rather than at it. Not blocking.
2. **Should the retry bound be a separate upstream PR?** The infinite `apply_prepared` retry is a pre-existing weakness this feature merely makes reachable. Likely a cleaner contribution on its own.
3. **Block withholding.** Concentrating a growing fraction of the miner cut in the finder's own output changes the withholding calculus. Unanalyzed for either implementation. Low priority at 5.7%, rising with each halving.
4. **SV2-JD bonus eligibility.** Who is the "finder" when the client built the template? Undefined. Out of scope; needs a decision before enabling both paths together.
5. **No published critique exists.** Nine search framings found no substantive public analysis of large flat finder bounties, for or against. The variance analysis here is **constructed, not cited**.

## Verification record

All measurements at `7815884`, branch `lottery-pplns`, head `059d7b0`, worktree `REPOS/blitzpool-lottery-pplns`. `cargo test -p bp-pplns --release` = **53 passing**, no production code modified.

- `crates/bp-pplns/tests/spike_bonus_sizing_modes.rs` (`059d7b0`) — M5a drift schedule, M5d duplicate-entry frequency by pool size, M5e dust-suppression reachability. 4 tests
- `crates/bp-pplns/tests/spike_bonus_1776.rs` (`8235dac`) — clamp behaviour across halvings, positional divergence, cap boundary. 3 tests
- `crates/bp-pplns/tests/spike_dust_cliff_1776.rs` (`8235dac`) — on-chain reach vs baseline by pool size and era. 1 test
- M4 — Postgres schema mirror of `pplns_balance` + `pplns_payout_history` against a local instance; `DO NOTHING` drop and `DO UPDATE` abort both reproduced. Scratch schema dropped afterward
- Phase 6 haircut figures (39,092,187 → 36,872,187 sats, 5.68%) re-derived through the distribution code, not by hand
- Implementation seams in "Implementation seams" above each confirmed by reading the cited lines at `059d7b0`
- Prior spikes preserved at `.buzz/.scratch/blitzpool-spikes/` (5 files), pending promotion in Phase 0

**Method note.** The first version of the sizing spike extracted the bonus with `max()` over the finder's payout entries, which silently returns the finder's *proportional share* whenever that exceeds the bonus — true in any small pool — and misreported a 0.1776 BTC bonus as 0.368 BTC. Correct extraction is positional: `distribution.rs` pushes the fee output (`:641`), then the bonus (`:651`), then miners sorted descending (`:673`), so the bonus is the first non-fee entry. Any future spike reading this code should do the same.
