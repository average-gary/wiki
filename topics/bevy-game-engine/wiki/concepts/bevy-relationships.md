---
title: "Bevy Relationships"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, ecs, relationships, hierarchy, child-of, hooks]
---

# Bevy Relationships

Generalized entity-to-entity links shipped in [[bevy-0-16-relationships.md|Bevy 0.16 (April 2025)]]. Built on component lifecycle hooks introduced in 0.14.

## Mechanics

Two paired components:

- A **`Relationship`** component is the source of truth, stored on the "source" entity
- A paired **`RelationshipTarget`** component is auto-synced on the "target" entity by component hooks

Both directions stay consistent. Insertion is O(1) — the hook system batches the synchronization.

The parent-child hierarchy was rebuilt as `ChildOf` (the Relationship) + `Children` (the RelationshipTarget). The same machinery that powers any custom relationship now powers the hierarchy — a small, principled API replacing what had been a special case.

## Why immutable components matter here

[[bevy-0-16-relationships.md|0.16]] also introduced **immutable components** (`#[component(immutable)]`) which prevent mutable access. This lets lifecycle hooks/observers capture *all* changes — required for the relationship invariant to hold (mutations through a back-door would leave the pair desynced).

## Custom relationships

User code can define its own Relationship/RelationshipTarget pairs for graph structures: faction membership, equipped items, target-tracking, scene graphs orthogonal to the transform hierarchy.

Sander Mertens's [[ecs-storage-taxonomy.md|ECS FAQ]] frames relationships as a structural primitive across modern ECS implementations (Flecs has them, Bevy now does, Unreal Mass and Unity DOTS have analogues). The framing Bevy adopted comes directly from the broader ECS design conversation.

## See also

- [[bevy-ecs-architecture.md|ECS architecture]]
- [[bevy-required-components.md|Required Components]]
- [[bevy-version-timeline.md|Version timeline]]
