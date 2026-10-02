# Wiki Articles Index

> Compiled articles for mining-pool-architecture.

Last updated: 2026-09-23

## Contents

| Category | Count | Index |
|----------|-------|-------|
| concepts | 6 | [concepts/](concepts/_index.md) |
| topics | 2 | [topics/](topics/_index.md) |
| references | 3 | [references/](references/_index.md) |
| theses | 0 | [theses/](theses/_index.md) |

## Start Here

**[Optimal Pool Architecture](topics/optimal-pool-architecture.md)** is the synthesis — it names the
design objectives, grades the evidence under each, and gives a reference architecture plus a
minimal-viable-pool baseline with the cost of every addition.

The organising concept underneath it is
**[The Two Hot Paths](concepts/the-two-hot-paths.md)**: job push and share submit are the only
latency-critical paths, and most architecture arguments are arguments about what sits on them.

## Reading order

1. [The Two Hot Paths](concepts/the-two-hot-paths.md) — the frame.
2. [Vardiff as a Control Loop](concepts/vardiff-as-control-loop.md) — why share rate is a control
   variable, and the silent defect in nearly every implementation.
3. [Pool Sizing Model](references/pool-sizing-model.md) — the arithmetic, and the two corrected figures.
4. [Connection Layer Scaling](concepts/connection-layer-scaling.md) — the layer that actually saturates.
5. [Share Accounting and Durability](concepts/share-accounting-and-durability.md) — what must persist,
   and why adversaries rather than payouts decide it.
6. [Share Storage Architectures](references/share-storage-architectures.md) — the eight real schemas, and
   why nobody writes one durable row per share.
7. [Regional Routing and Session Continuity](concepts/regional-routing-and-session-continuity.md) — how
   pools span regions, and why connection migration is unsolved.
8. [Template Sourcing and Control](concepts/template-sourcing-and-control.md) — where the block comes
   from and who chooses its contents.
9. [Pool Implementation Survey](topics/pool-implementation-survey.md) — what the real software does.
10. [Pool Protocol Timeline](references/pool-protocol-timeline.md) — how it got this way.
11. [Optimal Pool Architecture](topics/optimal-pool-architecture.md) — the synthesis.

## Cross-reference density

All 11 articles link to at least two others; the synthesis links to the rest. No orphans.

## Recent Changes

- 2026-09-22: Round 2 — 11 articles. Added `share-storage-architectures` and `regional-routing-and-session-continuity`; retracted the no-benchmark claim in `pool-sizing-model` and `optimal-pool-architecture`; corrected the SRI bounding claim and ckpool sharelog threading in `share-accounting-and-durability`.

- 2026-09-21: First compilation — 9 articles from 21 raw documents (research round 1).
