---
title: "False-positive harm: Turnitin's real error rate, named student cases, and the US Constitution flagged as AI"
source: https://www.insidehighered.com/news/quick-takes/2023/06/01/turnitins-ai-detector-higher-expected-false-positives
authors: Inside Higher Ed; Rolling Stone; Simon Willison / Alex Hern (Guardian); WeeklyGeek/RealClearScience; commentary from Margaret Mitchell & Emily Bender
venue: Inside Higher Ed (Jun 2023); Rolling Stone (2023); simonwillison.net (18 Apr 2024); weeklygeek.net (Jul 2023)
type: article
tags: [llm-writing-indicators, false-positives, harm, folklore, non-native, neurodivergent, delve]
quality: 4
confidence: high
ingested: 2026-07-13
summary: The human cost and the "tells are folklore" critique. Turnitin admitted a ~4% sentence-level false-positive rate (document-level higher, undisclosed) vs its marketed <1%. Named cases: Louise Stivers and William Quarterman (UC Davis) falsely accused. The US Constitution is rated "likely written entirely by AI" by GPTZero/ZeroGPT because formal, oft-quoted, low-perplexity prose reads as machine. "Delve" traces to human regional English, not an AI invention.
---

# False-positive harm + the folklore critique

**Quality: 4/5.** Named journalism + vendor admissions + expert commentary.

## Turnitin's real error rate

- Marketed **<1%** false-positive rate. Chief product officer **Annie Chechitelli** admitted a **~4% sentence-level** rate, and that the **document-level rate is higher than 1%** — but declined to disclose the number.
- **54%** of false-positive sentences sit directly adjacent to AI-flagged sentences (another 26% within two) → mixed human/AI documents are especially error-prone.
- Washington Post testing cited up to a **~50%** false-positive rate in adversarial/mixed conditions; independent reports cite **15–20%** for some student populations.

## Named harm cases

- **Louise Stivers** (UC Davis, political science): a self-written Supreme Court brief flagged by Turnitin → referred to Judicial Affairs; two-week investigation, grade decline, must self-report the allegation to law schools and the State Bar — no apology after being cleared.
- **William Quarterman** (UC Davis, history): flagged by **GPTZero**, faced misconduct proceedings.
- **Vanderbilt and others disabled Turnitin's detector**, citing unreliability and disparate impact on non-native and neurodivergent students. 2025 reporting: students record hour-long screen captures of their own work to preempt false accusations.

## The "tells are folklore" critique

- **Famous, formal human texts get flagged.** The **US Constitution** (1787) is rated by GPTZero as "likely to be written entirely by AI" and by ZeroGPT as "AI/GPT Generated." Same for Bible passages and classic/legal text. Reason: formal, oft-quoted, predictable prose is **low-perplexity** — exactly what detectors read as "machine."
- **Margaret Mitchell:** perplexity is "how surprising is this language based on what I've seen?" — "humans can write with low perplexity, too, especially when imitating a formal style used in law or certain types of academic writing." Implicates **neurodivergent, formulaic, and formal** human writers, not just ESL.
- **"Delve" is not an AI invention** — markedly more common in African/Nigerian English and formal academic writing predating ChatGPT. The Hern/Willison hypothesis: RLHF annotators largely based in Africa encoded *human* regional English, so "delve = AI" is really "delve = the English of the humans who trained it" — biasing against African writers. (Note: Juzek & Ward's corpus test does *not* support the ICE-based version of this claim; the labor reporting is real, the linguistic link contested.)
- **Base-rate / confirmation-bias problem:** reviewers now *expect* these features, notice them in AI text, discount them in human text; heavy editing removes tells; humans increasingly imitate AI style — collapsing any single feature's discriminative value.

## Why it matters for a reviewer

The false-positive cost is a real person's transcript/reputation. The specific stylistic tells (em-dash, "delve," lists, tidy structure, low surprise) are features of good, formal, non-Western-standard, or neurodivergent human writing — and of edited prose. Relying on them bakes in confirmation bias and cultural/linguistic discrimination.
