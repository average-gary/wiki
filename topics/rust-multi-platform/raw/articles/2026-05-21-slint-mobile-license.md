---
title: "Slint — iOS tech-preview, Android stable, 3-tier license with embedded royalty"
source: https://slint.dev/pricing
type: article
tags: [slint, ui-framework, mobile, ios, android, license, embedded, royalty]
date: 2026-05-21
quality: 6
confidence: high
agent: 5
summary: "iOS = tech-preview (Slint 1.12, June 2025). Android = officially supported since 1.5 (March 2024). Native renderer (Skia/WGPU) — NOT webview. License: 3 tiers — GPLv3 free; Royalty-Free paid (no embedded); Enterprise paid (embedded requires per-device royalty $1+/unit)."
---

# Slint — mobile, web, and the embedded royalty footgun

## Mobile state

| Platform | Status | Since |
|----------|--------|-------|
| Android | **Officially supported** | Slint 1.5 (March 2024) |
| iOS | **tech-preview** | Slint 1.12 (June 2025) |

Slint claims to be "the only Rust GUI toolkit to officially support Android." (predates Dioxus 0.6)

## iOS tech-preview details (1.12)

- Cross-compilation for iPhone + iPad from Rust
- > "Xcode support gives you all the convenience you need: Certificate management, deployment to hardware and simulators, sharing apps via TestFlight, and publishing to the App Store"
- Native font rendering via Skia
- Underlying graphics: WGPU
- Limitation: only Rust can target iOS in Slint (no C++/JS/Python on iOS yet)
- Not mentioned: accessibility (VoiceOver), performance benchmarks

## Mobile platform features

- `mouse-drag-pan-enabled` for touch scrolling
- `virtual-keyboard-position` and `virtual-keyboard-size` properties
- Auto keyboard show/hide on text-input focus
- `Window.safe-area-insets` for notches/status-bars/home-indicators
- Auto-scroll on Flickable when text field focused

## Mobile limitations

- "Virtual keyboard behavior differs between Android and iOS, potentially creating edge cases with custom keyboards"
- Touch targets: developer-sized ("Slint provides no automatic assistance")
- **"Multiple nested ScrollViews aren't supported"** — real constraint for any list-of-scrolling-cards

## Web/WASM caveats (verbatim)

> "Slint renders text directly, instead of benefitting from the browser's text rendering"

Implication: worse glyph quality, no native text selection, no browser spell-check, **a11y tooling cannot read text from canvas**.

> "Accessibility features (such as screen readers) are not available" in browser mode.

> "running Slint in browsers is currently not recommended for building general-purpose web applications."

## License — 3 tiers

| Tier | Cost | Allowed |
|------|------|---------|
| **GPLv3** | Free | Open-source apps only |
| **Royalty-Free** | Paid | Desktop, mobile, web — **excludes embedded** |
| **Enterprise** | Paid | All platforms; **embedded requires per-device royalties** ($1.00+/unit, prepay/buyout discounts available) |

**"Perpetual Fallback License"** kicks in after 12 consecutive monthly payments.

## Tier eligibility gates

- **Startup**: ≤10 employees, ≤€2M turnover, <5 yrs old
- **Small Enterprise**: ≤50 employees, ≤€10M

Embedded is **free** for non-commercial / personal / open-source use.

## When Slint wins

- Embedded UI (automotive/industrial/IoT) — primary niche
- Desktop where accessibility + multi-language bindings matter
- Figma-to-code workflow (their Figma plugin)
- Teams that need C++/JS/Python bindings (only available on non-iOS platforms)

## When license is a footgun

- Commercial embedded use → per-unit royalty
- Closed-source desktop without paid license → must use GPLv3 (forces app to be GPL)
- Indie commercial desktop → Royalty-Free tier required (paid)

## Cross-references

- [[Boring Cactus 2025 Rust GUI survey]]
