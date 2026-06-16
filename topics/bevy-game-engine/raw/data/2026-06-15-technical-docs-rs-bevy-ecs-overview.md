---
title: "bevy_ecs crate API documentation (docs.rs)"
source_url: https://docs.rs/bevy_ecs/latest/bevy_ecs/
source_date: 2026-03-02
ingested: 2026-06-15
type: data
author: Bevy maintainers / docs.rs
quality: 5
credibility: high
research_path: technical
tags: [bevy, ecs, docs-rs, world, schedule, observer]
---

# bevy_ecs crate API doc (0.18.1)

## Key findings

- Three core abstractions: Entities (IDs), Components (plain structs), Systems (plain Rust fns).
- Core types: `World`, `Entity`, `Component`, `Resource`, `Bundle`.
- Scheduling: `Schedule`, `System`, `SystemSet`, parallel executor that respects dependencies via `SystemParam` access analysis.
- Query/access: `Query`, `Commands`, `EntityCommands`, `SystemParam` (type-driven param extraction).
- **Reactivity**: `Observer` (reactive systems triggered by `Event`/`EntityEvent`), `Trigger` (immediate event dispatch), lifecycle `Hooks` for insertion/removal.
- Change detection: `Changed<T>`, `Added<T>` query filters; `Without<T>`; `Resource::is_changed()`.
- **Storage strategies**: Tables (default — fast iteration, slow add/remove) vs SparseSet (`#[component(storage = "SparseSet")]` — fast add/remove, slower iteration).
- Notable submodules: `hierarchy` (parent/child via `ChildOf` relationship — replaced the older `Parent`/`Children` pattern), `message`, `relationship`, `lifecycle`.
