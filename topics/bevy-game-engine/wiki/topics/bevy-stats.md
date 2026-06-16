---
title: "Bevy stats reference"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, stats, github, crates-io, ecosystem]
---

# Bevy stats reference

Snapshot 2026-06-15. Sources: [[bevy-github-stats.md|GitHub API]], [[bevy-crates-io-stats.md|crates.io API]], [[bevy-release-cadence.md|GitHub releases]], [[bevy-ecosystem-downloads.md|ecosystem crates]], [[bevy-foundation-metrics.md|release-notes contributor counts]], [[bevy-itchio-tag.md|itch.io]].

## Repo

- 46,626 stars
- 4,627 forks
- 311 watchers
- 502 open PRs / 13,725 closed (~14,227 lifetime)
- 432 contributors per default GitHub API page (real lifetime ~1,291+ per [[bevy-fifth-birthday.md|5th birthday]])
- Repo size 168.9 MB
- Created 2020-01-18; last push 2026-06-14
- Primary language: Rust (94.3%)

## Crates.io

- All-time downloads: **5,858,811**
- Recent (90 days): **1,137,009**
- Reverse dependencies on `bevy` directly: **1,865**
- Crates in `bevy_` namespace: **3,191**
- 61 published versions since 2020-01-18

## Per-version downloads

| Version | Date | Downloads |
|---------|------|-----------|
| 0.18.1 | 2026-03-04 | 340,391 |
| 0.18.0 | 2026-01-13 | 220,375 |
| 0.17.3 | 2025-11-17 | 202,929 |

## Per-release engineering

| Release | Date | Contributors | PRs |
|---------|------|--------------|-----|
| 0.18 | 2026-01-13 | 174 | 659 |
| 0.17 | 2025-09-30 | 278 | 1,311 |
| 0.16 | 2025-04-24 | 261 | 1,244 |
| 0.15 | 2024-11-29 | 294 | 1,217 |
| 0.14 | 2024-07-04 | 256 | 993 |

5,424 PRs across 0.14→0.18.

## Ecosystem plugin downloads (recent-90d)

| Plugin | Downloads | Latest |
|--------|-----------|--------|
| bevy_egui | 307,495 | 0.40.0-rc.1 (2026-05-29) |
| bevy-inspector-egui | 153,876 | 0.36.0 (2026-01-14) |
| avian3d | 97,170 | 0.6.1 (2026-03-23) |
| leafwing-input-manager | 71,377 | 0.20.0 (2026-01-07) |
| bevy_rapier3d | 51,148 | 0.34.0 (2026-05-14) |
| avian2d | 46,587 | 0.6.1 (2026-03-23) |
| bevy_rapier2d | 44,265 | 0.34.0 (2026-05-14) |
| bevy_kira_audio | 41,450 | 0.26.0-rc.1 (2026-05-15) |
| bevy_ecs_tilemap | 28,075 | 0.18.1 (2026-01-16) |
| bevy_mod_picking | 20,876 | 0.20.1 (stale; merged into core) |
| bevy_renet / renet | 11,972 / 18,783 | 4.0.1 / 2.0.0 |
| lightyear | 17,586 | 0.26.4 (2026-01-30) |
| bevy_replicon | 14,781 | 0.41.0-rc.1 (2026-06-02) |
| iyes_perf_ui | 5,797 | 0.5.0 (2025-05-20) |
| big_space | 2,958 | 0.12.0 (2026-02-09) |
| blenvy | 481 | 0.1.0-alpha.1 (stalled) |

## Adoption

- 21,985+ Discord members ([[bevy-fifth-birthday.md|2025-08]])
- 560 games tagged `bevy` on itch.io
- 1,865 reverse-deps on `bevy`

## Foundation

- Incorporated 2024-03-11
- 501(c)(3) granted 2024-09-25
- 2 full-time employees + 1 contractor (2025-08)
- Target salary $150,000/yr for full-time maintainer
- ~90% of income → maintainer salary
- Public revenue/donation totals: not published

## Comparisons

- `wgpu` (Bevy's renderer backend): 24.6M all-time / 6.6M recent — far larger than Bevy's userbase, indicating non-Bevy wgpu use
- Fyrox: 9,410 stars (vs Bevy's 46,626)

## Known data gaps

- No fresh cross-ECS performance benchmark — `rust-gamedev/ecs_bench_suite` was archived 2022-11-27, leaves no current Bevy-vs-Flecs/EnTT numbers
- No public actual revenue/donation totals from Bevy Foundation
- GitHub contributors API page caps at 432; lifetime real total per release-notes summation is much higher (1,291+ per 5th birthday)
- TWIB Feb–June 2026 issues weren't pulled in this research pass — refresh later for full year-1 2026 picture

## See also

- [[bevy-overview.md|Overview]]
- [[bevy-history.md|History]]
- [[bevy-version-timeline.md|Version timeline]]
- [[bevy-ecosystem.md|Ecosystem]]
