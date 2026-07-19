---
title: "Reference: overused words & phrases"
type: reference
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, reference, word-list, phrases]
sources:
  - raw/articles/2026-07-13-berenslab-excess-words-dataset.md
  - raw/papers/2026-07-13-kobak-excess-vocabulary-pubmed.md
  - raw/papers/2026-07-13-juzek-ward-why-delve.md
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
  - raw/articles/2026-07-13-grammarly-common-ai-words.md
---

# Reference: overused words & phrases

Lookup lists for a word-frequency scan. **Reminder:** every entry is a legitimate English word/phrase; the signal is *density and clustering*, never a single hit. See [[../topics/false-positives-and-fairness|false positives & fairness]].

## Tier 1 — highest-signal single words

The rare, high-excess-ratio words (most diagnostic per [[../../raw/papers/2026-07-13-kobak-excess-vocabulary-pubmed|Kobak]] and [[../../raw/papers/2026-07-13-juzek-ward-why-delve|Juzek & Ward]]):

> **delve / delves / delving, underscore(s), showcasing, intricate / intricacies, pivotal, realm, boasts, meticulous(ly), garner(ed), tapestry, testament, leverage / leveraging, harness, seamless(ly), multifaceted, nuanced, comprehensive, robust, foster(ing), elevate, unveil, unlock, groundbreaking, aligns, surpass(es)**

With measured effect sizes: `delves` ≈28×, `meticulous` ≈34.7×, `underscores` ≈10.9×, `showcasing` ≈10.2×, `intricate` ≈11.2×, `commendable` ≈9.8×.

## Tier 2 — the full "style" excess-word bank

The ~300 style words from the [[../../raw/articles/2026-07-13-berenslab-excess-words-dataset|berenslab/chatgpt-excess-words dataset]] (the data behind Kobak et al.). Abbreviated to stems:

accentuate, achieve, acknowledge, adept, adhere, advancement, advancing, advocate, affirm, aid, akin, align, alongside, amid(st), attain, augment, avenue, bolster, broader, burgeoning, capabilities, capitalize, categorize, combat, commendable, compelling, complex, comprehend, comprehensive, comprising, consequently, consolidate, conversely, correlate, craft, crucial, culminate, customize, delineate, delve, demonstrate, dependable, discern, disrupt, distinct, diverse, elevate, elucidate, embrace, emerge, emphasize, empower, emulate, enable, encapsulate, encompass, endeavor, enduring, enhance, ensure, equip, escalate, evolving, exacerbate, exceed, excel, exhibit, expedite, exploration, facilitate, findings, formidable, foster, foundational, furnish, garner, groundbreaking, groundwork, harness, heighten, highlight, hinder, hinge, illuminate, imperative, impressive, incorporate, inherent, innovative, insights, integrate, interconnectedness, interplay, intricate, invaluable, juxtapose, leverage, meticulous, multifaceted, necessitate, notable, notably, noteworthy, nuanced, nuances, optimize, orchestrate, overlook, paving, pinpoint, pioneering, pivotal, poised, pose, potential, precise, predominantly, pressing, promising, pronounced, propel, realm, refine, reframe, remarkable, renowned, resulting, revolutionize, scrutinize, seamless, serve, shape, shed (light), showcase, signify, solidify, spanning, spearhead, streamline, substantial, surge, surmount, surpass, swift, tapestry, testament, thorough, transformative, uncharted, uncover, underexplored, underscore, unlock, unparalleled, unravel, unveil, uphold, utilize, valuable, versatile, warrant, yield.

*(Full inflected list in the [[../../raw/articles/2026-07-13-berenslab-excess-words-dataset|raw dataset ingest]].)*

## Buzzwords / marketing register

revolutionize, innovative, cutting-edge, game-changing, transformative, "seamless integration," "scalable solution," "unlock the potential," "in today's fast-paced world," "in the ever-evolving landscape of."

## Formulaic phrases

- **Editorializing:** "It's important to note," "It's worth noting," "It is essential to understand," "Importantly," "Notably."
- **Significance inflation:** "stands as a testament to," "plays a vital/crucial/pivotal role," "marks a turning point," "leaves an indelible mark," "reflects a broader," "rich cultural heritage," "nestled in the heart of."
- **Transitions:** "That being said," "At its core," "To put it simply," "A key takeaway is," "From a broader perspective," "Moreover," "Furthermore," "Consequently," sentence-initial "Additionally."
- **Vague attribution:** "Industry reports suggest," "Observers have cited," "Experts argue," "Several sources."
- **Antithesis:** "not only X but also Y," "It's not just X, it's Y," "not a mirror but a portal."
- **Hedging:** "generally speaking," "tends to," "arguably," "to some extent," "broadly speaking."

## Chatbot residue (near-deterministic when present)

"I hope this helps," "Certainly!," "Of course!," "You're absolutely right!," "Would you like…," "let me know," "As of my last knowledge update," "here is a."

## Leaked tokens (conclusive when present)

`oaicite`, `oai_citation`, `contentReference`, `:contentReference[oaicite:0]{index=0}`, `turn0search0`, `grok_card`, `attached_file`, trailing `+1`, stray `**` in non-markdown.

## See also

- [[../concepts/lexical-overuse-words|Lexical overuse]] · [[../concepts/formulaic-phrases|Formulaic phrases]] · [[../concepts/markdown-and-formatting-tells|Formatting tells]]
- [[../topics/reviewer-checklist|Reviewer checklist]]
