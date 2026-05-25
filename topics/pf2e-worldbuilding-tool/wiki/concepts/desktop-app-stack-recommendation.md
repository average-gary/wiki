---
title: "Desktop app stack recommendation"
type: concept
created: 2026-05-24
updated: 2026-05-24
verified: 2026-05-24
volatility: high
confidence: high
sources:
  - "[[2026-05-24-desktop-app-stack-tauri-2-state-2026]]"
  - "[[2026-05-24-desktop-app-stack-electron-42-state]]"
  - "[[2026-05-24-desktop-app-stack-obsidian-plugin-model]]"
  - "[[2026-05-24-desktop-app-stack-sqlite-vec]]"
  - "[[2026-05-24-desktop-app-stack-kuzu-archived]]"
  - "[[2026-05-24-desktop-app-stack-duckdb-vs-sqlite]]"
  - "[[2026-05-24-desktop-app-stack-surrealdb-embedded]]"
  - "[[2026-05-24-desktop-app-stack-packaging-signing-2026]]"
tags: [desktop-app, tauri, electron, sqlite, sqlite-vec, embedded-db, plugins, packaging]
---

# Desktop app stack recommendation

Local-first, offline-capable, file-system-friendly, plugin-extensible. Optimized for a knowledge app that also needs to run an embedded vector index for RAG ([[llm-integration-architecture]]).

## Recommendation

**Tauri 2 (Rust backend, native webview, capability-gated IPC) + SvelteKit or React frontend + SQLite + FTS5 + sqlite-vec single-file vault.**

## Reasoning

### Why Tauri 2 over Electron

- **Tauri 2** stable since Oct 2024. <600 KB minimum bundle vs Electron 42's ~80–150 MB. Native OS webview, not bundled Chromium.
- **Capability JSON/TOML permissions** with `build.rs` codegen — a real security model for IPC commands, FS scopes, and network hosts. Electron has no equivalent at this layer.
- **Rust backend** aligns with the embedded-DB ecosystem (sqlite, sqlite-vec, automerge-rs, kuzu/cozodb/surrealdb-rs).
- **Mobile co-target on the roadmap** — Swift/Kotlin sub-packages — though treat mobile as v2 (WKWebView quirks, `tauri-action` mobile CI still maturing). Cross-ref [[rust-multi-platform]] for the broader picture.
- Electron 42 (May 2026) is a credible incumbent — Chromium 148 / V8 14.8 / Node 24.15, stable ASAR Integrity, MSIX auto-updater, Wayland default on Linux. **Pick Electron only if the team has zero Rust capacity or needs Chromium-specific features.** Otherwise Tauri 2 dominates on bundle size, security model, and mobile path.

### Why SQLite + FTS5 + sqlite-vec, not something exotic

- **[[2026-05-24-desktop-app-stack-sqlite-vec]]** — pure C, zero dep, runs Linux/macOS/Win/WASM/Pi. Float32/int8/binary vectors via `vec0` virtual table; flat + IVF + IVF-kmeans + DiskANN indexes; metadata filtering. v0.1.9 (Mar 2026), pre-1.0 but Mozilla Builders / Fly.io / Turso sponsored.
- **Single `.db` file inside the user's vault folder** = trivially portable, git-friendly enough, Time Machine / Backblaze-friendly.
- **SQLite + FTS5 handles relational + full-text** in the same query. With sqlite-vec it handles vector. One engine, three workloads.
- **DuckDB** is OLAP, not OLTP — bulk MVCC, columnar, suboptimal for high-frequency single-row writes. Use it later as an analytical adjunct over an SQLite mirror, never primary.
- **SurrealDB embedded** is the only multi-model option (graph + doc + KV + FTS + vector + live queries) after KuzuDB's archival. Pick it **only if graph queries dominate the data model** and you accept maturity risk. See [[world-data-model-recommendation]].
- **AVOID KuzuDB**. **[[2026-05-24-desktop-app-stack-kuzu-archived]]** — archived 2025-10-10, final v0.11.3. Was the natural pick for an embedded property-graph; now isn't. Cozo / SurrealDB / Neo4j-embedded are the active alternatives.

### Plugin architecture: copy Obsidian's vault model, fix its security gap

- **[[2026-05-24-desktop-app-stack-obsidian-plugin-model]]** — Obsidian is best-in-class for "vault as folder of files." Per-vault `.obsidian/plugins/<id>/manifest.json`. TS `Plugin` base class. **No sandbox**, Node fs/network unrestricted — third-party plugin can exfiltrate the vault. Marketplace is a social gate, not a technical one.
- **Recommendation**: copy the vault-as-folder + per-vault `.plugins/<id>/manifest.json` discovery model. **Replace Obsidian's permission gap with Tauri capability JSON** — declare per-plugin allowed commands, FS scopes, network hosts, LLM key access. The plugin system inherits the runtime's security model.

### Packaging + signing pipeline (2026)

**[[2026-05-24-desktop-app-stack-packaging-signing-2026]]**:
- 3-runner GitHub Actions matrix (macos-latest, windows-latest, ubuntu-latest) → Tauri bundler → cargo-dist v0.31 (Feb 2026).
- macOS: notarytool, **$99/yr** Apple Developer Program.
- Windows: **Azure Trusted Signing ~$120/yr** — replaces $300–700/yr EV certs (the rust-multi-platform topic flagged this).
- Linux: AppImage + Flathub.
- Auto-update: Tauri updater plugin with signed manifests; Electron 42 has MSIX auto-updater for Windows specifically.

## Frontend choice

SvelteKit or React. Both have first-class Tauri integration. Pick on team familiarity. Avoid Rust-native UI (Dioxus, Slint, egui, Iced) for this app — they don't yet have the editor-component ecosystem (Lexical, ProseMirror, CodeMirror 6) that a wiki/worldbuilding tool needs. Cross-ref [[rust-multi-platform]] § ui-framework-decision.

## What to avoid

- **KuzuDB** — archived.
- **Iced** — no mobile, broken a11y per cross-ref.
- **Electron** unless the team has zero Rust capacity (bundle + no capability model + no mobile).
- **Chroma** — Python/server-shaped, awkward to embed in a Rust desktop binary.
- **DuckDB as primary** — OLAP, wrong workload.
- **Building your own plugin sandbox** before shipping v1 — Tauri capabilities are good enough, ship that first.

## Mobile co-target

Feasible but **v2**. WKWebView quirks (rotation, Xcode 26 link issues per [[rust-multi-platform]]) and `tauri-action` mobile CI being "in progress" mean shipping iOS/Android same-codebase will be a 2–3 month slog of its own. Don't block the desktop v1 on it.

## See also

- [[rust-multi-platform]] (HUB topic) — UI framework decision, cross-compile matrix, signing economics. Reusable as-is; this concept layers PF2e-app-specific choices on top.
- [[world-data-model-recommendation]] — what sits inside the SQLite + sqlite-vec store
- [[llm-integration-architecture]] — what the embedded vector index is for
- [[recommended-stack]] — full integrated stack

## Open questions

- No first-party Tauri 2 vs Electron 2026 head-to-head benchmark (memory / startup / render) found.
- LanceDB embedded-mode page 404'd; LanceDB-vs-sqlite-vec is qualitative, not benchmarked.
- DuckDB current stable version not stated on `why_duckdb`.
- Wails 2026 state, Flutter desktop maturity, Qt/PySide6 not surveyed (deprioritized in plan).
- LLM streaming UI patterns (SSE vs WebSocket vs Tauri events) — separate research path.
