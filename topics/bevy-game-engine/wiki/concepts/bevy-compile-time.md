---
title: "Bevy compile time"
type: concept
created: 2026-06-15
updated: 2026-06-15
confidence: high
tags: [bevy, compile-time, mold, lld, cranelift, dynamic-linking]
---

# Bevy compile time

Productivity is one of [[bevy-overview.md|Bevy's six pillars]] — the [[bevy-introducing.md|2020 launch post]] declared a hard target: 0–1s iterative as the goal, 10+s as "unusable."

## Target: 0.8–3.0s iterative

Achievable with the full fast-compile recipe ([[bevy-quick-start-setup.md|setup docs]]):

1. **Alternative linker** — default Rust linker is slow:
   - `lld` via `clang` (`-fuse-ld=lld`) — 3-5x faster than default
   - **`mold`** (Linux-primary) — up to 5x faster than `lld`, the recommended option on Linux
2. **`cranelift` codegen** (nightly Rust only) — ~30% faster compile than LLVM
3. **`dynamic_linking` feature** — links Bevy as a dylib; recompile your code without re-linking the engine

## Without the recipe

Plain `cargo run` on a stock toolchain takes substantially longer — long enough that [[biggo-growing-pains.md|community feedback]] cites it as a productivity problem vs. Godot for prototyping/jams.

## Reality vs target

The 0.8–3.0s target is achievable but requires per-developer setup. The default experience falls behind Godot for fast iteration. Bevy's modularity ([[bevy-cargo-features.md|cargo features]]) helps: a 2D-only project with `default-features = false` and `features = ["2d"]` compiles less than a full default build.

## See also

- [[bevy-overview.md|Bevy overview]]
- [[bevy-cargo-features.md|Cargo features]]
- [[bevy-criticisms.md|Criticisms]]
