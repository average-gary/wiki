---
title: "Bevy rendering"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, rendering, wgpu, pbr, gpu-driven, solari, render-graph]
---

# Bevy rendering

Bevy's renderer is built on **wgpu** (Rust implementation of WebGPU) — the same backend that ships in Firefox and Servo. wgpu's recent download volume (24.6M all-time) dwarfs Bevy's, indicating its userbase extends well beyond Bevy.

## Architecture

The render pipeline runs in its own ECS world (the `RenderApp`) which mirrors the main world's renderable state. The render graph is itself ECS — render passes are nodes, edges are dependencies, the same scheduler primitives apply.

[[bevy-0-16-relationships.md|0.16]] introduced the **retained rendering world** model: main and render worlds maintain *separate* entity spaces synchronized via `MainEntity`/`RenderEntity` components. This replaces the older immediate-mode "clear & resync each frame" pattern, which paid full archetype-movement cost every frame.

## GPU-driven rendering (0.16)

[[bevy-0-16-relationships.md|0.16]] shipped GPU-driven rendering via:

- Multi-draw indirect — the GPU consumes a draw-list buffer instead of receiving individual draw calls
- Bindless resources — the GPU indexes into resource arrays rather than rebinding per draw
- GPU transform/cull — compute shaders update transforms and cull invisible objects without CPU involvement

Caldera scene benchmark (127,515 objects), mobile RTX 4090: 33.55 ms/frame → 10.16 ms/frame (~3x faster). Transform propagation alone went from 1.1 ms → 0.1 ms on M4 Max (~11x).

Tiering: full GPU-driven on Vulkan/Linux; partial on WebGL2 (which lacks the necessary features).

## Solari (0.17 experimental)

[[bevy-0-17-modernization.md|0.17]] shipped **Bevy Solari** — experimental physically-based real-time raytraced lighting capable of rendering "hundreds of shadow-casting lights" on fully dynamic scenes. [[bevy-0-18-release.md|0.18]] added specular materials, faster lighting reaction, and soft shadows. Solari is opt-in; production projects should not depend on it.

## DLSS and upscaling

[[bevy-0-17-modernization.md|0.17]] added DLSS support for NVIDIA RTX hardware.

## PBR and atmosphere

Standard PBR (metallic-roughness, normal/AO/emissive maps) shipped in 0.5 and has matured release-by-release. Procedural atmospheric scattering with day/night cycle landed via the `Atmosphere` component on cameras in [[bevy-0-16-relationships.md|0.16]]. [[bevy-0-18-release.md|0.18]] extended atmosphere to occlude/shade light and added `ScatteringMedium` assets for custom atmospheres (desert, foggy, alien).

Decals (forward + clustered), experimental occlusion culling, and anamorphic bloom shipped in 0.16. Light Textures (PointLightTexture etc. for masking lights — caustics, window-shadow fakes) shipped circa mid-2025.

## Materials

[[bevy-0-17-modernization.md|0.17]] dropped the type-level `Material` trait in favor of data-driven materials, partly to fix the [[bevy-criticisms.md|fragmentation across 3D/2D/UI materials JMS55 critiqued]]. The new system is decoupled from `bevy_render`, enabling third-party renderer pluggability.

## Virtual geometry

[[bevy-0-17-modernization.md|0.17]] added virtual geometry BVH culling. Bevy claims real-time rendering of 115B+ triangle scenes on consumer hardware. (Note: claim untested by this researcher.)

## Known gaps

Per [[bevy-criticisms.md|JMS55's 5th-birthday critique]] (Sept 2025):

- Asset processing APIs are "clunky and don't support enough features"
- Only outdated BasisU for texture compression
- glTF-to-virtual-geometry processor proved unfeasible — pipeline pushes shipping raw glTF/glb instead of optimized formats
- Custom materials "servicable but not enjoyable"; forces workarounds like `MeshTag`/`ShaderStorageBuffer`

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-version-timeline.md|Version timeline]]
- [[bevy-criticisms.md|Criticisms and limitations]]
