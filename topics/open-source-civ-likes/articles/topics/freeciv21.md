---
title: Freeciv21
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-freeciv21.md
  - raw/articles/2026-06-18-freeciv21-how-to-play.md
  - raw/articles/2026-06-18-freeciv21-rulesets-overview.md
  - raw/articles/2026-06-18-longturn-onboarding.md
---

# Freeciv21

[longturn/freeciv21](https://github.com/longturn/freeciv21) — modern Qt6
fork of [Freeciv](../topics/landscape.md#1-freeciv-lineage-1996), maintained
by the Longturn.net competitive multiplayer community.

The fork's stated rationale: *"roots in the well-known FOSS game Freeciv
and extends it for more fun, with a revived focus on competitive multiplayer
environments."* The word *revived* implicitly concedes upstream Freeciv had
let competitive MP atrophy.

## Stack

- **C++ 86.6%, C 6.6%, Python 4.1%, Lua 1.5%**
- License **GPL-3.0+**
- Build: **CMake 3.21+ with Ninja**
- Requires **Qt 6.6+** (base + SVG)
- Both **hex and square tiles**
- **>500 selectable nations**

## Activity

- 30,641 commits, 42 total releases
- v3.1.0 shipped 2024-08-10 — culmination of a two-year cycle
- **v3.1.1 — security-driven point release** (rare in OSS games), Lua-API
  bugfixes, server-disconnect fixes (date discrepancy: project site says
  March 2026, GitHub tag says March 2025 — see Open Questions)
- v3.2-dev.2 active dev branch: Qt6 migration, Markdown help text, civ2
  ruleset compatibility, expanded Map Editor

## Distribution

Snap, Flathub, AUR, .deb, Windows installer, macOS installer.

## Rulesets — the modding surface

Freeciv21 inherits Freeciv's ruleset architecture. Rulesets are
*"modifiable sets of data for units, advances, terrain, improvements,
wonders, nations, cities, governments, and miscellaneous game rules,
without requiring recompilation."*

Bundled rulesets:

| Ruleset       | Notes                                                |
| ------------- | ---------------------------------------------------- |
| civ1          | Civ-1 era rules                                      |
| civ2          | Civ-2 era rules                                      |
| civ2civ3      | Default for many Longturn games                      |
| classic       | Closer to canonical Freeciv balance                  |
| experimental  | Newer rules being tested                             |
| multiplayer   | Tuned for live MP                                    |

Workflow guidance: copy a bundled ruleset to a new directory rather than
editing in-place.

Activation:
- Server command: `rulesetdir <name>`
- Or: `freeciv21-server -r data/[ruleset].serv`

Each Longturn game runs a *custom* ruleset — the bundled ones are starting
points, not endpoints.

## Single-player onboarding

Concrete UI paths from the official manual:
- `Civilization > Government > Revolution`
- `Game > Load Another Tileset`
- `Unit > Fortify/Sentry`
- `Work > Build City`
- `Help > Terrain > Terrain Alterations`

Game-design quote that captures the core loop:
> *"The idea is to balance the quality of the site you find against
> getting your first city established as early as possible. You will find
> that balance becomes a key aspect of playing Freeciv21."*

The official Freeciv21 docs **recommend complete newcomers "start by
reading the legacy Freeciv Manual" first** — Freeciv21 onboarding leans on
upstream Freeciv docs for foundational concepts.

## Multiplayer — Longturn

Freeciv21 is the *de facto* engine of the **Longturn community** at
[longturn.net](https://longturn.net). Format:

> *"multiplayer one-turn-per-day playstyle and community... probably the
> closest thing Civilization and Freeciv will ever get to Massively
> multiplayer online strategy."*

Onboarding is two gates: register at Longturn.net, then sign up *and*
confirm participation when registrations open. Missing either drops you
from a game. Each game lists its required version (usually newest, but
older clients are kept available).

Community lives at `forum.longturn.net` and the
`discord.gg/98krqGm` Discord.

20–30 players per match; **one turn per day** is the only deadline mechanic
surfaced in the onboarding docs.

## Open questions

- **v3.1.1 release date** — March 2025 (GitHub) vs March 2026 (project
  site). Resolve by checking `git log` on the v3.1.1 tag.
- **Per-turn extension policy** — what happens when a Longturn player
  doesn't move on their day? Not surfaced in onboarding docs.

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
- [Freeciv-web](freeciv-web.md) — the browser fork
- [OSS 4X development pace](../concepts/oss-4x-development-pace.md)
- [Civ-likes as AI research testbeds](research-testbeds.md) — Freeciv21
  has *no* published AI-testbed work despite being arguably the highest-
  quality Freeciv variant for desktop research
