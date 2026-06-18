---
title: "0 A.D. — Wildfire Games / Pyrogenesis engine"
source: https://github.com/0ad/0ad
mirror_status: archived 2024-09 — primary now at https://gitea.wildfiregames.com
official: https://play0ad.com/
type: repo
ingested: 2026-06-18
quality: 4
confidence: high
license: GPL-2.0 / MIT / LGPL-2.1 (mixed; dependencies)
language: C++ / JavaScript / Lua
tags: [0ad, pyrogenesis, RTS, GPL, gitea-migration, civ-adjacent, post-alpha]
---

# 0 A.D. — Pyrogenesis engine

Real-time strategy of ancient warfare. **Civ-adjacent** (4X-lite —
territory, economy, civilizations) rather than pure 4X (no Civ-style tech
tree depth). Most mature OSS engine in this neighborhood.

## Pyrogenesis stack

- **C++ 63.7% + C 24%** core
- **JavaScript 6.1%, Lua 2.5%** scripting layers — hybrid C++/JS
  architecture for sim+gameplay
- Multi-license repo (LICENSE.txt mixed: MIT, GPL-2.0, LGPL-2.1) — reflects
  third-party dependencies

## Provenance and governance

- GitHub repo **archived September 2024**; project moved to
  **https://gitea.wildfiregames.com**. Future fetches should target Gitea,
  not the archived GitHub mirror.
- Maintained by **Wildfire Games** (volunteer team).
- Project began **2001**, public alpha started 2010, **dropped "Alpha" label
  with Release 28 "Boiorix" on 2026-02-18** — a 16-year alpha cycle.

## Release timeline (recent)

- **Alpha 27 "Agni"** (2025-01-30) — final alpha; named for Hindu fire god
- **Patch 27.1** (2025-07-17) — perf, crash, multiplayer-stability fixes
- **Release 28 "Boiorix"** (2026-02-18) — the **first non-alpha** release
  - New German/Cimbri faction with semi-nomadic economy and siege units
  - Gendered civilian models
  - Direct Freetype font rendering (better East Asian + Hi-DPI)
  - SpiderMonkey 128 upgrade — drops Win 7/8.1 and macOS <10.15
  - **First 64-bit Windows build**
  - **First official Linux AppImage**
- Quote from devs: *"our development process has matured, our releases are
  more frequent, and our commitment to quality has never been higher."*

## Funding constraint (documented)

2013 Indiegogo aimed for **$160,000**, raised only **$33,251** —
insufficient to hire substantial paid help. Project remained dependent on
volunteer churn for the next decade-plus.

## Self-hosted multiplayer lobby (architecture)

Three components: **ejabberd** (XMPP server for auth/chat) + lobby bots
**XpartaMuPP** (game hosting) + **EcheLOn** (rating) + **SQLite** (ratings,
stats). UDP port 3478 plus STUN. Reference deployment Ansible playbooks at
github.com/0ad/lobby-infrastructure.

## Critical reception

User reviews (SourceForge) report:
- **Performance demands too high** despite pre-2010 visual style
- **AI rushes are unfair** for new players
- **UI overhead**: more time on management than warfare
- **Mac compatibility broken** in some configurations
- **Missing tutorials** repeatedly cited

## Why this matters

Even though civ-adjacent rather than pure 4X, Pyrogenesis is the most
mature OSS engine in this neighborhood. The **2026-02-18 alpha-label drop
after 16 years** is the canonical example of OSS 4X/RTS development pace
problems — and also the canonical example of *eventually* delivering. The
**Gitea migration** is itself a notable governance datapoint as projects
move off GitHub.
