---
title: Bitcoin Mining Payout & Accounting Schemas
type: topic-index
created: 2026-05-23
updated: 2026-07-29
compiled: 2026-07-27
lint: 2026-07-15
status: active
summary: Payout and share-accounting schemas for Bitcoin mining pools — PPLNS, FPPS, PPS+, PPLNS-JD, hashpool.dev (Cashu ecash mints), btc++ event payout/accounting tracks, p2pool / p2poolv2 share-chain accounting, lottery-PPLNS finder-bonus hybrids (Parasite Pool, Blitzpool), Radpool (DLC+FROST decentralized FPPS).
---

# Bitcoin Mining Payout & Accounting Schemas

Survey of how Bitcoin mining pools account for hashrate contributions and pay miners. Centralized variance-smoothing schemes (FPPS, PPS+) versus risk-sharing schemes (PPLNS), versus Stratum-V2-job-declared variants (PPLNS-JD), versus decentralized share-chain accounting (p2pool / p2poolv2), versus ecash-redemption mints (hashpool.dev).

## Top-level questions

1. What are the canonical payout schemas (PPS, PPLNS, FPPS, PPS+, SOLO) and what risks does each one shift to whom?
2. How does Stratum V2 Job Declaration change accounting — what is "PPLNS-JD" and which pools claim to run it?
3. How does hashpool.dev use Cashu ecash mints to redenominate shares as bearer tokens, and what trust assumptions does that introduce?
4. How does p2pool / p2poolv2 do payout via a coinbase-output share-chain — what are PPLNS window semantics in a decentralized chain?
5. What was discussed in the btc++ payout/accounting tracks (Riga, Austin, Salvador) about decentralizing or improving pool accounting?
6. Cross-cutting: how do payout schemes interact with custody (custodial vs non-custodial), variance, fee policy, and SV2 negotiated job submission?

## Sections

- [[wiki/concepts/_index|Concepts]] — schema definitions (PPLNS, FPPS, PPS+, share difficulty, variance, hashrate luck)
- [[wiki/topics/_index|Topics]] — synthesis articles comparing schemes, mapping the design space
- [[wiki/reference/_index|Reference]] — pools, projects, repos, specs, conference talks
- [[wiki/decisions/_index|Decisions]] — design tradeoffs and ADRs
- [[wiki/theses/_index|Theses]] — testable claims about payout schemes

## Outputs

| Date | Title | Format |
|------|-------|--------|
| 2026-07-27 | [[output/plan-coinbase-direct-lottery-pplns-2026-07-27\|A fully coinbase-direct lottery-PPLNS on Blitzpool]] | roadmap |

## Sources

- [[raw/_index|Raw sources]]

## Related wikis

- [[../sv2-p2pool-integration/_index|sv2-p2pool-integration]] — JDS share-chain integration with SV2 reference apps (narrower scope)
- Coinbase rotation / payout-output handling now lives **in this topic** — see [[raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read|sv2-apps xpub/wildcard rotation]] (hub-side) and the `para` local wiki `REPOS/para/.wiki/output/` (the shipped ckpool+BDK design). The former `coinbase-rotation-bitcoin` topic was an empty skeleton and was removed 2026-07-29.

## Recent Changes

- 2026-07-29: Ingested [[raw/repos/2026-07-29-sv2-apps-xpub-coinbase-rotation-code-read|sv2-apps xpub/wildcard coinbase rotation @ e2930150]] — first `xpub`/wildcard-descriptor material in the hub (the term had zero prior occurrences). Unmerged `stratum-mining/sv2-apps` branch adding a reusable 552-line `XpubDerivator` (miniscript `has_wildcard()` gate, `AtomicU32` index, flat-file persistence, 12 tests incl. pinned derivation vectors and a real restart test), rotating the coinbase on `SubmitSolution` in both Pool and JD-client. It **reverses an explicit upstream decision** — the deleted test carried the comment "no wildcards allowed (at least for now… need to work out UX)". Rotates the pool's *own single* address, so **per-miner xpub-username derivation is still unimplemented anywhere**, but the branch supplies the primitive and proves `coinbase_outputs` tolerates runtime mutation behind a `SharedLock`. Persistence is measurably weaker than `para`'s shipped BDK design: bare non-atomic `fs::write`, `load_index` silently falling back to `start_index` on a corrupt file (replaying addresses from 0), increment-before-persist with warn-only failure, and no gap-limit knob at all. The ledger blocker from the 1776 rewiring plan stands untouched — `pplns_balance ON CONFLICT (address)` keys balances globally, so any per-miner design must split descriptor-for-ledger from derived-address-for-coinbase.
- 2026-07-27: **Planned a fully coinbase-direct lottery-PPLNS** → [[output/plan-coinbase-direct-lottery-pplns-2026-07-27|roadmap]] (9 articles consulted, 5 decisions, 6 phases, ~9 days). Three new spike measurements against the pinned clone **overturned the prior cost model**: exactly **1 payout-list position differs between any two per-finder distributions** (out of 202 / 65 / 30 across four weight budgets), because the bonus is carved out *before* the proportional split — so every non-finder's sats are identical regardless of who the finder is. Since `address_to_script` reads only `(network, address)` and never sats, re-keying the script memo on the address recovers ~500× of the fan-out cost previously called "the dominant unmeasured CPU term" (measured: 0.300 ms/finder at a 1000-output window versus 1.905 ms/finder for the distribution math — ~16%, never dominant). Real risk moves to the job-cache memory profile under `4 × N` resident entries with TTL-only eviction, which the plan gates behind a regtest load test with an explicit don't-ship outcome.
- 2026-07-27: **Corrected three long-standing Parasite Pool claims** against primary sources ([[raw/data/2026-07-27-parasite-blitzpool-onchain-and-code-verification|verification pass]]): its 1 BTC bounty **is** paid coinbase-direct to the finder (a different address every block across 938713/945601/958527 — only the ~68% remainder is custodial); its share weighting is cumulative unpaid difficulty with **no decay and no window**, so it is not PPLNS in Rosenfeld's sense and is **not hop-resistant**; and it is at **5 mainnet blocks, not 2**, on a sharply accelerating cadence. [[wiki/concepts/parasite-pool|Parasite Pool]] revised throughout; the "decay weighting" novelty claim struck. Also a negative result worth recording: no published critique of large flat finder bounties exists in any venue searched, so this wiki's variance analysis is constructed rather than cited.
- 2026-07-27: Researched **lottery-PPLNS feasibility** against a local clone of blitzpool-server-rust @ `7815884` → new concept [[wiki/concepts/lottery-pplns|Lottery-PPLNS (Finder-Bonus Hybrid)]] + code-level source [[raw/repos/2026-07-27-blitzpool-finder-bonus-code-read|finder-bonus code read]]. Finding: the finder-bonus mechanic already exists in Blitzpool's shared distribution math and PPLNS declines it in one line; per-finder speculative coinbase construction is already the architecture for the other three modes. EV-neutral for every miner — a pure variance trade. One correctness landmine (missing duplicate-address merge in the PPLNS ledger apply). Resolves the finder-bonus gap the README ingest flagged as unverified.
- 2026-07-27: Ingested [[raw/repos/2026-07-27-blitzpool-server-rust-github|warioishere/blitzpool-server-rust]] — non-custodial pool paying Solo/PPLNS/Group-Solo/Blockparty directly in the coinbase (multi-output PPLNS, signed pending ledger, coinbase weight-budget autoscaler). Compiled 2026-07-27.
- 2026-07-17: Compiled vnprc/coinbase-playground collection (6 sources) → new concept [[wiki/concepts/ctv-coinbase-payout-tree|CTV Coinbase Payout Tree]]; integrated flat/layered-tree numbers into payout-schema-taxonomy and ark-for-mining-payouts. Last compiled: 2026-07-17.
- 2026-07-15: Compiled demand-share-accounting-ext → [[wiki/concepts/sv2-share-accounting-ext|SV2 Share Accounting Extension]].

## Log

See [[log]].
