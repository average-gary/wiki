---
title: "openage — SFTtech/openage (Age of Empires II reimplementation)"
source: https://github.com/SFTtech/openage
type: repo
ingested: 2026-06-18
quality: 5
confidence: high
license: GPLv3-or-later
language: C++ / Python / Cython
tags: [openage, aoe2-reimpl, nyan-DSL, GPL-3.0, qt6, polyglot, civ-adjacent]
---

# openage — Age of Empires II reimplementation

GPLv3-or-later AoE II reimplementation. **Civ-adjacent** (RTS lineage, not
pure 4X) but architecturally important: introduces a **purpose-built modding
DSL** rare in OSS games.

## Stack

- **C++20** engine core (37.7%)
- **Python 3** (53.6%) — scripting, media conversion, in-game console
- **Cython** (5.2%) — bridge layer
- **Qt6** GUI, **OpenGL** renderer, **Opus** audio
- Build: CMake + `./configure --download-nyan && make`. Docker supported.

## nyan DSL

Custom modding language **"nyan"** ("Yet Another Notation") — purpose-built
data-definition DSL for content/rules.

This is rare in OSS games. Compare:
- Freeciv: ruleset files, plain text
- Unciv: JSON
- Bevy ecosystem: typically Rust + bevy_asset
- openage: a *typed*, dedicated DSL

Worth its own concept article in the wiki.

## Asset story

Requires original AoE I/II (or Definitive Edition) assets. Ships a converter
that *"transforms original assets into openage formats, which are a lot
saner and more moddable."*

Same pattern as Unciv (replace assets) but inverted (reuse original assets,
convert to better internal format).

## Status

Honestly self-described as **"basically non-functional"** gameplay-wise —
engine rewrite in progress. **v0.6.0 released 2024-11-26.** 14.3k stars,
1.2k forks, 197 open issues.

Planned: Haskell-based masterserver for matchmaking; Python AI scripting
interface with ML support.

## Why this matters

The **nyan DSL** + the self-aware **"we rewrote the sim"** stance make this
a uniquely educational architecture case study. Even if not playable, the
project is worth referencing whenever wiki articles discuss:
- Modding DSLs vs. data formats (JSON, ruleset, Lua)
- Asset replacement / conversion strategies
- C++/Python hybrid engines
- The "what does engine maturity even mean" question
