---
title: "llama.cpp grammars (GBNF) - structured output via constrained sampling"
source: "https://github.com/ggerganov/llama.cpp/blob/master/grammars/README.md"
type: repo
date_fetched: 2026-05-24
date_published: "unknown"
tags: [llm, local-llm, structured-output, llama-cpp, json-schema]
quality: 5
credibility: high
path: llm-integration-patterns
summary: "llama.cpp's GBNF grammar system constrains local-LLM output at the token level. Supports JSON-schema-to-grammar conversion, but schema is NOT injected into the prompt - models must be told about the structure. Key tool for guaranteed-valid PF2e statblocks from local models."
---

# llama.cpp Grammars (GBNF) for Structured PF2e Output

## What It Does
GBNF (GGML BNF) is a grammar format that constrains the sampler at every generation step. The model can only emit tokens that extend a valid prefix per the grammar. Result: 100% syntactically valid output, no JSON parse errors.

Direct quote from docs: you can "force the model to generate valid JSON, or speak only in emojis."

## JSON Schema -> Grammar
Three ways to use schema:
1. **llama-server**: pass `json_schema` field in request body
2. **llama-cli**: `--json` / `-j` flag with schema file
3. **Pre-convert**: `json_schema_to_grammar.py` script ahead of time

**CRITICAL caveat**: "The JSON schema is only used to constrain the model output and is not injected into the prompt." The model only sees the schema's existence at sampling time, not in its context. You must include a textual description in the prompt or output may be schema-valid but semantically wrong (e.g., empty strings, `null` everywhere).

## Performance Gotcha
Repeated optional patterns (`x? x? x?`) cause "extremely slow sampling." Use `x{0,N}` quantifier syntax instead.

## Example - PF2e Statblock Grammar (sketch)
```gbnf
root        ::= "{" ws "\"name\":" string "," ws
                 "\"level\":" integer "," ws
                 "\"traits\":" string-array "," ws
                 "\"ac\":" integer "," ws
                 "\"hp\":" integer "," ws
                 "\"actions\":" action-array "}"
action-array ::= "[" ws action ("," ws action)* ws "]"
action       ::= "{" ws "\"name\":" string "," ws "\"actions\":" action-cost "}"
action-cost  ::= "1" | "2" | "3" | "\"reaction\"" | "\"free\""
```

## Implications for PF2e Tool
- **Local statblock generation**: pair Qwen3-14B/32B + GBNF grammar derived from a Pydantic PF2e schema
- **Reliability**: even small (4B-8B) local models produce parseable JSON; semantic accuracy still depends on model size + RAG
- **Trade-off**: grammar enforcement hurts very small models more (they "fight" the grammar) - 8B+ recommended
- **Tool-calling**: not natively documented in this README, but llama-server now supports OpenAI-compatible `tools` API which uses grammars under the hood
