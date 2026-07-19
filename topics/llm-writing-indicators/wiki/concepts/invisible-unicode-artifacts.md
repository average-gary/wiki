---
title: Invisible Unicode artifacts — the near-deterministic tell
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, unicode, typography, deterministic]
sources:
  - raw/articles/2026-07-13-em-dash-mechanism-unicode-artifacts.md
---

# Invisible Unicode artifacts

Unlike em dashes, invisible Unicode characters are a *near-deterministic* tell: humans essentially never type them by hand, so their presence in a document is high-confidence evidence of machine generation (or at least machine processing).

## The characters

From [[../../raw/articles/2026-07-13-em-dash-mechanism-unicode-artifacts|Jarnach's analysis]], characters that leak into ChatGPT output:

| Code point | Name |
|---|---|
| U+00A0 | Non-breaking space (NBSP) |
| U+202F | Narrow no-break space (common around numbers/units) |
| U+200B | Zero-width space (ZWSP) |
| U+200C / U+200D | Zero-width non-joiner / joiner |
| U+FEFF | Byte-order mark (BOM) |

## Not a watermark

These are assessed as **artifacts, not deliberate watermarks** — inherited from training data, tokenization, and number-formatting conventions (e.g., a narrow no-break space between a number and its unit). No provider is known to be intentionally marking text this way; contrast with genuine [[../topics/detection-tools-and-limits|watermarking]], which is a separate, opt-in provenance technique.

## How to detect

Trivial: run the text through a script that flags each non-standard character by line and column and renders it visibly (e.g. `[NBSP]`, `[ZWSP]`). A single U+200B or U+FEFF in body text is a strong signal; a human keyboard doesn't produce them.

## Why it matters

This is one of the few tells with a near-zero false-positive rate *when present*. But absence proves nothing — copy-paste through a plain-text editor, or any "humanizer" pass, strips them. So it is a high-precision, low-recall signal: trust a hit, don't read anything into a miss.

## See also

- [[em-dash-and-punctuation|Em-dash & punctuation tells]] — the *weak* typographic tell, for contrast.
- [[markdown-and-formatting-tells|Markdown & formatting tells]] — leaked `oaicite`/`turn0search0` tokens are the same "should never reach a reader" class.
