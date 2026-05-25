---
title: "Ollama 2024-2026 feature roundup: structured outputs, tools, embeddings, desktop app"
source: "https://ollama.com/blog"
type: article
date_fetched: 2026-05-24
date_published: "2025-10-15"
tags: [llm, local-llm, ollama, structured-output, tool-calling, embeddings]
quality: 4
credibility: high
path: llm-integration-patterns
summary: "Ollama's 2024-2026 trajectory: structured outputs (Dec 2024), tool calling (July 2024), streaming-with-tools (May 2025), Qwen3-VL and GLM-4.6 (Oct 2025), native macOS/Windows desktop app (July 2025), cloud models (Sept 2025). The path-of-least-resistance local LLM runtime for desktop integration."
---

# Ollama Feature Roundup for PF2e Tool Integration

## Capabilities Timeline (Newest First)
- **Oct 2025**: GLM-4.6, Qwen3-Coder-480B (cloud), Qwen3-VL multimodal
- **Sept 2025**: Cloud Models - run datacenter-class models via Ollama API
- **July 2025**: Native macOS + Windows desktop application
- **May 2025**: Streaming + tool calling simultaneously (was previously either/or)
- **Dec 2024**: Structured Outputs - constrain to JSON schema
- **July 2024**: Tool support (Llama 3.1 era)
- **Apr 2024**: Embedding models (e.g., nomic-embed-text)

## What Each Feature Means for the PF2e Tool

### Structured Outputs (Dec 2024)
Same JSON-schema constraint as llama.cpp grammars (Ollama wraps llama.cpp). Means our app can request a PF2e statblock JSON and get a parseable response from any tool-capable Ollama model.

### Streaming + Tools (May 2025)
Lets the GM see the LLM's response stream in while it also calls tools (e.g., `lookup_spell("fireball")`, `roll_encounter_budget(party_level=5, threat="severe")`). Critical UX win - removes the awkward "thinking..." pause.

### Embedding Models
`ollama pull nomic-embed-text` gives you a 768-dim local embedding model with 8K context window. Pair with sqlite-vec for fully-offline RAG.

### Desktop App (July 2025)
Brings Ollama out of "CLI tool for hackers" into shipping-ready software. The PF2e tool can either (a) require user installs Ollama separately and connects via localhost:11434, or (b) bundle Ollama as a sidecar (license permitting).

### Cloud Models (Sept 2025)
Same API surface for local + cloud means "use Qwen3-32B locally, fall back to Ollama-cloud Qwen3-235B for hard rules questions" is trivially codeable.

## Recommended Local Stack for PF2e Tool (mid-2026)
- Runtime: Ollama 0.x (or llama.cpp directly for grammar control)
- Reasoning model: `qwen3:14b` (32GB Macs) or `qwen3:32b` (64GB)
- Embeddings: `nomic-embed-text` or `bge-m3`
- Vector store: sqlite-vec (in-process)
- Structured output: Ollama `format: <json-schema>` field
