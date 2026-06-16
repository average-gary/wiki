---
title: "ECS FAQ — Comparative Taxonomy of Storage Strategies"
source_url: https://github.com/SanderMertens/ecs-faq
source_date: 2024
ingested: 2026-06-15
type: repo
author: Sander Mertens (creator of Flecs)
quality: 4
credibility: high
research_path: academic
tags: [ecs, archetype, sparse-set, bitset, comparison, flecs]
---

# ECS FAQ (Sander Mertens, Flecs author)

Canonical, neutral, vendor-comparative reference for ECS storage strategies and design space.

## Key findings

- Three-way taxonomy of ECS storage:
  - **Archetypes / table-based**: entities in tables with components as columns; fast iteration, slower add/remove; "query evaluation overhead reduces to near-zero as tables stabilize." Used by Flecs, Unity DOTS, Unreal Mass, **Bevy ECS**, Legion, Hecs, Ark, Our Machinery.
  - **Sparse set**: per-component sparse set keyed by entity ID; fast add/remove, slower iteration. Used by EnTT, Shipyard.
  - **Bitset-based**: per-component arrays + bitsets indicating membership; flexible matching via bitset ops. Used by EntityX, Specs.
- Explicit warning against universal performance claims: "different implementations make different tradeoffs, and as such an operation that is really fast in one framework is quite slow in another" — strategy must match access patterns.
- Distinguishes cached vs uncached queries (Flecs framing, broadly applicable): cached queries expensive to create, cheap to iterate; uncached the inverse.
- Treats relationships (`ChildOf`, `IsA`, etc.) as structural primitives beyond hierarchies — the framing Bevy 0.16 adopted.

## Significance

Neutral cross-engine reference for understanding *why* Bevy chose hybrid archetype+sparse-set storage and how that decision sits in the broader ECS design space.
