---
title: "Reference: specs, repos, docs"
type: reference
created: 2026-06-15
updated: 2026-06-15
tags: [bevy, reference, links, repos, docs]
---

# Reference: specs, repos, docs

## Canonical project surface

- **Homepage**: <https://bevy.org/> (`bevyengine.org` 301-redirects here as of 2026)
- **GitHub**: <https://github.com/bevyengine/bevy>
- **Releases**: <https://api.github.com/repos/bevyengine/bevy/releases>
- **Foundation**: <https://bevy.org/foundation/>
- **News**: <https://bevy.org/news/>
- **Quick Start (Bevy Book)**: <https://bevy.org/learn/quick-start/getting-started/setup/>
- **Cargo features ref**: <https://github.com/bevyengine/bevy/blob/main/docs/cargo_features.md>

## API docs

- `bevy` crate: <https://docs.rs/bevy/latest/bevy/>
- `bevy_ecs`: <https://docs.rs/bevy_ecs/latest/bevy_ecs/>
- (and per-subcrate: bevy_render, bevy_pbr, bevy_app, etc.)

## Crates.io

- `bevy`: <https://crates.io/crates/bevy>

## Community

- This Week in Bevy: <https://thisweekinbevy.com/>
- Awesome-Bevy / bevy-assets: <https://github.com/bevyengine/bevy-assets>
- Cheat Book (UNMAINTAINED — flagged): <https://bevy-cheatbook.github.io/>

## Notable working groups / RFCs

- Stageless RFC: rfcs/45-stageless.md (landed in [[bevy-0-10-stageless.md|0.10]])
- BSN — Bevy Scene Notation (in flight, slipped 0.18)
- Inspector General — entity inspector working group
- WESL-ification — shader language migration

## Major ecosystem crates

| Crate | Purpose | Repo / Crate |
|-------|---------|--------------|
| avian3d / avian2d | Position-based physics (ex bevy_xpbd) | <https://crates.io/crates/avian3d> |
| bevy_rapier3d / bevy_rapier2d | Rapier physics integration | <https://crates.io/crates/bevy_rapier3d> |
| bevy_egui | egui integration | <https://crates.io/crates/bevy_egui> |
| bevy-inspector-egui | World/entity inspector | <https://crates.io/crates/bevy-inspector-egui> |
| leafwing-input-manager | Action-based input | <https://crates.io/crates/leafwing-input-manager> |
| lightyear | Networking with prediction/rollback | <https://crates.io/crates/lightyear> |
| bevy_replicon | Server-authoritative replication | <https://crates.io/crates/bevy_replicon> |
| bevy_kira_audio | Kira-based audio | <https://crates.io/crates/bevy_kira_audio> |
| bevy_ecs_tilemap | Tilemap support | <https://crates.io/crates/bevy_ecs_tilemap> |
| iyes_perf_ui | In-game perf overlay | <https://crates.io/crates/iyes_perf_ui> |
| big_space | Floating-origin / large coord spaces | <https://crates.io/crates/big_space> |

## Notable shipped Bevy games

| Game | Studio | Storefront |
|------|--------|------------|
| Tiny Glade | Pounce Light | <https://store.steampowered.com/app/2198150/Tiny_Glade/> |
| LongStory 2 | Bloom Digital | Steam app 2427820 |
| Tunnet | (indie) | itch.io |
| POLDERS | (indie) | Steam wishlist |
| Abysm | (indie, Bevy Spooky Jam 2024 winner) | Steam page |

Plus the [[bevy-itchio-tag.md|560 games tagged `bevy`]] on itch.io.

## Notable non-game Bevy users

- Foresight — spatial databases, satellite-constellation modeling, drone testing, CFD visualization
- Nominal — industrial test/data platform; aerospace/maritime/ground vehicle telemetry

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-version-timeline.md|Version timeline]]
- [[bevy-ecosystem.md|Ecosystem]]
