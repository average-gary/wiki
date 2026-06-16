---
title: "When will Bevy be Production Ready? (GitHub Discussion #21911)"
source_url: https://github.com/bevyengine/bevy/discussions/21911
source_date: 2025-11
ingested: 2026-06-15
type: article
author: Bevy maintainers and users
quality: 5
credibility: high
research_path: contrarian
tags: [bevy, production, stability, lts, breaking-changes]
---

# Bevy Discussion #21911 — production readiness

Direct quotes from a Bevy maintainer about API stability.

## Key findings

- **NthTensor (maintainer)**: API will probably never stabilize — "game engines don't really do that."
- **Magnitus-** (user): "major breaking changes every ~3 months can be a killer" for hobbyists with limited time.
- Documentation gap: even existing features like scene persistence leave users "on my own to figure out how to persist and load a scene."
- Missing infrastructure: no paid maintainer cohort to backport bug fixes to deprecated versions; community PRs against old branches don't merge upstream → **no stable LTS branch exists**.
- Runtime stability at v0.15.3 reported as "pretty solid"; bugs hit are usually user-error, not engine.
- NthTensor concedes Bevy has been "used in production since v0.6," so "production ready" depends on project requirements rather than any official line.
