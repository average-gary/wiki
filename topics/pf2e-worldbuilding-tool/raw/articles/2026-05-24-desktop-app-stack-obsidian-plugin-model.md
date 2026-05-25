---
title: "Obsidian plugin architecture — best-in-class local-first knowledge app reference"
source: "https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin"
type: guide
date_fetched: 2026-05-24
date_published: "unknown"
tags: [desktop-app, electron, plugin-architecture, local-first, obsidian, file-system-canon]
quality: 4
credibility: high
path: desktop-app-stack
summary: "Obsidian's plugin model: `.obsidian/plugins/<id>/` per-vault folder, `manifest.json` (id+name+description), TypeScript API exported from `obsidian` package, base `Plugin` class. No formal sandbox — plugins get full filesystem access via Node integration. Marketplace gates via review, not runtime sandbox. Useful as a reference design (file-as-canon vault model) but its security model is the part to NOT copy."
---

# Obsidian plugin model — what to copy and what not to

## Architecture (as reference)

- **Vault = directory of markdown files** ("file-system canon"). `.obsidian/` subfolder holds app config + plugins.
- Per-vault plugins live at `.obsidian/plugins/<plugin-id>/main.js + manifest.json`. Each plugin is auto-discovered on vault open.
- Plugin manifest minimum: `id`, `name`, `description`. Full schema also holds `version`, `minAppVersion`, `author`, `isDesktopOnly`.
- API exposed via `import { Plugin, Notice } from "obsidian"` — TypeScript-typed.
- Plugins extend `Plugin` base class; `onload()`/`onunload()` lifecycle.

## What to copy for PF2e worldbuilding tool

1. **Vault-as-folder model**: PF2e canon = directory of markdown / TOML / YAML — version-controllable, diffable, syncable via any cloud, transparent to user.
2. **Per-vault plugin folder**: keep plugins data-local. A campaign-specific plugin lives with the campaign vault.
3. **TypeScript API + base class**: low ceiling for plugin authors.
4. **Community marketplace + review**: human gate, not just a runtime gate.

## What to NOT copy

- **No sandbox**: Obsidian plugins get full Node `fs`, `child_process`, network. Docs literally warn "one mistake can lead to unintended changes to your vault" and recommend dev-vaults. For a worldbuilding tool that ingests third-party content packs + connects to LLMs with API keys, this is unacceptable.
- **Use Tauri 2 capability JSON instead** (see desktop-app-stack-tauri-2-state-2026.md): each plugin declares the commands + scopes it needs; the runtime enforces.

## Cross-reference

- Obsidian itself is Electron-based — proves Electron can ship a beloved local-first app. The plugin permissioning is its weakest link, not the chassis.
- Pairs with `2026-05-24-desktop-app-stack-tauri-2-state-2026.md` — Tauri's capability model is the technical answer to Obsidian's social/review-only model.
