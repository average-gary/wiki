---
title: "Bevy 0.16 Release Notes — Relationships, GPU-Driven Rendering, Required Components"
source_url: https://bevy.org/news/bevy-0-16/
source_date: 2025-04-24
ingested: 2026-06-15
type: article
author: Carter Anderson (Cart) / Bevy
quality: 5
credibility: high
research_path: academic
tags: [bevy, ecs, relationships, gpu-driven, required-components, immutable]
---

# Bevy 0.16 — Relationships, GPU-driven rendering

Most architecturally dense recent release — covers relationships, GPU-driven rendering, and required components in one primary-source document.

## Key findings

- **Generalized Relationships** built on component hooks: a `Relationship` component is the source of truth, automatically syncing a paired `RelationshipTarget` component. Maintains O(1) insertion. The parent-child hierarchy was rebuilt as `ChildOf` + `Children` — a small, principled API replacing a special-cased one.
- **Immutable components** (`#[component(immutable)]`) prevent mutable access, enabling lifecycle hooks/observers to capture *all* changes — critical for invariant maintenance and reactive systems.
- **Entity disabling** via `Disabled` component, with default query filters hiding disabled entities; `App::register_disabling_component` allows multiple distinct disabling semantics.
- **GPU-driven rendering** via multi-draw indirect, bindless resources, GPU transform/cull. Caldera scene (127,515 objects) on a mobile RTX 4090: 33.55 ms (0.15) → 10.16 ms (0.16) — ~3x improvement. Platform-tiered: full GPU-driven on Vulkan/Linux, partial on WebGL2.
- **Transform propagation**: 1.1 ms → 0.1 ms on M4 Max for the Caldera scene (~11x), saving ~6% of the 60-FPS frame budget.
- **Required Components** (introduced 0.15, refined 0.16): components declare their dependencies via `#[require(...)]`, replacing flat bundles. Cached on the archetype graph; only inserted if the caller didn't insert manually — combines bundle ergonomics with archetype-level efficiency.
- **Retained rendering world** (foundational): main and render worlds maintain separate entity spaces synchronized via `MainEntity`/`RenderEntity` components — replaces immediate-mode "clear & resync each frame" pattern, eliminating archetype-movement overhead.
- 261 contributors, 1,244 PRs.
- Procedural atmospheric scattering with day/night cycle via `Atmosphere` component on camera.
- Improved Spawn API with `children!` macro for declarative hierarchies.
- Unified Error Handling: systems/commands return `Result`, `?` operator works (panic-by-default in dev).
- Decals (forward + clustered), experimental occlusion culling, anamorphic bloom.
- `no_std` support across Bevy and subcrates.
- Entity cloning via `clone_and_spawn()`.
