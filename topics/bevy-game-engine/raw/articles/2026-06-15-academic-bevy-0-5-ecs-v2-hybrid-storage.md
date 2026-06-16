---
title: "Bevy 0.5 Release Notes — ECS V2 Rewrite (Hybrid Table + Sparse-Set Storage)"
source_url: https://bevy.org/news/bevy-0-5/
source_date: 2021-04-06
ingested: 2026-06-15
type: article
author: Carter Anderson (Cart) / Bevy
quality: 5
credibility: high
research_path: academic
tags: [bevy, ecs, archetype, sparse-set, scheduler, change-detection]
---

# Bevy 0.5 Release Notes — ECS V2

Primary-source release notes for Bevy 0.5 (April 2021), the release that split Bevy ECS from the hecs fork and rebuilt the storage model from scratch.

## Key findings

- Hybrid storage model — per-component opt-in:
  - **Tables** (default, archetypal): fast iteration, slow add/remove
  - **Sparse Sets**: fast add/remove, slower iteration
  - Set via `ComponentDescriptor::new::<T>(StorageType::SparseSet)`
- Most ECS frameworks pick one strategy; Bevy lets the developer choose per component. This is Bevy's defining ECS-design choice.
- **Stateful queries**: queries cache archetype/table matches across runs, eliminating the classic naive-archetype failure mode where query performance degrades as archetype count grows. Combined with for-each iterators: 1.5–3x iteration speed improvements for fragmented iteration.
- ~10x improvement on component add/remove (10K ops) vs Bevy 0.4.
- New parallel scheduler: systems run in parallel by default, with `SystemLabel`-based many-to-many dependencies (`.label()`, `.before()`, `.after()`).
- `ReportExecutionOrderAmbiguities` resource flags non-deterministic orderings as a debugging aid.
- **Reliable cross-frame change detection** via a "world tick" design — tracks component changes regardless of system ordering or stage membership.
- Resources unified into the component system as a special case.
- `WorldCell` enables simultaneous mutable resource access by enforcing borrow rules at runtime instead of compile time.
- Components decoupled from Rust types — "blob storage accepting any value with a given memory layout"; laid groundwork for scripting and dynamic components.

## Significance

This is the canonical document for Bevy's defining architectural choice (hybrid archetype + sparse-set storage) and stateful-query optimization. Every later Bevy ECS release builds on this foundation.
