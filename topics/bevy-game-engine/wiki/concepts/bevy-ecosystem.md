---
title: "Bevy ecosystem"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, ecosystem, plugins, rapier, avian, egui, lightyear, replicon]
---

# Bevy ecosystem

3,191 crates use the `bevy_` namespace; 1,865 crates depend on `bevy` directly ([[bevy-crates-io-stats.md|crates.io snapshot 2026-06-15]]). The ones that actually carry adoption load:

## Physics

- **Avian** (`avian3d`, `avian2d`) — Position-based dynamics, formerly named bevy_xpbd. **97k recent-90d downloads on avian3d** — the dominant Bevy physics crate as of 2026. Latest: 0.6.1 (2026-03-23). [[bevy-fifth-birthday.md|5th birthday]] flags Avian as the upstream physics direction.
- **bevy_rapier** (3d + 2d) — Wrapper around Rapier (the Rust physics library). Older, still actively maintained (0.34.0, 2026-05-14); 51k recent on `bevy_rapier3d`.
- **bevy_xpbd_3d** — Deprecated; superseded by Avian. Last update 2024-07-04.

The migration to Avian is visible in the download deltas: avian3d's recent-90d (97k) is roughly 2x bevy_rapier3d's (51k), despite Rapier having a much longer history.

## UI / dev tooling

- **bevy_egui** — egui integration. **307k recent downloads — the largest Bevy plugin period.** Latest 0.40.0-rc.1 (2026-05-29). The de-facto immediate-mode UI for tools, debug panels, editor prototypes.
- **bevy-inspector-egui** — Reflection-based world inspector built on egui. 154k recent. Latest 0.36.0 (2026-01-14). Shipped on top of egui because Bevy's official Inspector General editor is still in working-group phase.

## Input

- **leafwing-input-manager** — High-level input mapping (action -> binding). 71k recent. 0.20.0 (2026-01-07). The standard input crate when default `bevy::input` isn't enough.

## Networking

- **bevy_replicon** — Server-authoritative replication. 145k all-time, 15k recent. 0.41.0-rc.1 (2026-06-02). Currently the most-active Bevy networking crate.
- **lightyear** — Client-server networking with prediction/rollback. 91k all-time, 18k recent. 0.26.4 (2026-01-30). Used in production by some commercial Bevy projects.
- **bevy_renet** / **renet** — Older renet-based networking. Still maintained (4.0.1, 2026-03-04).
- **naia-bevy-client** — Older. Recent downloads fell off (251 in last 90 days) — losing share.

## Audio

- **bevy_kira_audio** — Kira-based audio with mixing/effects. 41k recent. 0.26.0-rc.1 (2026-05-15). The standard upgrade from `bevy::audio` for serious audio work.

## Picking

- **bevy_mod_picking** — Stale; 2024-07-09 last update. **Picking was merged into Bevy core in 0.15+** ([[bevy-fifth-birthday.md|5th birthday]]), making this crate obsolete.

## Tilemaps / spatial / perf

- **bevy_ecs_tilemap** — 28k recent. 0.18.1 (2026-01-16). Used widely despite first-party tilemaps shipping in [[bevy-0-17-modernization.md|0.17]] — the first-party version is newer and less feature-complete.
- **iyes_perf_ui** — In-game perf overlay. 6k recent. 0.5.0 (2025-05-20).
- **big_space** — Floating-origin / large-coord-space support. 3k recent. 0.12.0 (2026-02-09). Niche but important for space sims.

## Asset pipeline

- **blenvy** — Blender → Bevy asset pipeline. **Stalled** at 0.1.0-alpha.1 (2024-08-14). The asset-pipeline gap [[bevy-criticisms.md|JMS55 critiques]] is reflected here.

## What's missing

Per the contrarian sweep:

- No mature first-party asset pipeline (Blenvy stalled, glTF-to-virtual-geometry processor proved unfeasible)
- No proven high-level reactive UI API (Bevy Feathers is in flight, but reactivity is still a working-group topic)
- No mature animation graph at the level Unity/Unreal users expect (animation API "clunky, with too many confusingly-named components")
- No first-party editor (Inspector General WG)

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-criticisms.md|Criticisms]]
- [[bevy-vs-other-engines.md|Comparison to other engines]]
