---
title: "Tiny Glade on Steam — store page (Pounce Light)"
source_url: https://store.steampowered.com/app/2198150/Tiny_Glade/
source_date: 2024-09-23
ingested: 2026-06-15
type: data
author: Pounce Light
quality: 5
credibility: high
research_path: applied
tags: [bevy, production, tiny-glade, pounce-light, vulkan]
---

# Tiny Glade — Steam store page

Hard evidence for Bevy in commercial production.

## Key findings

- Released 2024-09-23 on Windows/macOS/Linux at $14.99.
- 97% positive across 13,357 English reviews — "Overwhelmingly Positive."
- Genre: gridless cozy building (no combat, no fail states); features procedural detail generation (ivy growth, sheep, fireflies) layered on player builds.
- Min-spec requires Vulkan 1.2, 4 GB RAM; older NVIDIA Kepler / Intel HD unsupported — reveals the Bevy/wgpu hardware floor in practice.
- Pounce Light is a 2-person studio.

## Caveat — what runs Tiny Glade

Bevy's own 5th birthday post (2025-08) lists Tiny Glade as a flagship Bevy commercial title, and TWIB issues confirm it uses Bevy ECS plus a heavily customized renderer. One third-party comparison source (Youngju 2026-05) claims Tiny Glade is "not Bevy" and instead runs a custom Rust engine — this appears to mistake the customization of the renderer for replacement of the engine. Bevy team's account is treated as authoritative here: **Tiny Glade is Bevy ECS + custom rendering**.
