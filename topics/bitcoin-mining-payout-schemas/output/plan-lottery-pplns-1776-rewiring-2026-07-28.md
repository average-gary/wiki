---
title: "Plan: rewiring Blitzpool for a coinbase-direct lottery-PPLNS (0.1776 BTC or 17.76% finder bonus)"
type: plan
format: roadmap
generated: 2026-07-28
revised: 2026-07-28
status: superseded
superseded_by: "plan-lottery-pplns-0.1776-build-2026-07-28.md"
supersedes: "plan-coinbase-direct-lottery-pplns-2026-07-27.md"
base_commit: 7815884c7c531561e1302ca311070d09f97c1c3c
fork: average-gary/blitzpool-server-rust
branch: lottery-pplns
upstream: warioishere/blitzpool-server-rust (AGPL-3.0-or-later)
sources:
  - "output/plan-coinbase-direct-lottery-pplns-2026-07-27.md"
  - "wiki/concepts/lottery-pplns.md"
  - "raw/repos/2026-07-27-blitzpool-finder-bonus-code-read.md"
  - "raw/data/2026-07-27-parasite-blitzpool-onchain-and-code-verification.md"
  - "wiki/concepts/pplns.md"
  - "wiki/concepts/variance-and-risk-shifting.md"
summary: "Roadmap for a coinbase-direct lottery-PPLNS on Blitzpool at the operator's revised sizing: 0.1776 BTC to start, with 17.76%-of-miner-cut as the scaling alternative. Five spikes against the pinned clone. Both candidate values sit under the repo's existing 1 BTC ceiling, so no ceiling work is needed; the two are not equivalent (17.76% is ~3.1x the absolute figure today); and the duplicate-finder ledger abort is the common case at the production weight-budget floor, not an edge case."
---

# Plan: rewiring Blitzpool for a coinbase-direct lottery-PPLNS

> **⚠️ SUPERSEDED — the sizing question this plan left open has been answered.** The operator chose **0.1776 BTC absolute**, for the pool's thematic identity. Percent mode is not being built. Build from **[the 0.1776 BTC build plan](plan-lottery-pplns-0.1776-build-2026-07-28.md)**, which drops the percent work, promotes the halving-drift guard to load-bearing, and adds verified implementation seams. This document is retained for its measurements (M1–M5) and the absolute-vs-percent comparison, which remain accurate.

> Revises [the 2026-07-27 roadmap](plan-coinbase-direct-lottery-pplns-2026-07-27.md) for three operator decisions: a finder bounty of **0.1776 BTC to start** (with **17.76% of the miner cut** under consideration as a scaling alternative), **no proof of address ownership**, and configurability per deployment. Fork created, branch cut, five spikes run at `7815884`.

**Fork:** https://github.com/average-gary/blitzpool-server-rust
**Branch:** `lottery-pplns` (worktree at `REPOS/blitzpool-lottery-pplns`, cut from `7815884`)

## Recommendation up front

**Ship percent-of-miner-cut as the mechanism.** It is halving-invariant, cannot hit the internal 95% clamp at any subsidy, and never needs an operator to revisit config at a halving. Absolute-sats mode should exist as an optional ceiling, not as the primary knob.

**On the number itself: the two proposals are not two spellings of the same thing.** At the current subsidy, 17.76% of the miner cut resolves to **0.555 BTC — about 3.1× the 0.1776 BTC figure** (M5). If the intent is "start conservative," 17.76% is not that; the percent that reproduces 0.1776 BTC exactly today is **5.68%**. So:

- Want today's economics, permanently, with no cliff → **percent mode at 5.68%**.
- Want the larger jackpot and the memorable number → **percent mode at 17.76%**, understanding it is a deliberate 3× increase and a permanent 17.8% haircut on every non-finder.
- Want a fixed headline BTC figure → **absolute at 0.1776 BTC** is genuinely viable (it does not clamp for five halvings, ~20 years), but the *proportion* silently drifts upward the whole way: 5.7% of the cut today, 11.2% after one halving, 21.7% after two, 40.9% after three, 73.5% after four. The scheme becomes progressively more lottery-like with nobody changing a setting.

Either 1776-flavoured value keeps the branding. Only percent mode keeps it *true* indefinitely — "17.76% of every block" never needs restating, whereas "0.1776 BTC" is a claim with a shelf life.

## What changed from the prior revision

The architecture is unchanged and still small: the finder-bonus mechanism already exists in the shared distribution math, and PPLNS declines it in one line. Dropping from 1.776 BTC to these values removes work and softens two risks.

| # | Finding | Effect |
|---|---|---|
| 1 | **Both candidates sit under `MAX_FINDER_BONUS_SATS`** (17,760,000 and 55,542,180 vs the `100_000_000` ceiling) | **The Phase 1 ceiling-raise work item disappears entirely.** No constant to change, no cap tests to update |
| 2 | 0.1776 BTC absolute does not clamp until **halving +5**, not the next one | The cliff is no longer imminent, but the haircut drift is continuous and silent |
| 3 | 17.76% of the cut **cannot clamp at any subsidy** | Percent mode is clamp-proof by construction (17.76 < 95) |
| 4 | The two values differ by **~3.1×** today, and percent mode tracks tx fees | A sizing decision, not a formatting one — needs an explicit choice |
| 5 | The duplicate-finder ledger abort fires for **every pool up to ~400 addresses** at the 50,000 WU budget floor | Phase 2 severity holds; my prior "intermittent, only on roomy blocks" framing understated it |

Carried forward unchanged from the prior revision: the ledger-abort correction (below), D1, D3, D4, D5, D7, and the M2/M3/M4 measurements.

### Correction to the record

The 2026-07-27 plan said the duplicate-finder hazard produces "accounting drift, not a crash — which is worse, because nothing alerts." **That was wrong, and wrong in the safer direction.** Verified against a live Postgres mirroring both schemas:

- `pplns_payout_history` is `ON CONFLICT ("blockHeight", address) DO NOTHING` (`crates/bp-db/src/pplns.rs:416`) → the duplicate row *is* silently dropped. 20,000,000 sats vanished from the audit trail in the test. This half of the prior claim holds.
- `pplns_balance` is `ON CONFLICT (address) DO UPDATE` (`crates/bp-db/src/pplns.rs:319-323`) → Postgres raises **`ON CONFLICT DO UPDATE command cannot affect row a second time`**. This half does not.

Both writes are in one transaction (`crates/bp-pplns-engine/src/ledger/mod.rs:100-137`), so the abort rolls back the whole booking. The real failure mode is: **the block pays correctly on-chain, and the pool can never book it.** `bin/blitzpool/src/block_confirmation.rs:246-249` logs `will retry next tick` and retries a deterministic error forever.

**A second, smaller correction, from this revision.** I previously called that abort "intermittent — it fires on roomy blocks and not starved ones," and framed the starved-budget case as a silver lining. Re-measured at the autoscaler's actual 50,000 WU floor (M5d), the duplicate forms for **every pool size from 5 to 400 addresses**, and only disappears at ~500+ where the trim eats the finder's proportional share. For a pool of realistic size this is the **default** outcome on any found block, not an occasional one. The silver lining was backwards: the starved case is the rare one.

## Measurements

Five spikes at `7815884`, release build, committed on the branch as tests. The Postgres checks (M4) were run against a local instance.

### M5 — Absolute vs percent sizing (new, this revision)

`crates/bp-pplns/tests/spike_bonus_sizing_modes.rs`, 4 tests. Eras are indexed by **halving offset**, not calendar year — the subsidy schedule is what matters and dating it invites an off-by-one on the cadence. 1.5% pool fee, 0.05 BTC tx fees, measured at both 8 and 500 equal miners (identical results at both).

#### M5a — 0.1776 BTC absolute: no clamp for five halvings, but continuous drift

| Halving | Subsidy | Miner cut | Bonus paid | % of cut | Clamped | Non-finder haircut |
|---|---|---|---|---|---|---|
| +0 | 3.125 | 3.127375 | 0.177600 | 5.68% | no | **5.7%** |
| +1 | 1.5625 | 1.588313 | 0.177600 | 11.18% | no | 11.2% |
| +2 | 0.78125 | 0.818781 | 0.177600 | 21.69% | no | 21.7% |
| +3 | 0.390625 | 0.434016 | 0.177600 | 40.92% | no | 40.9% |
| +4 | 0.195313 | 0.241633 | 0.177600 | 73.50% | no | 73.5% |
| +5 | 0.097656 | 0.145441 | **0.138169** | 95.00% | **yes** | 95.0% |

Reward conserved exactly at every row. The clamp is `((reward_for_miners as f64) * 0.95).floor()` at `crates/bp-pplns/src/distribution.rs:172`.

The cliff is ~20 years out rather than ~2, which is the main improvement over 1.776 BTC. But the drift in between is the real story: **the pool's character changes at every halving without any config change.** A miner who joins today at a 5.7% haircut is, three halvings later, paying 40.9% — for the same nominal jackpot.

#### M5b — 17.76% of the miner cut: flat forever

| Halving | Subsidy | Miner cut | Bonus paid | % of cut | Clamped | Haircut |
|---|---|---|---|---|---|---|
| +0 | 3.125 | 3.127375 | **0.555422** | 17.76% | no | 17.8% |
| +1 | 1.5625 | 1.588313 | 0.282084 | 17.76% | no | 17.8% |
| +2 | 0.78125 | 0.818781 | 0.145416 | 17.76% | no | 17.8% |
| +4 | 0.195313 | 0.241633 | 0.042914 | 17.76% | no | 17.8% |
| +8 | 0.012207 | 0.061274 | 0.010882 | 17.76% | no | 17.8% |

Nine halvings tested, all identical in proportion. The test **asserts** the clamp never binds — that is the structural guarantee, not an observation.

#### M5c — Fee sensitivity: percent mode tracks the mempool

At the current subsidy, varying tx fees:

| Tx fees | Block reward | Absolute bonus | Percent bonus | Ratio |
|---|---|---|---|---|
| 0.00 | 3.1250 | 0.177600 | 0.546675 | 3.08× |
| 0.05 | 3.1750 | 0.177600 | **0.555422** | 3.13× |
| 0.25 | 3.3750 | 0.177600 | 0.590409 | 3.32× |
| 1.00 | 4.1250 | 0.177600 | 0.721611 | 4.06× |
| 5.00 | 8.1250 | 0.177600 | **1.421355** | 8.00× |

Absolute mode is fee-invariant (asserted). Percent mode makes the jackpot swell on high-fee blocks — arguably a marketing asset ("the jackpot grows with the mempool"), but it means the advertised figure is a range, not a number.

#### M5d — The duplicate-entry hazard is the common case

`finder_entries == 2` is what triggers the Phase 2 ledger abort. At the autoscaler's 50,000 WU floor, current subsidy, 0.1776 BTC:

| Pool size | 5 | 10 | 25 | 50 | 100 | 200 | 300 | 400 | 500 | 1000 |
|---|---|---|---|---|---|---|---|---|---|---|
| Finder entries | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 1 | 1 |
| Outcome | abort | abort | abort | abort | abort | abort | abort | abort | hidden | hidden |

Also measured: the hazard is **independent of bonus size** — 0.1776 BTC, 17.76%, and the old 1.776 BTC all produce identical `finder_entries` at every budget from 6,000 to 200,000 WU. It is a property of the trim, not the bounty. Shrinking the bonus does not mitigate it at all.

#### M5e — Dust suppression is unreachable by either config

`bonus_emitted = capped_bonus >= min_payout` (`crates/bp-pplns/src/distribution.rs:175`) drops the bonus **silently** if it falls under the floor. Neither candidate can reach that: 0.1776 BTC is a constant 17,760,000 sats, and 17.76% of the cut stays above 546 sats through the entire subsidy schedule. Confirmed the path *is* silent when a config does reach it — a 100-sat request emits no bonus output, no warning, and still conserves the reward. Worth a startup guard anyway (D6), since it is reachable by operator typo.

### M1–M4 — carried forward

Measured at 1.776 BTC. All four remain valid for the smaller values; where the finding is a bound, 1.776 BTC is the **conservative** case and the smaller bonuses are strictly safer.

- **M1 — the clamp binds and mutates the scheme silently.** At 1.776 BTC it bound at the next halving; at 0.1776 BTC it binds at halving +5 (M5a). The mechanism and its silence are unchanged, which is what D6 addresses.
- **M2 — one output differs per finder, even when clamped.** 202/202 entries, exactly 1 differing position (index 1), reward conserved. This is the property the whole fan-out design rests on, so D3 and D5 carry over. (M5d supersedes M2's characterisation of the starved-budget case.)
- **M3 — the dust cliff does not happen.** On-chain outputs with vs without the bonus: 11/10, 101/100, 501/500, 1157/1157 at 10/100/500/2000 miners. The bonus costs exactly one extra output and pushes nobody into pending credit; even at the +2 subsidy with 500 miners the per-miner remainder is ~8,187 sats against a 546-sat floor. **Since this held at 1.776 BTC, it holds a fortiori at 0.1776 BTC and at 17.76%.** This is the result that says the coinbase-direct premise is sound.
- **M4 — the ledger failure, reproduced.** History (`DO NOTHING`): three rows offered, two landed, 20,000,000 sats missing from the audit trail. Balance (`DO UPDATE`): `cannot affect row a second time`, zero rows, transaction dead.

## Architecture decisions

D1, D3 (address-keyed script memo), D4 (no CTV), D5 (untouched fingerprint), and D7 carry over unchanged. D2 and D6 are revised by M5.

### D1 (unchanged): Bonus-on-top, not winner-only

The finder collects the bounty *and* their proportional share. Exactly EV-neutral for every miner at every size. This is what the existing shared math does, and it is the direct cause of the duplicate the ledger cannot handle. Accept the duplicate; fix the books.

### D2 (revised): Percent-of-miner-cut is the primary knob; absolute is an optional ceiling

Previously escalated to "mandatory" because 1.776 BTC clamped at the very next halving. At 0.1776 BTC that specific urgency is gone — the clamp is five halvings out (M5a). **The decision stands anyway, for a different and better reason:** absolute mode's haircut drifts 5.7% → 73.5% across four halvings with no config change and no log line. Percent mode holds its economics flat forever and is structurally clamp-proof (M5b).

**Decision.** `finder_bonus_percent: f64` is primary; `finder_bonus_max_sats: Option<u64>` is an optional absolute ceiling for operators who want a hard cap on a single block's payout. `GET /api/pplns/groups/finder-bonus-cap` (`crates/bp-api/src/controllers/groups.rs:445-461`) already returns live height + subsidy, which is exactly what percent → sats resolution needs.

**Both candidate values are supported by the same code.** 0.1776 BTC absolute is expressible as `finder_bonus_percent = 5.68` today, or as `finder_bonus_max_sats = 17_760_000` with a percent above it if the operator genuinely wants a fixed BTC figure. Shipping percent-primary costs nothing extra and does not foreclose the absolute headline.

**Consequence.** In percent mode the displayed BTC figure must be derived at runtime, and on high-fee blocks it moves (M5c). Marketing copy should quote the percentage and show a live derived estimate, not a hardcoded constant.

### D6 (revised): No ceiling change needed — but make the clamp and the dust floor loud

**The ceiling-raise work item is deleted.** `MAX_FINDER_BONUS_SATS = 100_000_000` (`crates/bp-group-mgmt/src/constants.rs:21-25`) rejected 1.776 BTC. It does not reject either new candidate: 17,760,000 sats (absolute) and 55,542,180 sats (17.76% at the current subsidy) both sit comfortably under it. Its doc comment — *"1 BTC is already absurd as a per-block bonus… anything bigger is almost certainly a config typo"* — is now consistent with the design rather than in conflict with it. **Leave the constant, the validator (`crates/bp-group-mgmt/src/group.rs:318`), and its cap tests (`:541-551`) untouched.**

One forward-looking caveat: in percent mode the resolved sats figure grows with tx fees. At 17.76%, a block with ~5 BTC of fees resolves to 1.42 BTC (M5c) — which *would* exceed the existing ceiling if that validator is on the resolution path. Phase 1 must check whether the percent→sats resolution passes through `validate_round_reset`; if it does, the ceiling becomes a fee-spike failure mode and needs either raising or bypassing for the resolved (as opposed to configured) value.

**What still needs building — make the silent paths loud:**

1. **Percent range check at config load:** reject outside `(0, 95]`. Cheap, catches the obvious typo class.
2. **Startup rejection** when the configured percent would clamp at the *current* subsidy — fail to start, don't clamp silently.
3. **Runtime warn** when the 95% clamp actually binds at build time, so a halving crossing appears in logs rather than in miner complaints.
4. **Runtime warn when the bonus is dropped for being under `min_payout_sats`** (M5e). Unreachable by either candidate config, but reachable by typo, and today the finder simply doesn't get paid with no diagnostic at all.

Because the operator's position is that users own their inputs, the pool's *own* config is the one place a typo is the operator's responsibility. Guard it there.

### D7 (unchanged): No ownership proof — accept it, and don't build a safety net that implies otherwise

The operator's decision, and it is defensible: the pool validates against consensus rules via `address_to_script` (`crates/bp-mining-job/src/address.rs:39-45`) and pays what the miner asked for. This matches every SV1/SV2 path today (`crates/bp-stratum-v1/src/client.rs:497-501` disconnects on an unparseable address) and is how Blitzpool already works.

**Decision: change nothing in the auth path.** Do not gate bonus eligibility on ownership. Do not add a confirmation step. The "opt-in ownership requirement" item from the prior Phase 6 is dropped.

**One thing does get fixed, and it is not about ownership.** The Job Declaration path validates *less* than the mining paths: `parse_user_identifier_as_address` (`crates/bp-stratum-v2/src/jdp/client.rs:656-677`) calls `AddressId::new` but **not** `address_to_script`, so a shape-valid-but-not-consensus-valid address gets a job token and fails later at `jdp/dynamic_outputs.rs:174`, whose production hook degrades to `coinbase_outputs: vec![0u8]` (`bin/blitzpool/src/jdp_hooks.rs:210-226`). That is a **consensus-validation gap** — precisely the one check the operator does want enforced. Phase 1 closes it. No signature from anyone is required.

**Consequence.** A typo sends the bounty to a valid address that isn't the miner's, irreversibly, on a block they may have waited years for. That is the accepted policy. Phase 6 discloses it — disclosure, not prevention.

## Implementation phases

Effort is **~10 days**, down from ~10.5 with the ceiling work removed.

### Phase 0 — Branch, harness, and two failing tests (1 day)

Fork and branch are **done**: `average-gary/blitzpool-server-rust`, branch `lottery-pplns` at `7815884`, worktree at `REPOS/blitzpool-lottery-pplns`. Baseline `cargo test -p bp-pplns --release` = **45 passing** (40 lib + 5 integration).

- [x] Fork, branch, worktree, baseline
- [x] Commit the 1.776 BTC spikes as tests (`spike_bonus_1776.rs`, `spike_dust_cliff_1776.rs` — 4 tests)
- [x] Commit the sizing-mode spike (`spike_bonus_sizing_modes.rs` — 4 tests, M5a–M5e). Suite now **53 passing**
- [ ] Promote the five prior spikes from `.buzz/.scratch/blitzpool-spikes/` into `crates/bp-pplns/tests/`
- [ ] Write the **two currently-failing** ledger tests, before any fix exists:
  - **(a) the abort** — a PPLNS distribution with a duplicated finder, asserting `apply_distribution` succeeds. Fails on the `DO UPDATE` violation. Needs a real Postgres, so it belongs with the DB-backed integration tests, not the pure-math suite.
  - **(b) the drift** — assert `Σ(audit rows) == Σ(coinbase outputs)`. Fails on the `DO NOTHING` drop.
- [ ] **Pin test (a) to a pool size that actually produces the duplicate.** Per M5d, ≤400 addresses at 50,000 WU does; 500+ does not. A test at 1000 miners passes for the wrong reason

**Validation.** Baseline green; both new tests red, each for its own distinct reason.

### Phase 1 — Config surface + consensus-validation gap (1 day)

Down from 1.5 days: no ceiling to raise, no cap tests to rewrite.

- [ ] Add `finder_bonus_percent: f64` and `finder_bonus_max_sats: Option<u64>` to `PplnsConfig` (`crates/bp-config/src/lib.rs:557-618`) — no `[pplns]` finder key exists today
- [ ] Percent range check at load: reject outside `(0, 95]` (D6.1)
- [ ] **Reject at startup** any percent that would clamp at the current subsidy (D6.2)
- [ ] **Warn at build time** when the 95% clamp binds (D6.3)
- [ ] **Warn when the bonus is suppressed under `min_payout_sats`** (D6.4) — today it vanishes with no diagnostic
- [ ] Resolve percent → sats against live `block_reward_sats` at build time, not at config load
- [ ] **Check whether resolved sats pass through `validate_round_reset`** — if so, a fee spike in percent mode can trip `MAX_FINDER_BONUS_SATS` (D6 caveat). Decide raise-vs-bypass with a test at 5 BTC of fees
- [ ] Document both keys in `blitzpool.example.toml:244-262`, defaulting **off** (`0.0`)
- [ ] **Close the JDP consensus gap (D7):** call `address_to_script` in `parse_user_identifier_as_address` (`crates/bp-stratum-v2/src/jdp/client.rs:656-677`) so an invalid address is refused at token issue, as SV1/SV2 mining already do — rather than degrading to an empty coinbase output set
- [ ] ~~Raise `MAX_FINDER_BONUS_SATS`~~ — **not needed**; both candidates are under the existing ceiling (M5)

**Validation.** Config round-trip tests; out-of-range fails startup loudly; a JDP client with a consensus-invalid address is refused a token rather than getting one that fails later.

### Phase 2 — Per-address merge in the PPLNS ledger (2.5 days) ⚠️ correctness-critical

Severity unchanged and, per M5d, **more frequently triggered than the prior revision claimed** — it is the default outcome for any pool under ~400 addresses, and it is independent of bonus size.

- [ ] Port the Group-Solo merge (`crates/bp-group-solo-engine/src/engine.rs:912-936` — sums sats *and* percent per address, deterministic insertion order) into `build_writes_from_snapshot` (`crates/bp-pplns-engine/src/engine.rs:644-660`)
- [ ] Merge must cover **both** outputs: the `AuditRow` list *and* the `BalanceWrite` list. The abort is on the balance side, the drift on the audit side. Fixing one leaves the other broken
- [ ] Turn both Phase 0 tests green
- [ ] Add the invariant test: `Σ(audit rows) == Σ(coinbase outputs)` with a duplicated finder
- [ ] **Bound the retry.** `bin/blitzpool/src/block_confirmation.rs:246-249` retries `apply_prepared` failures every tick forever, on a deterministic error. Add a retry ceiling or escalating alert — a pre-existing weakness the finder bonus makes reachable, worth fixing regardless of the merge

**Failure mode if skipped.** The coinbase pays the bounty correctly. `apply_prepared` aborts on every attempt. The block is never booked, `pplns_balance` never updates, every miner's pending credit is stale, and `block_confirmation` logs `will retry next tick` indefinitely. For a pool of realistic size this is the expected outcome, not a rare one (M5d).

**Validation.** Both tests green, plus a regtest block-found that books a real bonus and reconciles against the chain.

### Phase 3 — Thread the finder through the PPLNS engine (1 day)

Unchanged.

- [ ] Widen `PplnsEngine::build_distribution` (`crates/bp-pplns-engine/src/engine.rs:388`) to take the prospective finder
- [ ] Change the inflight cache key from `u64` to `(u64, AddressId)` (`crates/bp-pplns-engine/src/distribution.rs:175`), mirroring Group-Solo's `CacheKey` (`crates/bp-group-solo-engine/src/distribution.rs:130`)
- [ ] Replace `finder_bonus_sats: None` at `crates/bp-pplns-engine/src/distribution.rs:340` with the configured bonus + finder address
- [ ] Pass `miner_address` as the prospective finder in `pplns_payouts` (`bin/blitzpool/src/payout_resolver.rs:236-254`)
- [ ] **Preserve the invariant that a build never fails over a lost snapshot** — the fallback (`bin/blitzpool/src/payout_resolver.rs:270-276`) hands one miner the entire block via `solo_payouts`. Per-finder fan-out multiplies how often that path is reachable. Explicit test, not just care

**Validation.** Regtest: two connections from different addresses get coinbases differing in exactly one output (M2 predicts index 1); a found block on either books correctly.

**Note.** `inputs_cache` keyed by `()` (`crates/bp-pplns-engine/src/distribution.rs:180`) already shares the Redis window read and Postgres ledger query across concurrent builds, so this does not multiply DB load. Only the pure math fans out.

### Phase 4 — Address-keyed script cache (1 day)

Unchanged. M2 confirms the premise (payout tail byte-identical across finders). Measured 442× / 532× / 507× at 100 / 400 / 1000 outputs — worth doing, but note the measured baseline is ~16% of the distribution math, not a dominant term.

- [ ] Add a `(Network, address) → ScriptBuf` memo beneath the existing outputs cache (`crates/bp-mining-job/src/cache.rs:129`)
- [ ] Route `build_payout_outputs` (`crates/bp-mining-job/src/coinbase.rs:516`) through it
- [ ] **Bound it explicitly** — the existing job cache is TTL-only with no size cap (`ENTRY_TTL = 120s`, `PRUNE_INTERVAL = 10s`); do not add a second unbounded map
- [ ] Assert the improvement as a test, not a claim

### Phase 5 — Load-test the fan-out on regtest (3 days) ⚠️ the real gate

Unchanged, and still the phase whose answer I do not know. M3 removes the on-chain-reach worry but says nothing about memory.

- [ ] Sweep N ∈ {50, 200, 500, 1000} distinct addresses at a 30s template cadence
- [ ] **Job cache growth** — per-finder jobs turn ~4 resident entries into ~4 × N, each holding `coinbase_prefix`, `coinbase_suffix`, and both pre-rendered SV1 hex strings (~3× raw coinbase size). TTL-only eviction, no size cap. Measure resident memory; add a cap if needed
- [ ] **Redis snapshot keyspace** — one write per template becomes one per distinct address (`snapshot_ttl_secs` default 1200); `delete_all_fingerprinted_snapshots` has more keys to SCAN per apply
- [ ] **SV1 shared-job loss** — `crates/bp-stratum-v1/src/client.rs:840-842` documents that every PPLNS connection currently shares exactly one `MiningJob` per template. That optimization is gone by design. Measure notify-build latency at each N
- [ ] Confirm the autoscaler behaves: `[pplns].coinbase_weight_budget` floor 50,000 WU, stepping on 0.85/0.50 utilization × 1.15
- [ ] **Include a run at a pool size that produces the duplicate** (≤400 addresses per M5d) so the Phase 2 fix is exercised where it actually fires

**Validation.** A written report with numbers at each N, a recommended maximum, and a go/no-go. **If the memory profile is bad, the correct outcome is "don't ship it" — say so.**

### Phase 6 — Disclosure (1 day)

Revised for the new sizing and for D7.

- [ ] **Publish the haircut arithmetic for whichever mode ships.** At 0.1776 BTC absolute with 8 equal miners at the current subsidy: non-finder goes 39,092,187 → 36,872,187 sats, a **5.7%** haircut. At 17.76%: → 32,149,415 sats, a **17.8%** haircut (M5a/M5b)
- [ ] **If absolute mode ships, disclose the drift schedule**, not just today's number: 5.7% now → 11.2% → 21.7% → 40.9% → 73.5% across the next four halvings, with the 95% clamp at halving +5 (M5a). Miners are entitled to know the deal degrades on a known schedule
- [ ] **If percent mode ships, say so and quote the percentage**, with a live-derived BTC estimate rather than a hardcoded figure — and note the jackpot rises with mempool fees (M5c: 0.55 BTC typical, 1.42 BTC on a 5-BTC-fee block)
- [ ] State the EV result plainly: **expectation-neutral for every miner at every size.** It sells variance, not yield
- [ ] State the distributional consequence the expectation math hides: a 30%-of-pool miner collects often enough to feel it as income; a 0.1% miner experiences it as a per-block haircut against a bounty they will likely never collect. **The scheme is most attractive to the participants it treats worst**
- [ ] Disclose the trim interaction: the bonus output is never trimmed; small miners are. Under a starved budget even the *finder's own* proportional share is trimmed before the bonus (M5d)
- [ ] **Disclose the address policy (D7):** the pool pays the address in the stratum username, validated against consensus rules only. No ownership check, no recovery. A typo sends the bounty somewhere unrecoverable. State it where a miner configures their worker, not buried in terms
- [ ] Show live expected-time-to-block. Blitzpool's own pool states **42.4 years** at ~3.2 PH/s with zero blocks found

**Validation.** A miner reading the page can state unprompted that their expected earnings are unchanged, their variance is higher, and a typo'd address is unrecoverable.

## Risks & mitigations

| Risk | Source | Severity | Mitigation |
|---|---|---|---|
| Block pays on-chain but can never be booked; infinite retry | `crates/bp-db/src/pplns.rs:319-323` `DO UPDATE` + `bin/blitzpool/src/block_confirmation.rs:246-249` | **High** — default case for pools <400 addrs (M5d) | Phase 2 merge **and** a retry bound |
| Audit trail under-counts vs chain | `crates/bp-db/src/pplns.rs:416` `DO NOTHING` | **High** — silent | Phase 2, both output lists |
| Duplicate disappears at 500+ addresses — a large-scale test passes falsely | M5d | Medium — false confidence | Phase 0 test pinned ≤400 addrs; Phase 5 run at both |
| Absolute mode's haircut drifts 5.7% → 73.5% with no config change or log line | M5a | **High** — silent, slow | D2 percent mode; D6 startup rejection + runtime warn |
| Halving silently mutates the scheme to near-solo (5% remainder) | `crates/bp-pplns/src/distribution.rs:172`, M5a | Medium — 5 halvings out at 0.1776 BTC; impossible in percent mode | D2, D6 |
| Percent mode + fee spike trips `MAX_FINDER_BONUS_SATS` | M5c (1.42 BTC at 5 BTC fees) vs `crates/bp-group-mgmt/src/constants.rs:25` | Medium — unverified whether the validator is on this path | Phase 1 check with a 5-BTC-fee test |
| Bonus silently dropped under the dust floor | `crates/bp-pplns/src/distribution.rs:175`, M5e | Low — unreachable by either candidate, reachable by typo | Phase 1 warn (D6.4) |
| Solo-fallback hands one miner a whole block | `bin/blitzpool/src/payout_resolver.rs:270-276`; fan-out multiplies reachability | **High** | Explicit test in Phase 3 |
| Job-cache memory growth (~4 × N, no size cap) | `crates/bp-mining-job/src/cache.rs:79-83` | Medium | Phase 5; add a size cap |
| Typo'd address paid the bounty irreversibly | Accepted policy (D7); `crates/bp-mining-job/src/address.rs:39-45` validates consensus only | Medium — accepted | Phase 6 disclosure at point of configuration |
| JDP issues tokens for consensus-invalid addresses | `crates/bp-stratum-v2/src/jdp/client.rs:656-677` skips `address_to_script` | Medium | Phase 1 |
| Redis snapshot keyspace + SCAN cost | `crates/bp-pplns-engine/src/window/mod.rs:485-500` | Medium | Phase 5 sizing |
| Small miners bear the variance | [[../wiki/concepts/variance-and-risk-shifting\|Variance & Risk-Shifting]] | Medium — reputational | Phase 6; property, not bug |
| Loss of SV1 shared-job optimization | `crates/bp-stratum-v1/src/client.rs:840-842` | Low-Medium | Phase 5 latency |
| Upstream immaturity | Created 2026-06-23, 1 star, unaudited, single primary author | Medium | Pinned to `7815884`; AGPL-3.0-or-later applies to any deployment |

## Effort summary

| Phase | Prior revision | Now | Gate? |
|---|---|---|---|
| 0 — branch, harness, 2 failing tests | 1 d | 1 d | |
| 1 — config + JDP gap (**ceiling work dropped**) | 1.5 d | **1 d** | |
| 2 — per-address merge + retry bound | 2.5 d | 2.5 d | ⚠️ correctness |
| 3 — thread the finder through | 1 d | 1 d | |
| 4 — address-keyed script cache | 1 d | 1 d | |
| 5 — regtest load-test | 3 d | 3 d | ⚠️ go/no-go |
| 6 — disclosure | 1 d | 1 d | |
| **Total** | ~10.5 d | **~10 d** | |

Phases 1, 2, and 4 are independent and parallelizable. Phase 3 depends on 1; Phase 5 depends on 3 and 4.

## Open questions

1. **~~Percent or absolute?~~ Answered for the mechanism; open on the number.** Ship percent-primary (D2). What remains is the operator's call on the *value*: 5.68% (matches 0.1776 BTC today, permanently), 17.76% (a deliberate ~3.1× increase), or absolute 0.1776 BTC with the drift schedule disclosed. Needed before Phase 6, not before Phase 1 — the code supports all three.
2. **Is the 1776 symbolic?** Both candidates preserve it. If the symbolism is the point, percent mode preserves it *and* keeps it accurate indefinitely; absolute mode preserves the digits while the economics drift underneath them.
3. **Does the resolved percent→sats value hit `validate_round_reset`?** New, from M5c. If yes, percent mode has a fee-spike failure mode at 17.76%. Cheap to check in Phase 1.
4. **Should the retry bound be a separate upstream PR?** The infinite `apply_prepared` retry is a pre-existing weakness, not one this feature introduces. Likely a cleaner contribution on its own.
5. **Block withholding.** Concentrating 17.76% of the cut (or a drifting 5.7→73.5%) in the finder's own output changes the withholding calculus. Unanalyzed for either implementation.
6. **SV2-JD bonus eligibility.** Who is the "finder" when the client built the template? Undefined. Out of scope; needs a decision before enabling both.
7. **No published critique exists.** Nine search framings found no substantive public analysis of large flat finder bounties, for or against. The variance analysis here is **constructed, not cited**.

## Verification record

All measurements at `7815884`, branch `lottery-pplns`, worktree `REPOS/blitzpool-lottery-pplns`. Suite: `cargo test -p bp-pplns --release` = **53 passing** (45 baseline + 8 spike tests), no production code modified.

- `crates/bp-pplns/tests/spike_bonus_sizing_modes.rs` (commit `059d7b0`) — M5a–M5e. 4 tests. Asserts percent mode never clamps at nine consecutive subsidies, absolute mode is fee-invariant, and a sub-dust bonus is silently dropped
- `crates/bp-pplns/tests/spike_bonus_1776.rs` (commit `8235dac`) — M1, M2, cap-boundary. 3 tests
- `crates/bp-pplns/tests/spike_dust_cliff_1776.rs` (commit `8235dac`) — M3. 1 test
- M4 — Postgres schema mirror of `pplns_balance` + `pplns_payout_history` against a local instance; `DO NOTHING` drop and `DO UPDATE` abort both reproduced directly. Scratch schema dropped after the test
- Prior spikes preserved at `.buzz/.scratch/blitzpool-spikes/` (5 files), pending promotion in Phase 0

**A note on the M5 method.** The first version of the sizing spike extracted the bonus with `max()` over the finder's payout entries, which silently returned the finder's *proportional share* whenever that exceeded the bonus — true for any small pool — and reported a 0.1776 BTC bonus as 0.368 BTC. The committed version extracts positionally: `distribution.rs` pushes the fee output (`:641`), then the bonus (`:651`), then miners sorted descending (`:673`), so the bonus is the first non-fee entry. Any future spike reading this code should do the same.
