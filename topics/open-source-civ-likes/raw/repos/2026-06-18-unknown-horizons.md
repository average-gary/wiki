---
title: "Unknown Horizons — unknown-horizons/unknown-horizons"
source: https://github.com/unknown-horizons/unknown-horizons
type: repo
ingested: 2026-06-18
quality: 4
confidence: high
license: GPLv2 (code) / asset licenses separate
language: Python
tags: [unknown-horizons, fife-engine, python, anno-style, dormant, GPLv2]
---

# Unknown Horizons — unknown-horizons/unknown-horizons

Anno-style 2D RTS focused on **economy / city-building** — civ-adjacent
(no tech tree). Maintained by the unknown-horizons team.

## Stack

- **Python 98.8%** on top of **FIFE** (fifengine — C++ engine with Python
  bindings) + **fifechan** GUI
- License **GPLv2** (code); assets separately licensed
- **Component-based architecture**; **YAML object configs** for moddable
  components; **SQLite** for map storage
- Multiplayer via **pyenet** (optional dep) — UDP-based, ENet protocol

## Status (cautionary)

- **Last release: January 2019**
- **16,464 commits but 0 active PRs**
- Discord still listed but project is effectively **dormant**

## Why this matters

Cautionary case for the active wiki — shows what happens to a Python/FIFE
stack when momentum stops. Useful contrast to Unciv's 940-release pace
(Kotlin/libGDX) and Freeciv21's CMake/Qt6 modernization.

Also useful as the **anno-style / city-building** branch of the OSS 4X
lineage — when the wiki discusses subgenres (4X, RTS, city-builder,
empire-builder), Unknown Horizons anchors the city-builder cell.
