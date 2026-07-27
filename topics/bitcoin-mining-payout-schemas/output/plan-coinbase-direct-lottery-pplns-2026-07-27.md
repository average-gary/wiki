---
title: "Plan: a fully coinbase-direct lottery-PPLNS on Blitzpool"
type: plan
format: roadmap
generated: 2026-07-27
base_commit: 7815884c7c531561e1302ca311070d09f97c1c3c
repo: warioishere/blitzpool-server-rust (AGPL-3.0-or-later)
sources:
  - "wiki/concepts/lottery-pplns.md"
  - "raw/repos/2026-07-27-blitzpool-finder-bonus-code-read.md"
  - "raw/data/2026-07-27-parasite-blitzpool-onchain-and-code-verification.md"
  - "wiki/concepts/pplns.md"
  - "wiki/concepts/parasite-pool.md"
  - "wiki/concepts/variance-and-risk-shifting.md"
  - "wiki/concepts/tides.md"
  - "wiki/concepts/ctv-coinbase-payout-tree.md"
  - "raw/repos/2026-07-27-blitzpool-server-rust-github.md"
summary: "Implementation roadmap for the payout scheme nobody currently ships: a flat configurable bounty to the block finder AND the PPLNS remainder, both paid as direct coinbase outputs of the block that earned them. Six phases against a pinned Blitzpool clone, grounded in a code-level read plus three new spike measurements that overturned the prior cost model."
---

# Plan: a fully coinbase-direct lottery-PPLNS on Blitzpool

> Generated from the [bitcoin-mining-payout-schemas](../_index.md) wiki — 9 articles consulted, 3 new measurements taken against a pinned clone at `7815884`.

## Executive summary

Build the one point in the payout design space that no production pool occupies: a **flat, configurable bounty to whichever miner's share solved the block, plus the PPLNS remainder, with both paid as direct outputs of that block's coinbase.** Parasite Pool ships the bounty half non-custodially but custodies ~68% of the reward; Blitzpool pays everything on-chain but declines the bounty for PPLNS in a single line. Blitzpool already contains every mechanism required — the work is wiring, one correctness fix, and one cache re-key.

Three measurements taken for this plan **overturn the cost model** in the earlier feasibility assessment. The dominant risk I had flagged — defeated script-parse memoization — turns out to be a minor term (0.300 ms/finder at a 1000-output window, ~16% of the distribution math) *and* it is removable ~500× by re-keying one cache on the address instead of the payout list. The reason is a structural property worth stating plainly:

> **Exactly one output differs between any two per-finder distributions.** The carve-out is subtracted from `reward_for_miners` *before* the proportional split, so every non-finder's sats are identical no matter who the finder is. Measured across 200-miner windows at four weight budgets: 1 differing position out of 202, 65, and 30. The divergence is positional, local, and always at index 1.

That single fact is what makes this project small. The plan is **6 phases**, of which one (Phase 2) is correctness-critical and one (Phase 5) is a genuine load-test that has to happen on regtest before any mainnet exposure.

**The honest caveat up front:** this scheme is EV-neutral by construction. It sells variance, not yield, and the variance lands hardest on the smallest miners. Phase 6 is about disclosing that rather than marketing around it.

## What already exists (do not rebuild)

Verified by direct source read at `7815884`, not from the README:

| Mechanism | Location | State |
|---|---|---|
| Bonus carve-out, 95% cap, dust suppression | `crates/bp-pplns/src/distribution.rs:166-175` | complete, shared by PPLNS + Group-Solo |
| Bonus output emission | same file, `:649-657` | complete |
| Weight accounting for the bonus output | same file, `:233-241` | complete |
| Absolute ceiling = exactly 1 BTC | `crates/bp-group-mgmt/src/constants.rs:21-25` | complete |
| Per-connection speculative coinbase build | `bin/blitzpool/src/payout_resolver.rs:36-44` | complete (Solo/Group-Solo/Blockparty) |
| Job cache keyed on the payout list | `crates/bp-mining-job/src/cache.rs:92-104` | complete, designed for this |
| Block-found attribution by content hash | `crates/bp-share/src/lib.rs:221` | complete, no session component |
| Many concurrent distributions per template | `crates/bp-stratum-v2/src/jdp/dynamic_outputs.rs:300` | complete, in production for SV2 JD |
| Confirmation-gated orphan-safe ledger apply | `crates/bp-pplns-engine/src/ledger/mod.rs:74-140` | complete |

The single line that disables it all for PPLNS — `crates/bp-pplns-engine/src/distribution.rs:340`:

```rust
finder_bonus_sats: None, // finder-bonus is a Group-Solo feature
```

## Architecture decisions

### D1: Bonus-on-top, not winner-only

**Context.** [[../wiki/concepts/lottery-pplns|Lottery-PPLNS]] documents two variants. Blitzpool's shared math implements **bonus-on-top** (finder collects the bounty *and* their proportional share, appearing twice in the payout list). Parasite implements **winner-only** — verified in its payout SQL (`WHERE username != COALESCE($2, '')`) and `total_payment_amount = coinbasevalue − COIN_VALUE`.

**Decision: keep bonus-on-top.** It is what the existing code does, and the wiki's EV analysis shows it is the variant that is *exactly* EV-neutral for every miner at every size — P(finding) equals your share of the proportional payout, so expected collection equals expected forfeiture. Winner-only is EV-negative for large miners and EV-positive for small ones, which is a real economic change dressed as an implementation detail.

**Consequence.** The finder appears twice in the payout list. That is fine on-chain (two valid `TxOut`s) and is precisely the thing that breaks the ledger — see Phase 2. Accept the duplicate; fix the books.

### D2: Configure the bounty as a fraction of the miner cut, with an absolute sats override

**Context.** Both existing implementations configure an absolute sats amount (Parasite hardcodes `COIN_VALUE`; Blitzpool uses a per-group DB field). The wiki flags this as a scheduled cliff: 1 BTC is 32% of a 3.125 BTC miner cut today and ~65% after the next halving, after which the 95% cap starts binding and the scheme silently mutates into near-solo.

**Options.**
- **A — absolute sats only.** Matches both prior implementations and the existing `MAX_FINDER_BONUS_SATS` cap. Halving-fragile.
- **B — fraction of miner cut only.** Halving-stable, but loses the "1 BTC" headline that is the entire behavioral premise (the operator's own stated rationale is *"round number bias"*).
- **C — both, fraction as the primary knob, absolute as an optional ceiling.**

**Decision: C.** Configure `finder_bonus_percent` as primary, `finder_bonus_max_sats` as an optional clamp. An operator wanting the Parasite-style headline sets the percent to whatever yields 1 BTC today and gets automatic halving behavior; one wanting a hard number sets the clamp. Neither existing implementation does this, and it costs one extra config field.

**Consequence.** Marketing copy must derive the displayed BTC figure from live subsidy + fees rather than hardcoding it. The existing `GET /api/pplns/groups/finder-bonus-cap` endpoint already returns the current subsidy for exactly this purpose.

### D3: Re-key the script memo on the address, not the payout list

**Context.** This is the decision the new measurements produced, and it reverses my earlier assessment. `crates/bp-mining-job/src/cache.rs:129` memoizes parsed scripts under `OutputsKeyTuple = (Network, u64, &[PayoutEntry])`. A finder change alters the list, invalidating the key, so all N scripts re-parse per finder.

But `address_to_script` (`crates/bp-mining-job/src/address.rs:39-45`) is a pure function of `(network, address)` — **it never reads sats.** Including sats in the memo key is what makes it fragile, and the spike showed the payout tail is byte-identical across finders anyway.

**Measured** (release, Apple silicon, 500 distinct finders per template):

| Payout outputs | Status quo (list-keyed) | Address-keyed | Speedup |
|---|---|---|---|
| 100 | 15.62 ms (0.031 ms/finder) | 0.035 ms | 442× |
| 400 | 62.85 ms (0.126 ms/finder) | 0.118 ms | 532× |
| 1000 | 149.75 ms (0.300 ms/finder) | 0.295 ms | 507× |

**Decision: add a script cache keyed on `(Network, address)`** beneath the existing outputs cache. Leave the outputs cache as-is; it correctly memoizes the assembled `(amount, script)` vector, which genuinely does depend on sats.

**Consequence.** The largest term in the fan-out becomes a per-template constant instead of per-finder. Correction to the record: the earlier assessment called this the *dominant unmeasured* cost. Measured, it was never dominant — 0.300 ms/finder against 1.905 ms/finder for the distribution math. It is worth fixing because it is cheap to fix, not because it was the bottleneck.

### D4: Do not attempt CTV fanout

**Context.** [[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] is the wiki's other route to non-custodial payout at scale, and it directly addresses the coinbase output-count ceiling this design pushes against.

**Decision: explicitly out of scope.** It is gated on a BIP-119 soft fork, regtest-only, and the source itself calls the layered variant "strictly worse" for pool payouts. Blitzpool's existing greedy weight-budget trim already handles output pressure by deferring small miners to pending credit — a worse-fairness/never-worse-validity tradeoff that is already implemented and tested.

**Consequence.** Output count stays bounded by the weight budget. Note the interaction: the trim is greedy-largest-first, so a 1 BTC bonus output is *never* the one trimmed — small miners are. The bonus therefore increases how many miners get paid in credit rather than coin. Phase 6 has to disclose this.

### D5: Keep the fingerprint attribution scheme untouched

**Context.** The obvious fear is that per-finder coinbases break block-found attribution. Verified backwards: `payouts_fingerprint` hashes reward + ordered `(address, sats)` and has **no session or connection component**, which is exactly right — the question the ledger asks is "which distribution did this coinbase pay?", not "who submitted it."

**Decision: change nothing here.** Varying the payout list per finder makes the *existing* fingerprint carry finder information automatically. SV2 Job Declaration already runs many concurrent distinct distributions per template through this same machinery.

**Consequence.** Zero work in the block-found path. This is the single biggest reason the project is small rather than a redesign.

## Implementation phases

### Phase 0 — Branch, harness, and a failing test (0.5 day)

**Goal.** Establish the safety net before touching payout code.

- [ ] Branch from `7815884` in a worktree; confirm `cargo test -p bp-pplns` = 45 passing as the baseline
- [ ] Promote the three throwaway spikes in `.scratch/blitzpool-spikes/` into real tests under `crates/bp-pplns/tests/`
- [ ] Write the **currently-failing** ledger test first: a PPLNS distribution with a finder bonus, asserting the audit trail sums to what the coinbase pays (this is the Phase 2 bug, captured before the fix exists)

**Validation.** Baseline green; the new ledger test red for the right reason.

**Grounding.** The in-tree bonus tests only cover `suppress_matching_debits: true` (the Group-Solo model). The combination this project needs — bonus + PPLNS signed ledger + non-zero opening balances — is untested upstream. Five spike cases already pass against the pure math, including a 10 BTC over-cap clamp and four starved-budget cases.

### Phase 1 — Config surface (0.5 day)

**Goal.** Make the bounty configurable pool-wide, per D2.

- [ ] Add `finder_bonus_percent: f64` and `finder_bonus_max_sats: Option<u64>` to `PplnsConfig` (`crates/bp-config/src/lib.rs:557-617`) — there is no `[pplns]` finder key today
- [ ] Document both in `blitzpool.example.toml:244-262`, defaulting **off** (`0.0`)
- [ ] Validate at load: reject percent outside `[0, 95]`, clamp `max_sats` against `MAX_FINDER_BONUS_SATS`
- [ ] Resolve percent → sats against live `block_reward_sats` at build time, not at config load

**Validation.** Config round-trip tests; a rejected out-of-range value fails startup loudly rather than silently clamping.

### Phase 2 — Port the per-address merge into the PPLNS ledger (2 days) ⚠️ correctness-critical

**Goal.** Make the books agree with the chain when the finder appears twice.

This is the one phase that can cause silent, hard-to-detect financial damage, and it is the reason this project is not a flag flip.

- [ ] Port the Group-Solo merge (`crates/bp-group-solo-engine/src/engine.rs:912-936`, which sums sats *and* percent per address) into `build_writes_from_snapshot` (`crates/bp-pplns-engine/src/engine.rs:644-660`)
- [ ] Verify against the two constraints that make this mandatory: `pplns_payout_history` UNIQUE `(blockHeight, address)`, and the history-gated `bulk_upsert_pplns_balances` in `crates/bp-pplns-engine/src/ledger/mod.rs:74-140`
- [ ] Add a regression test asserting `Σ(audit rows) == Σ(coinbase outputs)` for a distribution containing a duplicated finder
- [ ] Turn the Phase 0 red test green

**Failure mode if skipped.** The coinbase pays correctly; the history insert "silently dedupes" per its own doc comment at `:78-86`; the bonus row vanishes from the audit trail and `totalPaidSats` under-counts what the chain actually paid. **Accounting drift, not a crash** — which is worse, because nothing alerts.

**Validation.** The invariant test above, plus a regtest block-found that books a real bonus and reconciles.

### Phase 3 — Thread the finder through the PPLNS engine (1 day)

**Goal.** Actually pay the bonus.

- [ ] Widen `PplnsEngine::build_distribution` (`crates/bp-pplns-engine/src/engine.rs:388`) to accept the prospective finder
- [ ] Change the inflight cache key from `u64` to `(u64, AddressId)` (`crates/bp-pplns-engine/src/distribution.rs:175`), mirroring Group-Solo's existing `(Uuid, u64, String)` triple
- [ ] Replace the `None` at `crates/bp-pplns-engine/src/distribution.rs:340` with the configured bonus + finder address
- [ ] Pass `miner_address` as the prospective finder in the PPLNS arm of `payout_resolver` (`bin/blitzpool/src/payout_resolver.rs:236`)
- [ ] **Preserve the invariant that a build must never fail over a lost snapshot** — the fallback at `crates/bp-pplns-engine/src/distribution.rs:369-386` hands one miner the *entire block*. Per-finder fan-out multiplies how often that path can be reached, so this deserves an explicit test, not just care

**Validation.** Regtest: two connections from different addresses receive coinbases differing in exactly one output; a found block on either books the correct distribution.

**Note.** The `inputs_cache` keyed by `()` already shares the Redis window read and Postgres ledger query across all concurrent builds, so this does *not* multiply database load. Only the pure math fans out.

### Phase 4 — Address-keyed script cache (1 day)

**Goal.** Remove the script-parse fan-out per D3.

- [ ] Add a `(Network, address) → ScriptBuf` memo beneath the existing outputs cache in `crates/bp-mining-job/src/cache.rs`
- [ ] Route `build_payout_outputs` (`crates/bp-mining-job/src/coinbase.rs:516`) through it
- [ ] Bound it explicitly — the existing job cache is TTL-only with **no size cap** (`ENTRY_TTL = 120s`, `PRUNE_INTERVAL = 10s`); do not add a second unbounded map
- [ ] Assert the ~500× improvement as a test, not a claim

**Validation.** A test showing N-address parse count is once-per-template rather than once-per-finder.

### Phase 5 — Load-test the fan-out on regtest (3 days) ⚠️ the real gate

**Goal.** Find out what actually breaks before a mainnet pool does.

Everything above is bounded work on mechanisms that already exist. This phase is where genuine unknowns live, and it should gate any mainnet exposure.

- [ ] Drive N distinct connected addresses against a regtest pool at a 30 s template cadence; sweep N ∈ {50, 200, 500, 1000}
- [ ] **Job cache growth.** Per-finder jobs turn ~4 resident entries into ~4 × N. Each holds `coinbase_prefix`, `coinbase_suffix`, *and* both pre-rendered SV1 hex strings — roughly 3× the raw coinbase size, on a coinbase carrying the full PPLNS payout list. TTL-only eviction, no size cap. **Measure resident memory; add a size cap if it grows unacceptably.**
- [ ] **Redis snapshot keyspace.** One write per template becomes one per distinct address (`snapshot_ttl_secs` default 1200), and `delete_all_fingerprinted_snapshots` has correspondingly more keys to SCAN after each apply. Commit `44b7a6c` already excluded these from Redis backup on the grounds a busy pool holds "orders of magnitude more of these" — the infrastructure anticipates the shape, but memory needs sizing.
- [ ] **SV1 shared-job loss.** `crates/bp-stratum-v1/src/client.rs:840-842` documents that every PPLNS connection currently shares literally *one* `MiningJob` per template. That optimization is gone by design here. Measure notify-build latency at each N.
- [ ] Confirm the autoscaler behaves: `[pplns].coinbase_weight_budget` floor 50,000 WU, stepping on 0.85/0.50 utilization × 1.15

**Validation.** A written report with numbers at each N, an explicit recommended maximum, and a go/no-go. **If the memory profile is bad, the correct outcome of this phase is "don't ship it" — say so.**

**Grounding.** The concurrency was designed for this (`cache.rs:33-37`: distinct payout sets "must not serialize behind one pool-wide lock", pinned by `concurrent_distinct_keys_build_independently` at `:770`). Designed-for is not the same as measured-at-scale, and this is the number both existing implementations are quietest about.

### Phase 6 — Disclosure, not marketing (1 day)

**Goal.** Tell miners the truth about what they are opting into.

- [ ] Publish the dilution arithmetic: at 1 BTC on a 3.125 BTC subsidy with a 1.5% fee, non-finder payout goes **38,476,562 → 25,976,562 sats — a 32.5% haircut** per block they don't win
- [ ] State the EV result plainly: **expectation-neutral for every miner at every size.** It sells variance, not yield
- [ ] State the distributional consequence, which the expectation math hides: a 30%-of-pool miner collects often enough to feel it as income; a 0.1% miner experiences it almost purely as a per-block haircut against a bounty they will likely never collect. **The scheme is most attractive to the participants it treats worst** — the ordinary structure of a lottery, and worth naming rather than describing as a benefit
- [ ] Disclose the trim interaction from D4: the bonus is never trimmed, small miners are
- [ ] Show live expected-time-to-block. Blitzpool's own pool currently states **42.4 years** at ~3.2 PH/s with zero blocks found — a 32.5% haircut against a bounty on that horizon is the single most important number a prospective miner needs

**Validation.** A miner reading the page can state, unprompted, that their expected earnings are unchanged and their variance is higher.

## Risks & mitigations

| Risk | Source | Severity | Mitigation |
|---|---|---|---|
| Audit trail under-counts vs chain | `bp-pplns-engine/src/engine.rs:644-660` has no per-address merge; history UNIQUE `(blockHeight, address)` | **High** — silent | Phase 2, written test-first in Phase 0 |
| Solo-fallback hands one miner a whole block | `bp-pplns-engine/src/distribution.rs:369-386`; fan-out multiplies reachability | **High** | Explicit test in Phase 3; never fail a build over a lost snapshot |
| Job-cache memory growth (~4 × N entries, no size cap) | `crates/bp-mining-job/src/cache.rs:79-83` | Medium | Phase 5 measurement; add a size cap |
| Redis snapshot keyspace + SCAN cost | `bp-pplns-engine/src/window/mod.rs:485-500`, `:537` | Medium | Phase 5 sizing; commit `44b7a6c` precedent |
| Halving turns the bounty into near-solo | [[../wiki/concepts/lottery-pplns\|Lottery-PPLNS]] § halving-relative configuration | Medium | D2 fraction-based config |
| Small miners bear the variance | [[../wiki/concepts/variance-and-risk-shifting\|Variance & Risk-Shifting]] | Medium — reputational | Phase 6 disclosure; this is a property, not a bug |
| Loss of SV1 shared-job optimization | `bp-stratum-v1/src/client.rs:840-842` | Low-Medium | Phase 5 latency measurement |
| No hop-resistance regression | Blitzpool's 4×-netdiff sliding window is unchanged; the bonus is hop-neutral (depends on luck, not window position) | Low | No action |
| Upstream repo immaturity | Created 2026-06-23, 1 star, unaudited, single primary author | Medium | Pin to `7815884`; the AGPL-3.0-or-later obligation applies to any deployment |

## Effort summary

| Phase | Effort | Gate? |
|---|---|---|
| 0 — branch, harness, failing test | 0.5 d | |
| 1 — config surface | 0.5 d | |
| 2 — per-address ledger merge | 2 d | ⚠️ correctness |
| 3 — thread the finder through | 1 d | |
| 4 — address-keyed script cache | 1 d | |
| 5 — regtest load-test | 3 d | ⚠️ go/no-go |
| 6 — disclosure | 1 d | |
| **Total** | **~9 days** | |

Phases 1, 2, and 4 are independent and parallelizable. Phase 3 depends on 1; Phase 5 depends on 3 and 4.

## Open questions

1. **Is there a defensible way to pick the bounty size?** Since the trade is expectation-neutral, the only principled criterion is the target population's risk preference — which no pool has attempted to elicit. Currently a pure marketing parameter.
2. **Does the lottery actually retain miners?** The claimed benefit is retention through excitement; the only argument on record is behavioral (*"round number bias"*). Parasite's hashrate fell from a ~182 PH/s peak (June 2025) to ~52 PH/s (April 2026) while the bounty was live — weak evidence against, confounded by the broader hobbyist cycle. Its block cadence *accelerated* over the same period, so the picture is genuinely unclear.
3. **Block withholding.** A finder bonus concentrates value in the finder's own coinbase output, changing the payoff structure of [[../wiki/concepts/block-withholding|withholding]] relative to plain PPLNS. Whether that opens a new profitable deviation is unanalyzed for either existing implementation. Flagged as an open question, not a finding.
4. **Interaction with SV2 Job Declaration.** JD clients supply their own payout outputs via ext `0x0003`. Whether a JD client should be eligible for the finder bonus — and who the "finder" even is when the client built the template — is undefined. Out of scope here; needs a decision before enabling both.
5. **No published critique exists to check this against.** Nine search framings found no substantive public analysis of large flat finder bounties, for or against. The variance analysis in this plan is **constructed, not cited** — worth knowing when weighing it.

## Sources consulted

- [[../wiki/concepts/lottery-pplns|Lottery-PPLNS (Finder-Bonus Hybrid)]] — the mechanism, guard rails, EV-neutrality result, the two variants, implementation hazards
- [[../raw/repos/2026-07-27-blitzpool-finder-bonus-code-read|Blitzpool finder-bonus code read @ 7815884]] — every file:line citation in the "what already exists" table and the phase tasks
- [[../raw/data/2026-07-27-parasite-blitzpool-onchain-and-code-verification|Parasite & Blitzpool on-chain + code verification]] — Parasite's winner-only exclusion, its coinbase-direct bounty, Blitzpool's 42.4-year expected block time
- [[../wiki/concepts/parasite-pool|Parasite Pool]] — the closest shipped comparable; the custody split
- [[../wiki/concepts/pplns|PPLNS]] — base scheme, Schrijvers IC parameter sensitivity
- [[../wiki/concepts/variance-and-risk-shifting|Variance & Risk-Shifting]] — the EV-vs-variance framing behind D1 and Phase 6
- [[../wiki/concepts/tides|TIDES]] — the other production coinbase-direct pool; output-count pressure precedent
- [[../wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]] — the rejected alternative in D4
- [[../raw/repos/2026-07-27-blitzpool-server-rust-github|blitzpool-server-rust README capture]] — autoscaler defaults, role split, config surface

### New measurements taken for this plan

Three spikes against `7815884`, release build, preserved at `.buzz/.scratch/blitzpool-spikes/`. Repo tree verified clean at that commit afterward; `cargo test -p bp-pplns` re-confirmed passing.

- `spike_output_divergence2.rs` — positional diff of per-finder payout lists: **1 differing position** out of 202 / 202 / 65 / 30 across roomy, equal-share, starved, and very-starved budgets. Reward conserved exactly in all cases; finder appears exactly twice in all cases.
- `spike_script_parse_cost.rs` — script-parse fan-out: 0.031 / 0.126 / 0.300 ms per finder at 100 / 400 / 1000 outputs, versus 442× / 532× / 507× cheaper with an address-keyed memo.
- `spike_perconn_cost.rs` (from the prior session) — distribution math: 0.193 / 0.738 / 1.905 ms per build at window 100 / 400 / 1000.

**These corrected the prior assessment.** The script-parse term was previously called the dominant unmeasured cost; measured, it is ~16% of the distribution math and largely removable. The measurements do not change the feasibility verdict — they make Phase 4 cheap and move the real risk decisively to Phase 5's memory profile.
