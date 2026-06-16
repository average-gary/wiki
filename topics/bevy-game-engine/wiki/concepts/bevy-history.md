---
title: "Bevy history and timeline"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, history, cart, timeline, governance]
---

# Bevy history and timeline

## Origin

**Carter Anderson** (Cart) created Bevy. First public release: **2020-08-10** ([[bevy-introducing.md|0.1 launch announcement]]).

Pre-Bevy: Cart was a Senior Software Engineer at Microsoft, with 4+ years building a game in Godot, plus experience with Unity, Unreal, SDL, Three.js. He left Microsoft to pursue Bevy full-time, motivated by the Rust gamedev ecosystem (then organized around Amethyst) and a clear data-oriented design vision.

The launch post articulated [[bevy-introducing.md|six pillars]] (Capable, Simple, Data Focused, Modular, Fast, Productive) and the "turtles all the way down" philosophy — no scripting boundary, no proprietary tooling, all the way down.

## Year 1: explosive uptake (2020–2021)

[[bevy-first-birthday.md|First birthday post]] details the first year:

- Week 1: 3rd-most-popular r/rust post of all time, 2,200 GitHub stars
- Day 10: $1,500/month sponsorship goal hit, anchored by **Embark Studios** — Cart went full-time on Bevy
- Releases 0.1–0.4 in the first ~4 months, roughly monthly
- April 2021 (~0.5): complete ECS rewrite (the [[bevy-0-5-ecs-v2.md|hybrid table+sparse-set system]] still in use today) and PBR introduction
- End of year 1: 10k stars, 255 contributors, 4,871 Discord members

## Year 2–3: ECS scheduler maturation (2021–2023)

The big architectural arc:

- Stage-based scheduling pain accumulating
- [[bevy-0-10-stageless.md|Bevy 0.10 (March 2023)]] shipped Schedule V3, the multi-year stageless redesign; "many foxes" benchmark improved 5x
- Pipelined parallel rendering landed alongside

## Year 4: Foundation pivot (2023–2024)

[[bevy-fourth-birthday.md|Fourth birthday post]]:

- **Bevy Foundation incorporated 2024-03-11** — Cart held all IP/domains/infra personally pre-Foundation; "no longer sustainable"
- Three releases (0.12, 0.13, 0.14) — renderer matured: deferred rendering, virtual geometry, irradiance volumes, reflection probes, volumetric fog
- 41% of all PRs in Bevy's history merged in year 4 alone
- Alice Cecile hired as full-time staff engineer

## Year 5: ECS modernization + tooling push (2024–2025)

[[bevy-fifth-birthday.md|Fifth birthday post]]:

- **501(c)(3) status granted 2024-09-25**
- 0.15 (Nov 2024): Required Components, entity picking integrated, animation graph, curves
- 0.16 (Apr 2025): GPU-driven rendering, [[bevy-relationships.md|Relationships]], procedural atmosphere, decals, occlusion culling
- 0.17 (Sept 2025): observers/events overhaul, headless widgets + Feathers, hot patching, DLSS, [[bevy-rendering.md|Solari]]
- BSN draft implementation ready for review
- Year-5 stats: 40,900 stars, 1,291 contributors, 2.75M downloads, 21,985 Discord members

## Year 6: BSN slips, 0.18 lands (late 2025–2026)

- 0.18 (2026-01-13): UI widgets (Popover, MenuPopup), variable fonts, Feathers ColorPlane, FreeCamera/PanCamera, atmosphere occlusion. Notably, **BSN slipped 0.18** despite being targeted there ([[bevy-0-17-modernization.md|0.17 release notes]] flagged it for 0.18 inclusion)
- 0.18.1 (2026-03-02) — patch
- 0.19 development cycle entered Jan 2026; rc.3 published 2026-06-10 ([[bevy-twib-jan-2026.md|TWIB January 2026]])

## Stats over time

- Year 1: 10k stars, 255 contributors
- Year 4: ~30k stars (implied), 1,027 contributors
- Year 5: 40.9k stars, 1,291 contributors
- 2026-06-15: 46.6k stars, 1,865 reverse-deps, 5.86M crates.io downloads

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-foundation.md|Foundation]]
- [[bevy-version-timeline.md|Version timeline]]
- [[bevy-stats.md|Stats reference]]
