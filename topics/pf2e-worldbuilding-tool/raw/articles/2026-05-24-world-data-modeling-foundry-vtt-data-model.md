---
title: "Foundry VTT Data Model — Documents, Embedded Documents, DataModel"
source: "https://foundryvtt.com/api/"
type: guide
date_fetched: 2026-05-24
date_published: unknown
tags: [data-model, document-db, schema, ttrpg, foundry]
quality: 5
credibility: high
path: world-data-modeling
summary: "Foundry VTT models a TTRPG world as ~16 primary Document types (Actor, Item, Scene, JournalEntry, Combat, RollTable, Cards, Macro, Playlist, Folder, Adventure, etc.) plus ~10 embedded-only types (Token, Wall, ActiveEffect, Note, Tile…). Schemas are declared via a DataModel base class and TypeDataModel allows per-system subtypes (e.g. `character` vs `npc` Actor) — this is a clean blueprint for typed-entity worldbuilding."
---

# Foundry VTT Document Model

## Three abstract layers
- **DataModel** — declares a schema (fields, types, validators) and holds state.
- **Document** — a DataModel that talks to the database, supports CRUD hooks, parent/child hierarchy, ownership.
- **TypeDataModel** — subtype machinery so one Document type (e.g. Actor) can have multiple shapes per game system.

## Primary Documents (each backed by its own collection)
Actor, Item, Scene, JournalEntry, Combat, Macro, Playlist, RollTable, Cards, Folder, Adventure, FogExploration, Setting, User, ChatMessage, ChatBubble.

## Embedded-only Documents (live inside a parent)
Token (in Scene), Wall (in Scene), AmbientLight, AmbientSound, Drawing, Tile, Note (map pin), Region, ActiveEffect (in Actor/Item), JournalEntryPage (in JournalEntry), TableResult (in RollTable), Card (in Cards), Combatant (in Combat), PlaylistSound (in Playlist).

## Subtype extensibility
11 of the primary Document types accept system-defined subtypes via `CONFIG.<Type>.dataModels`. PF2e's system, for example, registers `character`, `npc`, `hazard`, `loot`, `vehicle`, `familiar`, `party` as Actor subtypes — each with its own DataModel schema.

## Embedded collections
Children are accessed as collections on the parent: `actor.items`, `actor.effects`, `scene.tokens`, `scene.walls`, `journalEntry.pages`. They share the parent's lifecycle and permissions.

## Key takeaways for our tool
1. **Two-layer schema**: a small fixed set of typed nouns + a per-system subtype that declares extra fields. PF2e already has this — we should mirror it.
2. **Embedded vs linked**: rules-of-thumb — if a child can't exist without the parent (token, wall, journal page), embed it. If it has independent identity (item that can move actors), link by ID.
3. **Schema-as-code (DataModel)** is friendlier for LLM tool-use than schema-as-DB-migrations: the schema is introspectable at runtime.
4. **JournalEntryPage** is the closest analog to "a markdown note inside a typed entity" — a useful pattern for our hybrid markdown+graph design.
5. **Folders** are a generic organizational tree orthogonal to type — important so users can group however they like without changing the entity ontology.
6. Foundry stores everything as JSON in NeDB/LevelDB (per-collection). For our offline-first goal, the same pattern (one SQLite table per primary type with a JSON column for system data) works well.
