---
title: "sv2-spec issue #102 — the canonical reference for V2-to-V1 down-to-up"
category: concept
status: active
created: 2026-05-28
updated: 2026-07-27
verified: 2026-07-27
volatility: warm
confidence: high
sources:
  - raw/articles/2026-05-28-path2-sv2-spec-issue-102-proxy-annex.md
  - raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios.md
  - raw/articles/2026-05-28-path5-sjors-bio-recruiting.md
  - raw/repos/2026-07-27-blitzpool-rental-proxy-sv2-to-sv1-translator.md
tags: [sv2-spec, plebhash, jakubtrnka, proxy-annex, reverse-translator-named]
summary: "The reverse translator concept has exactly one named, sourced canonical reference inside the SRI ecosystem: sv2-spec issue #102."
---

# sv2-spec issue #102 — the canonical reference

The reverse translator concept has exactly one named, sourced canonical reference inside the SRI ecosystem: **sv2-spec issue #102**.

## The verbatim quote

From issue #102, opened by `@plebhash` on 2024-10-25:

> "**V2 to V1** down-to-up translation — zero configuration trivial translation layer for **sv2-native miners and legacy sv1 pools**"

This is the only sentence in any SRI canonical document that names the concept. Anyone implementing a reverse translator can cite this issue as the spec-level grounding.

## The four proxy archetypes (from #102 / PR #103)

1. **V1-to-V2 up-to-down** — existing SRI translator-proxy direction.
2. **V2-to-V1 down-to-up** — *the reverse translator*.
3. **V2-to-V2 mining proxy** — SV2 fan-out, no protocol translation.
4. **V2-to-V2 with Job Declaration** — JDC/JDS topology.

## Status (2026-05-28, spec side unchanged as of 2026-07-27)

- Issue #102: **open**.
- Companion PR #103 (the actual annex draft): **WIP / draft**, ~19 months stale, with the author's own self-review note "TODO: review correctness."
- Reviewer `@jakubtrnka` pushed to keep proxy taxonomy in a separate annex rather than the main mining-protocol spec — a soft political signal that core SRI authors view it as adjacent.

## Pairs with Sjors's recruiting

The other open canonical reference is Sjors Provoost's GitHub bio explicitly soliciting "reverse-translator development" ([[../../raw/articles/2026-05-28-path5-sjors-bio-recruiting]]). The spec acknowledges the concept; a contributor recruits for it. Demand inside the SRI ecosystem exists.

## Spec section 10.4.5 (V2→V1)

The SV2 spec has a "Discussion / Deployment Scenarios" section (10.4) including subsection 10.4.5 explicitly titled for V2→V1. The body text is **literally `...`** — left blank ([[../../raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios]]). The architectural shape exists in the spec's table of contents and nowhere else.

## The code-side gap closed on its own (2026-07-27 revision)

This article originally read: "**The work is greenfield from a code perspective.**" That was accurate against the sources surveyed on 2026-05-28 — blank spec section, open issue, stale PR, a contributor recruiting for the work. **It is no longer true.**

`warioishere/blitzpool-rental-proxy` (created 2026-06-27, a month after that research) is a deployed Rust implementation of the SV2-miner → SV1-pool leg, hand-authored in `src/proto/translate.rs` precisely because `stratum_translation` ships only the forward leg. See [[prior-art-blitzpool-rental-proxy]].

The two gaps have now decoupled, and it matters which one an implementer is reasoning about:

| Gap | 2026-05-28 | 2026-07-27 |
|---|---|---|
| **Spec**: §10.4.5 blank, #102 open, #103 stale, no canonical annex | open | **still open, unchanged** |
| **Code**: no working SV2→SV1 translator anywhere | open | **closed** — one AGPL implementation, deployed, single author, unreviewed |

The code-side closure is weak evidence of maturity (0 stars, 0 forks, ~1 month old, "expect rough edges") but strong evidence of feasibility and demand. Nothing about the spec-side situation changed.

## Implications for an implementer

- The work is **no longer greenfield from a code perspective** — read `translate.rs` before writing anything. It is an answer key for byte order, difficulty convention, and version-rolling mask handling.
- The work is on solid ground specification-wise.
- A draft `stratum-translation` PR adding inverse helpers (with reference to issue #102 + Sjors's recruiting) is still the path of least friction into the upstream codebase — and the pitch is now **stronger**, because it can cite a shipped out-of-tree implementation as evidence that the missing helpers forced someone to reimplement them. (AGPL, so citable and studiable, not copyable into MIT/Apache-2.0 SRI.)
- Filling in spec section 10.4.5 — even informally — would be a high-leverage adjacent contribution, and is now a **documentation** exercise rather than a design one: there is a running implementation to describe.

## See also

- [[prior-art-blitzpool-rental-proxy]] — the implementation that falsified the greenfield claim
- [[sv2-features-lost-with-sv1-upstream]] — what the spec acknowledges by leaving 10.4.5 blank
- [[architecture-and-state-machine]] — the implementation shape
- [[../topics/reverse-translator-playbook|the playbook]] — the build path
- [[customer-segments-and-tam.md|Customer segments and honest TAM read]]
- [[sv2-sv1-primitive-mapping.md|SV2 ↔ SV1 primitive mapping (for reverse translation)]]
