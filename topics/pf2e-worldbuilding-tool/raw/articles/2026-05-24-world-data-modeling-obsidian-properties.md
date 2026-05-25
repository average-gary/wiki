---
title: "Obsidian Properties — Frontmatter as Lightweight Schema"
source: "https://obsidian.md/help/Editing+and+formatting/Properties"
type: guide
date_fetched: 2026-05-24
date_published: unknown
tags: [data-model, markdown, frontmatter, obsidian]
quality: 4
credibility: high
path: world-data-modeling
summary: "Obsidian's Properties feature turns YAML frontmatter into a typed property layer over markdown notes — text/number/checkbox/date/datetime/list/tags/links — searchable and queryable. Combined with [[wikilinks]] for backlinks, it's the canonical 'markdown-as-database' pattern and the model to match for human-and-LLM-readable storage."
---

# Obsidian Properties

## Supported types
- **Text** — single line, raw (no markdown rendering); can contain quoted internal links `"[[Gandalf]]"`.
- **Number** — int or decimal; no expressions.
- **Checkbox** — boolean, renders as interactive checkbox.
- **Date** — `YYYY-MM-DD`; integrates with daily notes.
- **Date & time** — ISO 8601 `YYYY-MM-DDTHH:MM:SS`.
- **List** — YAML sequence; items can be text, numbers, or quoted links.
- **Tags** — special `tags:` field, also queryable via `#tag` syntax inline.

## Storage
YAML frontmatter at top of file between `---` fences. JSON also accepted, normalized to YAML on save.

```yaml
---
type: character
ancestry: elf
class: ranger
level: 7
location: "[[Otari]]"
tags: [pc, party-1]
---
```

## Querying
- Native search supports `[property:value]` syntax.
- Dataview plugin provides SQL/JS-like queries over properties.
- Bases (1.6+) provides spreadsheet-like views over property-typed notes.

## Backlinks
`[[Wikilink]]` syntax creates implicit edges. Obsidian builds a backlinks index and a graph view from these. Edges are untyped by default; community plugins (Breadcrumbs, Juggl) add typed/labeled edges via property values.

## Relevance to our tool
1. **The "markdown as canonical" reference design**: typed entities = files with `type:` property + per-type expected fields. Each PF2e entity becomes one `.md` file.
2. **Round-trippable for LLMs**: an agent can read a markdown file, edit YAML or prose, and the change is human-reviewable in git diff.
3. **Backlinks are untyped by default** — a real weakness for our use case. We need typed relations (`enemy_of`, `parent_of`, `member_of`) which means either a frontmatter convention (`relations: [{type: enemy_of, target: "[[Goblin King]]"}]`) or a sidecar index.
4. **Properties don't enforce schema** — Obsidian is schemaless. For PF2e we want validation on canonical types (a Character must have an ancestry). A schema-validating layer on top of the markdown is needed.
5. **Pattern to copy**: file = entity, YAML = structured fields, body = prose, wikilinks = soft references. Add: a SQLite/graph index built from the files for typed queries.
