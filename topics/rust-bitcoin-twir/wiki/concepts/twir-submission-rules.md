---
title: TWiR Submission Rules (Editorial)
type: concept
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: cold
confidence: high
sources:
  - "[[../../raw/articles/2026-06-22-twir-readme-submission-rules|README]]"
  - "[[../../raw/articles/2026-06-22-twir-pr-rejection-pr-8219|PR #8219 rejection]]"
---

# TWiR Submission Rules

Canonical rules from `rust-lang/this-week-in-rust` README, supplemented by observed editor behavior in closed PRs.

## Hard rejections (auto-fail)

1. **Paywalled content** — including Medium members-only.
2. **Email/info-capture gates** before reading.
3. **Bare GitHub repo or crates.io page links** with no narrative or release notes ([[../../raw/articles/2026-06-22-twir-pr-rejection-pr-8219|PR #8219]]: "We do not accept links solely to GitHub repos or to crates.io pages").
4. **Code of Conduct violations** (rants, degrading content).
5. **Duplicates** of recent posts (even with wording changed).
6. **LLM-written without disclosure** (LLM-assisted with disclosure is fine).

## Soft rejections (likely)

- **Title >5 words** — editors will ask for shortening (PR #8219 explicit: "Could you limit it to around 5 words?").
- **Project/Tooling Updates without Rust-specific framing** — needs examples, lessons learned, why.
- **Bare release notes / changelogs** — must include explanation beyond the diff.
- **Multiple submissions per contributor per week** — one is the cap.

## What works

- **How-to intros** and advanced deep dives.
- **Walkthroughs** explaining concepts in different ways than the Rust book / Rustlings / Rust by Example.
- **Tooling updates** when long form or framed as a tutorial.
- **Podcasts, screenshots, videos, slides, meetup recordings/announcements** (Rust-related).
- **Observations and thoughts** on Rust and the Rust community.
- **CFPs** for OSS projects.
- **Job announcements**.

## Submission mechanics

- Drafts live at `draft/YYYY-MM-DD-this-week-in-rust.md` — current draft is `draft/2026-06-24-this-week-in-rust.md` (issue 657, target this for Bitcoin-Rust submissions this week).
- Format: `* [Title of the linked Page](https://example.com/...)`.
- Video/audio: prefix with `[video]` or `[audio]`.
- Submit via PR to `rust-lang/this-week-in-rust` with the file edit.

## See also

- [[../topics/twir-rust-bitcoin-coverage-gap|TWiR Rust-Bitcoin Coverage Gap]]
- [[../topics/submission-playbook|Submission Playbook]]
