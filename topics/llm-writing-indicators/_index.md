---
title: LLM Writing Indicators
type: topic-index
created: 2026-07-13
updated: 2026-07-13
status: active
summary: Indicators of LLM-generated prose for reviewers and editors — the lexical, phrasal, structural, punctuation, and tonal tells that betray machine authorship, the empirical corpus evidence behind them, how they drift across models and versions, and the limits of both human intuition and automated detectors. The governing lesson across all sources: no single tell is proof; the tells detect statistical typicality, not authorship, and misfire badly on non-native, formal, and neurodivergent human writers. Practical reviewer checklist, false-positive risks, and why reliable detection is fundamentally hard.
sources_count: 26
---

# LLM Writing Indicators

Topic wiki cataloguing the tells of LLM-generated prose and how to review for them responsibly.

## The governing principle

**No single indicator is proof.** The tells detect *statistical typicality*, not authorship — so they systematically misfire on formal, formulaic, non-native, and neurodivergent human writing. Humans guessing by feel score ~50% ([[raw/papers/2026-07-13-jakesch-human-heuristics-flawed|Jakesch et al.]]). The signal is the *cluster* of tells plus verification of substance — never one word, one em dash, or one detector score. Start with the [[wiki/topics/reviewer-checklist|reviewer checklist]].

## Top-level findings

1. **The lexical tell is real and measured.** Two independent large corpora converge on the same word list. [[wiki/topics/empirical-evidence-base|Kobak et al.]] (15.3M PubMed abstracts) found `delves` ×28, `underscores` ×10.9, `showcasing` ×10.2; Liang et al. found `meticulous` ×34.7, `intricate` ×11.2 in ML peer reviews. At least 13.5% of 2024 abstracts were LLM-processed. See [[wiki/concepts/lexical-overuse-words|lexical overuse]].
2. **The tells decay.** The marker words are leaking into human *speech* at 25–50%/year (Max Planck, 740k hours), and vendors train out memed tells (the em-dash "fix," the 2025 sycophancy rollback). A 2026 checklist ≠ a 2023 checklist. See [[wiki/concepts/model-and-version-drift|model & version drift]].
3. **Two mechanisms explain everything.** Next-token averaging produces the *statistical* tells (low perplexity, the vocabulary, em dashes, Unicode); RLHF preference-tuning produces the *register* tells (sycophancy, puffery, formulaic structure). See [[wiki/concepts/why-llms-write-this-way|why LLMs write this way]].
4. **Deterministic tells beat probabilistic ones.** [[wiki/concepts/invisible-unicode-artifacts|Invisible Unicode]] (U+200B, U+FEFF) and [[wiki/concepts/markdown-and-formatting-tells|leaked tokens]] (`oaicite`, `turn0search0`) are near-conclusive *when present* — humans don't type them. Em dashes and "delve" are weak and contested.
5. **The durable tells are structural and content-level.** As words drift, what survives is [[wiki/concepts/vagueness-and-missing-specifics|missing specifics / no original ideas]], [[wiki/concepts/structural-formulas|templated structure]], and flat register — the "AI slop" a humanizer can't fix. See [[wiki/topics/ai-slop-and-structural-tells|AI slop & structural tells]].
6. **Automated detection is unreliable and unfair.** Best-possible detector AUROC → 0.5 as models improve (Sadasivan); paraphrasing collapses DetectGPT 70%→5% (DIPPER); OpenAI shut down its own classifier; detectors flag **61% of non-native essays** and rate the **US Constitution** as "AI." See [[wiki/topics/detection-tools-and-limits|detection tools & limits]] and [[wiki/topics/false-positives-and-fairness|false positives & fairness]].
7. **Verify substance, not just style.** The highest-yield, drift-proof, fairness-safe step is checking whether citations exist and facts are true. A fabricated citation is a finding regardless of authorship. See [[wiki/concepts/citation-and-fact-anomalies|citation & fact anomalies]].

## Sections

- [[wiki/concepts/_index|Concepts]] (15) — individual tells + mechanisms: lexical, phrasal, rhetorical, structural, tonal, punctuation/formatting, citation, perplexity/burstiness, RLHF cause, drift.
- [[wiki/topics/_index|Topics]] (5) — playbooks: reviewer checklist, false positives & fairness, detection tools & limits, AI slop, empirical evidence base.
- [[wiki/reference/_index|Reference]] (3) — overused word/phrase bank, detector comparison, corpus-study citations.

## The tells at a glance (by confidence)

| Confidence | Tells |
|---|---|
| **Near-conclusive when present** | Leaked tool tokens (`oaicite`, `turn0search0`), invisible Unicode, chatbot residue ("As of my last knowledge update") |
| **Strong in a cluster** | Lexical density (delve/underscore/…), puffery/significance inflation, bold-stacked lists, formulaic structure, missing specifics, fabricated citations |
| **Medium (cluster only)** | Rule of three, "not X but Y", sycophantic register, over-signposting |
| **Weak / contested / time-sensitive** | Em dashes, curly quotes, single lexical hits, detector scores |

## Sources

- 26 raw sources ingested 2026-07-13 (13 papers + 13 articles). See [[raw/_index|raw sources index]].
- 23 articles + 4 indexes in [[wiki/_index|wiki article layer]] (compiled 2026-07-13).

## Related hub topics

None directly adjacent — this is a standalone methodology topic. Tangentially relevant to any hub topic where LLM-drafted content is reviewed.
