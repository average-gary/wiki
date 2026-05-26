---
title: "process-compose — non-containerized multi-process orchestrator"
source_url: https://github.com/F1bonacc1/process-compose
type: tool
ingested: 2026-05-26
quality: 4
confidence: high
tags: [test-harness, dev-environment, process-compose, nix, just-dev]
---

# `process-compose` — for the `just dev` developer loop

YAML-driven docker-compose-alike for **non-containerized** processes. Go single-binary. Used by Fedimint's `devimint`-adjacent dev flows.

## Features

- Liveness / readiness probes
- Dependency ordering
- Per-process log aggregation with caching
- TUI + REST API
- First-class Nix integration

## Why it's the wrong fit for `cargo test`

- It's a YAML driver, not a Rust library — you'd shell out to it from tests.
- Adds a hard dep (the Go binary).
- Doesn't compose with port-allocation / drop-cleanup the way `corepc-node` does.

## Why it might be the right fit for `just dev`

- Hot-reload friendly when iterating on a single service.
- TUI is great for debugging multi-process behavior visually.
- Reuses the SAME binaries that `cargo test` picks up via env vars (`BITCOIND_EXE`, `P2POOLV2_EXE`, `SV2_P2POOL_EXE`).
- No hermetic-test concerns to worry about.

## Recommendation for sv2-p2pool

Use **`corepc-node`-style Rust harness for `cargo test`** (hermetic, fast, parallelizable) **+ `process-compose` for `just dev`** (visual debugging, hot-reload).

The two share binary-discovery via env vars; no double-maintenance.

## Skip if

You don't have a "manual demo / human-in-the-loop debugging" use case. For pure CI testing, `corepc-node` alone is enough.
