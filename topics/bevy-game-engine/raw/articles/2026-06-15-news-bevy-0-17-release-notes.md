---
title: "Bevy 0.17 Release Announcement"
source_url: https://bevy.org/news/bevy-0-17/
source_date: 2025-09-30
ingested: 2026-06-15
type: article
author: Bevy Foundation
quality: 5
credibility: high
research_path: news
tags: [bevy, release-notes, 0.17, solari, observers, dlss, hot-patching]
---

# Bevy 0.17

The "modernization" release where observers/events overhauled, headless UI widgets, hot-patching, and Solari landed.

## Key findings

- 278 contributors, 1,311 PRs — largest release to date.
- **Bevy Solari**: experimental physically-based real-time raytraced lighting (hundreds of shadow-casting lights, fully dynamic scenes).
- **Observer/Event overhaul**: `On` replaces `Trigger`; new `EntityEvent` and `Message` traits split targeted vs buffered events.
- **Headless UI widgets**: `Button`, `Slider`, `Checkbox`, `RadioButton` — interaction logic decoupled from styling.
- **Bevy Feathers**: opinionated tooling widget set built on headless widgets, designed for the upcoming Bevy Editor (accessibility + theming).
- **Hot patching**: live system reload via subsecond integration.
- **DLSS support** for NVIDIA RTX.
- First-party **tilemap chunk rendering** (built-in tilemaps finally landed).
- Public API decoupled from `bevy_render` (third-party renderer pluggability).
- `UiTransform` replaces `Transform` in UI.
- Data-driven materials drop type-level `Material` trait.
- Virtual geometry BVH culling — claims 115B+ triangle scenes at real-time on consumer hardware.
- Explicitly flags **BSN ("Bevy's Next Generation Scene/UI System")** as targeted for 0.18 — though 0.18 release notes did NOT actually ship it. **BSN slipped 0.18.**
