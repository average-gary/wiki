---
title: "Bevy Required Components"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, ecs, required-components, bundles, archetype]
---

# Bevy Required Components

Introduced in 0.15, refined in [[bevy-0-16-relationships.md|0.16]]. Components declare their dependencies via `#[require(...)]` attributes:

```rust
#[derive(Component)]
#[require(Transform, GlobalTransform, Visibility)]
struct Player;
```

Inserting `Player` automatically inserts `Transform`, `GlobalTransform`, `Visibility` if they aren't already present. The required-component graph is cached on the archetype graph, so this is a compile-once cost rather than per-insertion.

## Why this replaced flat Bundles

Bundles (`#[derive(Bundle)]`) were Bevy's prior "insert several components together" mechanism. They had two problems:

1. **No invariants** — you could spawn a `Player` without its required components, and nothing would catch it until later.
2. **Composition was nominal** — adding "make this thing visible" meant editing the bundle struct, not the component.

Required Components push the invariant onto the component itself: the component's `#[require(...)]` line is the single source of truth for "what does this need to function." Inserting it is enough; the dependency closure is computed from the component graph.

## Override behavior

If the caller manually inserts a required component, the `#[require(...)]` rule **does not** overwrite it — the manually-supplied value wins. This matters for cases where the default isn't what you want (e.g., a `Player` that starts invisible).

## See also

- [[bevy-ecs-architecture.md|ECS architecture]]
- [[bevy-relationships.md|Relationships]]
- [[bevy-version-timeline.md|Version timeline]]
