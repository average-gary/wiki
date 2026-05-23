---
title: "wasm-pack vs Trunk — libraries vs applications"
source: https://github.com/rustwasm/wasm-pack
type: article
tags: [wasm-pack, trunk, build-tool, wasm, web]
date: 2026-05-21
quality: 4
confidence: high
agent: 7
summary: "Complementary, not competitors. wasm-pack (v0.15.0, May 2026): targets libraries, builds + produces npm-publishable packages. Trunk (v0.21.14, May 2025): targets applications, HTML-as-entrypoint, dev server with HMR + asset pipeline. Both actively maintained."
---

# wasm-pack vs Trunk

## At a glance

| Tool | Targets | Strength | Status |
|------|---------|----------|--------|
| **wasm-pack** | Rust crates → npm packages | Library distribution | v0.15.0 (May 2026), 7.2k ★ |
| **Trunk** | Rust apps → static sites | App development workflow | v0.21.14 (May 2025), 4.3k ★ |

## wasm-pack

- Produces npm-publishable WASM packages (with `package.json` + JS shims)
- Workflow: `wasm-pack build --target web` → `pkg/` directory ready for `npm publish`
- Best fit: "I have a Rust crate, I want JS users to install it via npm"
- Actively maintained: 27 releases, 1,406 commits, 333 open issues

## Trunk

- HTML-as-entrypoint build tool
- Dev server with hot module reload (HMR)
- Asset pipeline (CSS/SCSS/JS/images)
- HTTP+WS proxy (for backend dev)
- Best fit: "I'm building a Yew/Leptos/Dioxus-web app and want a smooth dev loop"
- Repo recently moved from `thedodd/trunk` to **`trunk-rs/trunk`**

## When to use which

| Use case | Pick |
|----------|------|
| Ship a Rust crate as an npm dep | wasm-pack |
| Build a Rust frontend app | Trunk |
| Embed Rust in an existing Vite/Webpack app | wasm-pack + the JS bundler imports the package |
| Solo Rust web app from scratch | Trunk |

They're not in tension — large projects use both (wasm-pack for libraries pulled into a JS framework; Trunk for fully-Rust frontends).

## Cross-references

- [[rustwasm/wasm-bindgen]]
- [[Yew vs Leptos vs Dioxus-web]]
