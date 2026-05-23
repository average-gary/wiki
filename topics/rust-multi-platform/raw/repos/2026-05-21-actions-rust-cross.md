---
title: "houseabsolute/actions-rust-cross — canonical GitHub Actions matrix"
source: https://github.com/houseabsolute/actions-rust-cross
type: repo
tags: [github-actions, cross-compile, ci, release-pipeline]
date: 2026-05-21
quality: 4
confidence: high
agent: 3
summary: "Most-copied GitHub Actions wrapper for Rust cross-builds. Logic: on Linux uses cross for non-x86; on Windows/macOS uses native cargo. force-use-cross flag overrides on Linux."
---

# actions-rust-cross

## Build-tool selection logic

| Host | x86 targets | Other targets | Apple targets |
|------|-------------|---------------|----------------|
| Linux (`ubuntu-*`) | native cargo | `cross` | use `macOS-latest` instead |
| Windows (`windows-*`) | native cargo | native cargo | use `macOS-latest` instead |
| macOS (`macOS-*`) | native cargo | native cargo | native cargo |

`force-use-cross` parameter forces `cross` on Linux even for x86.

## Canonical 6-target matrix

```yaml
jobs:
  release:
    name: Release - ${{ matrix.platform.os-name }}
    strategy:
      matrix:
        platform:
          - os-name: Linux-x86_64
            runs-on: ubuntu-24.04
            target: x86_64-unknown-linux-musl
          - os-name: Linux-aarch64
            runs-on: ubuntu-24.04
            target: aarch64-unknown-linux-musl
          - os-name: Windows-x86_64
            runs-on: windows-latest
            target: x86_64-pc-windows-msvc
          - os-name: Windows-aarch64
            runs-on: windows-latest
            target: aarch64-pc-windows-msvc
          - os-name: macOS-x86_64
            runs-on: macOS-latest
            target: x86_64-apple-darwin
          - os-name: macOS-aarch64
            runs-on: macOS-latest
            target: aarch64-apple-darwin
    runs-on: ${{ matrix.platform.runs-on }}
    steps:
      - uses: actions/checkout@v6
      - uses: houseabsolute/actions-rust-cross@v1
        with:
          command: build
          target: ${{ matrix.platform.target }}
          args: "--locked --release"
          strip: true
```

## The pattern

Don't try to build everything from one host. Let GitHub-hosted runners (`ubuntu-24.04`, `macos-latest`, `windows-latest`) each handle their natural targets, and cross-compile only within the same OS family (e.g., aarch64-linux from x86_64-linux).

This is the **canonical 2025-2026 idiom**, replacing earlier "build everything from Linux + zigbuild + xwin" approaches because GitHub Actions runners are cheap and parallelism is free.

## Cross-references

- [[cross-rs/cross]]
- [[cargo-dist]] — generates this kind of matrix automatically
