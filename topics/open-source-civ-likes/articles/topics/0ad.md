---
title: 0 A.D.
type: topic
created: 2026-06-18
updated: 2026-06-18
confidence: high
sources:
  - raw/repos/2026-06-18-0ad-pyrogenesis.md
  - raw/articles/2026-06-18-wikipedia-0ad.md
  - raw/articles/2026-06-18-play0ad-release-news.md
  - raw/articles/2026-06-18-0ad-still-in-development-thread.md
  - raw/articles/2026-06-18-0ad-user-reviews-sourceforge.md
  - raw/articles/2026-06-18-0ad-self-hosted-lobby.md
---

# 0 A.D.

Real-time strategy of ancient warfare (500 BC – 1 BC). **Civ-adjacent** —
4X-lite (territory, economy, civilizations) but no Civ-style tech-tree
depth. Maintained by [Wildfire Games](https://wildfiregames.com/), the
volunteer team behind the Pyrogenesis engine.

This wiki includes 0 A.D. because Pyrogenesis is the **most mature OSS
engine** in the civ-like neighborhood, and the project's 16-year alpha
cycle is the canonical case study in
[OSS 4X development pace](../concepts/oss-4x-development-pace.md).

## Pyrogenesis stack

- **C++ 63.7% + C 24%** core
- **JavaScript 6.1%, Lua 2.5%** scripting layers — hybrid C++/JS
  architecture for sim+gameplay
- Multi-license repo (LICENSE.txt mixed: MIT, GPL-2.0, LGPL-2.1) reflecting
  third-party dependencies

## Provenance — the Gitea migration

- GitHub repo **archived September 2024**
- Primary now at **https://gitea.wildfiregames.com**

Future automated tooling (gh CLI, dependabot, etc.) needs to target Gitea,
not the archived GitHub mirror. This is itself a notable governance
datapoint — large OSS projects moving off GitHub.

## Project timeline (the 16-year alpha)

- **2001**: development started
- **2010**: first public alpha
- **2010–2026**: ~**16 years in alpha**
- **2026-02-18**: **Release 28 "Boiorix"** — the **first non-alpha
  release**

The 16-year alpha is the most-cited critique of OSS 4X dev pace — but
the project *did* eventually deliver, which is itself worth flagging.

### Recent releases

| Version | Date       | Notes                                                         |
| ------- | ---------- | ------------------------------------------------------------- |
| Alpha 27 "Agni" | 2025-01-30 | Final alpha. Named for the Hindu fire god.            |
| Patch 27.1      | 2025-07-17 | Perf, crash, multiplayer-stability fixes.             |
| Release 28 "Boiorix" | 2026-02-18 | **First non-alpha.** German/Cimbri faction (semi-nomadic, siege units), gendered civilian models, direct Freetype rendering (East Asian + Hi-DPI), SpiderMonkey 128 (drops Win 7/8.1 + macOS <10.15), **first 64-bit Windows build**, **first official Linux AppImage**. |

Developer framing for Release 28:
> *"our development process has matured, our releases are more frequent,
> and our commitment to quality has never been higher."*

## Funding constraint

The **2013 Indiegogo** campaign aimed for **$160,000**, raised only
**$33,251** — insufficient to hire substantial paid help. The project
remained dependent on volunteer churn for the next decade-plus. This is
the canonical financial constraint behind OSS 4X dev pace — see
[OSS 4X development pace](../concepts/oss-4x-development-pace.md).

## "Is 0 A.D. still in development?" — community perception

A 2020 forum thread captures the community's recurring dead-or-alive
concern. Insider **Wowgetoffyourcellphone** undercut the project's
**"62% complete" milestone metric** as *"largely arbitrary for years"* —
i.e. devs themselves admit progress tracking was theatre. Long inter-
release gaps spawn "is it dead?" threads that the team answers with
commit-count rebuttals (1547 commits in 14 months).

The 2026-02-18 Release 28 retrospectively answers the question — but it
took ~6 years from that 2020 thread.

## User-grade complaints (SourceForge reviews)

- **Performance**: *"the high demand this game puts on the hardware makes
  it completely useless - unplayable"* — common complaint despite the
  pre-2010-era visual style.
- **AI rushes are unfair** for new players.
- **UI overhead**: more time on management than warfare.
- **Mac compatibility broken** in some configurations.
- **Missing tutorials** repeatedly cited.

These persisted across many releases.

## Self-hosted lobby — three components

For private leagues, leagues, or research labs:

1. **ejabberd** — XMPP server for auth/chat
2. **Lobby bots**: `XpartaMuPP` (game hosting) + `EcheLOn` (rating)
3. **SQLite** — ratings/stats

Network: UDP port 3478 plus STUN.

Client-side `default.cfg`:
```
server = "your-server-address"
tls    = false
room   = "arena"
```

Critical gotchas:
- The MUC room must be **pre-created** and **`anonymous: false`** —
  otherwise bots cannot track players.
- **ACL syntax for bot admin must be multi-line allow blocks**, not
  comma-separated.

References: github.com/0ad/lobby-bots, github.com/0ad/lobby-infrastructure
(Ansible playbooks).

## See Also

- [Open Source Civ-Like Games — Landscape](landscape.md)
- [OSS 4X development pace](../concepts/oss-4x-development-pace.md)
- [openage](#) — same lineage of "we rewrote the sim" engines
