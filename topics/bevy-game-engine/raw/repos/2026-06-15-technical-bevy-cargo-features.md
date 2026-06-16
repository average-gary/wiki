---
title: "Bevy Cargo features reference (docs/cargo_features.md)"
source_url: https://github.com/bevyengine/bevy/blob/main/docs/cargo_features.md
source_date: 2026-06-15
ingested: 2026-06-15
type: repo
author: Bevy maintainers
quality: 5
credibility: high
research_path: technical
tags: [bevy, cargo, features, configuration]
---

# Bevy Cargo features reference

In-tree authoritative feature flag inventory.

## Key findings

- `default` = `2d` + `3d` + `ui` + `audio`.
- **Profiles**: `2d`, `3d`, `ui`, `audio` (each pulls scenes + picking).
- **Render features**: `bevy_render`, `bevy_core_pipeline`, `bevy_pbr`, `bevy_sprite_render`, `bevy_gizmos`, `bevy_post_process`, `bevy_anti_alias`, `meshlet`, `dlss`.
- **Audio formats**: `vorbis`, `flac`, `mp3`, `mp4`, `aac`, `wav` (under `bevy_audio`).
- **Image/asset formats**: `png`, `jpeg`, `webp`, `ktx2`, `basis-universal`, `dds`, `exr`, `tga`, `tiff`, `bmp`, `gif`, `ico`, `qoi`, `pnm`, `ff`.
- **Platform**: `wayland`, `x11`, `web`, `webgl2`, `webgpu`, `android-game-activity`, `android-native-activity`.
- **Dev/trace**: `bevy_dev_tools`, `file_watcher`, `embedded_watcher`, `trace_chrome`, `trace_tracy`, `bevy_debug_stepping`, `debug`, `detailed_trace`, `track_location`.
- **Perf/linking**: `dynamic_linking`, `multi_threaded`, `async_executor`.
- **Serialization/state**: `bevy_world_serialization`, `bevy_scene`, `bevy_state`, `serialize`.
- **Picking/UI/input**: `bevy_picking`, `mesh_picking`, `sprite_picking`, `ui_picking`, `bevy_ui_widgets`, `bevy_input_focus`.
- **Newer/notable**: `hotpatching`, `libm`, `critical-section`, `http`, `https`, `system_clipboard`, `custom_cursor`, `screenrecording` (gates `EasyScreenRecordPlugin`).

## Note on Bevy Cheat Book

`bevy-cheatbook.github.io` (Iyes' Cheat Book) is **explicitly no longer maintained** as of 2026 ("This book is no longer maintained. Much of the information in it is outdated"). Its platform-status pages (still useful for the structural blockers it documents) are an exception worth ingesting separately, but downstream agents should not cite Cheat Book API examples as current.
