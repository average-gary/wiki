---
title: "Structured data extraction using LLM schemas"
source: "https://simonwillison.net/2025/Feb/28/llm-schemas/"
type: article
date_fetched: 2026-05-24
date_published: "2025-02-28"
tags: [llm, structured-output, json-schema, pydantic, extraction]
quality: 4
credibility: high
path: llm-integration-patterns
summary: "Simon Willison's writeup of LLM 0.23's schema feature: JSON-schema-driven structured output across OpenAI, Anthropic, Gemini, Mistral, and local Ollama. Concise schema syntax, Pydantic-native API, SQLite logging - directly applicable to PF2e statblock/encounter generation pipelines."
---

# LLM Schemas - Cross-Provider Structured Output

## Provider Coverage
"OpenAI, Anthropic, Gemini and Mistral all offer variants of 'structured output' as additional options." Local models reach via `llm-ollama`. Behind the scenes some providers compile schema -> token-level constraints (Jsonformer-style), others rely on model capability + retry.

## Concise Schema Syntax
```bash
llm --schema 'name,age int,short_bio' 'invent a cool dog'
```
Newline-delimited or comma-delimited shorthand for fast prototyping. Translates to:
```bash
llm --schema 'name
level int
ac int
hp int
traits' 'invent a PF2e level 5 monster'
```

## Pydantic Integration
```python
from pydantic import BaseModel
class PF2eMonster(BaseModel):
    name: str
    level: int
    ac: int
    hp: int
    traits: list[str]

response = model.prompt("Generate a fey trickster level 4", schema=PF2eMonster)
parsed = response.json()
```

## SQLite Logging
LLM stores all requests/responses in SQLite, queryable per schema. For PF2e tool: every generated statblock can be logged, indexed, dedup'd, exported to JSONL for fine-tune datasets later.

## Provider Reliability
- Native structured output (OpenAI, Anthropic) - very high success rate
- Local via grammars (llama.cpp) - 100% syntactic, semantic depends on model
- Fallback: validate + retry loop with error feedback

## Implications for PF2e Tool
1. **Define Pydantic schemas once** for: Monster, Spell, Item, NPC, Encounter, Hazard, Location
2. **Reuse across providers** - same code path for cloud Sonnet vs local Qwen3
3. **Log every generation** to SQLite - corpus grows, becomes searchable, becomes future fine-tune data
4. **Two-stage generation**: stage 1 generates structured fields, stage 2 generates flavor prose unconstrained

## Relevance
Establishes that schema-driven generation is a solved cross-provider abstraction in 2025+; we can pick provider per-call rather than rewriting pipelines.
