---
title: "Bevy 0.10 Release Notes — Schedule V3 / Stageless ECS"
source_url: https://bevy.org/news/bevy-0-10/
source_date: 2023-03-06
ingested: 2026-06-15
type: article
author: Carter Anderson (Cart) / Bevy
quality: 5
credibility: high
research_path: academic
tags: [bevy, ecs, scheduler, stageless, run-conditions, system-sets]
---

# Bevy 0.10 — Schedule V3 / Stageless ECS

The release that collapsed Bevy's prior "stages with hard barriers" design into a single unified schedule.

## Key findings

- **Single unified schedule**: any system can specify ordering relationships against any other system across what were stage boundaries — eliminates "system_b not found because it's in a different stage" cross-stage referencing pain.
- **System Sets** unify the prior "labels" and "sets" concepts; sets are configurable, nestable, and "strictly additive" (rules can be added but not removed elsewhere) — a deliberate constraint to prevent scheduling paradoxes.
- **Run conditions** replace "run criteria" with simple boolean-returning systems supporting combinators (`not()`, `and_then()`, `or_else()`).
- **Exclusive systems** integrated directly into the schedule (vs running separately), enabling patterns like `(system_a, apply_system_buffers, system_b).chain()` for explicit command-buffer flush points.
- **Base Sets** preserve high-level structural ordering without rigid stages: each system belongs to at most one base set.
- Pipelined parallel rendering + stageless scheduling: "many foxes" benchmark improved from ~10 ms/frame (~100 FPS) to ~2.3 ms/frame (~434 FPS) — near 5x speedup.
- 173 contributors, 689 PRs merged.
- Implements rfcs/45-stageless.md, a multi-year design effort.
- Authorship credits: @alice-i-cecile, @maniwani, @WrongShoe, @cart, @jakobhellermann, @JoJoJet, @geieredgar.

## Significance

Anchors one of Bevy's three biggest architectural pivots (stageless schedule), with primary-source rationale and authorship.
