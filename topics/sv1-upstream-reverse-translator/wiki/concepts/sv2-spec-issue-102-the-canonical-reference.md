---
title: "sv2-spec issue #102 — the canonical reference for V2-to-V1 down-to-up"
type: concept
status: active
created: 2026-05-28
updated: 2026-05-28
confidence: high
tags: [sv2-spec, plebhash, jakubtrnka, proxy-annex, reverse-translator-named]
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

## Status (2026-05-28)

- Issue #102: **open**.
- Companion PR #103 (the actual annex draft): **WIP / draft**, ~19 months stale, with the author's own self-review note "TODO: review correctness."
- Reviewer `@jakubtrnka` pushed to keep proxy taxonomy in a separate annex rather than the main mining-protocol spec — a soft political signal that core SRI authors view it as adjacent.

## Pairs with Sjors's recruiting

The other open canonical reference is Sjors Provoost's GitHub bio explicitly soliciting "reverse-translator development" ([[../../raw/articles/2026-05-28-path5-sjors-bio-recruiting]]). The spec acknowledges the concept; a contributor recruits for it. Demand inside the SRI ecosystem exists.

## Spec section 10.4.5 (V2→V1)

The SV2 spec has a "Discussion / Deployment Scenarios" section (10.4) including subsection 10.4.5 explicitly titled for V2→V1. The body text is **literally `...`** — left blank ([[../../raw/papers/2026-05-28-path3-sv2-spec-discussion-deployment-scenarios]]). The architectural shape exists in the spec's table of contents and nowhere else.

## Implications for an implementer

- The work is greenfield from a code perspective.
- The work is on solid ground specification-wise.
- A draft `stratum-translation` PR adding inverse helpers (with reference to issue #102 + Sjors's recruiting) is the path of least friction into the upstream codebase.
- Filling in spec section 10.4.5 — even informally — would be a high-leverage adjacent contribution.

## See also

- [[sv2-features-lost-with-sv1-upstream]] — what the spec acknowledges by leaving 10.4.5 blank
- [[architecture-and-state-machine]] — the implementation shape
- [[../topics/reverse-translator-playbook|the playbook]] — the build path
