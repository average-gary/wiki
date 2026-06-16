---
title: "Future support for exporting Bevy games to Android and iOS (Discussion #20998)"
source_url: https://github.com/bevyengine/bevy/discussions/20998
source_date: 2025-09-13
ingested: 2026-06-15
type: article
author: Bevy maintainers and users
quality: 4
credibility: high
research_path: contrarian
tags: [bevy, mobile, ios, android, export, ergonomics]
---

# Bevy Discussion #20998 — mobile export

Maintainer admission on the mobile gap.

## Key findings

- **NthTensor (maintainer)**: "It is possible to ship games to iOS and Android, but not easy... We don't have enough devs using bevy on these platforms who are able to debug issues and improve ergonomics" — explicit ecosystem-resource gap.
- Pixel-level interaction with game objects requires workarounds.
- Multi-touch screen support has "constraints and implementation difficulties."
- No streamlined export workflow — manual setup instead of templated pipelines (compare Unity/Godot's mobile build buttons).
- **viridia**: deeper blocker is platform-vendor cooperation and Rust language support from Apple/Google — extends beyond Bevy.
