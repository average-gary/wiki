---
title: Loro README — features, bindings, algorithms
url: https://github.com/loro-dev/loro
retrieved: 2026-06-02
type: repo
---

The Loro repository README describes Loro as a CRDT library for local-first
and collaborative apps. The README explicitly lists three first-party bindings:
**Rust, JS (via WASM), and Swift**, with additional bindings (Python,
React Native, community C# / Go) via the separate `loro-ffi` repo. Supported
data types include text editing with **Fugue**, a rich-text CRDT, a moveable
tree, a moveable list, and an LWW map; the project also credits adapting the
**Event Graph Walker (Eg-walker)** algorithm to reduce computation and space.
The README does not mention Yjs wire compatibility (and Loro is in fact NOT
Yjs-format compatible), does not list Android/Kotlin support, and does not
publish production users in the README itself. The headline line emphasizes
post-1.0 stability and links to docs, blog, and an inspector debugging tool.
