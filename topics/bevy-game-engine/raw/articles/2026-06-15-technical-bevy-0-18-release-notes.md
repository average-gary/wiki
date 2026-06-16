---
title: "Bevy 0.18 release blog post"
source_url: https://bevy.org/news/bevy-0-18/
source_date: 2026-01-13
ingested: 2026-06-15
type: article
author: Bevy Foundation
quality: 5
credibility: high
research_path: technical
tags: [bevy, release-notes, 0.18, solari, ui, pbr]
---

# Bevy 0.18 (current shipping)

The current shipping release line as of 2026-06-15: **0.18**, with patch **0.18.1** published 2026-03-02. Domain note: `bevyengine.org` 301-redirects to `bevy.org`.

## Key findings

- 174 contributors, 659 PRs merged.
- `bevy_pbr`: procedural atmosphere now occludes/shades light; new `ScatteringMedium` asset for custom atmospheres (desert/foggy/alien); fixes for over-bright specular on point/area lights and Fresnel term.
- `bevy_render`: **Solari** (experimental raytraced renderer) gains specular materials, faster lighting reaction, soft shadows; new `FullscreenMaterial` trait + `FullscreenMaterialPlugin` for post-process shaders.
- `bevy_ui`: new widgets `Popover`, `MenuPopup`; improved `RadioButton`/`RadioGroup`; `AutoDirectionalNavigation` component for gamepad/keyboard nav; `FontWeight` + `FontFeatures` (variable fonts, OpenType features, ligatures); pickable text sections; `IgnoreScroll` for sticky headers; `TryStableInterpolate` for `Color` and `Val`. Bevy Feathers widget set adds `ColorPlane` 2D color picker.
- `bevy_app`: high-level Cargo feature **profiles** `2d`, `3d`, `ui` collapse dependency setup; first-party `FreeCamera` and `PanCamera` controllers in new `bevy_camera_controller`; `remove_systems_in_set()` + `ScheduleCleanupPolicy`.
- `bevy_asset`: `GltfExtensionHandler` trait for custom glTF extensions; abbreviated type paths in processor meta files; `Reader` upgraded to `SeekableReader`; `EasyScreenshotPlugin` and `EasyScreenRecordPlugin` (latter behind `screenrecording` feature).
- `bevy_ecs`: safe multi-component mutable access via `EntityMut::get_components_mut()` / `EntityWorldMut::get_components_mut()` (runtime aliasing checks).
- `bevy_animation`: glTF extensions enable `AnimationGraph` from loaded scenes.

## Significance

Anchor source for "what is Bevy today" — the version reference for everything else in the wiki.
