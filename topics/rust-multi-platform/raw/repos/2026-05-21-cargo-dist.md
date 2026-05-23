---
title: "axodotdev/cargo-dist (now `dist`) — release pipeline orchestrator"
source: https://github.com/axodotdev/cargo-dist
type: repo
tags: [release, packaging, ci, github-actions, installers]
date: 2026-05-21
quality: 5
confidence: high
agent: 4
summary: "Now branded `dist` (rebranding only). v0.31.0 (Feb 2026), 272 releases, 2k stars. Generates GitHub Actions workflow + tarballs + 5 installer types: shell, powershell, npm, homebrew, msi. v0.31 added 'simple' static-file hosting."
---

# cargo-dist (now `dist`)

## Naming

- Project rebranded from `cargo-dist` to `dist`
- Same project, same maintainer (axodotdev), same repo
- v0.31.0 released 2026-02-23

## What it does

Orchestrates the GitHub Actions pipeline that produces a Rust release. Picks "good build flags for shippable binaries", generates manifests, creates per-platform tarballs, generates installers, publishes to GitHub Releases.

## Pipeline phases

> "planning, building, hosting, publishing, and announcing releases"

## Hosting flexibility (v0.31+)

```toml
hosting = ["github", "simple"]
simple-download-url = "https://static.myapp.com/{tag}"
```

GitHub Releases as primary; simple static hosting as mirror.

## Recent (v0.30.x – v0.31.x)

- macOS codesigning configuration fixes
- Updated default macOS runners
- v0.30.4 (Feb 2026): CVE security updates
- No major architectural overhauls — incremental feature expansion

## Active maintenance

- 272 releases (incremental)
- 2k stars, 145 forks
- Healthy

## Cross-references

- [[cargo-dist installer types]]
- [[volks73/cargo-wix]] — used transitively for MSI
- [[Microsoft MSIX Trusted Signing]]
