---
title: "LDK v0.2.3 / v0.1.10 — Through the Loupe / Loupe de Loupe"
source: https://github.com/lightningdevkit/rust-lightning/tags
type: release
tags: [ldk, rust-lightning, security, project-loupe, anchor-reserves]
ingested: 2026-06-22
date: 2026-06-18
verified: 2026-06-22
volatility: hot
credibility: high
twir-fit: yes-strong
twir-section: Project/Tooling Updates
agent: news
---

# LDK v0.2.3 / v0.1.10 — "Through the Loupe" / "Loupe de Loupe"

Concurrent v0.2.x and v0.1.x point releases, 2026-06-18 (4 days before today).

## Release framing
- Addresses **several underestimates of anchor reserves** identified by **Project Loupe** (security audit).
- Both release lines shipped together for backports — security-flavored release.
- v0.2.x line started Dec 2, 2025 ("Natively Asynchronous Splicing").
- v0.2.2 (Feb 2026) brought async splicing to production.

## TWiR fit
- **Section**: Project/Tooling Updates.
- **Caveat**: TWiR rejects bare GitHub release links — but a release with security context and named audit (Project Loupe) is a substantive entry, not a bare changelog. Pair with the LDK blog if a write-up exists.
- **Submitter framing**: "LDK 0.2.3/0.1.10 — Project Loupe security release fixing anchor-reserve underestimates" (5-7 words possible for title).

## Risk
- If editors require an accompanying blog post, the GitHub Releases page text (which describes the audit context) may suffice; otherwise wait for a Spiral / LDK blog post.
