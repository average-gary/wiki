---
title: "Bevy's Fifth Birthday — what's still missing"
source_url: https://jms55.github.io/posts/2025-09-03-bevy-fifth-birthday/
source_date: 2025-09-03
ingested: 2026-06-15
type: article
author: jms55 (longtime Bevy renderer/Solari contributor)
quality: 5
credibility: high
research_path: contrarian
tags: [bevy, criticism, ui, editor, asset-processing, animation, materials, bsn]
---

# JMS55 — what's still missing in Bevy

The best steelman against Bevy as of 2025-09. Written by a respected core contributor.

## Key findings

- "It's hard to recommend Bevy for UI-heavy games and apps" — no proven high-level API for declaring/updating UI trees; BSN solves the declarative half but not reactivity.
- **Editor absence**: "a big, big hole for Bevy"; author personally hit friction setting up the Solari demo, says BSN-based prototypes were "exceedingly difficult to write and understand."
- **Asset processing**: APIs are "clunky and don't support enough features"; only outdated BasisU for texture compression; glTF-to-virtual-geometry processor proved unfeasible — pipeline pushes shipping raw glTF/glb instead of optimized formats.
- **Animation**: API is "quite clunky, with too many confusingly-named components" and requires excessive entities.
- **Custom materials**: "servicable but not enjoyable"; forces workarounds like `MeshTag`/`ShaderStorageBuffer`; fragmentation across 3D/2D/UI with no unified abstraction.
- Criticizes BSN implementation process for opacity and extended timeline.

## Significance

Specific, recent, written by an insider. Carries more weight than a drive-by hot take.
