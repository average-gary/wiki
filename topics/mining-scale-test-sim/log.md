# mining-scale-test-sim — log

## [2026-06-24] init | new topic wiki created via /wiki:research --plan

## [2026-06-24] research | "mining scale testing via simulation" → 38 sources ingested, 7 articles compiled

5 parallel research paths:
- Path 1 (gimballock vardiff sim) → 10 sources
- Path 2 (connection-scale bottlenecks) → 8 sources
- Path 3 (synthetic miner methodology) → 7 sources
- Path 4 (share validation cost model) → 6 sources
- Path 5 (load harness landscape) → 7 sources

Compiled articles:
- wiki/topics/the-bottleneck-thesis.md
- wiki/topics/simulator-architecture.md
- wiki/concepts/vardiff-decoupling.md
- wiki/concepts/connection-scale-bottlenecks.md
- wiki/concepts/share-validation-cost-model.md
- wiki/concepts/synthetic-miner-patterns.md
- wiki/concepts/load-harness-landscape.md
- wiki/reference/gimballock-vardiff-sim.md

Headline finding: connections saturate before share validation, supporting the user's premise. Two caveats: ckpool's actual vardiff is ~10× denser than the user assumed (drr=0.3 ≈ 1 share/3.3s); lock contention and burst-handshake CPU operate below the steady-state ceiling. Gimballock's Champion algorithm shipped to production VardiffState 2026-06-23 (commit 53924efb).

## [2026-06-24] research-round-2 | --plan close-gaps 1,2,3,5 | ultracode workflow w/ adversarial verify + completeness critic

Paths:
- A (IanoNjuguna sv2-tools PerformanceLoadTestSuite deep-read) → 1 source. Verdict: REWRITE — suite is 100% in-process mock (tokio::sleep), no SV2 wire deps, no sockets, license null, 8-month idle, 1500-mock ceiling. All 10 claims verified.
- B (sv2-apps integration benches inventory) → 2 sources. Verdict: NO per-share Criterion bench exists in sv2-apps or stratum; channels-sv2 has no [dev-dependencies] section. Bench-to-be scoped: extended.rs:676. All 7 claims verified.
- C (modern tokio 2024-2026 benchmarks) → 7 sources. Verdict: 2019 numbers survive at this scale; tokio LIFO regression issue #8065 in 1.51.x/1.52.0/1.52.1 → pin tokio = "1.50" or ">=1.52.2". 1 refuted (tokio-uring v0.5.0 May 2024, fixed in raw), 2 overgeneralized, 1 uncertain.
- D (vardiff ramp-up vs steady-state) → 3 sources. Verdict: burst-storm 1800× steady state for ~130 ms at ckpool startdiff=42 (S19 first-share rate 554 sps × 100k = 55.4 M sps; ~385 cores validation budget). Champion's AdaptiveSignPersist cuts ramp from ~34 min to ~15 min (commit 1c645bcf); cold-start overshoot 145% → 10%. All 12 claims verified.

Completeness critic surfaced 6 missing items + 7 cross-path connections. All applied to compiled articles:
- share-validation-cost-model.md Caveat 2 rewritten (3-OOM understatement corrected)
- the-bottleneck-thesis.md Caveat 3 added; crossover table gains a burst-phase row
- load-harness-landscape.md IanoNjuguna section converted from "promising lead" to "closed: rewrite"
- simulator-architecture.md Next Steps re-numbered (greenfield + per-share bench + tokio pin + ramp_N workload + slow_warmup/mid_block_retarget_rejection patterns)
- vardiff-decoupling.md gains Champion cold-start numbers + SV1→SV2 translator inheritance caveat
- connection-scale-bottlenecks.md row 6 mitigation rewritten (tokio pin; tokio-uring fs-only; monoio/compio for io_uring on TCP); new row 8b for burst validation
- gimballock-vardiff-sim.md iteration history gains Iteration 5 (SignPersist commit 1c645bcf)
- share-validation-cost-model.md cost table gains SRI code-location column
- NEW: concepts/operational-storm-postmortems.md
- NEW: synthetic-miner-patterns.md gains workload-pattern axis (Steady/RampN/DropoutN/SlowWarmup/MidBlockRetargetRejection)

51 raw files, 9 compiled articles. Thesis SUPPORTED in steady state; INVERTED for ~130 ms during burst-connect ramp-up.
