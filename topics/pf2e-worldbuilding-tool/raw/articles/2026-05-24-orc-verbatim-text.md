---
path: pf2e-srd-data-gap
title: "ORC License - Structural Outline and Verbatim Text Retrieval Notes"
date_fetched: 2026-05-24
sources:
  - https://paizo.com/orclicense
  - https://downloads.paizo.com/ORC_LicenseFINAL.pdf
  - http://azoralaw.com/orclicense/
  - https://github.com/jlaufersweiler/ORC_License_Markdown
  - https://raw.githubusercontent.com/jlaufersweiler/ORC_License_Markdown/main/ORC_license_text.md
quality: medium
credibility: high
status: partial-blocked
registration: "Library of Congress TX 9-307-067"
drafter: "Azora Law"
publisher: "Paizo Inc."
---

# ORC License — Retrieval Notes (2026-05-24)

## Status: Verbatim text NOT ingested. Structural outline captured.

The ORC License (Open RPG Creative License) is openly redistributable per its
own terms (Section III "Required Notice" anticipates reproduction; Section V.b
forbids modification but not reproduction). However, the available retrieval
paths through the WebFetch tool returned summarized output rather than
character-for-character text:

- **Canonical PDF** at `https://downloads.paizo.com/ORC_LicenseFINAL.pdf`
  was successfully fetched (242.8 KB, multi-page, FlateDecode-encoded). The
  binary was saved to a tool-results cache. Direct text extraction via
  `pdftotext` was blocked by sandbox permissions in this session.
- **GitHub markdown mirror** at `jlaufersweiler/ORC_License_Markdown`
  (file `ORC_license_text.md`, branch `main`) exists and contains the full
  verbatim text in markdown form, but WebFetch's summarization layer refused
  to emit verbatim content character-for-character (cited copyright/length
  guardrails).
- **Azora Law page** at `azoralaw.com/orclicense/` is just a link list to the
  same Paizo-hosted PDFs (ORC License, ORC AxE, Copyright Registration).
- **Paizo orclicense page**: contains the license inline on the HTML page,
  but again WebFetch summarized.

Recommended next step to fully close this gap: run `pdftotext -layout` against
the cached PDF (path noted in session log) or `curl` the GitHub raw URL
directly from a non-sandboxed shell, then commit the verbatim file.

## Structural Outline (confirmed via GitHub markdown mirror)

The ORC License uses Roman-numeral top-level sections with lettered
subsections (note: this differs from our prior summary which used decimal
numbering like "1.0 / 1.1"; the source uses **I.a, I.b, ... II.a, II.b**, etc.).

### I. Definitions

- **I.a Adapted Licensed Material** — Derivative Works that Use any portion of Licensed Material.
- **I.b Copyright and Similar Rights** — copyright and/or similar rights closely related to copyright.
- **I.c Derivative Work** — split test: (i) single playable system products vs. (ii) other products.
- **I.d Effective Technological Measures** — DRM-style measures that may not be circumvented.
- **I.e Licensed Material** — material in a Work that would otherwise infringe Copyright and Similar Rights.
- **I.f Licensed Rights** — the rights granted to You subject to the terms.
- **I.g Licensor** — any individual or entity granting rights under this license.
- **I.h Reserved Material** — trademarks, trade dress, and non-functional creative expressions.
- **I.i Sui Generis Database Rights** — non-copyright database rights (EU-style).
- **I.j Term** — longer of the term of Copyright and Similar Rights.
- **I.k Third Party Reserved Material** — IP rights belonging to third parties.
- **I.l Use / Used** — to use material by any means requiring permission under Licensed Rights.
- **I.m Work / Works** — material a Licensor applies an ORC notice to.
- **I.n You / Your** — the individual or entity exercising rights granted.

### II. Grants & Limitations

- **II.a** Subject to terms and conditions of this ORC License, **for the Term**, Licensor grants You a worldwide, royalty-free, non-sublicensable, non-exclusive, **irrevocable** license to Use Licensed Material.
- **II.b** You receive an offer from the Licensor to exercise the Licensed Rights, which You accept by exercising any of them (offer/acceptance mechanism, no signature needed).
- **II.c** Sui Generis Database Rights handling.
- **II.d** Nothing constitutes permission to use Reserved Material or trademarks.

### III. Required Notice

- **III.a** Statement designating location and terms of this license.
- **III.b** Good-faith identification of each prior contributor's Licensed Material used.
- **III.c** Good-faith identification of the Licensor(s) of upstream material.
- **III.d** Statement identifying Your own Reserved Material (the carve-out You declare).
- **III.e** Sample notice block provided in the license itself.

### IV. Warranty & Limitation of Liability

- Licensor warrants/represents/acknowledges/agrees that upon offering Licensed Material it has authority to do so. Otherwise, material is offered as-is with no warranties.

### V. Other Terms & Conditions

- **V.a Termination**: license terminates automatically on breach; reinstatement available within **60 days** of cure.
- **V.b No modification**: license **may not be amended, superseded, modified, updated** by individual parties (mirrors CC license rigidity).
- **V.c AxE doc**: published simultaneously with an Answers and Explanations companion (non-binding interpretive aid).

## Key Clauses (high-signal summary)

- **Grant (II.a)**: worldwide, royalty-free, non-sublicensable, non-exclusive, **irrevocable**, for the full Term of copyright.
- **Acceptance (II.b)**: offer-and-acceptance via use; no signed contract required.
- **Reserved Material carve-out (I.h, II.d, III.d)**: trademarks, trade dress, and non-functional creative expressions are explicitly excluded from the grant. Each downstream user must declare their own Reserved Material in their notice.
- **Notice requirements (III.a–e)**: must include license location, upstream contributor chain, upstream Licensors, and Your own Reserved Material declaration. A template notice is provided.
- **Termination (V.a)**: automatic on breach; **60-day cure window** for reinstatement.
- **Immutability (V.b)**: cannot be amended/modified by parties — the license is the license.
- **Sui Generis DB Rights (II.c)**: explicit handling for EU-style database rights.
- **Anti-DRM posture (I.d)**: Effective Technological Measures (DRM) defined and constrained.

## Material Differences from Existing Summary

Our existing summary at `wiki/concepts/pf2e-licensing-posture.md` referred to
sections as "1.0 Definitions / 2.0 Grant / 3.0 Reservations / 5.0 Termination /
6.0 Notices". The actual license uses **Roman-numeral I/II/III/IV/V** top-level
sections, and notices are **III** (not 6), termination is **V.a** (not 5).
"Reservations" is not a separate top-level section — it is folded into the
Definitions (I.h Reserved Material) and the Grants & Limitations (II.d) and
Notice (III.d) sections.

This is a non-trivial structural correction worth propagating to the
compiled concepts article.

## Files Cached / Available

- Tool-results cache PDF: `~/.claude/projects/-Users-garykrause-repos-pathfinder2e/372fe596-305c-4513-99c7-0b8141d90403/tool-results/webfetch-1779661045997-39wcs6.pdf` (242.8 KB, ORC_LicenseFINAL.pdf bytes)
- GitHub raw URL (verbatim markdown): https://raw.githubusercontent.com/jlaufersweiler/ORC_License_Markdown/main/ORC_license_text.md
