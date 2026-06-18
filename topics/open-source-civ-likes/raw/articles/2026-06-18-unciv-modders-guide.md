---
title: "Unciv Modders Guide — Introduction to Mods"
source: https://yairm210.github.io/Unciv/Modders/Mods/
type: article
ingested: 2026-06-18
quality: 5
confidence: high
tags: [unciv, modding, official-docs, json-mods, github-mod-registry]
---

# Unciv Modders Guide — Introduction to Mods

Official Unciv modding docs. Defines the entire Unciv mod ecosystem.

## What mods can / cannot do

> *"Mods can add, replace and remove basic game definitions, such as units,
> nations, buildings, improvements, resources and terrains."*

But mods **cannot create entirely new abilities** — only data, not code.

## Player install path

1. In-game Mod Manager → "Download mod from URL" → paste GitHub repo
2. Auto-extracted and ready to use

## GitHub-as-mod-registry

- Modders tag their repo with the GitHub topic **`unciv-mod`**
- The in-game Mod Manager queries GitHub for that topic and surfaces
  matching repos automatically.

This is unusually elegant — no centralized mod portal to maintain; GitHub
is the registry.

## File format — JSON only

Two folders:

- `/jsons` (game data)
- `/Images` (graphics)

**No compilation, no programming.** Desktop creation recommended over
mobile.

## Two mod classes

| Class            | Behavior                                                   | Use when                                                        |
| ---------------- | ---------------------------------------------------------- | --------------------------------------------------------------- |
| Extension mods   | Add to existing rulesets                                   | Easy; recommended starting point                                |
| Base ruleset mods | Set `"isBaseRuleset":true` in `ModOptions.json`; replace everything | Total conversions / radical rule changes |

## Why this matters

Defines distribution, install UX, and the JSON-only data-driven philosophy
that arguably makes Unciv the most accessible 4X modding platform in OSS.
