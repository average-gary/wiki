---
title: "Bevy in production — shipped games and commercial users"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: medium
tags: [bevy, production, tiny-glade, longstory-2, foresight, nominal]
---

# Bevy in production

**Confirmed commercial users (2024–2026)**:

## Shipped games

- **Tiny Glade** — Pounce Light. Released 2024-09-23 on Steam (Windows/macOS/Linux), $14.99. **97% positive across 13,357 reviews — "Overwhelmingly Positive"** ([[tiny-glade-steam.md|Steam page]]). Min-spec Vulkan 1.2. 2-person studio.
  - Note: one third-party comparison source claims Tiny Glade is "custom Rust engine, not Bevy." This contradicts Bevy's own [[bevy-fifth-birthday.md|fifth birthday post]] and multiple [[twib-tiny-glade-demo.md|TWIB issues]], which list Tiny Glade as a flagship Bevy game using Bevy ECS plus a customized renderer. The Bevy team's account is treated as authoritative here.
- **LongStory 2** — Bloom Digital. Sequel to the award-winning visual novel LongStory. Shipped to Steam (app 2427820) and itch.io ([[twib-longstory-2.md|TWIB 2025-06-30]]). Adds visual-novel as a confirmed Bevy commercial genre.
- **Tunnet** — Commercial ($5.99) on itch.io ([[bevy-itchio-tag.md|itch.io tag]]).
- **POLDERS** — In-development Dutch-themed city-builder; Steam wishlist live ([[twib-polders.md|TWIB 2025-01-13]]). Incubated in the Bevy Discord showcase channel.
- **Abysm** — 2024 Bevy Spooky Jam winner; physics-based puzzle game; Steam page live as of 2025-10 ([[twib-2025-10-27|TWIB Oct 2025]] — note: not ingested as separate raw, summarized in the news/trends agent return).

## Active commercial-trajectory titles (Steam pages, in development)

- **To Build a Home**, **Rare Episteme** — playtests active mid-2025 ([[twib-nominal-foresight.md|TWIB July 2025]]).
- **Foresight, Jarl, Roll It Up** — verified Bevy games per the Youngju 2026 comparison.

## Non-game commercial users

- **Pounce Light** — Studio that shipped Tiny Glade.
- **Bloom Digital** — Studio that shipped LongStory 2.
- **Foresight** — Spatial databases / visualization; satellite-constellation modeling, drone testing, CFD visualization. Confirmed Bevy user per [[twib-nominal-foresight.md|TWIB July 2025]] and [[bevy-fifth-birthday.md|5th birthday]].
- **Nominal** — Industrial test/data platform: telemetry, logs, video, simulation for aerospace/maritime/ground vehicles/energy. Confirmed Bevy user per [[twib-nominal-foresight.md|TWIB July 2025]].

## Indie adoption

- **560 games** tagged `bevy` on itch.io ([[bevy-itchio-tag.md|itch.io tag]]). Mix of paid + free; many browser-playable (WASM target).

## What this evidence supports — and doesn't

The data supports: Bevy is shipping commercial work across at least three distinct genres (cozy builder, visual novel, city-builder) and two non-game industrial-visualization companies. It is not a hobby-only engine.

The data does *not* support: Bevy as a mature mass-market platform. Commercial titles tend to be small-team indie projects with bespoke renderers (Tiny Glade) or narrow audiences (visual novels). No AAA, no major mobile-game success, no shipped console title — and the [[bevy-criticisms.md|criticisms article]] explains why.

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-ecosystem.md|Ecosystem]]
- [[bevy-criticisms.md|Criticisms]]
