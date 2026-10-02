# topics Index

> Compiled topics articles for mining-pool-architecture.

Last updated: 2026-09-23

## Contents

| File | Summary | Tags | Updated |
|------|---------|------|---------|
| [optimal-pool-architecture.md](optimal-pool-architecture.md) | **The synthesis — start here.** "Optimal" is objective-dependent, so four objectives are named and the evidence graded under each. The load-bearing findings: share validation is not the bottleneck (~1 µs/share, and vardiff makes share rate a function of connection count rather than hashrate), so the connection layer and the per-miner control loops are what matter; per-miner control must sit downstream of every aggregation point; the highest-consequence failure is a consensus-invalid coinbase paying zero on a found block; and the most dangerous failures are silent — there are at least three. Includes a reference architecture, a minimal-viable-pool baseline with the cost of each addition, and an explicit list of what the evidence does *not* support. | architecture-synthesis, design-objectives, reference-architecture, failure-modes, evidence-grading, minimal-viable-pool | 2026-09-21 |
| [pool-implementation-survey.md](pool-implementation-survey.md) | What the live implementations actually do, read on their own terms and not ranked — no benchmark comparing any of them exists. The axis that separates them is not language but whether accounting touches a database and where the process boundaries fall: ckpool splits by *function* into three daemons with no database, sv2-apps splits by *trust* into four binaries so boundaries can cross operators, and the managed-runtime pools take a database and push hashing into native code. Covers ckpool, sv2-apps, Miningcore, public-pool, NOMP, DATUM gateway, demand-cli. | ckpool, sv2-apps, public-pool, miningcore, nomp, datum, dmnd, implementation-comparison, role-separation | 2026-09-21 |

## Categories

- **synthesis**: optimal-pool-architecture
- **survey**: pool-implementation-survey

## Recent Changes

- 2026-09-23: `pool-implementation-survey` gained a Blitzpool section, and stale round-1 claims about SRI storage, benchmarks and bounding were corrected.

- 2026-09-21: Two topic articles compiled from research round 1.
