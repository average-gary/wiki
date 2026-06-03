---
title: "bible-ai-assistant — Qwen3.5 + hybrid RAG + constitutional guardrails"
url: https://github.com/t-timms/bible-ai-assistant
retrieved: 2026-06-02
type: repo
---

The most architecturally complete OSS Bible-RAG repo encountered. Stack: fine-tuned Qwen3.5-4B (bf16 LoRA SFT on ~1,800 examples, then ORPO alignment on 500 preference pairs targeting hallucination, repetition, off-topic). Hybrid retrieval = ChromaDB dense (nomic-embed-text-v1.5) + BM25Okapi sparse, fused via Reciprocal Rank Fusion, reranked by bge-reranker-v2-m3 cross-encoder, with topical/verse pinning. Constitutional-AI-style guardrails grounded in biblical principles, with counseling-pattern detection and safety referrals. Fully local: Docker Compose runs Ollama (Q4_K_M GGUF), FastAPI RAG server (8081), Gradio 6 UI (7860), optional Faster-Whisper STT + Kokoro TTS. 183 unit tests, CI/CD, deployment guides for PC, Jetson Nano, cloud. Licenses: code MIT, weights Qwen, Scripture public domain (WEB, KJV). This is a strong reference design for a christ-is-lord local-LLM plugin.
