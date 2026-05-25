---
title: "Prompt caching - Claude API documentation"
source: "https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching"
type: article
date_fetched: 2026-05-24
date_published: "2026-02-05"
tags: [llm, caching, anthropic, long-context, cost-optimization]
quality: 5
credibility: high
path: llm-integration-patterns
summary: "Authoritative Anthropic documentation on prompt caching mechanics, pricing multipliers, TTLs (5-min and 1-hour), minimum thresholds, and explicit vs automatic cache breakpoints. Critical reference for caching long PF2e world canon and rules text."
---

# Claude Prompt Caching - Key Mechanics for PF2e Worldbuilding

## TTLs and Pricing
- **5-min cache (default)**: 1.25x base input price for writes
- **1-hour cache (extended)**: 2x base input price, set via `cache_control: {type: "ephemeral", ttl: "1h"}`
- **Cache reads**: 0.1x base input price (10x discount)

| Model              | Base Input | 5m Write   | 1h Write | Read     |
|--------------------|-----------|-----------|----------|----------|
| Opus 4.7/4.6/4.5   | $5/M      | $6.25/M   | $10/M    | $0.50/M  |
| Sonnet 4.6/4.5     | $3/M      | $3.75/M   | $6/M     | $0.30/M  |
| Haiku 4.5          | $1/M      | $1.25/M   | $2/M     | $0.10/M  |

## Minimum Cacheable Tokens
- Opus 4.7/4.6/4.5, Haiku 4.5: **4,096 tokens**
- Sonnet 4.6/4.5, Opus 4.1: **1,024 tokens**
- Below threshold: silently uncached, no error.

## Cache Hierarchy
Order: `tools` -> `system` -> `messages`. Up to 4 explicit breakpoints per request. Lookback window of 20 blocks for hit detection.

## Patterns Relevant to PF2e Tool

### Static world bible in system prompt (5m or 1h TTL)
```json
{
  "system": [
    {"type": "text", "text": "<PF2e core rules digest>",
     "cache_control": {"type": "ephemeral", "ttl": "1h"}},
    {"type": "text", "text": "<World canon: Kingdom of X>",
     "cache_control": {"type": "ephemeral", "ttl": "1h"}}
  ]
}
```

### Pre-warming the cache
`max_tokens: 0` request loads system prompt before user interaction; eliminates first-hit latency.

### Tool definition caching
Mark `cache_control` on **last** tool in tools array - caches all tools up to that point.

## 2026 Updates
- **Feb 5, 2026**: Workspace-level cache isolation (Claude API + AWS + Microsoft Foundry beta). Bedrock/Vertex still org-level.

## Cache Invalidators
Tool def changes invalidate everything. System prompt changes invalidate system + messages. Image add/remove preserves system cache. Extended thinking parameter changes invalidate system cache.

## Practical Numbers for a GM Tool
For a 50K-token campaign canon + 10K rules digest = 60K tokens:
- First call (Sonnet 4.6): ~$0.225 cache write
- Subsequent calls in same session: ~$0.018 cache read (12x cheaper than no cache)
- Over a 4-hour session with 1h TTL refresh: massive cost reduction; this is the mechanism that makes "always include the world bible" viable.
