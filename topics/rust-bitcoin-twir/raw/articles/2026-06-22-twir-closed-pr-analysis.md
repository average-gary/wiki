---
title: "TWiR closed-PR analysis — Bitcoin-Rust submission history"
source: https://github.com/rust-lang/this-week-in-rust/pulls
type: analysis
tags: [twir, pull-requests, submission-history, primary]
ingested: 2026-06-22
verified: 2026-06-22
volatility: warm
credibility: high
twir-fit: meta
agent: gap-closing path D
---

# TWiR Closed-PR Analysis — Bitcoin-Rust Submission History

Searched `rust-lang/this-week-in-rust` PRs for keywords: bitcoin, lightning, ldk, bdk, fedimint, cashu, nostr, stratum, mining, hashpool, rust-bitcoin, bitcoind, miniscript.

## The only match: PR #1273 (May 2020)

- **Title**: "Added a Rust tutorial video link: A Rust & Wasm tutorial on building Bitcoin infrastructure."
- **URL**: https://github.com/rust-lang/this-week-in-rust/pull/1273
- **Author**: `soulofamachine`
- **Closed**: 2020-05-29 (self-closed, not merged)
- **Editor**: nellshamrell — comment: "do you mind adding this link to the draft for next week?"

## Outcome: NOT a rejection

The author resubmitted as **PR #1274**, which `nellshamrell` MERGED on 2020-06-01 with the comment "This is fantastic! Thank you!"

**Notable detail**: The merged PR title was sanitized — "A Rust & Wasm tutorial on building **Bitcoin** infrastructure" → "+ a Rust & Wasm tutorial on **distributed** infra". This is why the published 2020-06-02 issue body grep for "bitcoin" returns zero hits even though Bitcoin-adjacent content was actually merged.

## Searches returning zero results

- bdk, ldk, fedimint, cashu, nostr, stratum, hashpool, bitcoind, miniscript, "lightning network": **0 PRs**
- "lightning" alone: only matched the unrelated event format "lightning talks"
- "mining" alone: matched a 3D-rendering blog post about geological mining data
- rust-bitcoin and bitcoin: only PR #1273

## Verdict: (b) Submitter silence — strongly supported

1. **No editorial rejections exist** in the searched corpus.
2. **No submissions exist at all** for the flagship ecosystem terms.
3. **The one Bitcoin-adjacent submission that did get filed got merged** — editors are receptive when content is offered.
4. **Title sanitization on merge** ("Bitcoin" → "distributed infra") explains the zero-hit body greps despite acceptance.

The TWiR Bitcoin coverage gap across 656 issues is a **supply-side problem**: the rust-bitcoin / Lightning / BDK / LDK / Fedimint / Cashu / Stratum / hashpool communities have essentially never submitted their work to TWiR.

## Implication for thesis confidence

The [[../wiki/theses/coverage-gap-thesis|coverage-gap thesis]] is **upgraded to Strongly Supported / High Confidence**. The previously-flagged caveat ("submission attempts may have been rejected, not visible in archive") is now closed: no such attempts exist.

## Implication for action

A first-time well-formatted PR submitting a Rust-Bitcoin item to issue 657 has high prior probability of being merged. The bottleneck is not editorial; it is "someone needs to file the PR."

## Note on title-sanitization

Editor preference for "distributed infra" over "Bitcoin" framing in the 2020 merge suggests:
- Editors may prefer Rust-feature-first framing.
- "Bitcoin" branding may be perceived as off-topic; "Lightning Network" / "BDK" / "LDK" framing — naming the Rust crate, not the cryptocurrency — may fare better.
- Recommend titles like "LDK 0.2.3 Loupe security release" over "Bitcoin Lightning library security release".
