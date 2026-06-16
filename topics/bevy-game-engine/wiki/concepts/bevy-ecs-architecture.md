---
title: "Bevy ECS architecture"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, ecs, archetype, sparse-set, world, query, observer]
---

# Bevy ECS architecture

Bevy ECS is the core of the engine — components, systems, and resources are the load-bearing primitives, and rendering, UI, audio, input, and assets are themselves implemented as ECS systems and components. Cart's "turtles all the way down" framing ([[bevy-introducing.md|2020 launch]]) means there is no scripting boundary and no hidden engine layer: game code is the same kind of code as engine code.

## Core abstractions

Three primitives, all plain Rust types:

- **Entities** — opaque IDs (a `u32` index + generation counter)
- **Components** — plain structs implementing `Component`; storage is per-component, not per-entity
- **Systems** — plain Rust functions whose parameters describe the data they want; the scheduler infers access from the parameter list

Plus:

- `World` — owns all entities, components, resources
- `Resource` — singleton data not attached to any entity
- `Bundle` — convenience type for inserting multiple components at once (largely superseded by [[bevy-required-components.md|Required Components]] in 0.15+)

## Hybrid storage

Bevy's defining ECS-design choice — established in [[bevy-0-5-ecs-v2.md|Bevy 0.5 (April 2021)]] and unchanged since — is **per-component storage opt-in**:

- **Tables** (default, archetypal) — entities live in tables with components as columns; fast iteration, slow add/remove
- **Sparse Sets** (opt-in via `#[component(storage = "SparseSet")]`) — per-component sparse set keyed by entity ID; fast add/remove, slower iteration

Most ECS frameworks pick one strategy and ship it. Sander Mertens's [[ecs-storage-taxonomy.md|ECS FAQ]] lays out the three-way taxonomy:
- archetypal (Flecs, Unity DOTS, Unreal Mass, **Bevy**, Legion, Hecs)
- sparse-set (EnTT, Shipyard)
- bitset (EntityX, Specs)

Bevy's hybrid lets developers tune per component — frequent add/remove components (state markers, flags) get sparse-set; iteration-hot components (transforms, sprites) stay in tables.

## Stateful queries

Also from [[bevy-0-5-ecs-v2.md|0.5]]: queries cache archetype/table matches across runs, eliminating the classic naive-archetype failure mode where query performance degrades as archetype count grows. Combined with for-each iterators, this delivered 1.5–3x iteration speed improvements on fragmented data and ~10x improvement on component add/remove vs Bevy 0.4.

## Scheduler

The 0.5 scheduler ran systems in parallel by default with `SystemLabel`-based dependencies. [[bevy-0-10-stageless.md|Bevy 0.10 (March 2023)]] then collapsed the prior "stages with hard barriers" model into a single unified `Schedule` — see [[bevy-scheduler.md|scheduler design]] for the full story including run conditions, system sets, exclusive systems, and how the parallel executor works.

## Change detection

Reliable cross-frame change detection landed in 0.5 via a "world tick" design: tracks component changes regardless of system ordering or stage membership. Surfaced through `Changed<T>`, `Added<T>` query filters, and `Resource::is_changed()`.

## Reactivity (0.16+)

[[bevy-0-16-relationships.md|Bevy 0.16 (April 2025)]] generalized [[bevy-relationships.md|Relationships]] (entity-to-entity links built on component hooks) and introduced [[bevy-required-components.md|Required Components]]. [[bevy-0-17-modernization.md|Bevy 0.17 (Sept 2025)]] then overhauled the observer/event system: `On` replaced `Trigger`; new `EntityEvent` and `Message` traits split targeted vs buffered events. The current reactive model (`Observer`, `Trigger`, lifecycle `Hooks`) sits on top of immutable components (`#[component(immutable)]`).

## Hierarchy

Parent/child is no longer a special case. As of 0.16, hierarchy is just the `ChildOf` Relationship + its `Children` RelationshipTarget — the same machinery any custom relationship uses.

## Theoretical ceiling

[[ecs-scheduling-theory.md|Ratysz's foundational article]] (2020) makes the academic case explicit: optimal ECS scheduling with known runtimes is **NP-hard**. Disjointedness (the Rust-borrow-rule property letting two systems run in parallel) is **not transitive**: A∥B and B∥C does not imply A∥C. Bevy's scheduler is therefore a heuristic, not an optimum, and that's a structural ceiling no implementation can break.

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-scheduler.md|Scheduler design]]
- [[bevy-relationships.md|Relationships]]
- [[bevy-required-components.md|Required Components]]
- [[bevy-version-timeline.md|Version timeline]]
