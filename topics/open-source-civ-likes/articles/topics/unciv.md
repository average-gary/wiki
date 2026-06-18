---
title: Unciv
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-unciv.md
  - raw/articles/2026-06-18-unciv-modders-guide.md
  - raw/papers/2026-06-18-civagent-digital-player-unciv.md
---

# Unciv

[yairm210/Unciv](https://github.com/yairm210/Unciv) — open-source,
moddability-focused Android and Desktop **remake of Civ V**. By a wide
margin the highest-velocity OSS civ-like.

## Stack

- **Kotlin 99.5%** on top of **libGDX**
- License **MPL-2.0** (Mozilla Public License) — uncommon in this space;
  weaker copyleft than GPL, friendly to mod authors
- Modular layout: `android/`, `desktop/`, `core/`, `server/` subprojects

## Platforms

Android (Play, F-Droid), Windows MSI, Linux Flatpak/AUR, macOS Brew,
Raspberry Pi, web via Docker/VNC.

**iOS is explicitly not planned** — the project takes the position that
Apple's review and signing requirements aren't worth the cost.

## Release cadence — "live service"

As of 2026-06-18:

- **12,999 commits, 940 releases**
- Latest **v4.20.14 on 2026-06-16** (two days before this research)
- **5 point releases (4.20.10–4.20.14) in ~2.5 weeks** (May 31 – Jun 16,
  2025)

Recent themes: memory perf for large maps, modder-friendly JSON error
reporting (with file/line info), context-menu / UX work, console commands
(`civ add`/`civ remove`), new triggerable music-track unique, Boreal map
type. A black-screen-on-next-turn bug fixed in 4.20.14.

This release pace is unmatched in OSS civ-likes. Compare:
- Unciv: 940 releases
- Freeciv (canonical): 193 releases over decades
- Freeciv21: 42 releases
- 0 A.D.: ~28 alphas + Release 28

## Mod ecosystem — JSON-only + GitHub-as-registry

Unciv's mod story is unusually clean — see
[GitHub-as-mod-registry](../concepts/github-as-mod-registry.md).

**What mods can do**:
> *"Mods can add, replace and remove basic game definitions, such as units,
> nations, buildings, improvements, resources and terrains."*

Mods **cannot create entirely new abilities** — only data, not new code.

**Player install path**:
1. In-game Mod Manager → "Download mod from URL" → paste GitHub repo
2. Auto-extracted and ready

**The registry is GitHub itself**:
- Modders tag their repo with the GitHub topic `unciv-mod`
- The Mod Manager queries GitHub's topic search
- No central portal to maintain

**File format — JSON only**:
- Two folders: `/jsons` (game data), `/Images` (graphics)
- No compilation, no programming
- Desktop creation recommended over mobile

**Two mod classes**:
| Class            | Behavior                                                   | Use when                                   |
| ---------------- | ---------------------------------------------------------- | ------------------------------------------ |
| Extension mods   | Add to existing rulesets                                   | Easy; recommended starting point          |
| Base ruleset mods | Set `"isBaseRuleset":true` in `ModOptions.json`           | Total conversions / radical rule changes  |

## Copyright posture (project's own statement)

Unciv openly describes itself as a **"remake of Civ V"** — see
[Unciv copyright posture](../concepts/unciv-copyright-posture.md). The
project's own stance:

- Legal defense rests on **US Copyright Office circular FL-108**:
  intellectual property rights do not apply to mechanics. Game *mechanics*
  are not copyrightable; only *expression* is.
- **All Firaxis assets are off-limits** (images, sound) — must be replaced.
- Using "the Civilization name" or impersonating Civ branding is treated as
  *"probably illegal."*
- "Civilization" trademark is treated as **limited to the logo, not the
  word** — a position not litigation-tested.
- Project deliberately refuses to add **non-Civ-V features** — scope
  discipline as a legal-defense posture.

## Research use

Unciv is the testbed for [CivAgent / Digital Player](research-testbeds.md#civagent-digital-player-2025)
(Wang et al., NetEase Fuxi, 2025) — the only Unciv-as-research-testbed
paper found. Unciv's deterministic JSON rules and Kotlin codebase are
arguably easier to reason about than Freeciv-web's
C-server/JS-client/Python-proxy stack, making it a strong candidate for
prompt-engineering experiments with LLM agents.

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
- [Unciv copyright posture](../concepts/unciv-copyright-posture.md)
- [GitHub-as-mod-registry](../concepts/github-as-mod-registry.md)
- [Modding DSLs vs data formats](../concepts/modding-dsl-vs-data-format.md)
- [Civ-likes as AI research testbeds](research-testbeds.md)
