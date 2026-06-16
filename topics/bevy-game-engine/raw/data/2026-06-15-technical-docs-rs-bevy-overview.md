---
title: "bevy crate API documentation (docs.rs)"
source_url: https://docs.rs/bevy/latest/bevy/
source_date: 2026-03-02
ingested: 2026-06-15
type: data
author: Bevy maintainers / docs.rs
quality: 5
credibility: high
research_path: technical
tags: [bevy, docs-rs, crate, modules, features]
---

# bevy crate API doc landing (0.18.1)

## Key findings

- Version **0.18.1**, license MIT OR Apache-2.0; "100% of the crate is documented."
- Re-exported subcrate modules: `animation`, `app`, `asset`, `audio`, `camera`, `color`, `ecs`, `gizmos`, `gltf`, `input`, `light`, `math`, `pbr`, `picking`, `render`, `scene`, `sprite`, `state`, `text`, `time`, `transform`, `ui`, `utils`, `window`, `winit`.
- Note: `camera`, `color`, `light`, `picking`, `state` are now top-level modules (a structural change from earlier 0.x layouts).
- **Three-tier feature system**:
  - Profiles: `default`, `2d`, `3d`, `ui`
  - Collections: `dev`, `audio`, `scene`, `picking`, `default_app`, `default_platform`, render-specific
  - Individual Features: 100+
- Two canonical plugin groups: `DefaultPlugins` (full app) and `MinimalPlugins` (engine-only, e.g. headless).
- Tier-1 platform: `x86_64-unknown-linux-gnu`.
