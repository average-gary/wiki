---
title: "Scheduling and parallelism in Bevy ECS"
source_url: https://ratysz.github.io/article/scheduling-1/
source_date: 2020-09
ingested: 2026-06-15
type: article
author: Ratysz (yaks scheduler author; longtime Bevy contributor)
quality: 5
credibility: high
research_path: academic
tags: [bevy, ecs, scheduler, theory, np-hard, parallelism]
---

# Scheduling and parallelism in Bevy ECS (Ratysz)

Foundational, academically-styled treatment of ECS parallel scheduling theory written specifically about Bevy/Rust ECS.

## Key findings

- ECS scheduling is a formal optimization problem: "finding the optimal schedule for the systems, assuming their run times are known, is always **NP-hard**." Sets the theoretical ceiling on what any ECS scheduler can achieve.
- **Disjointedness rule** grounded in Rust borrowing semantics: systems can run in parallel only when their data accesses are disjoint; "data may be changed from only one place at a time, and data that may be changed elsewhere cannot be read."
- **Disjointedness is not transitive**: A∥B and B∥C does not imply A∥C. Direct implications for scheduler graph algorithms.
- **Unknown-runtime problem**: system runtimes "are in no way guaranteed to be equal, and often independently change," making static schedules underutilize resources — argument for dynamic/work-stealing approaches.
- Compares Bevy's stage-based implicit ordering (writes-before-reads inferred from insertion order) against `yaks`'s explicit dependency tags + dynamic queueing (start a system "if it is disjoint with already running systems").
- Both implementations must address thread-local systems and deferred modifications (command buffers) — practical constraints beyond pure theory.

## Significance

The most rigorous academically-styled treatment of ECS parallel scheduling theory written about Bevy/Rust ECS. Cited frequently in subsequent design discussions.
