---
title: Em-dash & punctuation tells
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: medium
tags: [llm-writing-indicators, punctuation, em-dash, typography]
sources:
  - raw/articles/2026-07-13-em-dash-discourse-rollingstone-techcrunch.md
  - raw/articles/2026-07-13-em-dash-mechanism-unicode-artifacts.md
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
---

# Em-dash & punctuation tells

The em dash (—) became *the* popular "ChatGPT tell" in 2025. It is real but weak, contested, and time-sensitive — the textbook example of a signal that produces false positives.

## The pattern

- **Em-dash overuse.** LLM output uses em dashes more often than nonprofessional human writing, and [[../../raw/articles/2026-07-13-wikipedia-signs-of-ai-writing|Wikipedia]] notes they appear "in a formulaic, pat way," frequently space-surrounded ( — ) against typographic norms.
- **Curly / smart quotes** (" " ' ') instead of straight quotes — but explicitly flagged as *weak* evidence, since Word and macOS auto-convert them for humans too.

## Why it happens

Three proposed causes ([[../../raw/articles/2026-07-13-em-dash-mechanism-unicode-artifacts|em-dash mechanism]]):
1. **Training-data base rate** (strongest) — em dashes are dense in the professionally-edited prose LLMs train on (Dickens, Dickinson, journalism, academia); next-token prediction reproduces that rate.
2. **RLHF polish reward** — raters like the rhythm em dashes create, amplifying the base rate.
3. **Tokenization** (speculative) — the em dash's byte sequence may merge into one efficient BPE token.

The model learns the *statistical association* between em dashes and good writing, with no grammatical understanding — hence overuse in the wrong places.

## The timeline matters

- **~April 2025:** "ChatGPT hyphen" meme goes viral ([[../../raw/articles/2026-07-13-em-dash-discourse-rollingstone-techcrunch|Rolling Stone]]).
- **Through 2025:** heavy em-dash use was genuine model default — OpenAI couldn't suppress it even when users asked.
- **~Nov 13–15, 2025:** OpenAI ships a fix; Sam Altman: custom instructions can now suppress em dashes ("Small-but-happy win"). But it works only via personalization, not by default.

After the fix, **both presence and absence prove little**: em dashes are suppressible on demand, and they were always a centuries-old human habit (Bryan Garner called the em dash "perhaps the most underused punctuation mark in American writing").

## Why it matters (and the warning)

Treat em-dash density as a *weak, contested, time-stamped* signal — never as proof. It flags skilled human writers and editors who legitimately love the mark. It is the canonical example for [[../topics/false-positives-and-fairness|false positives & fairness]]. Contrast with the near-deterministic [[invisible-unicode-artifacts|invisible Unicode]] tells, which humans essentially never produce.

## See also

- [[invisible-unicode-artifacts|Invisible Unicode artifacts]] — the reliable typographic tell.
- [[markdown-and-formatting-tells|Markdown & formatting tells]]
- [[model-and-version-drift|Model & version drift]]
