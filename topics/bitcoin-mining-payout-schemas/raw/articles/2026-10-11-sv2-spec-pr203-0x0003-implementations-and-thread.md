---
title: "sv2-spec PR #203 — 0x0003 reference implementation announced (warioishere, 2026-10-11) and the Sep 10–11 fixed-output/custody thread"
url: https://github.com/stratum-mining/sv2-spec/pull/203#issuecomment-6109310390
source: "gh api: sv2-spec issue 203 comments 5608416008, 5618079488, 5618191598, 5620606488, 5621143068, 5621522019, 5621681790, 5627178873, 5627554892, 5631032659, 5636327353, 5636418769, 6109310390; PR 203 commits/timeline/reactions; spec file extensions/0x0003-coinbase-transaction-payouts.md @ 47dbedd; fork PRs warioishere/stratum#1 (9be4023), warioishere/sv2-apps#1 (8e3f907), #2 (ec35ac8), #3 (90b3e3d) via gh pr view/diff; local clone ~/repos/blitzpool-server-rust origin/main b48998f via git show only"
type: articles
category: github-thread
author: warioishere (comment, all four PRs); thread: TheBlueMatt, plebhash, ckolivas, warioishere
date: 2026-10-11
ingested: 2026-10-12
volatility: hot
quality: 4
credibility: medium
confidence: high
tags: [sv2-spec, pr-203, extension-0x0003, coinbase-transaction-payouts, job-declaration, jdc, jds, blitzpool, sri, sv2-apps, stratum, bitcoin-core-sv2, block-reserved-weight, bad-blk-weight, weight-p, pending-ledger, primary-source, code-read]
summary: "On 2026-10-11 warioishere (Blitzpool) told sv2-spec PR #203 that extension 0x0003 now has a runnable JDC side in two fork PRs pinned to the PR's only commit 47dbedd — warioishere/stratum#1 (extensions_sv2 messages, TLV, payout math) and warioishere/sv2-apps#3 (jd-client) — tested on mainnet against Blitzpool's JDS in coinbase-only and full-template mode, plus two unrelated SRI bugs: coinbase-only JDC stops sending custom jobs after a chain-tip update (sv2-apps#1) and the bitcoin-core-sv2 IPC shim reserves max(4*size, 2000) WU instead of TDP's 1168 + 4*size, so a 42-output coinbase with a full mempool is rejected bad-blk-weight (sv2-apps#2). The comment proposes no spec text change; PR #203 has had zero commits, reviews or maintainer replies since 2026-09-10. Code read at the pinned SHAs confirms the library layer is a literal transcription of 47dbedd §3.1/§4/§6/§7.3/§8, that the JDC passes 0-value additional_outputs through verbatim and reserves their size, and that Blitzpool's JDS diverges from 47dbedd on fixed-amount additional_outputs (rejects non-zero, no F term) while interoperating because it only ever sends an empty list. The Sep 10–11 thread settled the F/R fixed-output math and a hard 'no partial payment' MUST, left TheBlueMatt's 'paid subset of static payouts' question and warioishere's §9.3 sentence unanswered, and recorded both sides arguing to freeze the extension at weights + fixed outputs."
---

# sv2-spec PR #203 — the 2026-10-11 implementation report and what sits behind it

Primary trigger: issue comment 6109310390 on [stratum-mining/sv2-spec#203](https://github.com/stratum-mining/sv2-spec/pull/203), created 2026-10-11T13:03:27Z, edited 13:20:35Z (GitHub exposes no edit diff). As of 2026-10-12 it is the last comment on the PR; the only later activity is two reactions (GitGab19 +1 2026-10-12T09:51Z, average-gary eyes 18:02Z).

## 1. The comment, verbatim

> hey, been on 0x0003 for the last few weeks on the pool side, and lately also got the jdc side going in SRI. there's now something you can actually test:
>
> stratum part (messages, tlv, payout math in extensions_sv2): https://github.com/warioishere/stratum/pull/1
> jdc part: https://github.com/warioishere/sv2-apps/pull/3
>
> it follows the spec as it is in this PR right now (47dbedd), so it pins down the current state. if something still changes or gets added to the spec or you still have some corrections in mind, let me know.
>
> to try it just build the JDC from the branch and set `coinbase_transaction_payouts = true` on the upstream. blitzpool's jds speaks 0x0003, I ran it on mainnet with a few bitaxes, cpu miners and NerdQaxes in coinbase-only and full-template mode.
>
> while testing I hit two bugs that have nothing to do with 0x0003, so they're separate:
> - coinbase-only jdc stops sending custom jobs after a chain tip update: https://github.com/warioishere/sv2-apps/pull/1
> - the IPC TP reserves too little block weight for the coinbase, so a bigger coinbase with a full mempool gets `bad-blk-weight` : https://github.com/warioishere/sv2-apps/pull/2
>
> Feel free to take whatever is useful, I can also push those bugfix PRs anytime, or jst pick it as you like.

It is an implementation report. It proposes nothing, asks whether anything will change, and names the exact spec commit it tracks.

## 2. Spec state it pins

- `gh pr view 203 --json commits` → one commit **47dbedd8cd5ecd6d7a2f323bccfe51873e31bef6** (author date 2026-07-26, committer date 2026-09-10T14:37:13Z, parent 0f38d51); last force-push 2026-09-10T14:37:52Z; no commits, reviews or inline comments after; state OPEN. `updatedAt` 2026-10-11T13:20:35Z is the comment edit.
- The wiki's earlier "as of 2026-09-15" pin referred to the `updated_at` of comment 5636418769 (edited 2026-09-15T11:56Z), not to any text change. **"Text as of 2026-09-15" and "@ 47dbedd" are byte-identical.**
- Load-bearing lines of `extensions/0x0003-coinbase-transaction-payouts.md` @ 47dbedd: L47-53 §3.1 table (`distribution_id U64`, `pool_payout B0_64K`, `payouts SEQ0_64K[B0_64K]`, `dust_limits SEQ0_64K[U32]`, `additional_outputs SEQ0_64K[B0_64K]`); L53 additional_outputs "encode fixed satoshi amounts, paid exactly as declared; MAY be 0 (e.g. `OP_RETURN`)"; L55 `weight_P` "MAY include value credited on behalf of miners that are not represented in `payouts`"; L89-97 §4 `W = weight_P + Σ weight[i]`, `F = Σ additional_outputs[j].value`, `R = T − F`, `amount[i] = floor(weight[i]·R/W)`, dust prune `< dust_limits[i]`, `pay_P = T − Σ pay[i] − F`; L101 "If F ≥ T, the distribution is unsatisfiable"; L113 "Intermediate arithmetic MUST use at least 128-bit integers"; L115-121 output order pool_payout, payouts, additional_outputs, JDC 0-value, TP 0-value; L147-151 TLV `0x0003`/`0x01`/length `0x0008`; L168 "Any mismatch MUST be rejected with `invalid-payout-distribution`. This includes fixed-amount outputs that are reduced, omitted, or otherwise modified: there is no partial payment of `additional_outputs`"; L172/L183 §7.2–7.3 grace window is a JDS/Pool MAY, stale on a non-latest id is an honest race, persistent stale on the latest id → fallback; L211 §9.3 "Value that cannot be paid on-chain … is held by the Pool"; L219 §10 settlement invalidation (SHOULD throughout).

## 3. warioishere/stratum#1 — `extensions_sv2` 0.3.1 (head 9be4023, OPEN, +727/−16, 4 commits, 4 ahead / 0 behind upstream main)

Literal transcription of 47dbedd; no semantic deviation found in its scope.

- Struct `sv2/extensions-sv2/src/coinbase_transaction_payouts.rs:43-55`: `distribution_id: u64`, `pool_payout: B064K`, `payouts: Seq064K<B064K>`, `dust_limits: Seq064K<u32>`, `additional_outputs: Seq064K<B064K>`; derives binary_sv2 Serialize/Deserialize (+ `SetPayoutDistributionOwned`).
- Constants `:15-32`: `EXTENSION_TYPE = 0x0003`, msg type `0x00`, channel bit `false`, `FIELD_TYPE_DISTRIBUTION_ID = 0x01`, error strings `"stale-payout-distribution"`, `"invalid-payout-distribution"`.
- TLV `sv2/parsers-sv2/src/tlv_extensions/mod.rs`: `DISTRIBUTION_ID_LENGTH = 8`, `u64::from_le_bytes`, any other length → `DistributionIdError::InvalidLength`; wrong ext/field type rejected.
- `pub fn compute_payout_amounts(template_revenue: u64, pool_weight: u64, weights: &[u64], dust_limits: &[u32], fixed_amounts: &[u64]) -> Result<PayoutAmounts, PayoutComputationError>` (`:141-147`). Order: length mismatch → `DustLimitsLengthMismatch`; `pool_weight == 0 || weights.contains(&0)` → `ZeroWeight`; `:158 if fixed_total >= template_revenue as u128 → FixedOutputsExceedRevenue`; `remaining = T − fixed_total`; `:172 (weight as u128 * remaining / total_weight) as u64`; `:173 if amount < dust_limit as u64 { None }`; `:183 pool_payout: (remaining - paid_to_miners) as u64`. u128 throughout; `amount_P` never computed (not needed).
- Tests: 9 math unit tests (`:188-270`: adds up, dust → pool, amount equal to dust is paid, fixed off the top, F ≥ T rejected incl. u64::MAX + u64::MAX, zero weights, length mismatch, u64::MAX weights, empty payouts); one wire roundtrip with a hard-coded 31-byte vector; three TLV tests. A scratch crate ran the 9 math tests + 3 spec cross-checks: 12/12 pass (cargo 1.92). Full workspace not compiled by this wiki.
- Breaking surface, unbumped: `handlers_sv2` adds a REQUIRED trait method `handle_set_payout_distribution(&mut self, server_id: Option<usize>, msg, tlv_fields: Option<&[Tlv]>)` to `HandleExtensionsFromServer{Sync,Async}` (+Owned); `parsers_sv2` adds `Extensions::CoinbaseTransactionPayouts` variants; both crates stay `0.7.0` (commit 4 is titled `feat(parsers_sv2, handlers_sv2)!:`). Only `extensions_sv2` bumps 0.3.0 → 0.3.1 (PATCH). `license = "MIT OR Apache-2.0"`, `#![no_std]`. No PR opened on stratum-mining/stratum (`gh pr list --author warioishere` → []); `gh pr checks 1` → no checks reported.
- Not in scope: output ordering, consensus TxOut decoding, constraints sizing, grace window, negotiation gating, settlement — all JDC-side in sv2-apps#3 or JDS-side (Blitzpool).

## 4. warioishere/sv2-apps#3 — jd-client 0x0003 (head 90b3e3d, OPEN, +2144/−260, 10 commits, base stratum-mining/sv2-apps 9be9d0f)

Stacks #1 (36dd85c, 8e3f907) and #2 (as cherry-pick 4e526de, not ec35ac8); last commit pins `stratum-core` to `warioishere/stratum` branch `feat/coinbase-transaction-payouts` in `stratum-apps/Cargo.toml:20` (Cargo.lock locks 9be4023). Touches jd-client, translator (mechanical trait impl), stratum-apps, bitcoin-core-sv2, integration-tests; **zero jd-server files**.

- Opt-in: `[[upstreams]] coinbase_transaction_payouts = true` (`config.rs:344-348`), threaded to both `Upstream::new` (MP `RequestExtensions` gets 0x0003 appended, `upstream/mod.rs:213-217`, sent after SetupConnection.Success, answer handled asynchronously by the ChannelManager) and `JobDeclarator::new` (`job_declarator/mod.rs:366-427`: `RequestExtensions{[0x0003]}`, `EXTENSION_NEGOTIATION_TIMEOUT = 10 s` at `:44`, then waits up to 10 s for the first `SetPayoutDistribution`).
- Outcomes (PR body "choices where the spec leaves room"): JDS declines or is silent 10 s → warning, **base protocol**; JDS agrees but pool `Some(false)` → fallback (`CoinbaseTransactionPayoutsNotSupportedByPool`, `channel_manager/mod.rs:1094-1110`); JDS agrees but no distribution in 10 s → fallback; pool never answers → `pool_supports… = None`, base-protocol jobs from the JDC's own solo output, no timeout (`:1683-1720`).
- `payout_distribution.rs` (new, 184 lines): `TryFrom` consensus-deserializes TxOuts with no script/value policy (`:26-45`); `outputs()` `:51-56` = pool_payout + all payouts + additional_outputs (for sizing); `coinbase_outputs(T)` `:61-100` calls `compute_payout_amounts(T, pool_weight, &weights, &dust_limits, &fixed_amounts)` with `fixed_amounts = additional_outputs[].value`, emits `[pool_payout(pay_P)] ++ payouts.zip(amounts).filter_map(non-None) ++ additional_outputs.iter().cloned()` (`:98`). Test `coinbase_outputs_follow_the_extension_order_and_skip_dust` (`:138-157`) uses `output(0, 3)` with script `[0x6a, 0x03]` and asserts it is emitted last, value 0.
- Constraints: initial `CoinbaseOutputConstraints` skipped when negotiated (`channel_manager/mod.rs:786-791`); `on_payout_distribution` (`:959-1028`) rejects non-increasing ids with **fallback** (`:969-976`), rejects `≥ Weight::MAX_BLOCK`, computes `coinbase_output_constraints_message(distribution.outputs())` (`:978` → `stratum-apps/src/coinbase_output_constraints.rs:44` exact `Σ o.size()`, no overhead), sends only on change, applies immediately if it fits what was reserved, else parks in `pending_payout_distribution` and promotes at the next `SetNewPrevHash` (`template_message_handler.rs:473`). With the SRI IPC TP a re-sent constraints message re-bootstraps the client and immediately emits NewTemplate + SetNewPrevHash.
- No height tracking anywhere. Full-Template: `handle_set_new_prev_hash` re-sends the STORED `DeclareMiningJob` with the `distribution_id` captured when the job was built (`:489-507`; the first send was deferred at `:450-452` for unactivated future templates) — an older id can be declared after a newer distribution was applied. Coinbase-only: rebuilds from the current distribution (`:525-595`). TLV via `utils.rs:74-84 frame_with_tlvs`, on `DeclareMiningJob` (Full-Template) or `SetCustomMiningJob` (Coinbase-only, `RouteMessageTo::UpstreamWithTlvs`).
- `stale-payout-distribution`: drop job + cached shares; ignore if the job's id ≠ latest known; else count, fallback at `MAX_STALE_PAYOUT_DISTRIBUTION_REJECTIONS = 3` (`:121-129`, `:1034-1065`). Counter resets on a new distribution and on `SetCustomMiningJobSuccess`, not on `DeclareMiningJobSuccess`. `on_payout_distribution` never re-declares.
- Integration tests `integration-tests/tests/jdc_coinbase_transaction_payouts.rs` (712 lines, 6 tests, `:81 additional_outputs: Vec::new()`): pool RequestExtensions includes 0x0003; coinbase-only first constraints = distribution outputs, custom job TLV id 7, outputs `[1.0, 24.5, 24.5] BTC` for T = 50 BTC weights 2/49/49; full-template TLV id 7 and suffix order; larger distribution id 8 waits for the next prev-hash; silent JDS → base protocol; pool declines → fallback; JDS without distribution → fallback. The non-empty `additional_outputs` path is unit-tested only. PR body: "regtest end-to-end … including a found block booked as declared", "mainnet against blitzpool with a Bitaxe, coinbase-only and full-template".

## 5. warioishere/sv2-apps#1 — coinbase-only JDC loses custom jobs (head 8e3f907, OPEN)

Base `miner-apps/jd-client/src/lib/channel_manager/template_message_handler.rs` L474 deserialized `self.coinbase_outputs` (JDS token outputs, pool output 0 sats) without setting `coinbase_tx_value_remaining`, L560 passed them to `job_factory.new_custom_job`, L566 `if let Ok(custom_job) = custom_job {` swallowed the Err — `JobFactory::new_custom_job` returns `InvalidCoinbaseOutputsSum` when outputs ≠ template revenue (stratum b1f678c `channels-sv2/src/server/jobs/factory.rs:452-453`). `upstream_message_handler.rs:102-105/226` had the same 0-value bug on channel open. Second bug: L528 `tokens.pop_front()` before the L540 upstream-channel check; two tip updates before the first miner connects exhaust both tokens. Fix: `ChannelManager::coinbase_outputs_for_template(&template)` (`channel_manager/mod.rs:1455-1464`) routed through all 7 build sites; token pop moved inside the upstream-channel branch; `JDCErrorKind::DeclaredJobHasBadCoinbaseOutputs` deleted. New test `integration-tests/tests/jdc_coinbase_only_chain_tip.rs` (290 lines, 2 tests, 10 s window). Verified locally: both pass on the branch, both fail on upstream main 56a916a with `JDC must send a SetCustomMiningJob for the new chain tip: Elapsed(())`. Not capnp-related.

## 6. warioishere/sv2-apps#2 — bitcoin-core-sv2 under-reserves block weight (head ec35ac8, OPEN)

- Bug: `bitcoin-core-sv2/src/unix_capnp/v31x/template_distribution_protocol/mod.rs:547-549` and `v30x/...:530-532` set the IPC `BlockCreateOptions.blockReservedWeight` to `(4*coinbase_output_max_additional_size).max(2000)`. sv2-spec `07-Template-Distribution-Protocol.md:70-94` requires `1168 + 4*size` (320 header + 12 tx count + 236 coinbase fixed fields + 400 worst-case scriptSig + 12 output count + 188 witness commitment). Core seeds `nBlockWeight` with the reservation (`src/node/miner.cpp:118`) and packs mempool chunks while `nBlockWeight + chunk_weight < block_max_weight` (`:250`; `DEFAULT_BLOCK_MAX_WEIGHT = MAX_BLOCK_WEIGHT`), so the shortfall only materialises when the mempool can fill the block.
- Shortfall: 0 WU for size ≤ 208 B (floor covers it), `4*size − 832` WU for 208 < size < 500, a constant **1168 WU** for size ≥ 500 B. PR example: 1385 B (42 payouts + pool) → old 5540 WU vs spec 6708 WU. Mainnet: "the JDS node rejected both declared jobs with `bad-blk-weight`".
- Fix: `const BLOCK_RESERVED_WEIGHT_WITHOUT_ADDED_OUTPUTS: u64 = 1168`, `fn block_reserved_weight(size) = (1168 + size*4).max(2000)` in `unix_capnp/mod.rs:19-22, 47-55`, called from both v30x and v31x; 3 unit tests (pass locally). `sigops` untouched.
- Not upstream: stratum-mining/sv2-apps `main` 56a916a (2026-10-12) and tag `v0.8.0` 7f49074 (2026-09-17) still carry the old formula. C++ `stratum-mining/sv2-tp` master `src/sv2/block_options.h:23-35` reserves `1168 + 400 + 4*size` (one reader found Sjors/sv2-tp at `2000 + 4*size`; both are ≥ the TDP figure), so an sv2-tp pool never had this bug.
- Blitzpool uses the buggy shim (`Cargo.toml:174` sv2-apps tag v0.8.0) but is immune by construction: `bin/blitzpool/src/boot.rs:310-320 tdp_constraint_for_budget` declares `ceil(budget/4) + 256` bytes with coinbase structure already inside the budget (`bp-pplns/src/weight.rs`: base 328 + witness 188 + pool output 172 + 200 WU margin); the only unmodelled items (header 320 + tx count 12) sit inside the 1024 WU headroom. After adopting the fix it will over-reserve by 1168 WU and its regtest helper comment `reserved_weight = size*4` goes stale.

## 7. Blitzpool JDS @ b48998f ("release 2.4.1", 2026-10-11) — the pool side the comment ran against

Read via `git show origin/main:<path>` only.

- Wire: `crates/bp-stratum-v2/src/extensions.rs:133-170` matches §3.1 (little-endian TLV; `:5-6` notes the spec's big-endian `00 02` examples are "taken as the error"). `payout_resolver.rs:444-472`: `pool_payout.weight = d.weight_p`, `payouts` = published entries only (`wire_weight > 0`), `dust_limits` = `DUST_LIMIT_SATS` 546 for every entry (`:451-458`), **`additional_outputs: Vec::new()` always** (`:467`, `:504`). The e2e test asserts the list is empty (`jdp_server.rs:1822`).
- `weight_P` (PPLNS) is the fee and only the fee over the published set: `crates/bp-pplns/src/weights.rs:173-182 pool_weight_for = published_total·fee_ppm/(1e6 − fee_ppm)`; `:385-396 WithheldValue::ToOtherMiners => pool_weight_for(published_total)`, `ToPool => pool_weight_for(full_total) + withheld_total`; enum doc `:111-120` ("PPLNS: spread over the published miners, who then owe the withheld miner"; "Group-Solo: left in the §4 residual"). Trimmed/sub-min-payout miners stay as `wire_weight = 0` entries in the fingerprinted snapshot; the Postgres signed ledger books `claim(T_actual) − paid` at booking (`bp-pplns-engine/src/engine.rs:276-327, 370-430`; `bp-coinbase-snapshot/src/actual.rs:23-61`). README:44 "Pool-wide balances sum to ~0"; README:83 PPLNS = ToOtherMiners, Team Mining = ToPool.
- `min_payout` (default 5000) is applied at build time by not publishing the entry, explicitly because a §4 dust prune would hand the value to the pool (`weights.rs:85-88`); wire dust_limits stay at the consensus floor.
- Publisher: `jdp_server.rs:361-416` — `tokio::time::interval` at `jdp_payout_distribution_interval_secs` (default 60, `bin/blitzpool/src/jdp.rs:30`), skips when `payouts_fingerprint` is unchanged (fingerprint ignores t_ref and wire weights), forced by settlement `Notify`. Never per height or per share; ids from Redis Lua `max(now_ms, stored) + INCR` (`payout_resolver.rs:645-670`).
- Grace: `bridge.rs:285-304 DistributionSlot { latest, previous }`, keyed by id + `settlement_epoch`; **no height dimension**. `invalidate_all_distributions()` (`:491-500`) bumps the epoch and clears `previous`; fired by `settle()` (`jdp_server.rs:320-327`) at **booking** (`block_confirmation.rs:239-246` after `confirmation_depth`), at found-time only for `CandidateBacking::UnbookableDistribution` (`dynamic_outputs.rs:176-184`: "a Bookable block settles after its booking, or the balances it just paid would be republished"). Chain tip is policed separately via prev_hash → `stale-chain-tip`.
- Validation: `jdp/payout_distribution.rs:104-143` recompute-and-compare, `T := Σ declared output values` (checked add, 0 refused), positional `(value, script)` equality, trailing outputs must be 0-value; `:76-83` **any non-zero `additional_outputs` value → `NonZeroAdditionalOutput`** (doc `:44-45` "ext 0x0003/SetPayoutDistribution MUST" — the pre-2026-09-09 draft). `crates/bp-share/src/lib.rs:209-241 compute_payout_amounts(weight_p, weights, dust_limits, t)` has **no F parameter**; rejects only `W == 0`. Full error-code maps in `jdp/client.rs:650-838` and `mining/client.rs:1959-2311`. Unit tests cover mutated/reordered/missing outputs and a non-empty 0-value `OP_RETURN` additional output (`:169-174, 211, 256, 276-345`).
- Blitzpool pins `stratum-core = "0.6.0"` (crates.io) and sv2-apps v0.8.0; it does not depend on, or pin, 47dbedd or either fork. README at b48998f describes 0x0003 support and the ledger; no doc text claims a mainnet run — that claim exists only in the GitHub comment.

## 8. The Sep 10–11 thread (comment ids, UTC)

- 5608416008 plebhash 09-09 20:39: diff changing `additional_outputs` from "Amount fields MUST be 0" to fixed satoshi amounts, introducing F/R ("Fixed amounts are funded off the top (R = T − F) … A Pool wishing to fund them from its own share alone can account for that when setting weight_P") after TheBlueMatt's "a pool might want to include fixed-amount outputs that aren't proportional". All in 47dbedd L53, 76-77, 90-101.
- 5618079488 TheBlueMatt 09-10 11:40: "The spec needs to clarify what should happen if the client wishes to pay less than `F` as well." Also floats pre-fetching next-block payout structure (context: the rejected round-trip design of #195/#202).
- 5618191598 ckolivas 09-10 11:48: well-connected pools are usually faster than local nodes even with the RTT (sv2-apps#638); plebhash 5627178873 replies node connectivity is treated as a controlled variable (stratumprotocol.org#336).
- 5620606488 plebhash 09-10 14:49: "adding this:" — the "no partial payment of `additional_outputs`" MUST, which had already landed in 47dbedd (force-push 14:37:52Z) at L168. "for now, my sentiment is that we should try to get this one merged … and let @warioishere experiment"; "we could either iterate on the design of this specific extension, or start a new one from scratch".
- 5621143068 warioishere 09-10 15:26: "the new additions didn't break anything on our 0x0003 ext impl. Feel free to test on blitzpool, it implemented the spec fully" — overstated for F > 0 (§7 above).
- 5621522019 TheBlueMatt 09-10 15:52: "but what if a pool wants to have all payouts be static and is fine with only a subset of payouts being paid?" (never answered); "I don't think 'patch the spec every 6 months with a new payout variant' … makes sense"; "support what we can support now and … refuse to change it to add more"; "or we just say that some pools have to do it via a custodian … the whole coinbase payout thing done this way is a bit of a marketing gimmick anyway".
- 5621681790 warioishere 09-10 16:04: custody = MiCA CASP / FINMA / FinCEN MSB exposure, licensing quotes "roughly half a million"; "Freeze the extension at weights plus fixed outputs and refuse further variants, fine by me. But then treat that frozen subset as a real payout path".
- 5627554892 plebhash 09-11 00:36: scaling ceiling — for a large flat pool `weight_P` may exceed Σ weight[i]; cites the opdup p2pool post (whose linked bitcointalk 2135429 gives the 5803-byte coinbase / 350 sat/B / 0.0203 BTC figures); "none of this is an argument against the extension".
- 5631032659 warioishere 09-11 07:31: "weight_P is only the fee over the published weights … the trimmed miners' share goes to the published miners who then owe it through a ledger … would it be worth a sentence in §9.3 saying the pool output may but need not absorb the unrepresented value?" (unanswered; not in 47dbedd); plan is several PPLNS pools by hashrate bracket.
- 5636327353 TheBlueMatt 09-11 14:54: "the trust model is effectively identical … at best … a workaround to a legal restriction".
- 5636418769 warioishere 09-11 15:01 (edited 09-15): ledger description — "the pool output is the fee and nothing else, on every block … counterparty risk between miners, not custody by the pool". Matches `WithheldValue::ToOtherMiners` (PPLNS only; Team Mining uses ToPool).

## 9. Divergences worth remembering

| Point | 47dbedd | stratum#1 / sv2-apps#3 | Blitzpool b48998f |
|---|---|---|---|
| additional_outputs amounts | fixed sats, MAY be 0 | fixed sats, F off the top | MUST be 0 (rejects non-zero); no F term |
| Zero weights | amount fields MUST be non-0 | any single 0 weight → ZeroWeight | only W == 0 rejected |
| T on the verifier side | recompute from (distribution, T) | n/a (JDC) | T := Σ declared outputs |
| Grace window | JDS MAY; id-based | JDC-side: none; 3 strikes on latest id → fallback | latest + previous by id + settlement epoch; no height |
| Settlement invalidation | SHOULD on block found | n/a | at booking (confirmation_depth), found-time only for unbookable |
| Height binding | none | none | none (prev_hash policed separately) |
| Publish cadence | unspecified | n/a | 60 s timer, fingerprint-gated, forced on settle |

Interop between Blitzpool's JDS and the fork JDC works because F = 0 on every distribution Blitzpool emits and Blitzpool's grace is height-agnostic.

## 10. What this changed for the silent-pool plan

See [plan-silent-pool-spec-2026-10-09.md](../../output/plan-silent-pool-spec-2026-10-09.md) §7.1 (UPSTREAM_DEPS pins incl. `bitcoin_core_sv2` past the `block_reserved_weight` fix), §8.4 step 9 (full-mempool test), §10 O10/O11, and the roadmap's Phase 4 spc-jdc bullet (fork of sv2-apps#3). The 0x0003 wire format, arithmetic, output order and the 0-value `OP_RETURN` carrier are unaffected.

## Source criticism

- **Single-author interop.** Author wrote both the JDS (Blitzpool) and the JDC fork; "two implementations" share one reading of the spec. The mainnet claim ("a few bitaxes, cpu miners and NerdQaxes") has no logs, block hashes or screenshots; the only indirect artifact is PR #2's `bad-blk-weight` report with 42 payout outputs. A few TH/s cannot have found a mainnet block, so settlement, booking from the actual coinbase and orphan handling have no real-hardware evidence; the found-block path is claimed on regtest only (PR #3 body).
- **"Implemented the spec fully" (09-10) is overstated** for the JDS: b48998f rejects non-zero additional_outputs and has no F parameter — a pre-2026-09-09 reading. Harmless today because it never emits valued additional outputs.
- **All four PRs are on personal forks, unmerged, with no upstream PRs**; stratum#1 reports no CI; parsers_sv2/handlers_sv2 carry breaking changes without version bumps. API surface may change on upstream review.
- **What this wiki verified itself**: file:line reads at the pinned SHAs via `gh api`/`gh pr diff`; Blitzpool via `git show` on the local clone (working tree untouched); compiled only the pure payout math in a scratch crate (12/12) and PR #1's two integration tests (pass on branch, fail on base). The full workspaces of stratum#1 and sv2-apps#3 were not built.
- The 2026-10-11 comment was edited 17 minutes after posting; GitHub does not expose the diff.
- Comment timestamps and the PR commit/timeline were read directly from the API; quotes are verbatim.

## See also

- [PPLNS-JD / SLICE](../../wiki/concepts/pplns-jd.md) — non-custodial payouts under JD, the extension this report implements
- [Spec: silent-pool](../../output/plan-silent-pool-spec-2026-10-09.md) — §3.5 JD mode, §7.1 pins, §8.4 step 9, §10 O10/O11 updated from this source
- [Roadmap: SPc pool](../../output/plan-spc-pool-pplns-jd-silent-payments-2026-10-09.md) — Phase 4 spc-jdc fork decision, R3
- [Blitzpool raw (README capture @ 7815884)](../repos/2026-07-27-blitzpool-server-rust-github.md) and [finder-bonus code read](../repos/2026-07-27-blitzpool-finder-bonus-code-read.md) — the bp-pplns provenance pin; this note reads the later b48998f for the JDS only
- [Lessons 2026-08-24: who controls the SV2 coinbase](../notes/2026-08-24-ll-jd-coinbase-control-amount-linkability.md) — JD carriers, `OP_RETURN`, §9.2 leak