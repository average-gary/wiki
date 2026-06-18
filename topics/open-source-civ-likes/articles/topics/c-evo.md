---
title: C-evo
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: medium
sources:
  - raw/repos/2026-06-18-c-evo.md
---

# C-evo

Civ II clone by **Steffen Gerlach** (German programmer). Originally Delphi
(Object Pascal), later ported to **Lazarus** for cross-platform builds.
Sits apart from the rest of the OSS civ-like landscape on three axes:
licensing, language, and AI architecture.

## License correction

The original research brief expected "C-evo open-sourcing news (it became
GPL relatively recently)." This is **incorrect**.

- C-evo has been **freeware since v0.1 (1999)**.
- The source code is **public domain** (*"This code is in the public
  domain"*) — *not GPL*.
- The public-domain status has been long-standing, not a recent
  relicensing.

Public-domain licensing in a maintained civ-like is genuinely unusual.
Compare:
- Freeciv: GPL-2.0+
- Freeciv21: GPL-3.0+
- Freeciv-web client: AGPL-3.0+
- Unciv: MPL-2.0
- 0 A.D.: GPL-2.0 / mixed
- openage: GPL-3.0+
- Unknown Horizons: GPLv2
- C-evo: **public domain**

## Distinct design

Explicitly **"tough and uncompromising AI"-focused** rather than
simulation-faithful Civ-clone. C-evo's pitch is the AI itself, not faithful
re-implementation. This is the inverse of Freeciv (faithful sim, weaker
AI) and Unciv (faithful Civ-V mechanics, mod-friendly).

## AI plugin architecture (the standout feature)

- Documented **DLL plugin interface** for AI opponents
- AI development kits in **C# (since 1.1.2), Delphi, and C++**
- Used as an AI research platform — cited at **IJCAI 2005**

This is rare — see [AI plugin architecture](../concepts/ai-plugin-architecture.md).
Compare:
- Freeciv: built-in C AI + Lua scripts (in-tree)
- Unciv: Kotlin AI (in-tree)
- C-evo: **pluggable AI DLLs** from any of three languages

## Activity

- Latest stable: **v1.3.6 on 2024-09-16**
- Project *is* still shipping despite low public profile
- Author Steffen Gerlach maintains it solo

## Distant Horizon (CDH)

The CDH fork was named in the research brief but the GitHub orgs
`c-evo-game/c-evo-dh` and `c-evo-game/c-evo-dh-stable` returned 404 at
research time. CDH's active home is **TBD** — possibly SourceForge,
GitLab, or a different GitHub org. Tracking down the live CDH repo is an
[open question](landscape.md#open-questions) for a follow-up round.

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
- [AI plugin architecture](../concepts/ai-plugin-architecture.md)
