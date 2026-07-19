---
title: Rust-Bitcoin TWiR Submission Playbook
type: topic-synthesis
created: 2026-06-22
updated: 2026-06-22
verified: 2026-06-22
volatility: hot
confidence: high
sources:
  - "[[../../raw/articles/2026-06-22-twir-readme-submission-rules|TWiR README]]"
  - "[[../../raw/articles/2026-06-22-twir-pr-rejection-pr-8219|PR #8219]]"
  - "[[../../raw/data/2026-06-22-twir-issue-cadence-stats|TWiR cadence]]"
---

# Rust-Bitcoin TWiR Submission Playbook

The actionable, step-by-step guide for landing Rust-Bitcoin content in TWiR. Targets `draft/2026-06-24-this-week-in-rust.md` (issue 657) but generalizes.

## Step 1: Pick the right item

| Want to land | Best section | Item profile |
|---|---|---|
| A specific crate release | Project/Tooling Updates | Must wrap the release in a blog post or annotated changelog. Bare GitHub Release link rejected. |
| A milestone version (1.0.0, etc.) | Crate of the Week | Single per issue; competitive. |
| A case study / architecture story | Observations/Thoughts | Named author, narrative arc, ~1000+ words wins. |
| A tutorial | Rust Walkthroughs | Step-by-step pedagogy, code examples, beginner-friendly. |
| Formal verification / algorithmic | Research | Rare slot, high signal — Kani / Miri / academic work fits. |
| Conference CFP | CFP - Events | bitcoin++ editions are clean fits — section is rarely populated. |
| Job listing | Jobs | Spiral, Lexe, Lightspark, Foundation, Block. |
| Specific BIP/feature deep-dive | Observations/Thoughts | Same as case study. |

## Step 2: Verify the item passes auto-rejection rules

Run through this checklist before opening a PR:

- [ ] **Public URL** — no paywall, no email gate, no Medium members-only.
- [ ] **Not a bare repo / crate link** — must point to a blog post, release notes with explanation, deep-dive article, conference talk recording, etc.
- [ ] **Title ≤ 5 words** (editors flag longer ones).
- [ ] **Rust-specific framing** — for Project/Tooling Updates, the content must teach a Rust reader something about Rust.
- [ ] **LLM disclosure** if applicable.
- [ ] **No CoC violations** (no rants, no maximalist tone).

## Step 3: Find the draft

```bash
# In your fork of rust-lang/this-week-in-rust:
ls draft/
# Edit the most recent dated file
$EDITOR draft/2026-06-24-this-week-in-rust.md
```

Format inside the right section:
```markdown
### Project/Tooling Updates

* [bitcoin_hashes 1.0.0 release](https://github.com/rust-bitcoin/rust-bitcoin/blob/master/hashes/CHANGELOG.md)
```

For video/audio:
```markdown
* [video] [Rita Anene — RBF in LDK Node](https://...)
* [audio] [Podcast on rust-bitcoin Kani proofs](https://...)
```

## Step 4: Open PR

- Fork `rust-lang/this-week-in-rust` (the local clone at `/Users/garykrause/repos/this-week-in-rust` is a clone, not a fork — fork first).
- Branch: `bitcoin-rust-issue-657-add-X` style.
- PR title: short and direct: "Add LDK 0.2.3 to Project/Tooling Updates" or similar.
- PR body: brief context — why this fits TWiR, what section, anything special (LLM disclosure, etc.).

## Step 5: Respond to editor feedback

Common editor comments and how to handle:

| Comment | Fix |
|---|---|
| "Title too long, ~5 words please" | Shorten in the markdown link text. |
| "Bare crate.io / GitHub link" | Find a blog post or write one. |
| "Wrong section" | Move the line to the right section. |
| "Duplicate from issue N" | Either remove or reframe with new angle. |
| "Need Rust-specific content" | Add explanation; or downgrade to a different section (CFP/Misc). |

## Submission slate for issue 657 (target: `draft/2026-06-24-this-week-in-rust.md`)

### Editor framing note (gap-closing finding)

The single Bitcoin-titled PR in TWiR's 13-year history (#1273 → #1274, May 2020) was merged with the title sanitized "Bitcoin" → "distributed infra". Implication for current submissions:

- **Lead with the Rust crate name**, not "Bitcoin"
- "LDK 0.2.3 — security release" ✅
- "Bitcoin Lightning library security release" ❌
- "bitcoin_hashes 1.0.0 — first stable major" ✅ (the crate name happens to contain "bitcoin"; that's fine because it IS the crate identifier)
- "Foundation KeyOS — Rust hardware-wallet OS" ✅
- "Foundation Bitcoin signing device firmware" ❌

Closed-PR analysis ([[../../raw/articles/2026-06-22-twir-closed-pr-analysis|details]]) shows zero rejections of Bitcoin-keyword submissions; the gap is purely supply-side. **Probability of merge for a well-formatted Bitcoin-Rust PR is very high.**

### Tier 1 — submit now (this issue)

1. **`bitcoin_hashes 1.0.0`** ([[../../raw/repos/2026-06-19-rust-bitcoin-units-0-5-0|details]])
   - Section: **Crate of the Week** (or Project/Tooling Updates)
   - Title: "bitcoin_hashes 1.0.0 — first stable major"
   - Wrapper: link to the rust-bitcoin/rust-bitcoin/hashes/CHANGELOG.md or a release-note PR description.

2. **LDK 0.2.3 / 0.1.10 Loupe security release** ([[../../raw/articles/2026-06-18-ldk-v0-2-3-loupe-release|details]])
   - Section: **Project/Tooling Updates**
   - Title: "LDK 0.2.3 / 0.1.10 — Project Loupe audit fix"
   - Wrapper: link to Spiral / lightningdevkit.org blog if a write-up exists, else GitHub Releases page (the audit context makes it substantive).

3. **Foundation KeyOS v1.2.1** ([[../../raw/repos/2026-06-18-foundation-keyos-v1-2-1|details]])
   - Section: **Project/Tooling Updates**
   - Title: "Foundation KeyOS v1.2.1 — Rust hardware-wallet OS"
   - Wrapper: link to a Foundation Devices blog post or the Slint blog post on Passport Prime. Passport Prime hardware-wallet UI is a Slint flagship — possible Slint cross-promotion.

4. **Lexe + LDK in SGX enclaves** ([[../../raw/articles/2026-06-10-lexe-ldk-sgx-enclaves|details]])
   - Section: **Observations/Thoughts**
   - Title: "Lexe runs LDK in SGX enclaves"
   - Direct link to the LDK blog post (canonical source, named author, no paywall).

5. **rust-bitcoin Kani PRs** ([[../../raw/repos/2026-04-rust-bitcoin-kani-pr-6393|details]])
   - Section: **Research**
   - Title: "Kani-verified consensus encoding in rust-bitcoin"
   - Wrapper: link to PR #6393 description or write a short blog post summarizing PRs #5579, #5955, #6393, #6243.

6. **bitcoin++ Toronto / Berlin / Seoul** ([[../../raw/articles/2026-06-btcplusplus-2026-schedule|details]])
   - Section: **CFP - Events**
   - Title: "bitcoin++ Toronto 2026 (Consensus edition)"
   - Wrapper: link to btcplusplus.dev/conf/toronto. If CFP not yet open, file under Upcoming Events instead.

### Tier 2 — submit subsequent issues (~weekly cadence)

- **CDK 0.17.1 release** ([[../../raw/repos/2026-06-16-cdk-v0-17-1|details]]) — Project/Tooling Updates.
- **P2Poolv2 v0.12.0** ([[../../raw/repos/2026-06-12-p2poolv2-v0-12-0|details]]) — Project/Tooling Updates / COTW candidate.
- **Fedimint H1 2025 review** ([[../../raw/articles/2025-06-30-fedimint-h1-2025-review|details]]) — Project/Tooling Updates (back-fill check first).
- **rust-nostr v0.45.0** when it ships — Project/Tooling Updates / COTW.
- **rust-dlc v0.8.0** when shipped — Project/Tooling Updates.
- **BDK 2026 Q2 update** when published.

### Tier 3 — Observations/Thoughts content to write yourself

These don't exist yet but synthesize from the data:

- **"The Rust-Bitcoin coverage gap in TWiR"** — the meta piece based on [[twir-rust-bitcoin-coverage-gap|coverage gap]].
- **"Rust on Bitcoin in 2026: ecosystem-by-the-numbers"** — based on [[../../raw/data/2026-06-22-crates-io-bitcoin-stack|crates.io]] + [[../../raw/data/2026-06-22-github-bitcoin-rust-repo-activity|GitHub activity]].
- **"Bitcoin's quiet majority in Rust"** — based on the [[../../raw/data/2025-02-13-state-of-rust-2024|State of Rust 2024]] gap.
- **"LDK's trait-based design philosophy"** — based on [[../../raw/articles/2026-06-10-lexe-ldk-sgx-enclaves|Lexe]] + Pathfinding + LDK README.

## Coordination — one-per-week constraint

If pushing all 6 Tier 1 items in issue 657:
- One submitter is rate-limited to one item.
- Need ~6 distinct contributors OR spread across issues 657-660.
- Recommended: lead with **bitcoin_hashes 1.0.0 (COTW)** + **LDK Loupe (Project/Tooling)** + **bitcoin++ Toronto (CFP-Events)** in 657 (different sections, low risk of collision); spread the rest across 658-660.

## See also

- [[twir-rust-bitcoin-coverage-gap|TWiR Coverage Gap]]
- [[ecosystem-state-2026|Rust Bitcoin Ecosystem State 2026]]
- [[../concepts/twir-submission-rules|Submission Rules]]
- [[../concepts/twir-sections|Sections Map]]
