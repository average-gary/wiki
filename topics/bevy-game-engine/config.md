---
title: bevy-game-engine — config
type: topic-config
created: 2026-06-15
---

# bevy-game-engine — config

## Scope

**In scope**:
- Bevy game engine — bevyengine.org, github.com/bevyengine/bevy
- Architecture: ECS (entity-component-system), scheduler, archetype storage, plugins, scenes, assets, reflection
- Renderer: wgpu-based rendering, render graph, materials, lights, PBR, 2D/3D pipelines
- Editor situation: bevy_editor, bevy-inspector-egui, third-party tooling
- Engine state at the present (Bevy 0.x → 1.0 trajectory): release cadence, breaking changes, what's missing
- Ecosystem: bevy_rapier (physics), bevy_egui (UI), avian, bevy_xpbd, networking (lightyear, bevy_replicon, naia), audio (bevy_kira_audio), input, asset crates
- Production users / shipped games / commercial use
- Comparisons: Bevy vs Godot, Unity, Unreal, Fyrox, Macroquad, raylib-rs
- Criticisms, limitations, performance gotchas, missing features
- Getting started, learning resources, official Bevy book/cheatbook
- Bevy as a non-game application platform (UI apps, simulators, CAD-style tools)

**Out of scope**:
- General Rust language tutorials beyond what touches Bevy idioms
- General game engine theory disconnected from Bevy's choices
- Non-Bevy ECS deep dives (mention only as comparison)

## Sensitivity

Public. Hub-publishable. Bevy is MIT/Apache-2.0 OSS.

## Source preferences

- **Primary**: bevyengine.org (book, blog), github.com/bevyengine/bevy (issues, PRs, RFCs, release notes), Bevy Discord/working groups, official examples
- **Secondary**: Bevy Cheat Book (bevy-cheatbook.github.io), This Week in Bevy, This Month in Bevy, Cart's design notes, working-group RFCs, ecosystem crate docs (bevy_rapier, bevy_egui, lightyear, etc.)
- **Tertiary**: practitioner blogs, conference talks (Bevy Meetup, RustConf), reddit r/bevy and r/rust_gamedev, podcast appearances, comparison/benchmark posts

## Adjacent topic wikis

- `rust-multi-platform` — Rust desktop/mobile/WASM surfaces; Bevy ships to all of them
- `iroh-transport-stratum-v2` — adjacent only via Rust networking ecosystem
