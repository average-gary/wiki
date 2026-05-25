---
title: "Kanka API 1.0 — Entity Types and Schema"
source: "https://app.kanka.io/api-docs/1.0"
type: guide
date_fetched: 2026-05-24
date_published: unknown
tags: [data-model, document-db, schema, ttrpg, kanka]
quality: 5
credibility: high
path: world-data-modeling
summary: "Kanka's API documents the canonical TTRPG worldbuilding ontology — ~20 typed entities (Character, Location, Family, Organisation, Item, Quest, Calendar, Timeline, Event, Race, Creature, Map, Journal, Ability, Tag, Note, Conversation, DiceRoll) wrapped in a single polymorphic 'entity' record. Every entity supports the same orthogonal sub-resources (relations, posts, tags, attributes, mentions, inventory, abilities), giving a clean entity-attribute-value layer on top of typed nouns."
---

# Kanka Entity Model

## Top-level entity types
- **Character** — PCs, NPCs
- **Location** — places, regions, settlements (hierarchical via `parent_location_id`)
- **Family** — bloodlines, dynasties (hierarchical)
- **Organisation** — guilds, factions, governments (hierarchical)
- **Object / Item** — physical things, magic items
- **Note** — freeform GM notes
- **Event** — historical events
- **Calendar** — custom calendars with months, weekdays, leap rules
- **Timeline** — eras + ages, attaches Events
- **Creature** — monsters, beasts (separate from Character)
- **Race** — playable/non-playable species
- **Quest** — multi-step adventures, with quest elements (characters, locations, items)
- **Map** — image maps with markers, groups, layers
- **Journal** — session logs
- **Ability** — feats, spells, class features
- **Tag** — cross-cutting categorization (also hierarchical)
- **Conversation** — in-world dialogue
- **DiceRoll** — saved roll formulas

## The "entity" wrapper pattern
Every typed object also lives in a single polymorphic `entities` table. That gives uniform sub-resources for *every* type:

- `entity_abilities` — attached spells/feats
- `entity_attributes` (Properties) — EAV key/value, supports number, text, checkbox, section
- `entity_assets` — files, links, aliases
- `entity_inventory` — items held, with amount + position
- `entity_mentions` — wiki-style backlinks (`[entity:1234]`)
- `entity_posts` — multiple body sections per entity (extra lore pages)
- `entity_relations` — typed edges to other entities, with relation text + visibility + two-way flag
- `entity_tags` — many-to-many with the Tag entity
- `entity_permissions` — per-role/per-user ACLs
- `entity_reminders` — calendar-linked timers

## Key takeaways for our tool
1. **Hybrid: typed nouns + EAV attributes**. The 20 typed entities give predictability; `entity_attributes` lets users add custom fields without schema migration.
2. **Polymorphic relations** are first-class — Character→Location, Character→Character, Quest→anything. Each relation has free-text "the relationship" and a visibility flag.
3. **Mentions = bi-directional backlinks** at the application layer, not file layer.
4. **Hierarchies are per-type** (`parent_location_id`, `parent_family_id`) rather than a generic tree.
5. **Posts** decouple "the entity record" from "long-form prose," so the typed metadata stays clean.
6. REST endpoints follow `/campaigns/{id}/{type-plural}/{entity-id}` and sub-resources hang off the entity ID, not the type ID — making a single `Entity` interface viable on the client.
