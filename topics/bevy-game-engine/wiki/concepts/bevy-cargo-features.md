---
title: "Bevy Cargo features"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, cargo, features, configuration, profiles]
---

# Bevy Cargo features

Bevy is heavily modular — every subsystem is a feature, and you ship only what you use. The 0.18 system has three tiers ([[docs-rs-bevy.md|docs.rs landing]], [[bevy-cargo-features-md.md|cargo_features.md]]).

## Tier 1: Profiles

High-level "what kind of app are you building?" toggles, introduced in 0.18:

- `default` = `2d` + `3d` + `ui` + `audio`
- `2d`, `3d`, `ui`, `audio` (each pulls scenes + picking)

For a 2D-only project: `bevy = { version = "0.18.1", default-features = false, features = ["2d"] }` collapses dependency setup.

## Tier 2: Collections

Subsystem-level groupings:

- Render: `bevy_render`, `bevy_core_pipeline`, `bevy_pbr`, `bevy_sprite_render`, `bevy_gizmos`, `bevy_post_process`, `bevy_anti_alias`, `meshlet`, `dlss`
- Dev: `bevy_dev_tools`, `file_watcher`, `embedded_watcher`, `bevy_debug_stepping`
- State: `bevy_state`, `bevy_scene`, `bevy_world_serialization`
- Picking: `bevy_picking`, `mesh_picking`, `sprite_picking`, `ui_picking`
- UI: `bevy_ui_widgets`, `bevy_input_focus`

## Tier 3: Individual features (100+)

- **Audio formats**: `vorbis`, `flac`, `mp3`, `mp4`, `aac`, `wav`
- **Image/asset formats**: `png`, `jpeg`, `webp`, `ktx2`, `basis-universal`, `dds`, `exr`, `tga`, `tiff`, `bmp`, `gif`, `ico`, `qoi`, `pnm`, `ff`
- **Platform**: `wayland`, `x11`, `web`, `webgl2`, `webgpu`, `android-game-activity`, `android-native-activity`
- **Trace/profile**: `trace_chrome`, `trace_tracy`, `debug`, `detailed_trace`, `track_location`
- **Perf/linking**: `dynamic_linking`, `multi_threaded`, `async_executor`
- **Newer**: `hotpatching`, `libm`, `critical-section`, `http`, `https`, `system_clipboard`, `custom_cursor`, `screenrecording` (gates `EasyScreenRecordPlugin`)

## DefaultPlugins vs MinimalPlugins

Two canonical plugin groups ([[docs-rs-bevy.md|docs.rs]]):

- **`DefaultPlugins`** — full app: rendering, windowing, input, audio, etc.
- **`MinimalPlugins`** — engine-only; e.g. headless servers, simulations, CLI tools

A headless dedicated server is `bevy = { ..., default-features = false, features = [] }` + `App::new().add_plugins(MinimalPlugins)`.

## dynamic_linking — fast iteration

`cargo add bevy -F dynamic_linking` links Bevy as a dylib. Per [[bevy-quick-start-setup.md|setup docs]]:

- Use during development for fast iterative builds
- **Don't ship with this enabled**
- On Windows, requires perf optimizations enabled to avoid linker errors

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-compile-time.md|Compile time]]
- [[bevy-platform-support.md|Platform support]]
