---
title: raw/papers
---

# raw/papers

- [2026-06-24-path1-gimballock-design.md](2026-06-24-path1-gimballock-design.md) — DESIGN.md: three-stage pipeline (Estimator, Boundary, UpdateRule), the `Composed<E, B, U>` adapter, algorithm registry, Belief/Uncertainty types, trial recording model, scenarios, Grid, stage-attributed metrics
- [2026-06-24-path1-gimballock-findings.md](2026-06-24-path1-gimballock-findings.md) — FINDINGS.md: iteration-by-iteration derivation of FullRemedy from ClassicComposed, then AdaCUSUM; the three-fix protocol; the `operational_fitness` composite metric
- [2026-06-24-path1-gimballock-metric-derivation.md](2026-06-24-path1-gimballock-metric-derivation.md) — METRIC_DERIVATION.md: the white paper. Theorem 1 (observable depends only on `e`), Theorem 2 (information floor `1/(r*τ)`), linear sign-split regret + direction-split effort metric, minimax-over-`r*` champion selection, decline-safety gate as hard constraint, hardware validation status
- [2026-06-24-path1-gimballock-theory.md](2026-06-24-path1-gimballock-theory.md) — THEORY.md: predecessor design note exploring conservation-law framing and LQ tracking cost. Includes the explicit "tries to break its own theory" §5 Holes, with validation pass that refutes the `δ²` cancellation and confirms the directional asymmetry
