---
title: "Obsidian Plugin Architecture & Security Model"
source_url: "https://obsidian.md/help/Extending+Obsidian/Plugin+security"
type: article
path: client
date_ingested: 2026-05-27
date_published: 2025-01-01
tags: [client, architecture, plugins, sandboxing]
quality: 4
confidence: high
summary: "Obsidian's plugin system is unsandboxed TypeScript-compiled-to-JavaScript loaded from .obsidian/plugins. No permission system; plugins inherit the host app's full filesystem and network access. Trust is community-mediated via Restricted Mode default + safety scorecards + automated malware scanning."
---

# Obsidian Plugin Architecture & Security Model

## Key findings

- **Plugins are NOT sandboxed**. Obsidian official docs: "Due to technical limitations, Obsidian cannot reliably restrict plugins to specific permissions or access levels. Plugins inherit Obsidian's access levels."
- **Effective plugin capabilities**:
  - Read/write any file on the user's computer (not just the vault)
  - Connect to any internet endpoint
  - Install additional programs
- **No granular permission system** — binary trust decision per plugin.
- **Plugin distribution**: TypeScript source → compiled to single `main.js` + `manifest.json` (id, name, description, version), placed in `.obsidian/plugins/<plugin-id>/`. In-process loading, no isolation.
- **Trust mitigations** (the *only* defenses):
  1. **Restricted Mode (default ON)** — third-party code execution disabled until user opts in.
  2. **Automated scanning** — community plugin directory scans for "security vulnerabilities, code quality issues, and malware."
  3. **Safety scorecards** — surfaced on each plugin's directory page.
  4. **Manual review** — popular, featured, and flagged plugins get human review.
  5. **Vulnerability reporting** — through plugin authors' docs or Obsidian support.
- **Lifecycle**: `onload()` / `onunload()` hooks. APIs include `Notice` (toast), `addRibbonIcon()` (sidebar icon), command palette registration, settings tab, vault file IO.

## Notable quotes / specifics

- Obsidian's stance: "Community plugins can access files on your computer", "can connect to internet", "can install additional programs."
- For sensitive use: "perform an independent security audit on the plugin before using it."
- Plugins typically developed in a separate vault to avoid corrupting the main vault during dev.

## Source notes

**Implication for a Logos-style suite**: Obsidian's model is the *baseline* the open-source extensible-app world has converged on, but it's a known weak point. A Bible study app handling potentially sensitive sermon notes / pastoral material has stronger reasons to sandbox than Obsidian does.

**Two architectural paths for the suite**:

1. **Obsidian-style (in-process, unsandboxed JS)** — fastest path to an ecosystem; lowest plugin-author friction; same security posture as Obsidian. Acceptable if the suite ships a curated marketplace + scorecards + Restricted Mode.

2. **VS Code-style extension host (out-of-process)** — extensions run in a separate Node.js or WebWorker process; renderer/UI process is protected from extension crashes and from extension UI manipulation. Extensions declare capabilities via `extensionKind`. Lazy-load via activation events. Higher engineering cost but stronger isolation.

3. **WASM plugins** (newer pattern, e.g., Zed, Figma) — plugins compile to WASM, host runs them in a wasmtime/wasmer sandbox with explicit capability grants. Strongest isolation, language-agnostic plugin authorship, but smaller ecosystem talent pool than JS.

**Recommendation for a Logos clone**: Hybrid. Core suite uses VS Code-style ext-host for full plugins (sermon builders, commentary engines that need filesystem + network). Lightweight transformations (custom rendering, glossary popups) run as WASM with capability-scoped APIs. Avoid the Obsidian "all or nothing" model — pastoral users will install many plugins from many authors and need finer trust granularity.

The plugin model IS the moat-extender for an OSS Logos: denominational plugins, language packs, sermon builders, lectionary engines, original-language tutors all become community-shipped surfaces. Get the trust model right at v1 — retrofit is brutal (Obsidian cannot fix theirs without breaking every plugin).
