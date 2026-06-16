---
title: "TWIB — Avian parallel solver, Light Textures, commercial Bevy at Nominal/Foresight"
source_url: https://thisweekinbevy.com/issue/2025-07-07-the-next-big-step-for-avian-performance-light-textures-and-playtests
source_date: 2025-07-07
ingested: 2026-06-15
type: article
author: This Week in Bevy
quality: 4
credibility: high
research_path: applied
tags: [bevy, nominal, foresight, avian, non-game]
---

# TWIB 2025-07-07 — Non-game commercial Bevy

Best single-link evidence that Bevy is used by real companies for industrial visualization.

## Key findings

- Names two non-game commercial Bevy users explicitly:
  - **Nominal** — industrial test/data platform: telemetry, logs, video, simulation for aerospace/maritime/ground vehicles/energy.
  - **Foresight** — machine vision, satellite-constellation modeling, drone testing, CFD visualization.
- Avian physics (the dominant 3rd-party Bevy physics crate) is gaining a parallel constraint solver via graph coloring — large-pile simulation scaling.
- Light Textures landed: PointLightTexture/etc. for masking lights — caustics, window-shadow fakes — production rendering feature.
- Active commercial-adjacent playtests for *To Build a Home* and *Rare Episteme*.
- Ongoing UI rendering migration to dedicated `bevy_ui_render` crate.
