---
title: "Bevy version timeline"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, releases, versions, timeline, cadence]
---

# Bevy version timeline

Cadence: roughly one minor release every ~3 months, with breaking-change migration guides; patch releases ship reactively. Source: [[bevy-release-cadence.md|GitHub Releases API]].

## Release table

| Version | Date | What landed |
|---------|------|-------------|
| 0.1 | 2020-08-10 | First public release ([[bevy-introducing.md|launch post]]) |
| 0.4 | ~2020-12 | End of year 1 monthly cadence |
| 0.5 | 2021-04-06 | [[bevy-0-5-ecs-v2.md|ECS V2]] — hybrid storage, stateful queries, parallel scheduler, change detection, PBR |
| 0.10 | 2023-03-06 | [[bevy-0-10-stageless.md|Stageless ECS / Schedule V3]] — single unified schedule, system sets, run conditions |
| 0.12 / 0.13 / 0.14 | 2023–2024 | Year 4 renderer maturation: deferred rendering, virtual geometry, irradiance volumes, reflection probes, volumetric fog |
| 0.14 | 2024-07-04 | 256 contributors, 993 PRs |
| 0.15 | 2024-11-29 | Required Components, entity picking integrated, animation graph, curves. 294 contributors, 1,217 PRs |
| 0.16 | 2025-04-24 | [[bevy-0-16-relationships.md|Relationships]], GPU-driven rendering, procedural atmosphere, decals, occlusion culling, immutable components, error handling. 261 contributors, 1,244 PRs |
| 0.17 | 2025-09-30 | [[bevy-0-17-modernization.md|Observers/events overhaul, headless widgets + Feathers, hot patching, Solari, DLSS, virtual geometry BVH, tilemaps]]. 278 contributors, 1,311 PRs (largest cycle) |
| 0.17.1–0.17.3 | 2025-10 to 2025-11 | Patches |
| 0.18.0 | 2026-01-13 | [[bevy-0-18-release.md|UI widgets (Popover, MenuPopup), variable fonts, Feathers ColorPlane, atmosphere occlusion, FreeCamera/PanCamera]]. 174 contributors, 659 PRs |
| 0.18.1 | 2026-03-02 | Patch (current shipping max stable) |
| 0.19.0-rc.1 | 2026-05-13 | First 0.19 RC |
| 0.19.0-rc.3 | 2026-06-10 | Latest pre-release at snapshot |

## "Hot topic" status check

| Topic | Status |
|-------|--------|
| Required Components | Shipped 0.15 (Nov 2024), refined 0.16 |
| Relationships | Shipped 0.16 (Apr 2025) |
| Unified error handling | Shipped 0.16 |
| Observer/Event overhaul | Shipped 0.17 (Sept 2025) — `On` replaced `Trigger` |
| Hot patching | Shipped 0.17 |
| Headless UI widgets + Feathers | Shipped 0.17 |
| First-party tilemaps | Shipped 0.17 |
| DLSS | Shipped 0.17 |
| Solari (raytraced lighting) | Experimental in 0.17, refined 0.18 |
| Virtual fonts / OpenType / Variable fonts | Shipped 0.18 (Jan 2026) |
| Bevy Editor | NOT SHIPPING — design specs done, Inspector General WG active |
| **BSN (Bevy Scene Notation)** | **Targeted for 0.18, slipped** — still not in stable as of 0.18.1 |
| 1.0 release | No date committed |

Source: [[bevy-fifth-birthday.md|fifth birthday]], [[bevy-0-17-modernization.md|0.17]], [[bevy-0-18-release.md|0.18]], [[bevy-twib-jan-2026.md|TWIB Jan 2026]].

## Active working groups (early 2026)

From [[bevy-twib-jan-2026.md|TWIB January 2026]]:

- WESL-ification (shader language migration)
- Better Release Notes
- Decoupled Rendering
- "Turtles all the way down" (`!Send` data in ECS)
- Inspector General (entity inspector)
- Async ECS ergonomics
- Font ergonomics (shipped in 0.18)
- GPU rendering, ray tracing, audio, CLI tooling, shader standards (ongoing per [[bevy-fifth-birthday.md|5th birthday]])

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-history.md|History]]
- [[bevy-criticisms.md|Criticisms]]
- [[bevy-foundation.md|Foundation]]
