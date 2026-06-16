---
title: "Bevy scheduler design"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, scheduler, stageless, system-set, run-condition, parallel]
---

# Bevy scheduler design

## From stages to stageless

Pre-0.10 Bevy organized systems into discrete **stages** with hard barriers between them. The pain was real and well-documented: "specify that system_a runs before system_b, only to be met with confusing warnings that system_b isn't found because it's in a different stage" ([[bevy-0-10-stageless.md|0.10 release notes]]).

[[bevy-0-10-stageless.md|Bevy 0.10 (March 2023)]] shipped Schedule V3, the "stageless" RFC. Key changes:

- **Unified Schedule** — any system can specify ordering against any other system regardless of where it sits
- **System Sets** unify the prior "labels" and "sets" concepts; sets are configurable, nestable, and *strictly additive* (rules can be added but not removed elsewhere) — a deliberate constraint to prevent scheduling paradoxes
- **Run conditions** replace "run criteria" with simple boolean-returning systems supporting combinators (`not()`, `and_then()`, `or_else()`)
- **Exclusive systems** integrated directly into the schedule, enabling patterns like `(system_a, apply_system_buffers, system_b).chain()` for explicit command-buffer flush points
- **Base Sets** preserve high-level structural ordering without rigid stages: each system belongs to at most one base set

The "many foxes" benchmark improved from ~10 ms/frame (~100 FPS) to ~2.3 ms/frame (~434 FPS) on the same hardware — near 5x.

The redesign was years in the making. [[bevy-0-10-stageless.md|0.10]] credits @alice-i-cecile, @maniwani, @WrongShoe, @cart, @jakobhellermann, @JoJoJet, and @geieredgar for landing rfcs/45-stageless.md.

## Parallel execution

The scheduler runs systems in parallel by default. Two systems can run concurrently iff their data accesses are **disjoint** — formalized in [[ecs-scheduling-theory.md|Ratysz's analysis]]:

- A system's accesses are derived from its `SystemParam` types (queries, resources, commands)
- Disjointedness is **not transitive** (A∥B and B∥C does not imply A∥C)
- Optimal scheduling with known runtimes is **NP-hard**, so Bevy's scheduler is a heuristic
- System runtimes vary per frame, so static schedules underutilize resources — argument for dynamic dispatch

`ReportExecutionOrderAmbiguities` flags non-deterministic orderings as a debugging aid (introduced in [[bevy-0-5-ecs-v2.md|0.5]]).

## Command buffers

Systems that mutate the world structurally (spawning entities, inserting/removing components) typically use `Commands`, which queue operations into a per-system buffer. Buffers are flushed at well-defined points (between `chain()`-linked systems, at set boundaries, or via explicit `apply_system_buffers`) — preserving the disjointedness guarantee while letting structural mutations happen.

## Current state (0.18.1)

The bevy_ecs API surface ([[docs-rs-bevy-ecs.md|docs.rs landing]]):

- `Schedule`, `System`, `SystemSet`
- `Query`, `Commands`, `EntityCommands`, `SystemParam`
- Reactivity layer: `Observer` (reactive systems triggered by `Event`/`EntityEvent`), `Trigger` (immediate event dispatch), lifecycle `Hooks`
- 0.18 added safe multi-component mutable access via `EntityMut::get_components_mut()` ([[bevy-0-18-release.md|0.18 release notes]])

## See also

- [[bevy-ecs-architecture.md|ECS architecture]]
- [[bevy-overview.md|Bevy overview]]
- [[bevy-version-timeline.md|Version timeline]]
- [[ecs-scheduling-theory.md|ECS scheduling theory]]
