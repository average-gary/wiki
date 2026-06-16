---
title: "Bevy Quick Start — Setup (Bevy Book)"
source_url: https://bevy.org/learn/quick-start/getting-started/setup/
source_date: 2026
ingested: 2026-06-15
type: article
author: Bevy Foundation
quality: 5
credibility: high
research_path: technical
tags: [bevy, setup, msrv, dynamic-linking, mold, cranelift]
---

# Bevy Quick Start — Setup

Canonical setup page. Tracks 0.18.1.

## Key findings

- Recommended dep line: `bevy = "0.18.1"` (or `cargo add bevy`).
- MSRV: "the latest stable release" of Rust — no pinned floor; nightly only required for `cranelift` codegen.
- Platform deps:
  - Linux: see `linux_dependencies.md` in repo
  - Windows: MSVC build tools, "Desktop development with C++"
  - macOS: `xcode-select --install`
- **`dynamic_linking`** feature (`cargo add bevy -F dynamic_linking`) — links Bevy as a dylib for fast iterative builds; not for shipping; on Windows requires perf optimizations enabled to avoid linker errors.
- Fast-compile recipe: alternative linker (`lld` via `clang` + `-fuse-ld=lld`), or **mold** (up to 5× faster than lld, Linux-primary), or **cranelift** codegen on nightly (~30% faster compile than LLVM).
- Stated compile-times target with fast-compile config: 0.8–3.0s iterative.
