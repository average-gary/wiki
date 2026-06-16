---
title: Bevy Game Engine — Wiki
type: wiki-root
created: 2026-06-15
updated: 2026-06-15
scope: hub-topic
---

# Bevy Game Engine — Wiki

Topic wiki for **Bevy** — a refreshingly-simple, data-driven game engine and app framework, written in Rust. License: dual MIT OR Apache-2.0. Covers ECS architecture, the wgpu-based renderer, the ecosystem, the editor situation, production use, and comparisons to Godot/Unity/Unreal/Fyrox/Macroquad.

## Layout

- `wiki/concepts/` — atomic concept articles (15)
- `wiki/topics/` — synthesizing topic articles (3)
- `wiki/reference/` — link index (1)
- `raw/` — ingested source material with provenance (39 files)
- `output/` — generated artifacts (none yet)
- `theses/` — testable claims for follow-up research

## Stats

- Sources ingested: **39** (26 articles, 3 repos, 10 data, 0 papers)
- Articles compiled: **19** wiki articles (15 concepts + 3 topics + 1 reference)
- Outputs: 0
- Last research session: 2026-06-15 `--deep` (8 agents)

## TL;DR

- **Current shipping**: Bevy **0.18.1** (2026-03-02). Pre-release: 0.19.0-rc.3 (2026-06-10).
- **License**: MIT or Apache-2.0. **No royalties, no runtime fees.**
- **Stats** (2026-06-15): 46.6k GitHub stars, 5.86M crates.io downloads all-time, 1,865 reverse-deps on `bevy`, 21,985+ Discord members.
- **Governance**: Bevy Foundation (Washington-state 501(c)(3), 2024). 2 FTE + 1 contractor; "drastically under-funded."
- **No 1.0 timeline.** API stability: maintainers explicitly say game-engine APIs "don't really do that." Breaking minors every ~3 months.
- **No editor in 0.18** — Inspector General WG active. **BSN slipped 0.18** despite being targeted there.
- **No console support** (NDA-blocked). Mobile is "possible but not easy." WASM works for indie-scale games.
- **ECS architecture is the load-bearing primitive**. Hybrid table+sparse-set storage from [[wiki/concepts/bevy-ecs-architecture.md|0.5]]; stageless schedule from [[wiki/concepts/bevy-scheduler.md|0.10]]; [[wiki/concepts/bevy-relationships.md|relationships + required components]] from 0.15-0.16; observers/events overhauled in [[wiki/concepts/bevy-version-timeline.md|0.17]].
- **Production use is real**: Tiny Glade (97% positive, 13.4k Steam reviews), LongStory 2, POLDERS, plus non-game industrial users Foresight and Nominal. See [[wiki/concepts/bevy-production-users.md|production users]].
- **Don't pick Bevy if** you need mobile/console quickly, you need an editor today, or you can't tolerate ~3-month migration overhead. **Do pick Bevy if** you're Rust-comfortable, want ECS-first, building tools/sims, or want to learn engine internals.

## Start here

- [[wiki/concepts/bevy-overview.md|Bevy overview]] — orient
- [[wiki/topics/bevy-state-of-2026.md|State of Bevy in 2026]] — should you use it?
- [[wiki/concepts/bevy-ecs-architecture.md|ECS architecture]] — the load-bearing core
- [[wiki/concepts/bevy-scheduler.md|Scheduler]] / [[wiki/concepts/bevy-relationships.md|Relationships]] / [[wiki/concepts/bevy-required-components.md|Required Components]] / [[wiki/concepts/bevy-rendering.md|Rendering]] — atomic concepts
- [[wiki/topics/bevy-vs-other-engines.md|Bevy vs other engines]] — comparison + decision matrix
- [[wiki/concepts/bevy-criticisms.md|Criticisms and limitations]] — steelman against
- [[wiki/concepts/bevy-version-timeline.md|Version timeline]] — release-by-release
- [[wiki/concepts/bevy-history.md|History]] — Cart, the Foundation, Year 1-5
- [[wiki/concepts/bevy-ecosystem.md|Ecosystem]] — major plugins
- [[wiki/concepts/bevy-production-users.md|Production users]] — shipped games + commercial users
- [[wiki/concepts/bevy-platform-support.md|Platform support]] — desktop / mobile / console / WASM
- [[wiki/topics/bevy-stats.md|Stats reference]] — numbers
- [[wiki/reference/specs-and-repos.md|Reference: specs, repos, docs]] — comprehensive link index

## Open questions

- **When does BSN ship?** Targeted for 0.18, slipped. 0.19 timeline unconfirmed at snapshot.
- **When does the editor ship?** Inspector General WG active in 2026; no committed date.
- **When does 1.0 happen?** [[wiki/concepts/bevy-fifth-birthday.md|Fifth birthday]]: no committed date. Carter explicitly avoids one.
- **Will mobile ergonomics improve?** Maintainer says it's a head-count problem (not enough mobile-focused contributors).
- **Will Avian fully replace Rapier as upstream physics?** [[wiki/concepts/bevy-fifth-birthday.md|Fifth birthday]] flags Avian as the upstream direction; Rapier still has more total downloads.
- **What does Bevy 0.19 ship?** Active working groups suggest: WESL shaders, Inspector General editor pieces, async ECS ergonomics. Specifics unconfirmed.
- **Does TWIB cover Feb–June 2026 issues?** Not pulled in this research pass; refresh later.
- **Is there a current Bevy-vs-Flecs-vs-EnTT performance benchmark?** `rust-gamedev/ecs_bench_suite` archived 2022-11-27; no current cross-engine numbers found.

## Adjacent wikis

- [[../rust-multi-platform/_index.md|rust-multi-platform]] — Rust mobile/desktop/WASM surfaces; Bevy ships to all of them via wgpu
