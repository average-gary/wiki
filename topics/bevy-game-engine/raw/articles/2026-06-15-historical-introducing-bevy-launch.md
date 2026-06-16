---
title: "Introducing Bevy (0.1 launch announcement)"
source_url: https://bevy.org/news/introducing-bevy/
source_date: 2020-08-10
ingested: 2026-06-15
type: article
author: Carter Anderson (Cart) / Bevy
quality: 5
credibility: high
research_path: historical
tags: [bevy, origin, cart, pillars, history]
---

# Introducing Bevy (2020-08-10)

Canonical origin document. Every later Bevy retrospective traces back to its six pillars and philosophy statements.

## Key findings

- First public release: **August 10, 2020**, by **Carter Anderson** (Cart, @cart-cart), then a Senior Software Engineer at Microsoft who left that role to pursue Bevy full-time.
- Pre-Bevy background: 4+ years building a game in Godot; experience with Unity, Unreal, SDL, Three.js; close follower of the Rust gamedev ecosystem (Amethyst era).
- **Six original design pillars**: Capable, Simple, Data Focused (ECS), Modular, Fast (parallel), Productive (compile times).
- Coined "Bevy ECS is the most ergonomic ECS in existence" and the "turtles all the way down" framing — game code traceable into engine source with no language/scripting boundary.
- Hard productivity stance: explicit acceptability scale (0-1s ideal, 10+s "unusable"), achieved 0.8-3s iterative compiles via dependency hygiene, LLD linker, nightly opts.
- Anti-competition framing: "Bevy is not trying to out-compete other open-source game engines" — positioned as shared infrastructure for Rust gamedev.
