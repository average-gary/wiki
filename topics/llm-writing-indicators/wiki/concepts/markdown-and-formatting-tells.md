---
title: Markdown & formatting tells — bold-stacked lists and leaked markup
type: concept
created: 2026-07-13
updated: 2026-07-13
status: active
confidence: high
tags: [llm-writing-indicators, formatting, markdown, leakage]
sources:
  - raw/articles/2026-07-13-wikipedia-signs-of-ai-writing.md
---

# Markdown & formatting tells

How a piece is *formatted* is often a stronger tell than what it says. LLM chat output has a house style, and when it is pasted into a document, the formatting fingerprint comes with it.

## The bold-stacked list (the signature)

The single most recognizable formatting tell: a vertical list of **bold mini-heading + colon + tidy one-line explanation**, repeated:

> **Scalability**: The system handles growth efficiently.
> **Reliability**: Uptime is consistently high.
> **Security**: Data is protected end-to-end.

Combined with excessive boldface scattered through paragraphs (every "key term" bolded), this is the "key takeaways" chat aesthetic transplanted into prose.

## Markdown leakage (very high-confidence)

Chat markdown surviving into a context that doesn't render it:
- Literal `**bold**` or `*italic*` asterisks in plain-text or wikitext.
- `#`-prefixed lines or `-`/`*` bullets pasted where they don't render.
- **Emoji as bullets or heading prefixes** (✅, 🚀, 📌).

## Leaked tool/citation tokens (near-deterministic)

The highest-confidence tells of all — internal tokens that should never reach a reader:
- `contentReference`, `oaicite`, `oai_citation`, `:contentReference[oaicite:0]{index=0}`
- `turn0search0`, `grok_card`, `attached_file`, stray `:::` fenced blocks, a trailing `+1`.

When you see one of these, provenance is essentially settled — a human did not type `oaicite`.

## Heading artifacts

- **Title Case On Every Heading**; **skipped heading levels** (jumping to level 3).
- Thematic-break horizontal rules inserted before headings.

## Why it matters

Formatting tells are cheap to scan and, at the leaked-token end, near-deterministic. They also survive vocabulary drift — a model that stopped saying "delve" still emits bold-stacked lists. The catch: legitimate markdown documents *use* bold and bullets, so context is everything — a bulleted list is only a tell when it appears where the medium or author wouldn't normally produce one, or when the bold-stack pattern is mechanical.

## See also

- [[invisible-unicode-artifacts|Invisible Unicode artifacts]]
- [[structural-formulas|Structural formulas]]
- [[../../raw/articles/2026-07-13-wikipedia-signs-of-ai-writing|Wikipedia AISIGNS catalog]] (source)
