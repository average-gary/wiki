---
title: "block/buzz — README & architecture overview"
source: https://github.com/block/buzz
raw_source: https://raw.githubusercontent.com/block/buzz/main/README.md
type: repo
tags: [buzz, block, nostr, architecture, rust, relay, agents]
confidence: high
ingested: 2026-07-23
summary: "Canonical description of buzz: a self-hostable Nostr-relay workspace where humans and AI agents share rooms; crate map, dependency stack, protocols, maturity traffic-light."
---

# block/buzz — README & architecture

- **What it is:** "A workspace where humans and agents build together, on a relay you own." Mental model: "an event log with taste and a suspicious number of Rust crates." Every message, reaction, workflow step, review approval, and git event is a **signed Nostr event in one append-only log**.
- **Monorepo layout:** `/crates` (Rust workspace), `/web` (frontend), `/desktop` (Tauri), `/mobile` (Flutter), `/bin`, `/deploy`, `/docs`, `/migrations`, `/scripts`. Language split ~ Rust 48% / TS 35% / JS 8% / Dart 6%.
- **Crates:** `buzz-core` (protocol types, NIP-01 filters), `buzz-relay` (Axum relay server), `buzz-db` (Postgres), `buzz-auth` (NIP-42/98), `buzz-pubsub` (Redis), `buzz-search` (Postgres FTS), `buzz-audit`, `buzz-cli` (JSON in/out, agent-first), `buzz-acp` (ACP↔MCP harness), `buzz-agent`, `buzz-dev-mcp`, `buzz-workflow` (YAML automation), `buzz-persona`, `buzz-sdk`, plus `git-sign-nostr` / `git-credential-nostr`.
- **Backend deps:** PostgreSQL (events + full-text search), Redis (pub/sub, presence, typing), S3/MinIO (Blossom media). Relay serves WebSocket + REST; default dev endpoint `ws://localhost:3000`.
- **Clients pointed via `BUZZ_RELAY_URL`** (set before launch or switch in-app). Desktop = Tauri+React; mobile = Flutter (being wired up); CLI = `buzz-cli` (agent-first, needs `BUZZ_PRIVATE_KEY`).
- **Agents are first-class:** own keypairs, channel memberships, audit trails. "Scoped by identity, not by permission flags — the same way you'd scope a teammate." ACP harness supports Goose, Codex, Claude Code + built-in agent "Fizz."
- **Protocols:** NIP-01 (events/filters), NIP-42 (Schnorr auth), NIP-34 (git patches). Toolchain: Docker, Rust 1.88+, Node 24+, pnpm 10+, optional Hermit. Dev workflow: `just setup && just build`, then `just dev`/`just relay`.
- **Maturity traffic-light (README):** "Works today" (relay, channels, DMs, media, audit log, desktop app, buzz-cli, YAML workflows) / "Being wired up" (mobile, workflow approval gates, huddle events) / "Strong opinions, pending code" (web-of-trust reputation, push, culture). Caveat: *"Please do not plan your compliance program around the [pending] column yet."* Apache-2.0, launched v0.4.x in 2026-07.
