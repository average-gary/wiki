---
title: "Plan: Cross-platform PF2e + Biblical-reskin reference & worldbuilding app"
type: plan
format: spec
generated: 2026-05-25
sources:
  - "[[recommended-stack]]"
  - "[[recommended-reskin-stack]]"
  - "[[desktop-app-stack-recommendation]]"
  - "[[world-data-model-recommendation]]"
  - "[[llm-integration-architecture]]"
  - "[[pf2e-licensing-posture]]"
  - "[[pf2e-remaster-name-mapping]]"
  - "[[remaster-monotheism-fit]]"
  - "[[denominational-lens-decision]]"
  - "[[magic-theology-approaches]]"
  - "[[biblical-cosmology-pf2e-mapping]]"
  - "[[class-ancestry-reskin-verdicts]]"
  - "[[yhwh-deity-template]]"
  - "[[biblical-miracle-to-pf2e-spell-map]]"
  - "[[worldbuilding-tool-landscape-2026]]"
  - "[[prior-christian-rpg-lessons]]"
  - "[[rust-multi-platform]]"
tags: [pf2e, biblical-reskin, cross-platform, tauri, sqlite-vec, ollama, anthropic, spec, mvp]
---

# Plan: Cross-platform PF2e + Biblical-reskin reference & worldbuilding app

> **Format**: technical specification.
> **Wiki grounding**: 17 articles across `pf2e-worldbuilding-tool` + `pf2e-biblical-reskin` topics, plus `rust-multi-platform`.
> **User-locked decisions** (interview): scope = reference + full worldbuilding day 1; stack = Tauri 2 desktop + mobile; LLM = optional BYO-key; content = Lewisian default + all lenses bundled + free-with-donate.

## Executive Summary

A single **Tauri 2 application** targeting **macOS / Windows / Linux / iOS / Android** that combines:

1. **Reference layer** (offline, search-first) — PF2e Remaster mechanics + Biblical-reskin content packs (5 denominational lenses).
2. **Worldbuilding layer** (markdown vault) — GM authors campaigns; entities + typed relations + statblocks.
3. **Optional LLM layer** (BYO-key, off by default) — Ollama local + Anthropic cloud, RAG over the vault, structured statblock generation.

**Distribution**: free, app-store + sideload + direct download; donate/Patreon for sustainment. **License posture**: pure ORC mechanics + Christian Biblical content (replaces Golarion entirely → monetizable, but distribution is free by community-friendly choice). Foundry pf2e schema is the primary data-ingestion target ([[pf2e-licensing-posture]]).

---

## 1. System Architecture

### 1.1 High-level diagram

```
┌─────────────────────────── User vault (filesystem folder) ───────────────────────────┐
│                                                                                       │
│   campaigns/                                                                          │
│     <campaign>/                                                                       │
│       npcs/cassian.md                  (markdown + frontmatter, canonical)            │
│       npcs/cassian.statblock.json      (Foundry pf2e-shaped, schemaful)               │
│       locations/...                                                                    │
│       sessions/...                                                                    │
│                                                                                       │
│   reference/                                                                          │
│     pf2e/                              (bundled — read-only)                          │
│       spells/, monsters/, feats/, deities/, classes/, ancestries/                     │
│       remaster-name-mapping.json                                                      │
│     biblical/<lens>/                   (5 lens packs: lewisian | catholic |           │
│       deities/, saints/, miracles/, cosmology/, class-reskins/                        │
│                                         reformed | pentecostal | orthodox)            │
│       biblical-miracle-to-pf2e-spell-map.json                                         │
│                                                                                       │
│   .pf2e-tool/                                                                         │
│     index.db                  ◄── SQLite + FTS5 + sqlite-vec (rebuilt on file watch)  │
│     plugins/<id>/manifest.json                                                        │
│     capabilities.json                                                                 │
│     license-provenance.json                                                           │
│     llm-config.json           (optional; off by default)                              │
│                                                                                       │
└───────────────────────────────────────────────────────────────────────────────────────┘
        ▲                                                            ▲
        │ file watch / two-way sync                                  │
┌───────┴──────────────────────────┐                  ┌──────────────┴──────────────────┐
│   Tauri 2 core (Rust)            │                  │   Optional LLM client            │
│                                  │                  │   ├─ Ollama (local default)      │
│   ├─ vault watcher (notify-rs)   │                  │   └─ Anthropic / OpenAI / etc.   │
│   ├─ schema validator (jsonschema│ ◄────────────────┤      (BYO key; off by default)   │
│   ├─ SQLite + FTS5 + sqlite-vec  │   IPC commands   │                                  │
│   ├─ capability gate             │   (capability-   │   RAG: chunk + embed + query     │
│   ├─ markdown parser (pulldown-  │    gated)        │   Tools: lookup_rule,            │
│   │    cmark + YAML frontmatter) │                  │     xp_budget,                   │
│   ├─ content-pack loader         │                  │     validate_statblock,          │
│   └─ lens switcher               │                  │     search_canon                 │
└──────────┬───────────────────────┘                  └─────────────────────────────────┘
           │ IPC (capability-gated)
┌──────────┴──────────────────────────────────────────────────────┐
│   Webview UI (SvelteKit)                                        │
│                                                                 │
│   ├─ Mobile shell (read-heavy reference; bottom-tabs nav)       │
│   ├─ Desktop shell (sidebar; multi-pane editor)                 │
│   ├─ Reference browser (search-first; statblock cards)          │
│   ├─ Worldbuilding editor (markdown + frontmatter)              │
│   ├─ Encounter builder (XP budget, monster picker)              │
│   ├─ Session companion (initiative, HP, conditions)             │
│   └─ Plugin host (per Obsidian model + Tauri capabilities)      │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Component map

| Component | Crate / library | Source/grounding |
|---|---|---|
| **Tauri runtime** | `tauri = "2"` | [[desktop-app-stack-recommendation]] |
| **Mobile co-target** | `tauri-action` (mobile CI; iOS Swift sub-package, Android Kotlin sub-package) | [[rust-multi-platform]] § ui-framework-decision |
| **Frontend** | SvelteKit + TypeScript (responsive layout) | Concept article + interview |
| **Embedded DB** | `rusqlite` + FTS5 + `sqlite-vec` (load via vec0 vtable) | [[2026-05-24-desktop-app-stack-sqlite-vec]] |
| **Vault watcher** | `notify-rs` | Standard Rust ecosystem |
| **Markdown parsing** | `pulldown-cmark` + `serde_yaml` for frontmatter | Standard |
| **Schema validation** | `jsonschema` crate against generated JSON Schema | [[world-data-model-recommendation]] |
| **LLM clients** | `reqwest` + per-provider crate (`async-anthropic`, `ollama-rs`) | [[llm-integration-architecture]] |
| **RAG embeddings** | `bge-m3` via Ollama for local; `voyage-3` via API for cloud | [[llm-integration-architecture]] |
| **Plugin sandbox** | Tauri capability JSON + per-plugin scope manifests | [[desktop-app-stack-recommendation]] § plugin-architecture |

### 1.3 Platform matrix

| Platform | Bundle target | Webview | Notes |
|---|---|---|---|
| macOS | `.app` (Universal: x86_64 + aarch64) | WKWebView | Notarytool $99/yr Apple Developer |
| Windows | `.msi` + `.exe` | WebView2 (bundled or system) | Azure Trusted Signing ~$120/yr |
| Linux | `.AppImage` + `.deb` + Flatpak | WebKitGTK | No signing cost |
| iOS | `.ipa` (App Store + sideload via TestFlight + Apple's new sideload-EU API where applicable) | WKWebView | Tauri 2 mobile rough — see § Risks |
| Android | `.apk` (sideload) + `.aab` (Play Store) | WebView (Chrome) | Cleaner than iOS for Tauri 2 |

The reference layer is **fully usable on mobile from v1**. The worldbuilding editor ships **mobile in v1.1** if Tauri 2 mobile editor-component issues prove tractable; otherwise mobile is read-only for vault content with a "view-only on phone, edit on desktop" UX disclaimer.

---

## 2. Data Model

### 2.1 Two-tier schema (per [[world-data-model-recommendation]])

**Mechanical layer** (schemaful, validated): PF2e Remaster statblocks, encounters, hazards. Foundry-style DataModel-per-subtype. JSON Schema validation at write-time.

**Lore layer** (schemaless, freeform): NPCs, locations, factions, sessions, notes. Markdown + YAML frontmatter. Typed relations (since Obsidian backlinks are untyped — biggest weakness in [[2026-05-24-world-data-modeling-obsidian-properties]]).

### 2.2 Canonical entity types (from [[2026-05-24-world-data-modeling-kanka-entity-types]] + Foundry pf2e)

```yaml
# Lore (markdown + frontmatter)
character | npc | creature | location | faction | family | quest |
event | era | calendar | session | note | tag | map

# Mechanical (JSON, schemaful per Foundry pf2e DataModel-per-subtype)
character.statblock | npc.statblock | creature.statblock |
hazard | item | spell | feat | ancestry | class | deity | saint
```

### 2.3 Frontmatter convention (lore layer)

```yaml
---
title: Lord Cassian
type: npc
status: budding              # seedling | budding | evergreen
license_provenance: orc      # orc | community-use | homebrew | proprietary
relations:
  - member_of: [[house-velerian]]
  - enemy_of: [[the-pale-circle]]
  - wields: [[sword-of-meridian]]
  - sanctified_to: [[saint-michael]]   # Champion patron link
mechanical: characters/cassian.statblock.json
lens: lewisian               # which content lens this entity assumes
---
```

### 2.4 SQLite schema (mirror)

```sql
CREATE TABLE entities (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,                    -- character, npc, location, ...
  campaign_id TEXT NOT NULL,
  source TEXT NOT NULL,                  -- 'vault' | 'reference' | 'plugin:<id>'
  lens TEXT,                             -- lewisian | catholic | ... | NULL for system-neutral
  license_provenance TEXT NOT NULL,      -- orc | community-use | homebrew | proprietary
  frontmatter JSON NOT NULL,
  body TEXT,                             -- markdown body
  body_text TEXT,                        -- plain-text mirror (for FTS)
  statblock JSON,                        -- only for mechanical entities
  file_path TEXT NOT NULL UNIQUE,
  mtime INTEGER NOT NULL,
  hash TEXT NOT NULL                     -- content hash for cache invalidation
);

CREATE VIRTUAL TABLE entities_fts USING fts5(
  title, body_text,
  content='entities', content_rowid='rowid',
  tokenize='porter unicode61'
);

CREATE VIRTUAL TABLE entities_vec USING vec0(
  embedding float[768],                  -- bge-m3 / voyage-3 dim
  +entity_id TEXT,
  +chunk_idx INTEGER
);

CREATE TABLE relations (
  from_id TEXT NOT NULL,
  edge_type TEXT NOT NULL,               -- member_of, enemy_of, located_in, ...
  to_id TEXT NOT NULL,
  properties JSON,
  PRIMARY KEY (from_id, edge_type, to_id),
  FOREIGN KEY (from_id) REFERENCES entities(id),
  FOREIGN KEY (to_id) REFERENCES entities(id)
);

CREATE TABLE remaster_aliases (
  legacy_name TEXT NOT NULL,
  remaster_name TEXT NOT NULL,
  category TEXT NOT NULL,                -- spell, feat, monster, language, ...
  notes TEXT,
  PRIMARY KEY (legacy_name, remaster_name)
);
-- Seeded from [[pf2e-remaster-name-mapping]] (~330 pairs).

CREATE TABLE miracle_spell_map (
  miracle TEXT PRIMARY KEY,
  reference TEXT NOT NULL,               -- "Mt 14:25"
  spell_id TEXT,                         -- FK to entities (optional; null if homebrew)
  spell_name TEXT NOT NULL,              -- denormalized for display
  tradition TEXT,                        -- divine, primal, arcane, occult
  sanctification TEXT,                   -- holy, unholy, either, na
  notes TEXT
);
-- Seeded from [[biblical-miracle-to-pf2e-spell-map]] (~50 rows).
```

### 2.5 Content packs (bundled, read-only)

Each pack is a directory of markdown + JSON:

```
reference/biblical/<lens>/
  deities/yhwh.md + yhwh.statblock.json
  saints/michael.md + michael.statblock.json
  saints/george.md
  cosmology/heaven.md
  cosmology/sheol.md
  cosmology/gehenna.md
  miracles/elijah-fire.md   (cross-refs spell map)
  class-reskins/champion.md
  class-reskins/oracle.md
  ...
  pack.toml                 (lens metadata, default-loaded flag, dependency on base PF2e pack)
```

The 5 lens packs (Lewisian default + Catholic + Reformed + Pentecostal + Orthodox) ship in the binary. User toggles active lens in settings; SQLite mirror filters by `lens IN ('active', NULL)` — system-neutral entries always visible.

---

## 3. API Design (Tauri IPC commands)

All commands are capability-gated. Plugins declare which commands they need in their manifest.

### 3.1 Reference layer (read-only)

```rust
// src/commands/reference.rs
#[tauri::command]
async fn search(query: String, types: Option<Vec<String>>, lens: Option<String>) -> Vec<SearchHit>;
// FTS5 + sqlite-vec hybrid; returns ranked hits.

#[tauri::command]
async fn get_entity(id: String) -> Option<Entity>;

#[tauri::command]
async fn list_entities(filter: ListFilter) -> Vec<EntitySummary>;

#[tauri::command]
async fn lookup_alias(name: String) -> Option<RemasterAlias>;
// "Magic Missile" → "Force Barrage"

#[tauri::command]
async fn lookup_miracle(reference: String) -> Option<MiracleSpellMap>;
// "Mt 14:25" → walking-on-water spell mapping

#[tauri::command]
async fn xp_budget(party_level: u8, party_size: u8, difficulty: Difficulty) -> XpBudget;

#[tauri::command]
async fn validate_statblock(statblock: serde_json::Value) -> ValidationResult;
```

### 3.2 Worldbuilding layer (read+write)

```rust
#[tauri::command]
async fn create_entity(campaign: String, type_: String, frontmatter: serde_json::Value) -> Entity;

#[tauri::command]
async fn update_entity(id: String, patch: EntityPatch) -> ValidationResult;
// Round-trip: writes to .md file → vault watcher rebuilds SQLite mirror

#[tauri::command]
async fn add_relation(from_id: String, edge_type: String, to_id: String) -> Relation;

#[tauri::command]
async fn list_campaigns() -> Vec<Campaign>;

#[tauri::command]
async fn create_campaign(name: String, default_lens: String) -> Campaign;

#[tauri::command]
async fn export_to_foundry(campaign: String, target_path: String) -> ExportResult;
// Foundry pf2e JournalEntry + Actor pack export per [[recommended-stack]] phase 3
```

### 3.3 Settings + lens switching

```rust
#[tauri::command]
async fn get_settings() -> Settings;

#[tauri::command]
async fn set_active_lens(lens: String) -> Settings;
// Triggers SQLite reindex (filtered).

#[tauri::command]
async fn list_available_lenses() -> Vec<LensManifest>;
```

### 3.4 LLM layer (off by default)

```rust
#[tauri::command]
async fn llm_configure(provider: LlmProvider, config: LlmConfig) -> Result<()>;
// LlmProvider: Ollama { url } | Anthropic { api_key, model } | OpenAI { api_key, model }
// Stored encrypted (keychain on macOS, DPAPI on Windows, libsecret on Linux,
// keychain on iOS, EncryptedSharedPreferences on Android)

#[tauri::command]
async fn llm_chat(messages: Vec<Message>, tools: Vec<ToolDef>) -> StreamResponse;
// Streams via Tauri events; supports tool-use loop.

#[tauri::command]
async fn llm_generate_statblock(prompt: String, kind: StatblockKind) -> serde_json::Value;
// Wraps Pydantic-equivalent JSON Schema → provider-specific structured output.
// Two-stage: structured fields first, free-form prose second [[llm-integration-architecture]].

#[tauri::command]
async fn llm_rag_query(question: String, scope: RagScope) -> RagResponse;
// scope: Campaign | ReferenceOnly | Both
// Always returns citations.
```

---

## 4. Implementation Details

### 4.1 Vault watcher → SQLite mirror

```rust
// src-tauri/src/vault.rs
async fn rebuild_on_change(event: notify::Event) {
    for path in event.paths {
        if let Some(ext) = path.extension() {
            match ext.to_str() {
                Some("md") => {
                    let parsed = parse_frontmatter_and_body(&path)?;
                    upsert_entity_lore(&parsed)?;
                    rebuild_fts_for(&parsed.id)?;
                    enqueue_embedding_task(&parsed.id)?;
                }
                Some("json") if is_statblock(&path) => {
                    let json = serde_json::from_reader(File::open(&path)?)?;
                    validate_against_schema(&json)?;
                    upsert_entity_mechanical(&json)?;
                }
                _ => {}
            }
        }
    }
}
```

Embedding rebuild is async; UI shows a small "indexing N entities…" toast.

### 4.2 Search ranking (hybrid FTS + vector)

```rust
async fn search(query: &str, lens: Option<&str>) -> Vec<SearchHit> {
    let fts_hits = sqlx::query_as!(
        SearchHit,
        "SELECT entity_id, bm25(entities_fts) as score
         FROM entities_fts
         JOIN entities ON entities.rowid = entities_fts.rowid
         WHERE entities_fts MATCH ?
           AND (entities.lens IS NULL OR entities.lens = ?)
         ORDER BY score LIMIT 50",
        query, lens.unwrap_or("lewisian")
    ).fetch_all(&pool).await?;

    let query_vec = embed(query).await?;  // local Ollama or remote API
    let vec_hits = sqlx::query_as!(
        SearchHit,
        "SELECT entity_id, distance as score
         FROM entities_vec
         WHERE embedding MATCH ?
           AND k = 50
         ORDER BY distance",
        bytes(&query_vec)
    ).fetch_all(&pool).await?;

    // Reciprocal rank fusion
    fuse_rrf(fts_hits, vec_hits, 0.5)
}
```

If LLM is not configured (the v1 default), the vector path is skipped and search is FTS5-only — still good enough for a reference app.

### 4.3 LLM tool loop (when enabled)

```rust
const TOOLS: &[ToolDef] = &[
    tool!("lookup_rule", "Look up a PF2e rule by name", LookupRuleArgs),
    tool!("lookup_monster", "Look up a monster", LookupMonsterArgs),
    tool!("xp_budget", "Calculate encounter XP budget", XpBudgetArgs),
    tool!("validate_statblock", "Validate a statblock", StatblockArgs),
    tool!("search_canon", "Search wiki/RAG", SearchArgs),
    tool!("lookup_miracle", "Map Bible reference → PF2e spell", MiracleArgs),
    tool!("lookup_alias", "Map legacy name → Remaster name", AliasArgs),
];

async fn run_loop(messages: Vec<Message>, max_iters: u8) -> Conversation {
    let mut conversation = Conversation::from(messages);
    for _ in 0..max_iters {
        let response = llm_call(&conversation, TOOLS).await?;
        if let Some(tool_calls) = response.tool_calls {
            for call in tool_calls {
                let result = dispatch_tool(call).await?;
                conversation.push_tool_result(result);
            }
        } else {
            return conversation;  // model stopped calling tools
        }
    }
    conversation  // hit max_iters; warn user
}
```

Bound iterations and token spend per task ([[llm-integration-architecture]] § agent-loop). Pre-warm Anthropic 1h cache with the system prompt + active campaign canon at session start.

### 4.4 Lens switching

```rust
async fn set_active_lens(lens: &str) -> Result<()> {
    settings::set("active_lens", lens)?;
    // No SQLite rebuild needed — queries already filter by lens.
    // Reload UI state.
    emit_event("lens-changed", lens)?;
    Ok(())
}
```

The lens is a query-time filter, not a build-time partition. All 5 lens packs live in SQLite; the active lens just constrains which rows are visible.

### 4.5 Plugin model

Per [[desktop-app-stack-recommendation]] § plugin-architecture: copy Obsidian's vault-as-folder + per-plugin manifest, but enforce **Tauri capabilities** for the security gap Obsidian leaves open.

```toml
# .pf2e-tool/plugins/<id>/manifest.toml
[plugin]
id = "fantasy-statblocks-importer"
name = "Fantasy Statblocks Importer"
version = "0.1.0"
author = "..."

[capabilities]
allowed_commands = ["get_entity", "create_entity", "search"]
fs_scope = ["plugins/fantasy-statblocks-importer/data/**"]
network_hosts = []
llm_keys = false
```

The Tauri capability JSON is generated from this manifest at plugin-load time. Plugins cannot call commands they didn't declare; cannot access vault paths outside their scope; cannot reach the LLM API keys unless explicitly granted.

### 4.6 License-provenance tracking

Every entity carries `license_provenance: orc | community-use | homebrew | proprietary`. The export-to-Foundry path checks this before writing — community-use-flagged entities (Golarion-named content; not part of the default Biblical reskin since it replaces Golarion) emit a Community Use boilerplate notice. Pure ORC + Biblical-reskin homebrew exports without restriction (per [[pf2e-licensing-posture]]).

---

## 5. Content packs (the Biblical reskin)

### 5.1 Lens packs structure

Each lens pack is a versioned content directory loaded into SQLite at app startup. The 5 v1 lens packs:

| Pack | Default? | Pulls from concept article | Highlights |
|---|---|---|---|
| **Lewisian** | ✅ | [[denominational-lens-decision]] § Lewisian, [[magic-theology-approaches]] approach #2 | Mere-Christianity 66-book canon; Charism+Lewisian magic-theology hybrid; deferred denominational specifics |
| **Catholic** | | [[denominational-lens-decision]] § Catholic | 73-book canon (deuterocanon); 9-choir angels; named saints as Champion patrons; Thaumaturge implements = relics |
| **Reformed** | | [[denominational-lens-decision]] § Reformed | 66-book; cessationist (use sparingly); covenant theology scaffold; Word-as-sword |
| **Pentecostal** | | [[denominational-lens-decision]] § Pentecostal | 66-book; spiritual-warfare frame; healing/tongues/prophecy charisms |
| **Orthodox** | | [[denominational-lens-decision]] § Orthodox | LXX+ canon; theosis; icons; Aerial Toll Houses as level-15+ post-mortem dungeon |

A **6th "peace-church" lens** (Anabaptist/Quaker, per gap E) is *deliberately not shipped in v1* because it fights PF2e's combat core; documented in the wiki as critical-mirror reference, not playable lens.

### 5.2 Per-pack content (v1 minimum)

Each lens pack includes:

1. **YHWH deity entry** — fully filled stat block per [[yhwh-deity-template]].
2. **3-7 saint/archangel entries** — Catholic ships ~20 (St Michael/George/Raphael/Gabriel/Uriel/Pantokrator-Christ/etc.); Orthodox similar; Reformed ships covenant-figures only (Abraham, Moses, David, Isaiah, Christ); Pentecostal ships Bible-heroes (Elijah, Daniel, Paul); Lewisian ships universal minimum.
3. **Cosmology entries** — Heaven, Sheol/Hades, Gehenna, Tartarus, Abyss, New Jerusalem, plus lens-specific (Purgatory for Catholic; Toll Houses for Orthodox).
4. **Class reskin notes** — concrete lens-specific tweaks per [[class-ancestry-reskin-verdicts]].
5. **Champion-cause variants** — saint-attached for Catholic/Orthodox; abstract virtue for Reformed/Lewisian; Bible-hero exemplar for Pentecostal.
6. **Magic-theology approach default** — Lewisian → hybrid Charism+Lewisian; Reformed → all-magic-demonic or strict-historicist; Catholic/Orthodox/Pentecostal → Charism+Lewisian.

### 5.3 Reference layer (system-neutral, lens-NULL)

Bundled and queryable regardless of active lens:

- All ~330 Remaster name aliases ([[pf2e-remaster-name-mapping]]).
- ~50-row biblical-miracle-to-PF2e-spell map ([[biblical-miracle-to-pf2e-spell-map]]).
- 1 Enoch Watchers forbidden-arts table (the Charism+Lewisian primary-text anchor — [[2026-05-25-1-enoch-book-of-watchers-ch6-16]]).
- Aquinas q.96 a.2 causal-vs-significatory test ([[2026-05-25-aquinas-summa-q95-q96-divination-magic]]).
- Pseudo-Dionysian 9-choir → PF2e celestial mapping ([[biblical-cosmology-pf2e-mapping]]).
- 3-track fiend mapping (Lucifer-fall devils / Watcher-fall demons / Revelation-horsemen daemons).

These are reference content — the cross-cutting knowledge the user can access in any lens.

---

## 6. UI / UX

### 6.1 Mobile (read-heavy reference shell)

```
┌─────────────────────────────┐
│ 🔍  Search                  │  ← persistent search; FTS5 hybrid
├─────────────────────────────┤
│  Cassian, Lord                                      [npc]
│  Lewisian Lens                                            │
│  ─────                                                    │
│  Member of  House Velerian                                │
│  Enemy of   The Pale Circle                               │
│  Wields     Sword of Meridian                             │
│  Patron     St Michael (saint)                            │
│  ─────                                                    │
│  Lord Cassian is a knight of...                           │
│  [↓ statblock] [↓ relations graph]                        │
├─────────────────────────────┤
│ 🏠 📖 ⚔️  📚 ⚙️                                            │
│ home rule encntr canon settings                           │
└─────────────────────────────┘
```

Bottom tabs: Home (recent + campaigns) / Rules (PF2e reference) / Encounter (XP budget + monster picker) / Canon (lore browser) / Settings.

### 6.2 Desktop (multi-pane editor)

```
┌──────────┬──────────────────────────────────┬────────────┐
│ Sidebar  │ Editor pane                       │ Inspector  │
│          │                                   │            │
│ Camps    │ # Lord Cassian                    │ Statblock  │
│  ▸ Test1 │                                   │            │
│  ▾ Main  │ Lord Cassian is a knight...       │ AC 22      │
│   NPCs   │                                   │ HP 95      │
│   Locns  │ ## Background                     │ ...        │
│   Quests │                                   │            │
│          │ He served under [[the-margrave]]  │ Relations  │
│ Refrnce  │ before the betrayal of...         │ ─────      │
│  Spells  │                                   │ member_of  │
│  Mons.   │                                   │  H.Velerian│
│  Saints  │                                   │            │
│  Aliases │                                   │ enemy_of   │
│          │                                   │  Pale Circ.│
│ Plugins  │                                   │            │
│  ⚙       │                                   │ patron     │
│          │                                   │  St Mich.  │
└──────────┴──────────────────────────────────┴────────────┘
```

Multi-pane; sidebar / editor / inspector. CodeMirror 6 for the editor (markdown + frontmatter); inspector renders the statblock + typed relations from frontmatter.

### 6.3 Lens switcher

Settings → "Active lens": dropdown with 5 options. Description text under each (from [[denominational-lens-decision]] worked-examples). Switching is instant (query-time filter); no rebuild.

---

## 7. Testing Strategy

### 7.1 Unit tests (Rust)

- `cargo test` for each command handler.
- Schema-validation tests: every entity type round-trips frontmatter → SQLite → frontmatter losslessly.
- Remaster-alias lookup: 100% coverage of the ~330 pairs.
- Miracle-spell map: 100% coverage of the ~50 pairs.
- XP budget calculator: validate against PF2e GM Core encounter table.

### 7.2 Integration tests

- Vault → SQLite round-trip: 1000-entity vault rebuilds cleanly in <2s on dev hardware.
- Lens-switch: changing active lens shows/hides correct entities without data loss.
- Foundry-pf2e import: ingest a known compendium, verify all records mirror correctly.

### 7.3 LLM evals (when LLM enabled)

Held-out QA over the bundled canon. Per [[llm-integration-architecture]] § agent-loop:

- **Statblock validity**: 95%+ of generated statblocks pass `validate_statblock` first try.
- **Canon faithfulness**: RAG queries cite the right source ≥90% of the time.
- **Rules-correctness**: encounter recommendations don't violate XP budget rules in 100% of test cases.

### 7.4 Mobile e2e

- iOS / Android instrumentation tests via Tauri 2 mobile tooling.
- Manual at-table testing on iPad + iPhone before App Store submission.
- Reference-only flow must work fully offline (no network calls except optional LLM).

---

## 8. Deployment & Distribution

### 8.1 CI/CD

GitHub Actions matrix per [[2026-05-24-desktop-app-stack-packaging-signing-2026]]:

```yaml
strategy:
  matrix:
    platform:
      - { os: macos-latest, target: aarch64-apple-darwin }
      - { os: macos-latest, target: x86_64-apple-darwin }
      - { os: macos-latest, target: aarch64-apple-ios }
      - { os: ubuntu-latest, target: x86_64-unknown-linux-gnu }
      - { os: ubuntu-latest, target: aarch64-linux-android }
      - { os: ubuntu-latest, target: armv7-linux-androideabi }
      - { os: windows-latest, target: x86_64-pc-windows-msvc }
```

- macOS notarization: notarytool ($99/yr Apple Developer Program).
- Windows signing: Azure Trusted Signing (~$120/yr; replaces $300-700 EV certs).
- Linux: AppImage + Flathub.
- Auto-update: Tauri updater plugin with signed release manifests.

### 8.2 App store posture

- **Mac App Store**: yes, free.
- **Microsoft Store**: yes, free.
- **iOS App Store**: yes, free. Free with optional in-app donation. **Risk**: Apple review for reskinned PF2e + religious content; mitigation = pure ORC mechanics (legally clean), Biblical content described as "fantasy setting inspired by Christian tradition" not "Christian-evangelism app."
- **Google Play**: yes, free.
- **Sideload (iOS EU + Android global)**: `.ipa` and `.apk` direct downloads from project site.
- **Direct download**: macOS `.dmg` / Windows `.msi` / Linux `.AppImage` from project site.

### 8.3 Updates + content packs

App binary updates via Tauri updater (signed manifests). Content packs (lens packs) ship in the binary in v1; v2 may move to downloaded-on-demand to shrink binary size if it crosses ~200 MB.

### 8.4 Backups + sync

Vault is plain markdown files in a user-chosen directory. Backups = whatever the user already does for their files (Time Machine, iCloud Drive, Dropbox, Syncthing, git). v2 adds Automerge live sync per [[recommended-stack]] phase 4.

---

## 9. Implementation Phases

| Phase | Wks | Goal | Wiki grounding | Validation |
|---|---|---|---|---|
| **0. Scaffold** | 1-2 | Tauri 2 project, SvelteKit shell, vault model, SQLite + sqlite-vec wired | [[recommended-stack]] phase 0 | App opens; empty vault renders; smoke FTS query works |
| **1. Reference layer** | 3-6 | Bundled PF2e content (spells/monsters/feats); Remaster alias lookup; XP budget; statblock viewer | [[pf2e-remaster-name-mapping]], Foundry pf2e ingestion | Search "Force Barrage" returns the spell; alias lookup "Magic Missile" → "Force Barrage"; encounter math verified |
| **2. Biblical reskin packs** | 7-9 | Lewisian default lens; YHWH deity entry; ~10 saint/archangel entries; cosmology entries; class-reskin notes; miracle-spell map; class-reskin verdicts | [[recommended-reskin-stack]], [[yhwh-deity-template]], [[biblical-miracle-to-pf2e-spell-map]] | Lens switch works; YHWH stat block valid; miracle "Mt 14:25" → *Water Walk* |
| **3. Worldbuilding editor (desktop)** | 10-13 | Markdown editor + frontmatter; entity creation; typed relations; campaign management; license-provenance tracking | [[world-data-model-recommendation]] | Create NPC; add relations; vault round-trips losslessly |
| **4. Mobile co-target** | 14-16 | iOS + Android builds for reference layer; read-only worldbuilding view on phone | [[rust-multi-platform]], [[desktop-app-stack-recommendation]] § mobile | Reference layer fully usable on phone; vault read-only renders; TestFlight + Play internal track |
| **5. All 5 lens packs** | 17-19 | Catholic + Reformed + Pentecostal + Orthodox lens packs filled to v1 minimum | [[denominational-lens-decision]], [[denominational-scope]] paths | Each lens passes content review; switching between lenses works |
| **6. LLM layer (optional)** | 20-23 | Ollama + Anthropic clients; BYO-key onboarding; RAG via sqlite-vec; tool loop with PF2e validators; pre-warm 1h cache | [[llm-integration-architecture]] | Statblock generation eval ≥95%; canon-faithfulness ≥90%; off by default |
| **7. Foundry export + plugin SDK** | 24-26 | Foundry pf2e JournalEntry + Actor pack export; plugin loading per Obsidian model + Tauri capability gates | [[recommended-stack]] phase 3-4 | Round-trip a campaign through Foundry; sample plugin loads + respects capability scope |
| **8. App-store submission + launch** | 27-28 | Notarization, signing, store listings, donate flow, marketing site | [[2026-05-24-desktop-app-stack-packaging-signing-2026]] | Live on Mac App Store, MS Store, App Store, Play Store; direct downloads working |

**Total**: ~28 weeks to v1.0 with all 5 lens packs, mobile, optional LLM. **First user-facing build (Phase 4 desktop reference)**: ~9 weeks.

---

## 10. Risks & Mitigations

| Risk | Source | Mitigation |
|---|---|---|
| **Tauri 2 mobile editor immaturity** | [[desktop-app-stack-recommendation]] § mobile co-target; [[rust-multi-platform]] | Mobile is **reference-only in v1**; editor on mobile is v1.1. iPad has more headroom than iPhone. Fallback: read-only on mobile, edit on desktop. |
| **App Store review uncertainty (Christian content + reskinned PF2e)** | Interview gap; no wiki coverage | Frame as "fantasy setting inspired by Christian tradition," not religious-instruction app; pure ORC mechanics legally clean; donate flow uses Apple/Google in-app purchase to stay compliant. |
| **DragonRaid trap** (piety-as-mechanical-input) | [[prior-christian-rpg-lessons]] | No verse-recitation mechanics; no virtue-as-XP; no GM dice rigging. App is reference + worldbuilding; theology is *content*, not mechanics. |
| **Rapture warning** (right system, wrong setting framing) | [[prior-christian-rpg-lessons]] (gap-round update) | Lewisian default = mere-Christianity neutrality; pick-on-first-launch defers committing the user to one denomination. |
| **PF2e community AI sentiment is hostile-but-conditional** | [[worldbuilding-tool-landscape-2026]] § LLM integration; [[2026-05-24-reddit-pf2e-ai-gm-sentiment]] | LLM is **off by default**; clearly labeled in onboarding. Local-LLM (Ollama) is the suggested first option; Anthropic is opt-in cloud. Visible RAG citations on every LLM output. |
| **KuzuDB archived → no embedded graph DB** | [[recommended-stack]] cross-finding #4 | SQLite with recursive CTEs handles 1-2 hop graph queries fine. SurrealDB or CozoDB optional for v2 power-user view. |
| **Foundry-pf2e schema drift over time** | [[pf2e-licensing-posture]] | Pin Foundry-pf2e version on each release; refresh quarterly per Foundry's Paizo errata cadence. CI test that ingest still works. |
| **AoN commercial license is non-transferable** | [[pf2e-licensing-posture]] (gap-closing finding) | Don't ingest AoN at all in v1. Foundry-pf2e schema is the only data source. AoN linking is *web links out*, not bundled content. |
| **Cessationist users find Cleric magic theologically loaded** | [[denominational-lens-decision]] § cessationism axis; [[remaster-monotheism-fit]] § Pharasma escape hatch | Reformed lens defaults Cleric to "rare/biblical-figure-only" framing; Pharasma-precedent `sanctification: none` available as user setting. |
| **Mobile binary size with 5 lens packs bundled** | Interview gap | Measure at Phase 5; if >200 MB, switch to first-launch download per pack. Otherwise bundle for offline-first. |
| **Designer commentary closed as negative finding — sanctification is *accidentally* monotheism-friendly** | [[remaster-monotheism-fit]] (gap-round update) | This is actually a *strength*, not a risk: Paizo isn't going to deprecate the framework based on theological framing they never adopted. The mechanical chassis is stable. |

---

## 11. Cross-Cutting Concerns

### 11.1 Security

- **Plugin sandbox**: Tauri capabilities, manifest-declared scopes, no implicit FS or network access. Stricter than Obsidian's no-sandbox model ([[desktop-app-stack-recommendation]]).
- **LLM API keys**: stored in OS keychain (macOS Keychain / Windows DPAPI / Linux libsecret / iOS Keychain / Android EncryptedSharedPreferences); never in plain config.
- **Vault paths**: user-chosen at first launch; app cannot escape declared scope.

### 11.2 Privacy

- **No telemetry by default.** Optional anonymized error reports (off-by-default opt-in).
- **No cloud calls without LLM enabled.** Reference + worldbuilding work fully offline.
- **LLM calls**: when enabled, Ollama is local-only by default; Anthropic/cloud is BYO-key (user knows the API costs are theirs).

### 11.3 Performance targets

- **Cold-launch**: <2s on M1 Mac, <3s on mid-range Android, <4s on iPhone 12+.
- **Search latency**: <50ms for FTS5; <200ms for hybrid FTS+vec on 10k-entity vault.
- **Vault rebuild**: <2s per 1000 entities; incremental on file-watch (sub-second per single change).
- **LLM round-trip** (when enabled): bound by provider; pre-warmed Anthropic 1h cache should yield ~1s first-token.

### 11.4 Accessibility

- **Screen-reader support** via SvelteKit ARIA semantics.
- **Mobile a11y** is rough across all Rust UI frameworks per [[rust-multi-platform]] — Tauri 2 webview path means we inherit native webview a11y, which is actually better than Iced/Slint/Dioxus.
- **High-contrast / dim mode** for at-table use.
- **Large-touch UI** on mobile — minimum 44pt targets per Apple/Material guidelines.

### 11.5 Backwards compatibility

- Vault format is plain markdown + JSON; never goes obsolete.
- SQLite schema versions tracked; migrations run on app startup.
- Content packs versioned; old packs supported for at least 2 minor versions.

---

## 12. Open Questions

1. **Mobile editor target date** — when does Tauri 2 mobile become stable enough for the markdown editor? Assumed late v1 / v1.1.
2. **Lens-pack content scope** — how deep should each lens pack go in v1? The v1-minimum spec lists 3-7 saint entries per pack; should Catholic ship 20+? **Suggested**: ship Catholic deeper (~20) since it's the richest material per [[denominational-lens-decision]]; ship others at v1-minimum and expand based on user demand.
3. **Saint data per Catholic / Orthodox** — does the wiki have enough to ship 10+ saint entries with complete stat blocks, or is this a `/wiki:research` follow-up?
4. **Foundry export round-trip fidelity** — losslessly importing from Foundry then exporting back: does the user's modifications to entities survive? Needs design work in Phase 7.
5. **App-store review for reskinned PF2e** — is there a known precedent for an App Store app shipping ORC-licensed mechanics? Worth checking Apostles & Witnesses, Adventurer's Guide to the Bible (5E) commercial precedents.
6. **LLM eval harness** — concrete eval harness specifics not defined; build during Phase 6.
7. **Pricing telemetry** — how do you measure donate-flow conversion if there's no telemetry? Assume Patreon and direct-donate platforms for top-of-funnel; in-app shows pre-built links.
8. **Plugin marketplace** — v1 doesn't include one. Does v1.x ship one (security-curated like Obsidian Community Plugins) or does that wait?

---

## 13. Sources Consulted

### From `pf2e-worldbuilding-tool` topic

- [[recommended-stack]] — overall architecture template
- [[desktop-app-stack-recommendation]] — Tauri 2 + SQLite + sqlite-vec; capability-gated plugins
- [[world-data-model-recommendation]] — markdown-canonical + SQLite mirror; two-tier schema
- [[llm-integration-architecture]] — Ollama + Anthropic; tool loop; RAG
- [[pf2e-licensing-posture]] — ORC-only monetizable; AoN non-transferable; Foundry-pf2e Apache 2.0 schema
- [[pf2e-remaster-name-mapping]] — ~330 legacy↔Remaster aliases
- [[worldbuilding-tool-landscape-2026]] — community AI sentiment; Obsidian + Foundry as the bimodal stack

### From `pf2e-biblical-reskin` topic

- [[recommended-reskin-stack]] — content-side decisions
- [[remaster-monotheism-fit]] — what works as-is; Pharasma escape hatch
- [[denominational-lens-decision]] — 5 lenses + decision aid
- [[magic-theology-approaches]] — 6 approaches; Charism+Lewisian hybrid + Watcher forbidden-arts table
- [[biblical-cosmology-pf2e-mapping]] — Pseudo-Dionysian → PF2e celestial chain; 3-track fiend mapping
- [[class-ancestry-reskin-verdicts]] — class-by-class verdicts; Champion/Thaumaturge/Oracle/Nephilim wins
- [[yhwh-deity-template]] — 4 lens fills + Pharasma escape hatch
- [[biblical-miracle-to-pf2e-spell-map]] — ~50 row reference table
- [[prior-christian-rpg-lessons]] — DragonRaid trap, Testament solve, Rapture warning

### From `rust-multi-platform` (sibling HUB topic)

- UI framework decision matrix; Tauri 2 mobile production state; signing economics

### Total

**17 wiki articles + ~78 raw sources behind them across both topics.**
