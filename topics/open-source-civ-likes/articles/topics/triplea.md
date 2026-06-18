---
title: TripleA (boundary marker)
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-triplea.md
---

# TripleA — boundary marker

[triplea-game/triplea](https://github.com/triplea-game/triplea) is a Java /
GPL-3.0 turn-based strategy / board-game engine. *"Similar to Axis &
Allies or Risk."*

This article exists primarily to **mark the boundary of what civ-like
means** in this wiki. TripleA is *not* civ-like — but it is an active,
high-quality OSS strategy project that gets confused with civ-likes.

## Why TripleA is excluded

A civ-like in this wiki's sense (see
[Landscape § What civ-likes have in common](landscape.md#what-civ-likes-have-in-common-and-what-defines-them)):
- eXplore, eXpand, eXploit, eXterminate core loop (4X)
- Tech tree of meaningful depth
- Multiple win conditions
- Procedural map + civilization personality / leader trait system
- Historical progression from antiquity through to modern / future era

TripleA fails the test:

| Criterion                | TripleA                                |
| ------------------------ | -------------------------------------- |
| 4X loop                  | No — pre-defined scenarios             |
| Tech tree depth          | Thin / scenario-specific               |
| Procedural map           | No — community-created scenario maps   |
| Tech progression / eras  | No — fixed-era tactical combat         |
| Leader trait / civ system | Maps have factions, not civ archetypes |

It's a **tactical / board-game engine**, not a 4X game.

## What TripleA actually is

- **Java 99.8%, GPL-3.0**
- Active **lobby system** for live multiplayer
- Community-created maps span WWII, historical, and fantasy scenarios
- 15,647 commits, 1.5k stars
- Latest release **`2026-06.16.15647` on 2026-06-15** (date-stamped versioning)
- Very active — release cadence comparable to Unciv

## Why include TripleA at all

A short stub article pinning TripleA as the canonical "active OSS strategy
project that is *not* a civ-like" reference helps the wiki taxonomy stay
crisp. When a reader asks "what about TripleA?", the answer is clear: it's
an excellent project, just not in scope.

[OpenRA](https://www.openra.net) (Red Alert / Tiberian Dawn / Dune 2000
reimplementation) is similarly out of scope for the same reasons —
real-time tactical combat, no 4X loop.

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
