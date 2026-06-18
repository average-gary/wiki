---
title: Open Source Civ-Like Games — Landscape
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-freeciv-canonical.md
  - raw/repos/2026-06-18-freeciv21.md
  - raw/repos/2026-06-18-freeciv-web.md
  - raw/repos/2026-06-18-unciv.md
  - raw/repos/2026-06-18-0ad-pyrogenesis.md
  - raw/repos/2026-06-18-openage-aoe2.md
  - raw/repos/2026-06-18-unknown-horizons.md
  - raw/repos/2026-06-18-c-evo.md
  - raw/repos/2026-06-18-triplea.md
  - raw/articles/2026-06-18-wikipedia-freeciv-history.md
  - raw/articles/2026-06-18-wikipedia-0ad.md
---

# Open Source Civ-Like Games — Landscape

Survey of the active open-source / free-software civ-like ecosystem as of
mid-2026. Three families dominate: **the Freeciv lineage** (canonical Freeciv,
[Freeciv21](../topics/freeciv21.md), [Freeciv-web](../topics/freeciv-web.md),
plus 3D experiments), **the Civ-V remake lineage** ([Unciv](../topics/unciv.md)),
and **the civ-adjacent RTS / city-builder cluster** ([0 A.D.](../topics/0ad.md),
openage, Unknown Horizons). [C-evo](../topics/c-evo.md) sits apart as the
public-domain, AI-plugin-focused outlier.

## At a glance

| Project        | Lineage          | Lang / Engine            | License             | Status (2026-06)               |
| -------------- | ---------------- | ------------------------ | ------------------- | ------------------------------ |
| Freeciv        | upstream         | C + GTK/Qt/SDL2          | GPL-2.0+            | Active (3.2.4 March 2026)      |
| Freeciv21      | Freeciv fork     | C++ / Qt6 / CMake        | GPL-3.0+            | Very active (Longturn-driven)  |
| Freeciv-web    | Freeciv fork     | JS + Three.js + Java/Tomcat + patched C server | AGPL-3.0+ (client) / GPL (server) | Hosted live |
| Unciv          | Civ V remake     | Kotlin / libGDX          | MPL-2.0             | Live-service cadence (940+ rels)|
| 0 A.D.         | civ-adjacent RTS | Pyrogenesis (C++/JS/Lua) | GPL-2.0 + mixed     | **Post-alpha** (R28, 2026-02)  |
| openage        | AoE II reimpl    | C++/Python/Cython/Qt6    | GPL-3.0+            | Engine WIP, "non-functional"   |
| Unknown Horizons | city-builder   | Python / FIFE            | GPLv2               | **Dormant** (last rel 2019)    |
| C-evo / CDH    | Civ II clone     | Object Pascal / Lazarus  | **public domain**   | Maintained (1.3.6 2024-09)     |
| TripleA        | board / A&A      | Java                     | GPL-3.0             | Very active (date-stamped rels)|

(TripleA included as the **boundary marker** — see [TripleA](../topics/triplea.md)
for why it's adjacent rather than civ-like.)

## The three families

### 1. Freeciv lineage (1996+)

The oldest and most fragmented family. The canonical `freeciv/freeciv`
remains active (3.2.4 March 2026) — *not* superseded by the forks despite a
common misperception. Three meaningful descendants:

- **[Freeciv21](../topics/freeciv21.md)** is the Qt6 / CMake modernization
  driven by the **Longturn** competitive multiplayer community. Its existence
  is itself a critique — the Longturn fork rationale uses the word *"revived
  focus on competitive multiplayer"*, implicitly conceding upstream had let
  competitive MP atrophy. Ships >500 nations, hex+square tiles, and notably
  shipped a security-driven point release (v3.1.1) — rare in OSS games.

- **[Freeciv-web](../topics/freeciv-web.md)** is the browser fork. It does
  not reimplement the simulation — it keeps the **patched C Freeciv server**
  and bridges it to a Three.js HTML5 client via a Python `freeciv-proxy`
  WebSocket-to-socket shim. The client is licensed **AGPL-3.0+** to match
  its hosted-service posture; the server inherits upstream GPL. This proxy
  pattern is reusable: any project with a legacy C/native game server
  considering web playability can study Freeciv-web's
  [WebSocket bridge architecture](../concepts/websocket-bridge-pattern.md).

- **3D experiments (Fciv.net / freecivx.net)** are the most fragile branch
  — they appear in Wikipedia's fork list but aren't load-bearing for the
  community.

The Freeciv lineage has documented **structural issues**: the *city smallpox*
balance failure ran for **5+ years** before being addressed in v2.0 (2005);
multiplayer wasn't an original design target and was retro-fitted via fork
c. 2002; the original `play.freeciv.org` server was shut down March 2018 and
later "revived by volunteers." The Longturn / Freeciv21 split is the most
durable response to those weaknesses.

### 2. Civ V remake lineage — Unciv

[Unciv](../topics/unciv.md) is genealogically separate from Freeciv. It is
a **Kotlin / libGDX remake of Civ V**, not derived from Freeciv code. As of
2026-06, Unciv has 12,999 commits and **940 releases** — five point releases
(4.20.10–4.20.14) shipped in ~2.5 weeks in May–June 2025. By a wide margin
the **highest-velocity OSS civ-like**.

Unciv's structural choices differentiate it sharply:

- License is **MPL-2.0** (weaker copyleft than GPL) — friendly to mod
  authors who don't want to relicense their content as GPL.
- All mods are **JSON only**, two folders: `/jsons` (data), `/Images`
  (graphics). No code, no compilation.
- The mod registry **is GitHub itself**: modders tag their repo with the
  topic `unciv-mod`, and the in-game Mod Manager queries GitHub's topic
  search. No central portal to maintain — see
  [GitHub-as-mod-registry](../concepts/github-as-mod-registry.md).

Unciv's most controversial property is its **legal posture toward Firaxis**
— see [Unciv copyright posture](../concepts/unciv-copyright-posture.md). The
project openly calls itself a "remake of Civ V"; rests its defense on US
Copyright Office circular FL-108 (mechanics aren't copyrightable);
*replaces* all Firaxis assets (images/sound) and scope-disciplines itself
to **avoid adding non-Civ-V features** as a deliberate legal strategy. The
posture has not been litigation-tested.

### 3. Civ-adjacent: 0 A.D., openage, Unknown Horizons

These projects are not pure 4X — they belong to RTS / city-builder branches
of the broader strategy genre — but the wiki includes them because their
engines and modding stories are influential reference points for anyone
building an OSS civ-like.

- **[0 A.D.](../topics/0ad.md)** runs on the **Pyrogenesis** engine (C++
  core + JS/Lua scripting). After 16 years in alpha (2010–2026), it dropped
  the alpha label with **Release 28 "Boiorix" on 2026-02-18** — see
  [0 A.D. development pace](../concepts/oss-4x-development-pace.md). Now
  ships with a 64-bit Windows build, official Linux AppImage, and gendered
  civilian models. The **Indiegogo 2013 funding shortfall** ($33,251 of
  $160,000 target) is the canonical example of why volunteer-only OSS 4X
  development takes a decade-plus.

- **openage** (AoE II reimplementation) is the architecturally most
  interesting of the cluster despite being self-described as "basically
  non-functional" gameplay-wise. It introduces **nyan**, a *purpose-built*
  data-definition DSL for content/rules — see
  [Modding DSLs vs. data formats](../concepts/modding-dsl-vs-data-format.md).
  Compare: Freeciv plain-text rulesets, Unciv JSON, openage typed nyan DSL.

- **Unknown Horizons** is the cautionary tale — Python on top of FIFE,
  GPLv2, Anno-style city-builder, **dormant since January 2019**. Useful
  as a contrast to Unciv's 940-release pace.

## C-evo: the unicorn

[C-evo](../topics/c-evo.md) by Steffen Gerlach is the genre's outlier:

- Object Pascal (Delphi → Lazarus) — the *only* mainstream Pascal-based
  civ-like.
- **Public domain** source code — *not GPL*, contrary to a common
  misconception. Unique among maintained civ-likes.
- **DLL-pluggable AI** with development kits in **C#, Delphi, and C++** —
  see [AI plugin architecture](../concepts/ai-plugin-architecture.md). This
  is genuinely rare; Freeciv has Lua hooks but C-evo's plugin AI is
  binary-pluggable from three languages.
- Cited at IJCAI 2005 as an AI research platform.

Latest stable v1.3.6 on 2024-09-16 — actively maintained, low public profile.

The **C-evo: Distant Horizon (CDH)** fork was named in the research brief
but the GitHub orgs `c-evo-game/c-evo-dh` and `c-evo-game/c-evo-dh-stable`
returned 404 at research time. CDH's active home is **TBD** — see
[Open questions](#open-questions).

## What civ-likes have in common (and what defines them)

A civ-like in this wiki's sense:

- **eXplore, eXpand, eXploit, eXterminate** core loop (4X)
- **Tech tree** of meaningful depth (Freeciv-style ~80+ techs, Unciv-style
  Civ-V tree)
- **Multiple win conditions** (military, science, culture, diplomatic)
- **Procedural map** + civilization personality / leader trait system
- **Historical progression** from prehistory / antiquity through to a
  modern / future era

[TripleA](../topics/triplea.md) is **excluded** even though it's an active
GPL-3.0 turn-based strategy engine — it's an Axis-and-Allies-style tactical
board-game engine. No exploration phase, no tech tree growth, pre-defined
scenarios. The exclusion is itself useful — pinning down what civ-like
*means*.

[OpenRA](https://www.openra.net) (Red Alert / Tiberian Dawn / Dune 2000
reimplementation) is similarly excluded — RTS with no tech-tree progression
or 4X loop.

## Open questions

1. **C-evo: Distant Horizon repo location** — GitHub orgs 404; needs
   tracking down. Possibly SourceForge, GitLab, or a different GH org.
2. **Freeciv21 v3.1.1 release date** — project page says March 2026,
   GitHub tag says March 2025. Reconcile by checking the tag commit date.
3. **0 A.D. Gitea migration impact** — official source moved from GitHub
   (archived 2024-09) to https://gitea.wildfiregames.com. What does this
   mean for contributor onboarding and the gh-tooling ecosystem?
4. **Unciv copyright posture under stress** — has Firaxis ever publicly
   commented? Is FL-108's "mechanics aren't copyrightable" stance robust to
   the look-and-feel angle (UI layout, art direction)?
5. **Freeland / other obscure entries** — research brief named Freeland;
   nothing usable surfaced. Is it real and findable? What other obscure
   OSS civ-likes (Bevy/Godot/web-stack) exist that this round missed?
6. **Why no academic Freeciv21-specific papers?** CivRealm uses Freeciv-web
   (the web fork); CivAgent uses Unciv. Freeciv21 — arguably the
   highest-quality Freeciv variant for desktop research — has no published
   AI-testbed work. Opportunity gap.

## See Also

- [Freeciv21](../topics/freeciv21.md) — the modern Qt6 fork
- [Freeciv-web](../topics/freeciv-web.md) — the browser fork
- [Unciv](../topics/unciv.md) — Kotlin Civ V remake
- [0 A.D.](../topics/0ad.md) — Pyrogenesis engine, post-alpha
- [C-evo](../topics/c-evo.md) — public-domain, plugin-AI civ-like
- [Civ-likes as AI research testbeds](research-testbeds.md)
- [OSS 4X development pace](../concepts/oss-4x-development-pace.md)
- [Modding DSLs vs data formats](../concepts/modding-dsl-vs-data-format.md)
- [Unciv copyright posture](../concepts/unciv-copyright-posture.md)
