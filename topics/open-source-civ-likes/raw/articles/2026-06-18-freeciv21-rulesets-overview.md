---
title: "Freeciv21 Manual — Rulesets Overview"
source: https://longturn.readthedocs.io/en/latest/Modding/Rulesets/overview.html
type: article
ingested: 2026-06-18
quality: 5
confidence: high
tags: [freeciv21, rulesets, modding, official-docs, longturn]
---

# Freeciv21 Manual — Rulesets Overview

Official Freeciv21 modding docs. Defines the ruleset surface area:

> *"modifiable sets of data for units, advances, terrain, improvements,
> wonders, nations, cities, governments, and miscellaneous game rules,
> without requiring recompilation."*

## Workflow guidance

> *"It is suggested that you do not edit the existing files in the
> 'civ2civ3', 'classic', 'experimental', 'multiplayer', 'civ1', or 'civ2'
> directories, but rather copy them to another directory and edit the
> copies."*

## Bundled rulesets

| Ruleset       | Notes                                                |
| ------------- | ---------------------------------------------------- |
| civ1          | Civ-1 era rules                                      |
| civ2          | Civ-2 era rules                                      |
| civ2civ3      | Default for many Longturn games                      |
| classic       | Closer to canonical Freeciv balance                  |
| experimental  | Newer rules being tested                             |
| multiplayer   | Tuned for live MP                                    |

## Format

Plain UTF-8 text with **cross-file dependencies** (e.g., units reference
advances in techs file). Translatable strings use American English ASCII.

## Activation

- Server command: `rulesetdir`
- Or launched with: `freeciv21-server -r data/[ruleset].serv`

## Why this matters

The ruleset model powers both single-player variety and the entire Longturn
competitive scene — each LT game runs a custom ruleset.

Pairs naturally with the freeciv.fandom.com Ruleset Modding Tutorial as the
hands-on counterpart to this overview.
