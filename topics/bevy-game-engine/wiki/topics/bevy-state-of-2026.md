---
title: "State of Bevy in 2026"
type: topic
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, 2026, current-state, roadmap, 1-0, bsn, editor]
---

# State of Bevy in 2026

A synthesizing snapshot for someone evaluating Bevy in mid-2026.

## Where Bevy actually is

- **Current shipping**: 0.18.1 (2026-03-02)
- **Pre-release**: 0.19.0-rc.3 (2026-06-10)
- **Cadence**: ~3 months per minor; patch releases reactive
- **License**: MIT or Apache-2.0
- **Stars**: 46.6k (vs 40.9k a year ago)
- **Crates.io downloads**: 5.86M all-time / 1.14M last 90 days
- **Reverse deps on `bevy`**: 1,865; `bevy_*` namespace: 3,191 crates
- **Discord**: 21,985+ members
- **itch.io games tagged `bevy`**: 560
- **Foundation**: 501(c)(3); 2 FTE + 1 contractor; "drastically under-funded"

## What's mature enough to use

- **ECS core** — stable since 0.5; relationships and required components landed cleanly in 0.15-0.16; the post-0.16 model is the future and it's solid
- **2D rendering + sprites** — confirmed shipping VN games ([[bevy-production-users.md|LongStory 2]]) and tilemap-based games
- **3D PBR rendering** — Caldera scene ~10 ms/frame on mobile RTX 4090 ([[bevy-rendering.md|0.16 GPU-driven]])
- **Avian physics** — dominant ecosystem physics, 97k recent-90d downloads
- **bevy_egui** — the largest plugin (307k recent), de-facto immediate-mode UI
- **WASM/Web target** — works for indie-scale games (560 itch.io entries)
- **Linux as tier-1 dev target** — full GPU-driven rendering

## What's experimental / partial / in flight

- **Solari raytraced lighting** — experimental in 0.17, refined 0.18; opt-in, not production-stable
- **Bevy Feathers** — opinionated tooling widget set; still maturing
- **Hot patching** — landed in 0.17; production-readiness varies
- **DLSS** — 0.17; NVIDIA RTX only
- **Virtual geometry** — 0.17 added BVH culling with claims of 115B+ triangle scenes
- **Async ECS ergonomics** — working group active

## What's NOT shipping in 0.18

- **Bevy Editor** — design specs done, [[bevy-fifth-birthday.md|Inspector General WG active]]; no shipping editor
- **BSN (Bevy Scene Notation)** — targeted for 0.18 per [[bevy-0-17-modernization.md|0.17 release notes]], **slipped** — still not in stable
- **First-class mobile export** — possible but [[bevy-criticisms.md|hard]]
- **Console support** — structurally blocked
- **High-level reactive UI API** — known gap per [[bevy-criticisms.md|JMS55 critique]]
- **Mature asset pipeline** — Blenvy stalled; glTF-to-virtual-geometry processor proved unfeasible
- **Stable LTS branch** — explicitly does not exist per [[bevy-criticisms.md|maintainer NthTensor]]

## Roadmap pieces with no committed date

Per [[bevy-fifth-birthday.md|Carter's 5th birthday post (2025-08)]] — "no explicit 1.0 timeline":

- BSN completion (in flight, slipped 0.18)
- Reactivity ecosystem
- Standardized widgets (built on top of [[bevy-0-17-modernization.md|0.17 headless widgets]])
- Baseline editor
- Avian as upstream physics

## What 2026 has added since 2025

- **0.18** (Jan): UI widget set (Popover, MenuPopup, RadioGroup), variable fonts + OpenType features, first-party FreeCamera/PanCamera, atmosphere occlusion, Solari refinements, screenshot/screen-record plugins, glTF extension handler trait
- **Active working groups** ([[bevy-twib-jan-2026.md|TWIB Jan 2026]]): WESL shader migration, decoupled rendering, Inspector General editor, async ECS ergonomics, "turtles all the way down" `!Send` data work
- **2 confirmed non-game commercial users** ([[bevy-production-users.md|Foresight, Nominal]]) — industrial/scientific visualization is becoming a real Bevy use case

## Should you use Bevy in 2026?

| If you want to... | Verdict |
|-------------------|---------|
| Ship a mobile indie game in 6 months | No — use Unity or Godot |
| Build a console game | No — use Unity / Unreal |
| Build a Steam indie game with a small Rust-comfortable team | Yes — see [[bevy-production-users.md\|Tiny Glade, LongStory 2, POLDERS]] |
| Build an industrial / scientific visualization app | Yes — see [[bevy-production-users.md\|Foresight, Nominal]] |
| Build internal tools / simulators in Rust | Yes |
| Learn engine internals from the inside out | Yes — Bevy is the textbook |
| Prototype a game in a weekend jam | Maybe — Macroquad or Godot probably faster |
| Build a long-lived project that can't tolerate breaking changes every 3 months | No — wait for [[bevy-version-timeline.md\|1.0]] |

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-version-timeline.md|Version timeline]]
- [[bevy-criticisms.md|Criticisms]]
- [[bevy-vs-other-engines.md|Comparison]]
- [[bevy-production-users.md|Production users]]
