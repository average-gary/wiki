---
title: GitHub-as-Mod-Registry (Unciv pattern)
type: concept
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/articles/2026-06-18-unciv-modders-guide.md
  - raw/repos/2026-06-18-unciv.md
---

# GitHub-as-Mod-Registry (Unciv pattern)

[Unciv](../topics/unciv.md) ships an in-game Mod Manager. Most game mod
managers query a centrally-maintained portal (Steam Workshop, Nexus Mods,
ModDB). Unciv does not. Instead:

1. Modders tag their GitHub repo with the topic **`unciv-mod`**
2. Unciv's Mod Manager queries GitHub's topic search
3. Matching repos appear in the Mod Manager
4. User picks one → Mod Manager downloads and extracts

The "registry" is **GitHub's existing topic infrastructure**.

## Why this is elegant

- **No portal to maintain.** No backend, no moderation queue, no
  uptime SLA, no spam filtering — GitHub already runs all of that.
- **Modders own their distribution.** No publisher relationship, no
  asset upload, no review. A `git push` is a release.
- **Forking, issues, and PRs come for free.** Mods are repos; the
  collaboration toolkit is identical to any other GitHub project.
- **Discovery is searchable** with GitHub's normal full-text + topic
  search.

## What it requires

- **Mods must be data-only** (no executable code). Unciv enforces this
  by accepting only JSON in `/jsons` and images/sounds in `/Images`. If
  the mod ecosystem allowed code, GitHub-as-registry would invite
  arbitrary-code-execution attacks via tag-and-pull.
- **The game must trust the mod format**. Unciv parses JSON into typed
  Kotlin data classes; malformed JSON produces a modder-friendly error
  (with file/line info, recently improved in v4.20.13) but cannot
  exploit the engine.
- **GitHub must remain accessible**. Users in jurisdictions where
  GitHub is blocked (or rate-limited from Tor) lose mod discovery.

## Why other projects don't do this

The pattern requires a JSON-only / data-only mod format. Most game mod
ecosystems include code (Lua, Python, native plugins) for behavioral
mods. Once code is in scope, you need:

- Sandboxing (or a curation step)
- A trust signal beyond "GitHub topic"
- Probably a moderation queue

Steam Workshop / Nexus / ModDB exist *because* most games' mod ecosystems
need that layer. Unciv sidesteps the layer by deciding mods can't add
new mechanics.

## Comparison

| Pattern                  | Examples                              | Code mods? | Curation cost          |
| ------------------------ | ------------------------------------- | ---------- | ---------------------- |
| Centralized portal       | Steam Workshop, Nexus, ModDB          | Yes        | High (moderation, infra)|
| Federated repository     | Bethesda CK / Skyrim Nexus            | Yes        | Medium                 |
| Filesystem-only          | Old-school `.../mods/` drop-in        | Yes        | None (no discovery)    |
| **GitHub-as-registry**   | **Unciv**                             | **No**     | **Near-zero**          |

## Generalization

The pattern is reusable for **any data-driven game** that can constrain
mods to declarative content. Examples where it could work:

- A Bevy / Godot 4X with TOML/JSON ruleset format
- A turn-based-strategy engine where AI is built-in but content is moddable
- A board-game implementation engine (TripleA-style — though
  [TripleA](../topics/triplea.md) uses XML scenarios with a different
  delivery model)

## Limitations

- **Versioning is per-commit, not semver-aware** — Unciv's Mod Manager
  pulls HEAD of `main`. Mod authors who want stable releases need to
  use branches and the player needs to know which branch.
- **No audit trail** — GitHub's topic system has no provenance signing.
  A modder can rename / re-tag / delete a repo and the Mod Manager
  silently loses track.
- **GitHub vendor lock-in** — if GitHub changes its topic search API or
  rate limits, the entire mod registry could degrade overnight.

## See Also

- [Unciv](../topics/unciv.md)
- [Modding DSLs vs data formats](modding-dsl-vs-data-format.md)
