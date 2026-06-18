---
title: Modding DSLs vs Data Formats
type: concept
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-openage-aoe2.md
  - raw/repos/2026-06-18-unciv.md
  - raw/articles/2026-06-18-freeciv21-rulesets-overview.md
  - raw/articles/2026-06-18-unciv-modders-guide.md
---

# Modding DSLs vs Data Formats

OSS civ-likes (and civ-adjacent engines) take three distinct approaches
to defining moddable game content. Each has tradeoffs that ripple through
modding UX, type safety, and tooling.

## The three approaches

### 1. Plain-text rulesets — Freeciv / Freeciv21

[Freeciv21 rulesets](../topics/freeciv21.md#rulesets--the-modding-surface)
are *"modifiable sets of data for units, advances, terrain, improvements,
wonders, nations, cities, governments, and miscellaneous game rules,
without requiring recompilation."*

- **Format**: plain UTF-8 text with cross-file dependencies
- **Loading**: `rulesetdir <name>` server command, or
  `freeciv21-server -r data/[ruleset].serv`
- **Bundled**: civ1, civ2, civ2civ3, classic, experimental, multiplayer
- **Author workflow**: copy a bundled ruleset, edit the copy
- **Translation**: American English ASCII for translatable strings

Strengths:
- No new tooling — any text editor
- Cross-file references (units → advances → techs) keep the data
  decomposed
- Decades of accumulated rulesets exist as templates

Weaknesses:
- No formal schema → modding errors surface at runtime, often opaquely
- Cross-file dependencies make refactoring fragile
- The format is *de facto* a DSL but with no parser tooling, no syntax
  highlighting, no autocomplete

### 2. JSON-only — Unciv

[Unciv mods](../topics/unciv.md#mod-ecosystem--json-only--github-as-registry)
require:

- Two folders: `/jsons` (game data), `/Images` (graphics)
- **No compilation, no programming**
- File-and-line error reporting (improved in v4.20.13)

Strengths:
- Machine-validatable: Unciv parses into typed Kotlin data classes
- Trivially editable on any device
- Diff-friendly for git workflows
- Enables [GitHub-as-mod-registry](github-as-mod-registry.md)

Weaknesses:
- No expression power — can't add new behaviors, only data
- Verbose for nested structures
- No comments (vanilla JSON; some projects use JSON5 to fix this — Unciv
  does not)

### 3. Purpose-built DSL — openage's nyan

[openage](../topics/landscape.md#3-civ-adjacent-0-ad-openage-unknown-horizons)
introduces **nyan** ("Yet Another Notation") — a *typed*, dedicated
data-definition DSL for content/rules.

- Unique to openage in the OSS strategy-game space
- Required at build time: `./configure --download-nyan && make`
- Designed to handle AoE II-style data (units, techs, civs, sounds,
  graphics) with type safety

Strengths:
- Compile-time validation
- Designed for the domain — can express civ-like patterns naturally
- Extensible: can grow with the engine without re-shimming JSON

Weaknesses:
- Modders must learn a new language
- Tooling (LSP, syntax highlighting) is project-specific
- Onboarding cost is high for casual modders
- openage is "basically non-functional" gameplay-wise — nyan's real-
  world use is largely engine-internal so far

## Comparison table

| Property                          | Freeciv plain-text | Unciv JSON | openage nyan |
| --------------------------------- | ------------------ | ---------- | ------------ |
| Type safety                       | None               | Schema-derived | Compile-time |
| Modder tooling needed             | Text editor        | Text editor | Build chain  |
| Error messages                    | Runtime, opaque    | File+line   | Compile-time |
| Cross-file references             | Yes                | Yes (via IDs) | Yes (typed) |
| Mod registry-friendly             | Hard               | Easy        | Hard         |
| Casual-modder onboarding          | Low (copy/paste)   | Lowest      | High         |
| Power ceiling                     | Medium             | Low         | High         |

## Which to choose

For a new OSS civ-like in 2026:

- **JSON** if your gameplay is fully data-driven, your mod ecosystem is
  novice-heavy, and you want
  [GitHub-as-registry](github-as-mod-registry.md) discovery for free.
- **Plain-text rulesets** only if you're forking Freeciv and have to.
- **Purpose-built DSL** if your gameplay needs are sufficiently
  irregular that JSON would be a pile of escape hatches *and* you have
  the engineering bandwidth to maintain the DSL tooling.

The pattern most likely to ship: **JSON with a strict schema**, error
messages that include file+line, and an eventual escape hatch (Lua
hooks, expression language, scripted units) once the data layer
saturates.

## See Also

- [Unciv](../topics/unciv.md)
- [Freeciv21](../topics/freeciv21.md)
- [GitHub-as-mod-registry](github-as-mod-registry.md)
- [AI plugin architecture](ai-plugin-architecture.md) — orthogonal: DSL
  is for data, plugin AI is for behavior
