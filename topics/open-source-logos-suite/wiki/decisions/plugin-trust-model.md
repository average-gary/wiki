---
title: Decision — Plugin Trust Model
type: decision
created: 2026-05-27
updated: 2026-05-27
verified: 2026-05-27
volatility: cold
status: active
confidence: high
tags: [decision, plugin, trust, sandboxing, capabilities]
sources:
  - "[[raw/articles/2026-05-27-client-obsidian-plugin-arch]]"
  - "[[raw/articles/2026-05-27-case-file-over-app]]"
---

# Decision — Plugin Trust Model

## Context

The plugin system is the moat extender for an OSS Logos suite. Sermon builders, denominational extensions, language packs, AI integrations, and BYO-license adapters all live there. Trust matters because plugins might:

- Handle the user's API keys (ESV, NIV, Anthropic)
- Read sermon drafts and personal notes
- Make network requests
- Write to the file system

The trust model decision **must be made at v1**. Retrofitting trust onto an existing untrusted plugin ecosystem is essentially impossible (Obsidian's experience).

## Options considered

### Option A — Obsidian-style all-in-process JS (rejected)

Plugins run in the same process as the host app, with full file/network access. No sandboxing, no permission system, no capability manifests.

**Pros**:
- Simplest to implement
- Lowest latency
- Easy plugin authoring
- Obsidian has the largest plugin ecosystem in the space

**Cons**:
- A single malicious plugin owns the user's API keys, sermon drafts, and personal data
- No way to declare "this plugin only needs read access to Bible text"
- Obsidian docs explicitly admit no sandboxing — known limitation, not fixable without breaking change
- Unsuitable for a Bible-study app handling personal data and BYO-license keys

### Option B — Pure WASM with capabilities (rejected)

All plugins are WASM modules with capability descriptors; pure functions over text.

**Pros**:
- Strong sandboxing
- Cross-language plugin authoring
- Capability declarations explicit

**Cons**:
- WASM only — full plugins (sermon builder UI, AI integrations) are awkward in WASM
- Plugin authoring in Rust/Go/AssemblyScript narrower than JS
- Debugging WASM is harder than debugging Node

### Option C — VS Code-style out-of-process extension host (chosen)

Plugins run in a separate process (Node or Worker) communicating via JSON-RPC. Capability manifest declares required permissions; user grants on install.

**Pros**:
- Process isolation = sandboxing
- Capability manifests = explicit permission model
- Crash-isolation: a buggy plugin doesn't crash the host
- Mature pattern (VS Code, Sublime, Atom)
- Plugin authors use familiar JS/TS

**Cons**:
- Higher latency than in-process
- IPC overhead
- More complex than Obsidian's model

### Option D — Hybrid: out-of-process for full plugins + WASM for lightweight transforms (chosen — combined with C)

Two plugin runtimes, picked based on plugin shape:

- **Out-of-process Node/Worker** for full plugins (sermon builders, AI assistants, full UI panels)
- **WASM with capabilities** for lightweight pure-function transforms (text processors, syntax-tree queries, simple panels)

Plugin manifest declares which runtime; the host loads accordingly.

**Pros**:
- Right tool for each job
- Heavy plugins get full Node/JS capability; light plugins get cheap WASM sandbox
- Capability model unified across both runtimes

**Cons**:
- Two runtimes to maintain
- Plugin authors choose runtime (potential confusion)

## Decision

**Adopt Option D — hybrid out-of-process + WASM.**

### Plugin manifest format

```json
{
  "name": "sermon-builder",
  "version": "1.0.0",
  "runtime": "node",  // or "wasm"
  "capabilities": [
    "read:bible-text",
    "read:user-notes",
    "write:user-notes",
    "network:api.openai.com"
  ],
  "entry": "main.js",
  "signature": "...",
  "author": "..."
}
```

### Capability list (initial)

- `read:bible-text` — read all installed Bible texts and lexicons
- `read:user-notes` — read user's notes/sermons/highlights
- `write:user-notes` — create/update user content
- `read:user-library` — list installed packages
- `read:settings` — read user preferences
- `write:settings` — update user preferences (scoped to plugin)
- `network:<host>` — make HTTPS requests to specific host
- `network:any` — unrestricted HTTPS (require explicit user grant)
- `ui:panel` — render a UI panel
- `ui:command` — register a command in the command palette

User installation flow:

1. User downloads plugin (signed manifest verified)
2. Host displays requested capabilities
3. User explicitly grants (or denies)
4. Plugin loads in its declared runtime with granted capabilities only

### Distribution

- **Plugin marketplace** (a static site or GitHub repo with manifests + signatures)
- **Direct install** via plugin URL (manifest + tarball + signature)
- **Side-load** for development

### Plugin signing

Plugins are signed by author key. Host verifies signature; warns if unsigned. The marketplace requires signed plugins.

## Implications

- Plugin SDK must support both runtimes — design the API surface to be runtime-agnostic
- Plugin marketplace tooling needs signature verification
- User onboarding must include a clear "what is this plugin asking for" UX
- Capabilities must be enforced *at the boundary* — plugins can't fake capabilities
- Plugin output that touches user files goes through capability checks — write operations always logged

## What this prevents

- A malicious sermon-builder plugin can't read the user's ESV API key (separate plugin scope)
- A buggy plugin can't crash the host
- A plugin can't silently exfiltrate notes to a remote server (network capability declared)
- An update with new capabilities requires re-grant (can't sneak permissions in)

## What this doesn't prevent

- A user grants `network:any` and the plugin abuses it — user's choice
- Plugin author publishes a backdoored plugin under known author key — out of scope (use marketplace moderation, signed reviews)
- Side-channel attacks (timing, etc.) — out of scope for v1

## See Also

- [[../concepts/client-architecture|Client architecture]]
- [[../topics/engineering-playbook|Engineering playbook]]
