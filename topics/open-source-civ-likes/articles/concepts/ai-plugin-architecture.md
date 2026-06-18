---
title: AI Plugin Architecture (C-evo pattern)
type: concept
created: 2026-06-18
updated: 2026-06-18
confidence: medium
sources:
  - raw/repos/2026-06-18-c-evo.md
---

# AI Plugin Architecture (C-evo pattern)

Most OSS civ-likes ship a single, in-tree AI implementation:

- [Freeciv / Freeciv21](../topics/freeciv21.md): C AI core with Lua
  scripting hooks (in-tree)
- [Unciv](../topics/unciv.md): Kotlin AI (in-tree)
- [0 A.D.](../topics/0ad.md): JS-scripted AI (in-tree)

[C-evo](../topics/c-evo.md) takes the inverse approach: the engine
**ships an AI plugin interface**, AI implementations are **separate DLLs**.

## C-evo's interface

- Documented **DLL plugin interface** for AI opponents
- Development kits in **C# (since 1.1.2), Delphi, and C++**
- Each AI module is a separate binary loaded at game start
- Used as an AI research platform, cited at IJCAI 2005

This is rare in the genre.

## Why a plugin interface matters

- **Drop-in AI swaps**: a single game can mix multiple AIs from different
  authors as different opponents. The wiki user can compare strategies
  the way professional Go players analyze AlphaZero vs. KataGo.
- **Language plurality**: an AI in C# does not require recompiling the
  engine. A research lab can prototype in Python via a thin shim. C-evo
  ships kits in three languages because the contract is binary, not
  source.
- **Sandboxable**: a plugin DLL can in principle be process-isolated;
  in-tree AI cannot. C-evo does not appear to do process isolation in
  practice, but the architecture allows it.
- **Research reproducibility**: cite a specific AI binary version. Rerun
  the experiment by loading the same binary. In-tree AI requires citing
  a specific commit hash, which doesn't bind a behavior.

## Why most projects don't do this

- **API-stability cost**: a plugin interface is a long-term contract. In-
  tree AI can refactor whenever the engine refactors. C-evo's pace
  (latest stable v1.3.6 on 2024-09-16, single maintainer) is a hint
  that maintaining the plugin contract is *part* of the project's
  identity, not an afterthought.
- **Performance ceiling**: the in-process plugin call boundary still
  beats network-RPC AI, but in-tree AI can share data structures
  zero-copy.
- **Build complexity**: shipping AI kits in three languages multiplies
  the project's CI surface — C-evo is small enough to absorb this; a
  Freeciv-scale project probably can't.
- **Mod community fit**: plugin AI invites code mods, not data mods.
  Unciv's [GitHub-as-mod-registry](github-as-mod-registry.md) wouldn't
  work safely if mods were code.

## Reapplications worth considering

A new civ-like engine might adopt the C-evo pattern when:

- The point of the engine *is* AI research (CivRealm-style — see
  [Civ-likes as AI research testbeds](../topics/research-testbeds.md))
- Multiple competing AIs are a feature, not a curiosity
- A primary maintainer is willing to commit to API stability

For most projects, the simpler default is in-tree AI plus scripted
behavioral hooks (Freeciv's Lua approach). The C-evo pattern is the
specialist's choice.

## Adjacent concepts

- **CivRealm** ([papers/2026-06-18-civrealm-iclr-2024.md](../../raw/papers/2026-06-18-civrealm-iclr-2024.md))
  exposes a Gymnasium-style API — closer to "external client connecting
  to a game server" than "DLL plugin loaded by a game engine." Different
  contract, similar goal.
- **Vox Deorum** uses Civ V's mod hooks (via the Vox Populi mod) to
  inject LLM-driven AI — proprietary engine, but the architectural
  shape is plugin-AI-like.

## See Also

- [C-evo](../topics/c-evo.md)
- [Civ-likes as AI research testbeds](../topics/research-testbeds.md)
- [Modding DSLs vs data formats](modding-dsl-vs-data-format.md) —
  orthogonal: data-mods vs. behavior-plugins
