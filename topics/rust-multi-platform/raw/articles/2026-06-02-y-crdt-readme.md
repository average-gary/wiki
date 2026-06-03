---
title: y-crdt monorepo README — yrs ecosystem
url: https://github.com/y-crdt/y-crdt
retrieved: 2026-06-02
type: repo
---

The y-crdt monorepo describes itself as Rust libraries oriented around the
**Yjs algorithm and protocol with cross-language and cross-platform support**.
The crucial guarantee: the project "aims to maintain behavior and **binary
protocol compatibility with Yjs**, therefore projects using Yjs/Yrs should be
able to interoperate with each other." This is the line that distinguishes
yrs from Loro. Bindings enumerated: pycrdt (Python), yrb (Ruby), yr (R),
ydotnet (.NET/C#), **yswift (Swift / iOS)**, **ykt (Kotlin / Android/JVM)**.
Core crates: yrs (Rust core), ywasm (WebAssembly/JS), yffi (C FFI). README
sponsors include **NLNET, Ably, AppFlowy** — the most concrete published
production-adjacent signal for the y-crdt project.
