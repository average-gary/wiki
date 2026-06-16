---
title: "Bevy overview"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, ecs, rust, game-engine, overview]
---

# Bevy overview

**Bevy** is a refreshingly-simple, data-driven game engine and app framework, written in Rust. License: dual **MIT OR Apache-2.0** (at your option). The current shipping release as of 2026-06-15 is **0.18.1** (published 2026-03-02); main branch is in the 0.19 development cycle (rc.3 published 2026-06-10).

## Pillars

The original [[bevy-introducing.md|2020 launch announcement]] declared six design pillars; they still anchor the project:

- **Capable** — provide a complete 2D + 3D engine, not a toolkit
- **Simple** — newcomers can be productive without learning engine internals first
- **Data Focused** — ECS architecture all the way down (see [[bevy-ecs-architecture.md|ECS architecture]])
- **Modular** — every subsystem is a plugin; pick what you need
- **Fast** — parallel-by-default scheduler ([[bevy-scheduler.md|scheduler design]])
- **Productive** — fast iterative compile times (target 0.8–3.0s with [[bevy-compile-time.md|fast-compile config]])

## What ships in the box

The default `bevy` crate at 0.18.1 re-exports modules: `animation`, `app`, `asset`, `audio`, `camera`, `color`, `ecs`, `gizmos`, `gltf`, `input`, `light`, `math`, `pbr`, `picking`, `render`, `scene`, `sprite`, `state`, `text`, `time`, `transform`, `ui`, `utils`, `window`, `winit`. See [[bevy-cargo-features.md|Cargo features]] for the three-tier feature system (profiles / collections / individual features).

## What does NOT ship in the box

- **No editor.** This is the single biggest [[bevy-criticisms.md|critique]]; design specs exist, the editor working group is active, but no shipping editor in 0.18. JMS55, a core renderer contributor, calls it "a big, big hole for Bevy" ([[bevy-criticisms.md|JMS55 critique]]).
- **No bundled physics** — physics is delegated to ecosystem crates, primarily [[bevy-ecosystem.md|Avian]] (formerly bevy_xpbd) and bevy_rapier.
- **No console support.** Switch / PS / Xbox are blocked by NDAs and platform-vendor Rust support, not problems Bevy can fix alone ([[bevy-platform-support.md|platform support]]).
- **No asset-creation tools** — Bevy is a runtime, not a content authoring environment.

## Position vs other engines

Bevy is *not* a Unity replacement. The honest comparison ([[bevy-vs-other-engines.md|see comparison]]):

- vs **Unity / Unreal** — Bevy lacks an editor, mobile pipelines, console support, and the ecosystem maturity of either; Bevy wins on license, modularity, and ECS-first architecture
- vs **Godot** — Godot ships an integrated editor and faster iteration for 2D indie work; Bevy targets engine-internals visibility ("turtles all the way down") that Godot deliberately abstracts
- vs **Fyrox** — Fyrox is the other notable Rust engine; ships an editor + integrated physics; far smaller ecosystem (~9.4k stars vs Bevy's ~46.6k)
- vs **Macroquad / ggez** — those are 2D-focused minimal frameworks; Bevy is comparatively heavyweight

## Sponsors and use

Public commercial users include [[bevy-production-users.md|Pounce Light (Tiny Glade), Bloom Digital (LongStory 2), Foresight, Nominal]]. See [[bevy-production-users.md|production users]] for details.

## Governance

Bevy is governed by the [[bevy-foundation.md|Bevy Foundation]], a Washington-state 501(c)(3) public charity (incorporated 2024-03-11, charity status granted 2024-09-25). The Foundation employs **2 full-time maintainers + 1 contractor** as of 2025-08; founder Carter Anderson takes a 50%+ pay cut from market rate, and the Foundation is publicly characterized as "drastically under-funded for our ambitions." See [[bevy-foundation.md|Foundation details]].

## Stats snapshot (2026-06-15)

- 46,626 GitHub stars; 4,627 forks
- 5.86M crates.io downloads all-time; 1.14M in the last 90 days
- 1,865 crates depend on `bevy`; 3,191 crates use the `bevy_` namespace
- 21,985+ Discord members
- 560 games tagged `bevy` on itch.io
- 1,291+ unique lifetime contributors

See [[bevy-stats.md|stats reference]] for the full data dump.
