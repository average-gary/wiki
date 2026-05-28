---
title: "Bibledit Cloud (translation workbench)"
source_url: "https://github.com/bibledit/cloud"
type: repo
path: oss
date_ingested: 2026-05-27
date_published: 2026-03-21
tags: [oss, bible-software, bibledit, translation, usfm, paratext-alternative, gpl]
quality: 4
confidence: high
summary: "Bibledit is the leading OSS Bible *translation* workbench — USFM editor, Git versioning, collaboration. Active in 2026 (release 2026-03-21). Adjacent to but not overlapping with study-Bible apps."
---

# Bibledit Cloud (translation workbench)

## Key findings
- Bibledit is OSS scripture **translation** software — the open analogue to SIL/UBS Paratext (which is widely used but proprietary and gated to vetted translators).
- Cloud variant runs as a server-based, browser-accessible app. Desktop variants exist too.
- Codebase: C (78%), C++ (15%), JS, HTML. Surprisingly low-level for a web app — likely for performance and embeddability.
- Features: USFM editor, rich text editing, **Git-based version control** for translation drafts, multi-language UI, import/export across formats, "consultation" workflow (translation review).
- License: **GPL-3.0**.
- Active: latest release **2026-03-21**, 21 numbered releases. Solid cadence.

## Notable quotes / specifics
> "Source code for Bibledit core library and Cloud binary."

> Latest release: 2026-03-21. C/C++ codebase with web frontend.

## Source notes
- **Maintainer**: Bibledit GitHub org, small but consistent contributor base.
- **Last active**: 2026, healthy.
- **License**: GPL-3.0.
- **What it does well**:
  - Real Git versioning for translation drafts — unique strength.
  - Self-hostable, privacy-respecting alternative to Paratext.
  - Handles USFM properly, which is the dominant translation format.
- **Gaps**:
  - Targets translators, not Bible *students* — wrong shape for a Logos competitor's primary user.
  - UX is functional, not polished.
  - Discoverability and onboarding are weak (typical for a niche OSS tool).
- **Relevance to OSS Logos suite**: Bibledit is *adjacent*, not a competitor. A Logos-equivalent suite could integrate with Bibledit (read its USFM output, surface translation deltas) without reimplementing translation tooling. That kind of OSS-to-OSS handshake is itself a differentiator vs. closed Logos.
