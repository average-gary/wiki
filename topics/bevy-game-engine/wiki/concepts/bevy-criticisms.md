---
title: "Bevy criticisms and limitations"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, criticism, editor, mobile, console, breaking-changes, lts]
---

# Bevy criticisms and limitations

The strongest critiques as of mid-2026 — most from people inside or close to the project, not drive-by hot takes.

## No editor

The single most-named gap. Quoting [[jms55-critique.md|JMS55, a longtime Bevy renderer/Solari contributor (Sept 2025)]]:

> "[The lack of an editor is] a big, big hole for Bevy."

His [[jms55-critique.md|critique]] also flags:
- No proven high-level API for declaring/updating UI trees — BSN solves the declarative half but not reactivity
- BSN-based prototypes "exceedingly difficult to write and understand"
- Custom materials "servicable but not enjoyable" — fragmented across 3D/2D/UI with no unified abstraction
- Animation API "clunky, with too many confusingly-named components"
- Asset processing APIs "clunky and don't support enough features"; only outdated BasisU for texture compression; glTF-to-virtual-geometry processor proved unfeasible

The official [[bevy-editor-vision.md|editor vision doc]] acknowledges editor absence as "a longstanding frustration" and "consistent push back against using Bevy." Critically, the planned editor is *intentionally narrower* than Unity/Godot/Unreal editors — explicitly NOT for asset creation, NOT an IDE replacement, NOT for editing live game state. So even when the editor ships, the gap will partially remain.

## API churn — and there is no LTS

[[bevy-discussion-21911.md|Bevy maintainer NthTensor on Discussion #21911 (Nov 2025)]]:

> "Game engines don't really do that [stabilize their API]."

Combined with the ~3-month minor cadence, this means:

- Breaking changes every minor release; migration guides ship with each release
- No paid maintainer cohort to backport bug fixes — community PRs against old branches don't merge upstream
- **No stable LTS branch exists**
- Hobbyist on Discussion #21911: "major breaking changes every ~3 months can be a killer" for limited-time developers

## Documentation rot

Per the [[biggo-growing-pains.md|BigGo community-discussion synthesis (Oct 2025)]]:

> "Docs, examples, copilot, agents, and chat assistants are all a few versions off from each other, creating confusion and slowing development."

Pre-1.0 churn outpaces docs and AI training data. The [[bevy-cheatbook-platforms.md|community-maintained Bevy Cheat Book]] — which historically anchored newcomer learning — is **explicitly no longer maintained as of 2026** ("This book is no longer maintained. Much of the information in it is outdated"). Newcomers pointed there receive stale information.

## Mobile / console / WASM

[[bevy-discussion-20998.md|Bevy maintainer NthTensor on mobile (Sept 2025)]]:

> "It is possible to ship games to iOS and Android, but not easy... We don't have enough devs using bevy on these platforms who are able to debug issues and improve ergonomics."

Specifics:

- **Android**: less mature than iOS; emulator devices have known problems; real-hardware testing required
- **iOS**: usable; some apps shipped; ergonomics weak
- **Multi-touch** has "constraints and implementation difficulties"
- **No streamlined mobile export workflow** — manual setup, no Unity/Godot-style "build for Android" button
- **Nintendo Switch**: Rust toolchain support "not progressed enough to be useful for Bevy yet"
- **PlayStation**: NDA-gated; status unknown
- **WASM/Web**: multithreading not supported (WASM main-thread limit) — "limited performance and possible audio glitches"; WebGL2 caps 3D scenes at 256 lights; WebGPU lifts limits but breaks compatibility

The structural blocker (per maintainer viridia on the same thread): **Apple/Google/Nintendo/Sony Rust support and platform NDAs**, not anything Bevy can fix alone.

## Compile times + iteration speed

Per [[biggo-growing-pains.md|BigGo synthesis]] and Bevy's own setup docs:

- Target with full fast-compile config: 0.8–3.0s iterative
- Without: significantly longer
- Compile time + Bevy's own dev cycle (frequent breaking changes) makes iteration "substantially slower than Godot, especially for prototyping/jams"

## "Architectural purity over shipping"

[[biggo-growing-pains.md|Community critique]] frames this as a project-direction concern: Bevy "may be developed with a goal of prioritizing its ECS system over practical goals, or facilitating the game dev itself." Whether one agrees, the *symptom* — gaps in editor / asset pipeline / animation that other engines treat as table stakes — is real and the maintainers acknowledge it.

## What this means for adopters

Bevy is a strong fit for:

- Tools, simulators, technical visualizations (where ECS-first matches the domain — see [[bevy-production-users.md|Foresight, Nominal]])
- Indie commercial games where the team is comfortable building tooling (Pounce Light, Bloom Digital — see [[bevy-production-users.md|production users]])
- Rust-shop teams who already know Rust well
- Learning engine internals from the inside out

Bevy is a poor fit for:

- Mobile-first projects on a deadline
- Console releases
- Teams that need an editor for designers/artists today
- Long-lived projects that can't tolerate ~3-month migration overhead

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-platform-support.md|Platform support]]
- [[bevy-vs-other-engines.md|Comparison to other engines]]
- [[bevy-version-timeline.md|Version timeline]]
