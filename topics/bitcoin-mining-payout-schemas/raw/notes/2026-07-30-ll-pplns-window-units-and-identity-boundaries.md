---
title: "Lessons Learned: PPLNS window units, share retention, and where pool responsibility ends"
type: notes
source: session
date: 2026-07-30
tags: [lessons-learned, pplns, tides, pplns-jd, payout-window, share-retention, difficulty-retarget, xpub-payout-identity, sv2-translator, spec-writing]
lesson_count: 6
category: notes
confidence: high
volatility: cold
verified: 2026-07-30
summary: "N = 8 × D is a share-difficulty count, not 8 blocks — the distinction is a ~100× retention error for a 1% pool. Retention must exceed the current window because an upward difficulty retarget grows the window backwards. And a spec that keeps 'solving' problems the operator considers out of scope is accreting mechanism, not rigor."
---

# Lessons Learned: PPLNS window units, share retention, and where pool responsibility ends

> Extracted from the 2026-07-30 session revising `output/plan-xpub-miner-identity-spec-2026-07-29.md`
> (revision 4). Six lessons: two unit/correctness errors I made and the operator corrected, two
> design-boundary rules, one code-reading finding, one process lesson about spec scope creep.

## Lesson 1: `N = 8 × D` is a count of share difficulty, not a count of blocks

**Category**: correction
**Context**: Pinning the PPLNS payout window in a spec so a retention policy could be written against it. The wiki had the number (`8 × D`) in both [[../../wiki/concepts/tides|TIDES]] and [[../../wiki/concepts/pplns-jd|PPLNS-JD]]; I had to state what it *meant* operationally.
**Symptom**: I wrote "`N = 8 × D` … that is **~8 blocks of work in expectation, ~80 minutes**" into the spec, and repeated it in the log. The operator caught it: *"it's not 8 blocks. it's 8 times the difficulty number of shares."*
**Root cause**: I read "8 × network difficulty" as "the work in 8 blocks" and then silently converted work→time using the **network's** 10-minute block interval. That conversion is only valid for a pool holding 100% of network hashrate. The window is a quantity of **accumulated share difficulty** that *this pool* must accumulate from *its own* miners' shares.
**Fix**: Rewrote the window definition around accumulated share difficulty and added a hashrate→time table making the dependency unmissable:

| Pool share of network hashrate | Time to accumulate `8 × D` |
|---|---|
| 100 % (hypothetical) | ~80 minutes |
| 10 % | ~13 hours |
| 1 % | ~5.5 days |
| 0.1 % | ~55 days |

The wiki already said this plainly and I misread it — TIDES's own parameters line reads *"**N scales with D** (no fixed share count)"*, and the [[../../wiki/concepts/sv2-share-accounting-ext|share-accounting extension]] defines the boundary as a difficulty *accumulation* walked back from the block, not a block tally.

**Rule**: A PPLNS window expressed as a multiple of network difficulty is a **share-difficulty quantity**, and converting it to wall-clock time requires dividing by the *pool's* hashrate, not the network's. For a 1% pool the window is ~5.5 days, not ~80 minutes — a ~100× error. Never let a difficulty-denominated window be restated in blocks or minutes without naming the pool-hashrate assumption.

## Lesson 2: An upward difficulty retarget grows the payout window *backwards*, so retention must exceed the current window

**Category**: discovery
**Context**: Working out how much share history a pool must keep. The operator supplied the mechanism: *"the window can increase during network difficulty adjustment so we have to retain older shares in case the window size increases across a network difficulty adjustment."*
**Symptom**: None yet — this is the class of bug that ships silently. A pool pruning to exactly the current window would pass every test until a retarget.
**Root cause**: `D` changes every 2016 blocks and the window is `8 × D` in accumulated share difficulty. When `D` rises, the window's threshold rises, so walking back from the block accumulates further into share history than before. Shares that sat just *outside* the window at the old `D` fall back *inside* it at the new `D`. Pruning against the pre-retarget edge deletes shares that are about to become payable again.
**Fix**: Made retention a stated spec requirement expressed in accumulated share difficulty, never a clock or block count. Bitcoin clamps retargets to a factor of 4 per period, so `4 × 8 × D = 32 × D` at the current `D` is the worst-case-safe floor, re-evaluated each period. Added a monitoring row (margin between the oldest retained share and the current window edge), a regtest that retargets upward and asserts previously-outside shares are pulled back in and paid, and a restore caution — a ledger pruned under a lower `D` and then restored can leave owed shares simply absent.

**Rule**: When a payout window's size is a function of a *changing* consensus parameter, retention must cover the window's maximum reachable extent, not its current extent. Size it by the parameter's maximum permitted change (Bitcoin's retarget clamp is 4×) and re-evaluate at each adjustment. Pruning to the current window edge is a correctness bug whose first symptom arrives one retarget later.

## Lesson 3: A distinct payout identity is a distinct user — including on the same connection from the same hardware

**Category**: rule
**Context**: I had written a spec section treating a miner changing their descriptor as a "ledger-identity migration" requiring credit carry-forward, and had called it the design's single most important remaining gap.
**Symptom**: Two rounds of operator correction. First: *"if a user changes their username, they can't expect the same account/descriptor to be credited. we should explicitly not support that."* Then, when I kept the analysis around as a documented consequence: *"Stop worrying about payout_ids rotating. don't mention it again. it's the users responsibility to manage their identity. to use, even a new identity on the same connection/miner should be treated as a new user."*
**Root cause**: I treated "one human operates both identities" as a fact the pool possesses and must therefore act on. The pool does not possess it — it sees two distinct `payout_id`s. Inferring the link is precisely the identity-correlation the design exists to avoid. I had also inverted the difficulty: I assumed transport-level rotation (session migration) was hard, when it is just a reconnect, while the part that needed specifying (share retention) was absent from the spec entirely.
**Fix**: Deleted the rotation framing rather than relocating it — the mid-window overlap analysis, the two-outputs-one-operator discussion, the drain-the-window operator advice, and two regtests all removed. The section became a **retention** section. What survived is the merge-granularity rationale: merge on `payout_id`, because anything coarser requires the identity-linking the design refuses to perform.

**Rule**: In a system whose purpose is *not* correlating identities, "these two identities are probably the same person" is not knowledge the system has — so any feature premised on it (migration, merging, dedup, reconciliation) is out of scope by construction, not merely unimplemented. State the boundary and stop analyzing past it.

## Lesson 4: Pool responsibility ends at correct payment plus publication — not at whether the miner notices

**Category**: rule
**Context**: I had flagged, as a residual hazard, that a stale identity restore could pay an address a miner no longer watches, and had recommended reconciling descriptor changes forward.
**Symptom**: Operator: *"we can't hold user's hands, we can only inform them. if they're not watching their wallets, it's not our problem."*
**Root cause**: I'd bundled two different failures under one warning. Paying the *wrong party* is a pool defect. Paying the *right party* at a script they can derive and spend, which they then fail to monitor, is not — and the mitigations available for it are all worse than the problem: retaining balances (which is the FinCEN custody trigger this design avoids) or refusing to pay.
**Fix**: Bounded the caution to what it actually is — a stale restore can only re-point an account at an older descriptor *of its own*, so funds land somewhere that account's holder can derive and spend. The pool's duty is discharged by publishing the receipt endpoint and by the block heights being on the public chain. Separately, the restore case that *does* cost something turned out to be the share ledger, not the identity table.

**Rule**: Distinguish "the system paid the wrong party" (a defect to engineer against) from "the payee didn't look" (not the system's problem). For the latter, the honest deliverable is disclosure plus a discoverable audit trail; engineering further usually means taking custody, which trades a documentation gap for a regulatory one.

## Lesson 5: Aggregation mode in the SV2 Translator collapses per-device identity structurally, not incidentally

**Category**: gotcha
**Context**: Assessing whether the SV2 Translator can forward each V1 device's own descriptor upstream as its payout identity, so a pool can pay per device.
**Root cause**: `TproxyMode::Aggregated` (`miner-apps/translator/src/lib/utils.rs:180-215`) is documented as sharing *"a single extended Sv2 channel"* across all downstream V1 connections, distinguishing devices by extranonce_prefix allocation while *"presenting them as a single entity to the upstream server."* `downstream_message_handler.rs:117-118` collapses every channel id to `AGGREGATED_CHANNEL_ID` (`u32::MAX`, `utils.rs:36`). One upstream channel carries one `user_identity`, and the pool parses payout identity from the channel-open `user_identity`. The only per-device identity path (the `EXTENSION_TYPE_WORKER_HASHRATE_TRACKING` / `TLV_FIELD_TYPE_USER_IDENTITY` per-share TLV) is emitted *only* in non-aggregated mode and is then discarded by the pool (`pool-apps/pool/src/lib/channel_manager/mining_message_handler.rs:919`, `if let Some(_user_identity) = user_identity { /* …in the future */ }`).
**Fix**: Non-aggregated mode becomes a hard requirement of any per-device payout design, documented as a constraint rather than a tuning knob.

**Rule**: Before designing per-device semantics on top of a proxy, check whether the proxy multiplexes devices onto one upstream session. If it presents N devices as one entity, per-device identity is *unrepresentable* upstream regardless of how much of the proxy you refactor — that is a mode requirement, not an effort estimate.

## Lesson 6: A spec section that keeps growing to "solve" a declared non-goal is accreting mechanism, not rigor

**Category**: pattern
**Context**: Across three consecutive turns I documented a mid-window identity-overlap case with increasing thoroughness — consequence analysis, a disclosure obligation, operator advice, two regtests, a monitoring row — for a scenario the operator had already ruled out of scope.
**Symptom**: An explicit instruction to stop: *"don't mention it again."*
**Root cause**: The analysis was internally sound, which made it feel like diligence. But "I found a real consequence" and "this consequence is in scope" are separate questions, and I only asked the first. Each turn's careful documentation of an out-of-scope case pushed genuinely load-bearing content (the window's unit, the retarget retention floor) further down the page — and in fact one of those was still *wrong* while I was polishing the part that didn't matter.
**Fix**: Deleted the section and its downstream propagation rather than trimming it. Replaced the tests and the monitoring row with ones covering the in-scope requirement (difficulty-accumulated window boundary, retarget-driven retention).

**Rule**: When an operator rules something out of scope, remove the analysis rather than demoting it to a documented caveat — a "documented consequence" of a non-goal still consumes review attention and still implies the system must handle it. Check that effort is going to the load-bearing claims: a correct analysis of an out-of-scope case is worth less than a correct *unit* on an in-scope one.

## See also

- [[../../wiki/concepts/pplns|PPLNS]] — the rolling-window mechanism these lessons refine
- [[../../wiki/concepts/tides|TIDES]] — `share_log_window = 8 × current_block_difficulty`, the primary source for lesson 1
- [[../../wiki/concepts/pplns-jd|PPLNS-JD / SLICE]] — converges on the same `8 × D`
- [[../../wiki/concepts/sv2-share-accounting-ext|SV2 Share Accounting Extension]] — the window boundary as a difficulty accumulation
- [[../../wiki/concepts/xpub-payout-identity|xpub Payout Identity]] — lesson 5's Translator constraint
- [[../../output/plan-xpub-miner-identity-spec-2026-07-29|Spec: wildcard-descriptor miner identity]] — the artifact all six lessons were extracted from
