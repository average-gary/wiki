---
title: "Freeciv (canonical upstream) — freeciv/freeciv"
source: https://github.com/freeciv/freeciv
type: repo
ingested: 2026-06-18
quality: 5
confidence: high
license: GPL-2.0
language: C
tags: [freeciv, canonical-upstream, GPL-2.0, autotools, meson, redmine]
---

# Freeciv (canonical) — freeciv/freeciv

Canonical upstream of the entire Freeciv lineage. All forks (Freeciv21,
Freeciv-web) descend from this codebase.

## Stack and language mix

- **C 86.7%, C++ 6.9%, Python 2.6%**
- License **GPL-2.0**
- Modular tree:
  - `/client` — client implementations (historical: GTK, SDL2, Qt)
  - `/server` — game server
  - `/ai` — AI implementations
  - `/lua` — Lua scripting integration
  - `/data` — rulesets, tilesets, scenarios, sound, music
  - `/common` — shared types and protocol

## Build system

**Dual** — autotools (`configure.ac`, `autogen.sh`) and Meson
(`meson.build`, `meson_options.txt`) coexist. This is unusual; most projects
pick one. Likely a transition in progress.

## Activity (as of 2026-06-18)

- **32,447 commits, 193 tagged releases, 1.6k stars, 274 forks**
- **Freeciv 3.2.4 released March 2026** (Wikipedia) — upstream is *not*
  abandoned despite Freeciv21's modernization push.
- Bug tracker on **Redmine** (redmine.freeciv.org), forum at
  forum.freeciv.org. Non-GitHub workflow worth noting for contributor
  onboarding.

## Why this matters

This is the lineage anchor for the wiki. Three downstream forks coexist:

1. **Freeciv21** — Qt6 modernization, Longturn-focused
2. **Freeciv-web** — browser fork (AGPL-3.0+)
3. **Fciv.net / freecivx.net** — 3D experiments

Upstream Freeciv continues as the GTK/SDL2/Qt5 desktop client and the
shared C server that all forks track.
